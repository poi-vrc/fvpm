# MIT License
#
# Copyright (c) 2024 poi-vrc
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

include_guard(GLOBAL)
include(CMakePackageConfigHelpers)

define_property(TARGET PROPERTY MVPM_TARGET_GROUP INHERITED)

function (mvpm_build_add_subdirectory dir)
    add_subdirectory(${dir})
endfunction()

function(mvpm_build_add_interface name)
    add_library(${name} INTERFACE)
    target_include_directories(${name} INTERFACE ${ARGN})
endfunction()

function(mvpm_build_add_object_library name)
    cmake_parse_arguments(ARG "" "" "INCLUDES;DEPENDS" ${ARGN})

    set(target_name mvpm-${name}-objects)
    add_library(${target_name} OBJECT ${ARG_UNPARSED_ARGUMENTS})
    set_property(TARGET ${target_name} PROPERTY POSITION_INDEPENDENT_CODE ON)
    set_property(GLOBAL APPEND PROPERTY MVPM_OBJECT_LIBRARIES ${target_name})

    if (ARG_INCLUDES)
        target_include_directories(${target_name} ${ARG_INCLUDES})
    endif()

    if (ARG_DEPENDS)
        target_link_libraries(${target_name} ${ARG_DEPENDS})
    endif()
endfunction()

function(mvpm_build_lib_dir name)
    file(GLOB srcs *.cpp)
    mvpm_build_add_object_library(mvpm-${name} ${srcs} DEPENDS mvpm-interface)
endfunction()

function(_mvpm_build_get_target_obj_libs srcs_output objs_output target_name)
    get_property(project_obj_libs GLOBAL PROPERTY MVPM_OBJECT_LIBRARIES)
    set(srcs "")
    set(objs "")

    foreach(project_obj_lib IN LISTS project_obj_libs)
        get_target_property(target_group ${project_obj_lib} MVPM_TARGET_GROUP)
        
        if ("${target_group}" STREQUAL "${target_name}")
            list(APPEND objs ${project_obj_lib})
            list(APPEND srcs $<TARGET_OBJECTS:${project_obj_lib}>)
        endif()
    endforeach()

    set(${srcs_output} ${srcs} PARENT_SCOPE)
    set(${objs_output} ${objs} PARENT_SCOPE)
endfunction()

function(mvpm_build_add_library target_name)
    cmake_parse_arguments(ARG "" "" "DEPENDS" ${ARGN})

    _mvpm_build_get_target_obj_libs(srcs objs ${target_name})
    if (NOT srcs)
        message(FATAL_ERROR "No obj libs matched with target ${target_name}")
    endif()

    add_library(${target_name} SHARED ${srcs})
    if (ARG_DEPENDS)
        target_link_libraries(${target_name} PRIVATE ${ARG_DEPENDS})
    endif()
endfunction()

function(mvpm_build_add_executable target_name)
    cmake_parse_arguments(ARG "" "" "DEPENDS" ${ARGN})

    _mvpm_build_get_target_obj_libs(objs srcs ${target_name})
    if (NOT srcs)
        message(FATAL_ERROR "No obj libs matched with target ${target_name}")
    endif()

    add_executable(${target_name} ${srcs})
    if (ARG_DEPENDS)
        target_link_libraries(${target_name} PRIVATE ${ARG_DEPENDS})
    endif()
endfunction()

function(mvpm_build_get_export_name output)
    set(${output} ${PROJECT_NAME}-export PARENT_SCOPE)
endfunction()

function(mvpm_build_install_targets)
    mvpm_build_get_export_name(export_name)
    install(
        TARGETS ${ARGN}
        EXPORT ${export_name}
        LIBRARY DESTINATION lib/${PROJECT_NAME}
        INCLUDES DESTINATION include/${PROJECT_NAME}
    )
endfunction()

function (mvpm_build_export)
    set(install_dir lib/${PROJECT_NAME}/cmake)
    set(config_cmake_path ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake)

    mvpm_build_get_export_name(EXPORT_CMAKE_NAME)
    install(
        EXPORT ${EXPORT_CMAKE_NAME}
        NAMESPACE ${PROJECT_NAME}::
        DESTINATION ${install_dir}
    )

    configure_package_config_file(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/mvpm_config.cmake.in
        ${config_cmake_path}
        PATH_VARS EXPORT_CMAKE_NAME
        INSTALL_DESTINATION ${install_dir}
        NO_CHECK_REQUIRED_COMPONENTS_MACRO
        NO_SET_AND_CHECK_MACRO
    )
    install(FILES ${_config_path} DESTINATION ${install_dir})

    set(version_cmake_path ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake)
    write_basic_package_version_file(
        ${version_cmake_path}
        COMPATIBILITY SameMajorVersion
    )
    install(FILES ${_config_version_path} DESTINATION ${install_dir})
endfunction()

function (mvpm_build_publish)
    mvpm_build_add_interface(minivpm-includes code/include)
    mvpm_build_add_library(minivpm)
    mvpm_build_install_targets(minivpm)
    mvpm_build_export()
endfunction()
