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
project ( external_mozjs NONE )
set ( ${PROJECT_NAME}_STATICLIB_VERSION 52.8-1 )
set ( ${PROJECT_NAME}_DESCRIPTION "MozJS library build for Staticlibs" )
set ( ${PROJECT_NAME}_URL https://github.com/staticlibs/external_mozjs )

# standalone build
if ( NOT DEFINED STATICLIB_TOOLCHAIN )
    if ( NOT DEFINED ${PROJECT_NAME}_TOOLCHAIN )
        if ( WIN32 )
            if ( CMAKE_SIZEOF_VOID_P EQUAL 8 )
                set ( ${PROJECT_NAME}_TOOLCHAIN "windows_amd64_msvc" )
            else ( )
                set ( ${PROJECT_NAME}_TOOLCHAIN "windows_i386_msvc" )
            endif ( )
        elseif ( APPLE )
            set ( ${PROJECT_NAME}_TOOLCHAIN "macosx_amd64_clang" )
        elseif ( UNIX )
            set ( ${PROJECT_NAME}_TOOLCHAIN "linux_amd64_gcc" )
        else ( )
            message ( FATAL_ERROR "Cannot determine toolchain to use, please specify [${PROJECT_NAME}_TOOLCHAIN]" )
        endif ( )
    endif ( )
else ( )
    set ( ${PROJECT_NAME}_TOOLCHAIN ${STATICLIB_TOOLCHAIN} )
endif ( )

if ( NOT ${PROJECT_NAME}_TOOLCHAIN MATCHES "linux_amd64_gcc" )
    message ( FATAL_ERROR "Unsupported toolchain: [${${PROJECT_NAME}_TOOLCHAIN}]" )
endif ( )

# standalone build
if ( NOT DEFINED CMAKE_LIBRARY_OUTPUT_DIRECTORY )
    set ( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR} )
endif ( )

# copy prebuilt lib
set ( ${PROJECT_NAME}_PREBUILT_DIR ${CMAKE_CURRENT_LIST_DIR}/prebuilt/${${PROJECT_NAME}_TOOLCHAIN} )
configure_file (
        ${${PROJECT_NAME}_PREBUILT_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}mozjs-52${CMAKE_SHARED_LIBRARY_SUFFIX}
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${CMAKE_SHARED_LIBRARY_PREFIX}mozjs-52${CMAKE_SHARED_LIBRARY_SUFFIX}
        COPYONLY )

# prebuilt library
add_library( mozjs SHARED IMPORTED GLOBAL )
set_target_properties( mozjs PROPERTIES IMPORTED_LOCATION
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${CMAKE_SHARED_LIBRARY_PREFIX}mozjs-52${CMAKE_SHARED_LIBRARY_SUFFIX} )

# anchor target
add_custom_target ( ${PROJECT_NAME} DEPENDS mozjs )

# pkg-config
set ( ${PROJECT_NAME}_MODULE mozjs )
set ( ${PROJECT_NAME}_PC_CFLAGS "-I${CMAKE_CURRENT_LIST_DIR}/include/mozjs-52" )
set ( ${PROJECT_NAME}_PC_LIBS "-L${CMAKE_LIBRARY_OUTPUT_DIRECTORY} -lmozjs" )
configure_file ( ${CMAKE_CURRENT_LIST_DIR}/resources/pkg-config.in 
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/pkgconfig/mozjs.pc )
