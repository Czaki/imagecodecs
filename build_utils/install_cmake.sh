#!/usr/bin/env bash
set -e

yum install -y wget openssl-devel

wget -q https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0.tar.gz
tar zxf  cmake-3.16.0.tar.gz
cd cmake-3.16.0
echo "Bootstrap cmake"
./bootstrap
echo "Build cmake"
make -s -j $(nproc)
echo "install cmake"
make install
make clean
