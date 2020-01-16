#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
yum install -y pcre pcre-devel openssl-devel java-1.8.0-openjdk-devel wget libtool cmake3 snappy-devel

wget https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0.tar.gz
tar zxvf  cmake-3.16.0.tar.gz
cd cmake-3.16.0
./bootstrap && make && make install
make clean

bash "${DIR}/gettext_install.sh"