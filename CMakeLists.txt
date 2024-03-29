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

cmake_minimum_required(VERSION 3.28)
project(fvpm LANGUAGES C CXX VERSION 0.1.0)
include(cmake/modules/fvpm_setup.cmake)

fvpm_build_add_subdirectory(external)

fvpm_build_add_subdirectory(code)
if (FVPM_BUILD_APPS)
    fvpm_build_add_subdirectory(apps)
endif()
if (FVPM_BUILD_BINDINGS)
    fvpm_build_add_subdirectory(bindings)
endif()
if (FVPM_BUILD_TEST)
    fvpm_build_add_subdirectory(test)
endif()

fvpm_build_publish()
