#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PATH="/usr/local/opt/gettext/bin:$PATH"
build_dir=${DIR}/libs_build
download_dir=${DIR}/libs_src
PATH=${build_dir}/bin:${PATH}
LD_LIBRARY_PATH=${build_dir}/lib:${LD_LIBRARY_PATH}
# export CPLUS_INCLUDE_PATH=:${build_dir}/include:${CPLUS_INCLUDE_PATH}

if [ -x "$(command -v cmake3)" ]; then
  CMAKE3=cmake3
else
  CMAKE3=cmake
fi

ls "${download_dir}"

mkdir -p "${build_dir}"

# echo "Build openssl"
# cd "${download_dir}/openssl"
# SYSTEM=$(uname -s) ./config --prefix="${build_dir}"
# make
# make test
# make install

echo "Build charls"
cd "${download_dir}/charls" || exit 1
mkdir -p build
cd build || exit 1
${CMAKE3} -DCMAKE_INSTALL_PREFIX="${build_dir}" -DBUILD_SHARED_LIBS=1 -DCMAKE_BUILD_TYPE=Release ..
make install

echo "build swig"
cd "${download_dir}/swig-3.0.10" || exit 1
./configure --prefix="${build_dir}"
make
make install

echo "Build jxrlib"
cd "${download_dir}/jxrlib" || exit 1
git stash
git apply "${DIR}/jxrlib.patch" # for macos build
PREFIX="${build_dir}" DIR_INSTALL="${build_dir}" make swig
PREFIX="${build_dir}" DIR_INSTALL="${build_dir}" make
PREFIX="${build_dir}" DIR_INSTALL="${build_dir}" make install
cd "${build_dir}/lib" || exit 1
if [ "$(uname)" == "Darwin" ]; then
  ln -s libjxrglue.dylib libjxrglue.dylib.0 || true
  ln -s libjpegxr.dylib libjpegxr.dylib.0 || true
else
  ln -s libjxrglue.so libjxrglue.so.0 || true
  ln -s libjpegxr.so libjpegxr.so.0 || true
fi

echo "Build libpng"
cd "${download_dir}/libpng" || exit 1
mkdir -p build
cd build || exit 1
${CMAKE3} -DCMAKE_INSTALL_PREFIX="${build_dir}" ..
make install


echo "Build bzip2"
cd "${download_dir}/bzip2" || exit 1
git stash
git apply "${DIR}/bzip2.patch" # for macos build
make -f Makefile-libbz2_so
make install PREFIX="${build_dir}"
cp libbz2.so.1.0.8 "${build_dir}"/lib
cp libbz2.so.1.0 "${build_dir}"/lib

echo "Build c-blosc"
cd "${download_dir}/c-blosc" || exit 1
mkdir -p build
cd build || exit 1
cmake -DCMAKE_INSTALL_PREFIX="${build_dir}" ..
cmake --build .
# ctest
cmake --build . --target install

echo "Build libjpeg-turbo"
cd "${download_dir}/libjpeg-turbo" || exit 1
mkdir -p build
cd build || exit 1
cmake -G"Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${build_dir}" -DWITH_JPEG8=1 -WITH_12BIT=1 ..
make install

echo "Build liblzf"
cd "${download_dir}/liblzf" || exit 1
sh ./configure --prefix="${build_dir}"
make
make install

echo "Build libwebp"
cd "${download_dir}/libwebp" || exit 1
sh ./autogen.sh
sh ./configure --prefix="${build_dir}"
make
make install
cd "${build_dir}/lib" || exit 1
ln -s libwebp.so.7 libwebp.so.6

echo "Build Little-CMS"
cd "${download_dir}/Little-CMS" || exit 1
sh ./configure --prefix="${build_dir}"
make
make install

echo "Build lz4"
cd "${download_dir}/lz4" || exit 1
make
PREFIX="${build_dir}" make install

echo "Build openjpeg"
cd "${download_dir}/openjpeg" || exit 1
mkdir -p build
cd build || exit 1
cmake -DCMAKE_INSTALL_PREFIX="${build_dir}" ..
make install

echo "Build xz"
cd "${download_dir}/xz" || exit 1
sh ./autogen.sh
sh ./configure --prefix="${build_dir}"
make
make check
make install
make installcheck

echo "Build zfp"
cd "${download_dir}/zfp" || exit 1
mkdir -p build
cd build || exit 1
${CMAKE3} -DCMAKE_INSTALL_PREFIX="${build_dir}" ..
make install

echo "Build zlib"
cd "${download_dir}/zlib" || exit 1
mkdir -p build
cd build || exit 1
cmake -DCMAKE_INSTALL_PREFIX="${build_dir}" ..
make install

echo "Build zstd"
cd "${download_dir}/zstd" || exit 1
make
PREFIX="${build_dir}" make install
