# Copyright 2018, alex at staticlibs.net
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cmake_minimum_required ( VERSION 2.8.12 )

# toolchain setup
set ( STATICLIB_TOOLCHAIN linux_amd64_gcc CACHE STRING "toolchain triplet" )
if ( NOT DEFINED STATICLIB_CMAKE )
    set ( STATICLIB_CMAKE ${CMAKE_CURRENT_LIST_DIR}/../../cmake CACHE INTERNAL "" )
endif ( )
set ( CMAKE_TOOLCHAIN_FILE ${STATICLIB_CMAKE}/toolchains/${STATICLIB_TOOLCHAIN}.cmake CACHE INTERNAL "" )

project ( external_mozjs_test CXX )
include ( ${STATICLIB_CMAKE}/staticlibs_common.cmake )

# dependencies
if ( NOT DEFINED STATICLIB_DEPS )
    set ( STATICLIB_DEPS ${CMAKE_CURRENT_LIST_DIR}/../../ CACHE INTERNAL "" )
endif ( )
staticlib_add_subdirectory ( ${STATICLIB_DEPS}/external_icu )
staticlib_add_subdirectory ( ${CMAKE_CURRENT_LIST_DIR}/../../external_mozjs )
set ( ${PROJECT_NAME}_DEPS mozjs )
staticlib_pkg_check_modules ( ${PROJECT_NAME}_DEPS_PC REQUIRED ${PROJECT_NAME}_DEPS )

# test executable
add_executable ( mozjs_test ${CMAKE_CURRENT_LIST_DIR}/mozjs_test.cpp )
target_include_directories ( mozjs_test BEFORE PRIVATE
        ${${PROJECT_NAME}_DEPS_PC_INCLUDE_DIRS} )
target_link_libraries ( mozjs_test PRIVATE
        mozjs )

# register test
enable_testing ( )
add_test ( mozjs_test ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/mozjs_test )
