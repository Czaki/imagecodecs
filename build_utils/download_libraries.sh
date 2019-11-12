#!/usr/bin/env bash
mkdir -p libs_src
git clone --depth 1 --branch v1.2.11 https://github.com/madler/zlib libs_src/zlib
git clone --depth 1 --branch v1.9.2 https://github.com/lz4/lz4 libs_src/lz4
git clone --depth 1 --branch v1.4.4 https://github.com/facebook/zstd libs_src/zstd
git clone --depth 1 --branch v1.17.0 https://github.com/Blosc/c-blosc libs_src/c-blosc
git clone --depth 1 --branch bzip2-1.0.8 git://sourceware.org/git/bzip2.git libs_src/bzip2
git clone --depth 1 --branch v5.2.4 https://github.com/xz-mirror/xz libs_src/xz
git clone --depth 1 --branch v1.6.37 https://github.com/glennrp/libpng libs_src/libpng
git clone --depth 1 --branch v1.0.3 https://github.com/webmproject/libwebp libs_src/libwebp
git clone --depth 1 --branch 2.0.3 https://github.com/libjpeg-turbo/libjpeg-turbo libs_src/libjpeg-turbo
git clone --depth 1 --branch 2.0.0 https://github.com/team-charls/charls libs_src/charls
git clone --depth 1 --branch v2.3.1 https://github.com/uclouvain/openjpeg libs_src/openjpeg
git clone --depth 1 --branch v0.2.1 https://github.com/glencoesoftware/jxrlib libs_src/jxrlib
git clone --depth 1 --branch 0.5.5 https://github.com/LLNL/zfp libs_src/zfp
git clone --depth 1 --branch lcms2.9 https://github.com/mm2/Little-CMS libs_src/Little-CMS
wget http://dist.schmorp.de/liblzf/liblzf-3.6.tar.gz
tar zxvf  liblzf-3.6.tar.gz -C libs_src
mv libs_src/liblzf-3.6 libs_src/liblzf