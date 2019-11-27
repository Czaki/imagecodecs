#!/usr/bin/env bash
set -e
set -x

wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.7/bin/mac-intel-x86_64/hdf5-1.8.7-mac-intel-x86_64-shared.tar.gz
tar zxf hdf5-1.8.7-mac-intel-x86_64-shared.tar.gz
cd hdf5-1.8.7-mac-intel-x86_64-shared
ls *
cp lib/* "/usr/local/lib"
cp include/* "/usr/local/include"
cp bin/* "/usr/local/bin"