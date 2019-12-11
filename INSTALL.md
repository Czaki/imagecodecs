# How to build Imagecodecs on Linux or MacOS
This is information how to build imagecodecs from source on system which n
not have needed images in given version in repository. 

All libraries listed in imagecodecs dependencies are build from sources. 
Develooper tools are install from repository if possible. 

Also this instruction not need to install project dependencies in root.  

## Install on linux
This approach is tested on ubuntu and centos (manylinux image)

1. Check if you have all developer tools installed
    1. `pcre` 
    2. `openssl` - developer packages
    3. `java-jdk`
    4. `cmake3`
    5. `wget`
    6. `xz` - developer package
    7. `freetype` - developer package
    8. `gettext` - if version in repository you may look 
        to `build_utils/gettext_install.sh` for instruction of building from source
    9. for build 32 bits tests you may need `libpng` development files.
2. Download all libraries `build_utils/download_libraries.sh`
3. Build libraries `build_utils/build_libraries.sh`
4. Set `LD_LIBRARY_PATH` to `build_utils/libs_build/lib` 
5. `pip install .`in root directory

## Build manylinux wheel.
To build wheels the python package `cibuildwheel` is used. 
For install it please use `python -m pip install cibuildwheel==1.0.0`

To speedup build process I decide to create docker images which 
base on proper manylinux2010 images. 
The prebuild images can be get from docker hub as
 `bokota/bokota/imagecodecs_64:2019.11.18` and `bokota/imagecodecs_i686:2019.11.18`
 You may also build it from source using `build_utils/docker_64.sh` and `build_utils/docker_i686.sh`
 scripts. 



If you prefer to use prebuild docker images set
```bash
export CIBW_MANYLINUX_X86_64_IMAGE=bokota/imagecodecs_64:2019.12.10
export CIBW_MANYLINUX_I686_IMAGE=bokota/imagecodecs_i686:2019.12.10
``` 
If you prefer to use your own builds then use:
```bash
export CIBW_MANYLINUX_X86_64_IMAGE=imagecodecs_manylinux2010_x86_64
export CIBW_MANYLINUX_I686_IMAGE=imagecodecs_manylinux2010_i686
``` 

For 64 bits wheels `export CIBW_BUILD="*64"`.
For 32 bits wheels `export CIBW_BUILD="*i686"`.
For all wheels `export CIBW_BUILD="*"`.

Other variables needed 
```bash
export CIBW_TEST_REQUIRES="-r requirements_test.txt"
export CIBW_TEST_COMMAND="python -m pytest {project}/tests/test_imagecodecs.py"
export CIBW_PLATFORM=linux
export CIBW_BEFORE_BUILD="pip install build_requires_numpy; pip install cython git+https://github.com/kiyo-masui/bitshuffle@0.3.5"
```
numpy in version 1.16.5 is needed for python 2.7

Then launch `cibuildwheel`
all produced wheels should be in `wheelhouse` directory

## Build on macos.
The first part is common for both install and build wheels. 

1. install needed tools `brew install pcre openssl nasm automake libtool libomp gcc@9`
    gcc is needed if You would like to use `openmp` compilation flags
2. download needed libraries `bash build_utils/download_libraries.sh` 
3. build libraries
    ```bash
   export LDFLAGS=-L/usr/local/opt/openssl/lib
   export CPPFLAGS=-I/usr/local/opt/openssl/include
   MACOSX_DEPLOYMENT_TARGET="10.10" bash build_utils/build_libraries.sh 
   ```
   the `MACOSX_DEPLOYMENT_TARGET` is needed if you would like to build libraries 
   against older macos version than your system
4. Call `bash build_utils/fix_macos_lib.sh` for fix loader path of library (Modern version of macos has SIP protection)
5. Set `LIBRARY_PATH` environment variable to directory with lib. (most probably ``export LIBRARY_PATH=`pwd`/build_utils/libs_build/lib)``

### Install
6. Call `pip install .`

### Build wheel
6. set needed environment variables 
```bash
export CIBW_BUILD="*"
export CIBW_TEST_REQUIRES="-r test_requirements.txt"
export CIBW_TEST_COMMAND="python -m pytest {project}/tests/test_imagecodecs.py"
export CIBW_PLATFORM=macos
export CIBW_BEFORE_BUILD="pip install build_requires_numpy cython"
```
7. call `cibuildwheel`
   all produced wheels should be in `wheelhouse` directory


