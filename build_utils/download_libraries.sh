#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
download_dir=${DIR}/libs_src
mkdir -p "${download_dir}"
# git clone --depth 1 --branch OpenSSL_1_1_1d https://github.com/openssl/openssl ${download_dir}/openssl
git clone --depth 1 --branch v1.2.11 https://github.com/madler/zlib "${download_dir}/zlib"
git clone --depth 1 --branch v1.9.2 https://github.com/lz4/lz4 "${download_dir}/lz4"
git clone --depth 1 --branch v1.4.4 https://github.com/facebook/zstd "${download_dir}/zstd"
git clone --depth 1 --branch v1.17.0 https://github.com/Blosc/c-blosc "${download_dir}/c-blosc"
git clone --depth 1 --branch bzip2-1.0.8 git://sourceware.org/git/bzip2.git "${download_dir}/bzip2"
git clone --depth 1 --branch v5.2.4 https://github.com/xz-mirror/xz "${download_dir}/xz"
git clone --depth 1 --branch v1.6.37 https://github.com/glennrp/libpng "${download_dir}/libpng"
git clone --depth 1 --branch v1.0.3 https://github.com/webmproject/libwebp "${download_dir}/libwebp"
git clone --depth 1 --branch 2.0.3 https://github.com/libjpeg-turbo/libjpeg-turbo "${download_dir}/libjpeg-turbo"
git clone --depth 1 --branch 2.0.0 https://github.com/team-charls/charls "${download_dir}/charls"
git clone --depth 1 --branch v2.3.1 https://github.com/uclouvain/openjpeg "${download_dir}/openjpeg"
git clone --depth 1 --branch v0.2.1 https://github.com/glencoesoftware/jxrlib "${download_dir}/jxrlib"
git clone --depth 1 --branch 0.5.5 https://github.com/LLNL/zfp "${download_dir}/zfp"
git clone --depth 1 --branch lcms2.9 https://github.com/mm2/Little-CMS "${download_dir}/Little-CMS"
wget -q http://dist.schmorp.de/liblzf/liblzf-3.6.tar.gz
tar zxvf  liblzf-3.6.tar.gz -C "${download_dir}"
mv "${download_dir}/liblzf-3.6" "${download_dir}/liblzf"

wget -q 'https://sourceforge.net/projects/swig/files/swig/swig-3.0.10/swig-3.0.10.tar.gz'
tar zxvf  swig-3.0.10.tar.gz -C "${download_dir}"
