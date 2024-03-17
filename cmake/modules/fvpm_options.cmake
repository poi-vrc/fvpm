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

function(_fvpm_add_compile_options)
    set_property(GLOBAL APPEND PROPERTY FVPM_COMPILE_OPTIONS ${ARGN})
endfunction()
function(_fvpm_add_link_options)
    set_property(GLOBAL APPEND PROPERTY FVPM_LINK_OPTIONS ${ARGN})
endfunction()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# options
option(FVPM_BUILD_TEST "Enable build tests" OFF)
option(FVPM_BUILD_TSAN "Enable build tsan" OFF)
option(FVPM_BUILD_ASAN "Enable build asan" OFF)
option(FVPM_BUILD_UBSAN "Enable build ubsan" OFF)
option(FVPM_FORCE_BUILD_CURL "Enable force-build CURL even if it exists in system" OFF)

# enable ctest
if (FVPM_BUILD_TEST)
    enable_testing()
endif()

# detect compiler
if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    _fvpm_add_compile_options(-std=c++20 -Wall -Wextra -Werror)

    if (FVPM_BUILD_TSAN)
        message(STATUS "Building with tsan")
        _fvpm_add_compile_options(-fsanitize=thread)
        _fvpm_add_link_options(-fsanitize=thread)
    endif()

    if (FVPM_BUILD_ASAN)
        message(STATUS "Building with asan")
        _fvpm_add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
        _fvpm_add_link_options(-fsanitize=address)
    endif()

    if (FVPM_BUILD_UBSAN)
        message(STATUS "Building with ubsan")
        _fvpm_add_compile_options(-fsanitize=undefined)
        _fvpm_add_link_options(-fsanitize=undefined)
    endif()
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # warning C4668: '__STDC_WANT_SECURE_LIB__' is not defined as a preprocessor macro, replacing with '0' for '#if/#elif'
    # warning C5039: 'TpSetCallbackCleanupGroup': pointer or reference to potentially throwing function passed to 'extern "C"' function under -EHc.on.
    # warning C4820: '4' bytes padding added after data member '_SOCKET_ADDRESS::iSockaddrLength'
    # warning C5045: Compiler will insert Spectre mitigation for memory load if /Qspectre switch specified
    _fvpm_add_compile_options(/std:c++20 /Wall /wd4668 /wd5039 /wd4820 /wd5045 /WX /permissive-)
else ()
    message(FATAL_ERROR "Unsupported compiler")
endif()
