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

# if(NOT FVPM_FORCE_BUILD_JSONCPP)
#   find_package(jsoncpp)
#   if (NOT jsoncpp_FOUND)
#     set(FVPM_FORCE_BUILD_JSONCPP ON)
#   endif()
# endif()

# if (FVPM_FORCE_BUILD_JSONCPP)
# endif()
add_subdirectory(jsoncpp EXCLUDE_FROM_ALL)

if(NOT FVPM_FORCE_BUILD_CURL)
  find_package(CURL)
  if (NOT CURL_FOUND)
    set(FVPM_FORCE_BUILD_CURL ON)
  endif()
endif()

if(FVPM_FORCE_BUILD_CURL)
  message(STATUS "Building fvpm's own CURL build")
  set(BUILD_TESTING OFF)
  set(BUILD_CURL_EXE OFF)
  set(BUILD_LIBCURL_DOCS OFF)
  set(ENABLE_CURL_MANUAL OFF)
  set(HTTP_ONLY ON)

  # select SSL library
  if (WIN32)
    set(CURL_USE_SCHANNEL ON)
  else()
    set(CURL_USE_OPENSSL ON)
  endif()

  add_subdirectory(curl EXCLUDE_FROM_ALL)

  unset(BUILD_TESTING)
  unset(BUILD_CURL_EXE)
  unset(BUILD_LIBCURL_DOCS)
  unset(ENABLE_CURL_MANUAL)
  unset(HTTP_ONLY)
  unset(CURL_USE_SCHANNEL)
  unset(CURL_USE_SSL)
endif()

if (FVPM_BUILD_TEST)
  # For Windows: Prevent overriding the parent project's compiler/linker settings
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  add_subdirectory(gtest EXCLUDE_FROM_ALL)
endif()

add_subdirectory(semver EXCLUDE_FROM_ALL)
