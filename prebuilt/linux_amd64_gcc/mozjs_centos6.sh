#!/bin/bash
#
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

set -e
set -x

# variables
export MOZJS_LIB_VERSION=52
export MOZJS_TARBALL_VERSION=${MOZJS_LIB_VERSION}.8.0esr
export D="sudo docker exec builder"

# docker
sudo docker pull centos:6
sudo docker run \
    -id \
    --name builder \
    -w /opt \
    -v `pwd`:/host \
    -e PERL5LIB=/opt/rh/devtoolset-7/root//usr/lib64/perl5/vendor_perl:/opt/rh/devtoolset-7/root/usr/lib/perl5:/opt/rh/devtoolset-7/root//usr/share/perl5/vendor_perl \
    -e LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root/usr/lib64:/opt/rh/devtoolset-7/root/usr/lib:/opt/rh/python27/root/usr/lib64 \
    -e PYTHONPATH=/opt/rh/devtoolset-7/root/usr/lib64/python2.6/site-packages:/opt/rh/devtoolset-7/root/usr/lib/python2.6/site-packages \
    -e PKG_CONFIG_PATH=/opt/rh/python27/root/usr/lib64/pkgconfig:/opt/icubuild/pkgconfig \
    -e PATH=/opt/rh/devtoolset-7/root/usr/bin:/opt/rh/python27/root/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    -e SHELL=/bin/bash \
    -e LDFLAGS=-static-libstdc++ \
    centos:6 \
    bash

# dependencies
$D yum install -y \
    centos-release-scl-rh
$D yum install -y \
    devtoolset-7 \
    python27 \
    autoconf213 \
    git \
    svn \
    patch \
    zip \
    xz

# cmake
$D git clone https://github.com/Kitware/CMake.git
$D bash -c "cd CMake && git checkout v2.8.12.2"
$D bash -c "cd CMake && ./configure --prefix=/usr/local"
$D bash -c "cd CMake && make -j 8"
$D bash -c "cd CMake && make install"

# icu
$D git clone https://github.com/staticlibs/cmake.git
$D git clone https://github.com/staticlibs/external_icu.git
$D mkdir -p icubuild
$D bash -c "cd icubuild && cmake ../external_icu"

# patchelf
$D git clone https://github.com/wilton-iot/tools_linux_patchelf.git
$D mkdir -p /usr/local/bin
$D ln -s /opt/tools_linux_patchelf/patchelf /usr/local/bin/patchelf

# mozjs
$D curl -LO https://ftp.mozilla.org/pub/firefox/releases/${MOZJS_TARBALL_VERSION}/source/firefox-${MOZJS_TARBALL_VERSION}.source.tar.xz
$D tar xJf firefox-${MOZJS_TARBALL_VERSION}.source.tar.xz
# TODO: fixme
$D bash -c "cd firefox-${MOZJS_TARBALL_VERSION}/js/src && patch < /host/mfbt-link.patch"
$D mkdir firefox-${MOZJS_TARBALL_VERSION}/js/src/build_OPT.OBJ
$D bash -c "cd firefox-${MOZJS_TARBALL_VERSION}/js/src/build_OPT.OBJ && \
    ../configure \
    --prefix=/opt/mozjs${MOZJS_TARBALL_VERSION} \
    --with-system-icu"
$D bash -c "cd firefox-${MOZJS_TARBALL_VERSION}/js/src/build_OPT.OBJ && make -j 8"
$D bash -c "cd firefox-${MOZJS_TARBALL_VERSION}/js/src/build_OPT.OBJ && make install"
$D cp /opt/mozjs${MOZJS_TARBALL_VERSION}/lib/libmozjs-${MOZJS_LIB_VERSION}.so .
$D strip libmozjs-${MOZJS_LIB_VERSION}.so
$D patchelf --set-rpath '$ORIGIN/.' libmozjs-${MOZJS_LIB_VERSION}.so
$D mv libmozjs-${MOZJS_LIB_VERSION}.so /host
$D mv /opt/mozjs${MOZJS_TARBALL_VERSION}/include /host
