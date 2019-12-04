# -*- coding: utf-8 -*-
# _imagecodecs.pyx
# distutils: language = c
# cython: language_level = 3
# cython: boundscheck=False
# cython: wraparound=False
# cython: cdivision=True
# cython: nonecheck=False

# Copyright (c) 2008-2019, Christoph Gohlke
# Copyright (c) 2008-2019, The Regents of the University of California
# Produced at the Laboratory for Fluorescence Dynamics.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

"""Image transformation, compression, and decompression codecs.

Imagecodecs is a Python library that provides block-oriented, in-memory buffer
transformation, compression, and decompression functions for use in the
tifffile, czifile, and other scientific imaging modules.

Decode and/or encode functions are currently implemented for Zlib DEFLATE,
ZStandard (ZSTD), Blosc, LZMA, BZ2, LZ4, LZW, LZF, ZFP, NPY, PNG, WebP,
JPEG 8-bit, JPEG 12-bit, JPEG SOF3, JPEG LS, JPEG 2000, JPEG XR, PackBits,
Packed Integers, Delta, XOR Delta, Floating Point Predictor, Bitorder reversal,
and Bitshuffle.

:Author:
  `Christoph Gohlke <https://www.lfd.uci.edu/~gohlke/>`_

:Organization:
  Laboratory for Fluorescence Dynamics. University of California, Irvine

:License: 3-clause BSD

:Version: 2019.11.26

Requirements
------------
This release has been tested with the following requirements and dependencies
(other versions may work):

* `CPython 2.7.16, 3.5.4, 3.6.8, 3.7.5, 3.8.0 64-bit <https://www.python.org>`_
* `Numpy 1.16.5 <https://www.numpy.org>`_
* `Cython 0.29.14 <https://cython.org>`_
* `zlib 1.2.11 <https://github.com/madler/zlib>`_
* `lz4 1.9.2 <https://github.com/lz4/lz4>`_
* `zstd 1.4.4 <https://github.com/facebook/zstd>`_
* `blosc 1.17.0 <https://github.com/Blosc/c-blosc>`_
* `bzip2 1.0.8 <https://sourceware.org/bzip2>`_
* `xz liblzma 5.2.4 <https://github.com/xz-mirror/xz>`_
* `liblzf 3.6 <http://oldhome.schmorp.de/marc/liblzf.html>`_
* `libpng 1.6.37 <https://github.com/glennrp/libpng>`_
* `libwebp 1.0.3 <https://github.com/webmproject/libwebp>`_
* `libjpeg-turbo 2.0.3 <https://github.com/libjpeg-turbo/libjpeg-turbo>`_
  (8 and 12-bit)
* `charls 2.1.0 rc1 <https://github.com/team-charls/charls>`_
* `openjpeg 2.3.1 <https://github.com/uclouvain/openjpeg>`_
* `jxrlib 0.2.1 <https://github.com/glencoesoftware/jxrlib>`_
* `zfp 0.5.5 <https://github.com/LLNL/zfp>`_
* `bitshuffle 0.3.5 <https://github.com/kiyo-masui/bitshuffle>`_
* `lcms 2.9 <https://github.com/mm2/Little-CMS>`_

Required for testing (other versions may work):

* `tifffile 2019.7.26 <https://pypi.org/project/tifffile/>`_
* `czifile 2019.7.2 <https://pypi.org/project/czifile/>`_
* `python-blosc 1.8.1 <https://github.com/Blosc/python-blosc>`_
* `python-lz4 2.2.1 <https://github.com/python-lz4/python-lz4>`_
* `python-zstd 1.4.4 <https://github.com/sergey-dryabzhinsky/python-zstd>`_
* `python-lzf 0.2.4 <https://github.com/teepark/python-lzf>`_
* `backports.lzma 0.0.14 <https://github.com/peterjc/backports.lzma>`_
* `zfpy 0.5.5 <https://github.com/LLNL/zfp>`_
* `bitshuffle 0.3.5 <https://github.com/kiyo-masui/bitshuffle>`_

Notes
-----
Imagecodecs is currently developed, built, and tested on Windows only.

The API is not stable yet and might change between revisions.

Works on little-endian platforms only.

Python 2.7, 3.5, and 32-bit are deprecated.

The `Microsoft Visual C++ Redistributable Packages
<https://support.microsoft.com/en-us/help/2977003/
the-latest-supported-visual-c-downloads>`_ are required on Windows.

Refer to the imagecodecs/licenses folder for 3rd party library licenses.

This software is based in part on the work of the Independent JPEG Group.

This software includes modified versions of `dcm2niix's jpg_0XC3.cpp
<https://github.com/rordenlab/dcm2niix/blob/master/console/jpg_0XC3.cpp>`_
and `openjpeg's color.c
<https://github.com/uclouvain/openjpeg/blob/master/src/bin/common/color.c>`_.

Manylinux and macOS wheels courtesy of `Grzegorz Bokota
<https://github.com/Czaki>`_.

To install the requirements for building imagecodecs from source code on
current Debian based Linux distributions, run:

    ``$ sudo apt-get install build-essential python3-dev cython3
    python3-setuptools python3-pip python3-wheel python3-numpy python3-pytest
    libz-dev libblosc-dev liblzma-dev liblz4-dev libzstd-dev libpng-dev
    libwebp-dev libbz2-dev libopenjp2-7-dev libjpeg62-turbo-dev libjxr-dev
    liblcms2-dev libcharls-dev libtiff-dev python3-blosc``

The imagecodecs package can be challenging to build from source code. Consider
using the `imagecodecs-lite <https://pypi.org/project/imagecodecs-lite/>`_
package instead, which does not depend on external third-party C libraries
and provides a subset of image codecs for the tifffile library:
LZW, PackBits, Delta, XOR Delta, Packed Integers, Floating Point Predictor,
and Bitorder reversal.

Other Python packages providing imaging or compression codecs:

* `numcodecs <https://github.com/zarr-developers/numcodecs>`_
* `Python zlib <https://docs.python.org/3/library/zlib.html>`_
* `Python bz2 <https://docs.python.org/3/library/bz2.html>`_
* `Python lzma <https://docs.python.org/3/library/lzma.html>`_
* `python-snappy <https://github.com/andrix/python-snappy>`_
* `python-brotli <https://github.com/google/brotli/tree/master/python>`_
* `python-lzo <https://bitbucket.org/james_taylor/python-lzo-static>`_
* `python-lzw <https://github.com/joeatwork/python-lzw>`_
* `packbits <https://github.com/psd-tools/packbits>`_
* `fpzip <https://github.com/seung-lab/fpzip>`_

Revisions
---------
2019.11.26
    Pass 2755 tests.
    Do not require scikit-image for testing.
    Use CharLS 2.1.
2019.11.18
    Add bitshuffle codec.
    Fix formatting of unknown error numbers.
    Fix test failures with official python-lzf.
2019.11.5
    Rebuild with updated dependencies.
2019.5.22
    Add optional YCbCr chroma subsampling to JPEG encoder.
    Add default reversible mode to ZFP encoder.
    Add imread and imwrite helper functions.
2019.4.20
    Fix setup requirements.
2019.2.22
    Move codecs without 3rd-party C library dependencies to imagecodecs_lite.
2019.2.20
    Rebuild with updated dependencies.
2019.1.20
    Add more pixel formats to JPEG XR codec.
    Add JPEG XR encoder.
2019.1.14
    Add ZFP codec via zfp library (WIP).
    Add numpy NPY and NPZ codecs.
    Fix some static codechecker errors.
2019.1.1
    Update copyright year.
    Do not install package if Cython extension fails to build.
    Fix compiler warnings.
2018.12.16
    Reallocate LZW buffer on demand.
    Ignore integer type output arguments for codecs returning images.
2018.12.12
    Enable decoding of subsampled J2K images via conversion to RGB.
    Enable decoding of large JPEG using patched libjpeg-turbo.
    Switch to Cython 0.29, language_level=3.
2018.12.1
    Add J2K encoder (WIP).
    Use ZStd content size 1 MB if it cannot be determined.
    Use logging.warning instead of warnings.warn or print.
2018.11.8
    Decode LSB style LZW.
    Fix last byte not written by LZW decoder (bug fix).
    Permit unknown colorspaces in JPEG codecs (e.g. CFA used in TIFF).
2018.10.30
    Add JPEG 8-bit and 12-bit encoders.
    Improve color space handling in JPEG codecs.
2018.10.28
    Rename jpeg0xc3 to jpegsof3.
    Add JPEG LS codec via CharLS.
    Fix missing alpha values in jxr_decode.
    Fix decoding JPEG SOF3 with multiple DHTs.
2018.10.22
    Add Blosc codec via libblosc.
2018.10.21
    Builds on Ubuntu 18.04 WSL.
    Include liblzf in srcdist.
    Do not require CreateDecoderFromBytes patch to jxrlib.
2018.10.18
    Improve jpeg_decode wrapper.
2018.10.17
    Add JPEG SOF3 decoder based on jpg_0XC3.cpp.
2018.10.10
    Add PNG codec via libpng.
    Add option to specify output colorspace in JPEG decoder.
    Fix Delta codec for floating point numbers.
    Fix XOR Delta codec.
2018.9.30
    Add LZF codec via liblzf.
2018.9.22
    Add WebP codec via libwebp.
2018.8.29
    Add PackBits encoder.
2018.8.22
    Add link library version information.
    Add option to specify size of LZW buffer.
    Add JPEG 2000 decoder via openjpeg.
    Add XOR Delta codec.
2018.8.16
    Link to libjpeg-turbo.
    Support Python 2.7 and Visual Studio 2008.
2018.8.10
    Initial alpha release.
    Add LZW, PackBits, PackInts and FloatPred decoders from tifffile.c module.
    Add JPEG and JPEG XR decoders from czifile.pyx module.

"""

__version__ = '2019.11.26'

import io
import numbers
import numpy

cimport numpy
cimport cython

from cython.operator cimport dereference as deref
from cpython.bytearray cimport PyByteArray_FromStringAndSize
from cpython.bytes cimport (PyBytes_FromStringAndSize, PyBytes_AS_STRING,
                            _PyBytes_Resize)

from libc.math cimport ceil
from libc.string cimport memset, memcpy, memmove
from libc.stdlib cimport malloc, free, realloc
from libc.setjmp cimport setjmp, longjmp, jmp_buf
from libc.stdint cimport (int8_t, uint8_t, int16_t, uint16_t,
                          int32_t, uint32_t, int64_t, uint64_t, UINT64_MAX)

from numpy cimport (PyArray_DescrNewFromType, NPY_BOOL, NPY_INTP,
                    NPY_INT8, NPY_INT16, NPY_INT32, NPY_INT64, NPY_INT128,
                    NPY_UINT8, NPY_UINT16, NPY_UINT32, NPY_UINT64,
                    NPY_FLOAT16, NPY_FLOAT32, NPY_FLOAT64,
                    NPY_COMPLEX64, NPY_COMPLEX128, )


cdef extern from 'numpy/arrayobject.h':
    int NPY_VERSION
    int NPY_FEATURE_VERSION

numpy.import_array()


###############################################################################

cdef _parse_output(out, ssize_t out_size=-1, out_given=False, out_type=bytes):
    """Return out, out_size, out_given, out_type from output argument."""
    if out is None:
        pass
    elif out is bytes:
        out = None
        out_type = bytes
    elif out is bytearray:
        out = None
        out_type = bytearray
    elif isinstance(out, numbers.Integral):
        out_size = out
        out = None
    else:
        # out_size = len(out)
        # out_type = type(out)
        out_given = True
    return out, out_size, out_given, out_type


cdef _create_array(out, shape, dtype, strides=None):
    """Return numpy array of shape and dtype from output argument."""
    if out is None or isinstance(out, numbers.Integral):
        out = numpy.empty(shape, dtype)
    elif isinstance(out, numpy.ndarray):
        if out.shape != shape:
            raise ValueError('invalid output shape')
        if out.itemsize != numpy.dtype(dtype).itemsize:
            raise ValueError('invalid output dtype')
        if strides is not None:
            for i, j in zip(strides, out.strides):
                if i is not None and i != j:
                    raise ValueError('invalid output strides')
        elif not numpy.PyArray_ISCONTIGUOUS(out):
            raise ValueError('output is not contiguous')
    else:
        dstsize = 1
        for i in shape:
            dstsize *= i
        out = numpy.frombuffer(out, dtype, dstsize)
        out.shape = shape
    return out


cdef _parse_input(data):
    """Return bytes memoryview to input argument."""
    cdef const uint8_t[::1] src
    try:
        src = data
    except ValueError:
        src = numpy.ravel(data, 'K').view(numpy.uint8)
    return src


def _default_level(level, default, smallest, largest):
    """Return compression level in range."""
    if level is None:
        level = default
    if largest is not None:
        level = min(level, largest)
    if smallest is not None:
        level = max(level, smallest)
    return level


def version(astype=None):
    """Return detailed version information."""
    jpeg_turbo_version = str(LIBJPEG_TURBO_VERSION_NUMBER)
    versions = (
        ('imagecodecs', __version__),
        ('numpy_abi', '0x%X.%i' % (NPY_VERSION, NPY_FEATURE_VERSION)),
        ('cython', cython.__version__),
        ('icd', _ICD_VERSION),
        ('zlib', '%i.%i.%i' % (
            ZLIB_VER_MAJOR, ZLIB_VER_MINOR, ZLIB_VER_REVISION)),
        ('lzma', '%i.%i.%i' % (
            LZMA_VERSION_MAJOR, LZMA_VERSION_MINOR, LZMA_VERSION_PATCH)),
        ('zstd', '%i.%i.%i' % (
            ZSTD_VERSION_MAJOR, ZSTD_VERSION_MINOR, ZSTD_VERSION_RELEASE)),
        ('lz4', '%i.%i.%i' % (
            LZ4_VERSION_MAJOR, LZ4_VERSION_MINOR, LZ4_VERSION_RELEASE)),
        ('bitshuffle', '%i.%i.%i' % (
            BSHUF_VERSION_MAJOR, BSHUF_VERSION_MINOR, BSHUF_VERSION_POINT)),
        ('blosc', BLOSC_VERSION_STRING.decode('utf-8')),
        ('bz2', str(BZ2_bzlibVersion().decode('utf-8')).split(',')[0]),
        ('lzf', hex(LZF_VERSION)),
        ('png', PNG_LIBPNG_VER_STRING.decode('utf-8')),
        ('webp', hex(WebPGetDecoderVersion())),
        ('jpeg', '%.1f' % (JPEG_LIB_VERSION / 10.0)),
        ('jpeg_turbo', '%i.%i.%i' % (
            int(jpeg_turbo_version[:1]),
            int(jpeg_turbo_version[3:4]),
            int(jpeg_turbo_version[6:]))),
        ('jpeg_sof3', JPEG_SOF3_VERSION.decode('utf-8')),
        ('charls', _CHARLS_VERSION),
        ('opj', opj_version().decode('utf-8')),
        ('jxr', hex(WMP_SDK_VERSION)),
        ('zfp', _ZFP_VERSION.decode('utf-8')),
    )
    if astype is str or astype is None:
        return ', '.join('%s-%s' % (k, v) for k, v in versions)
    elif astype is dict:
        return dict(versions)
    else:
        return versions


# Bitshuffle ##################################################################

cdef extern from 'bitshuffle.h':
    int BSHUF_VERSION_MAJOR
    int BSHUF_VERSION_MINOR
    int BSHUF_VERSION_POINT

    int bshuf_using_NEON() nogil
    int bshuf_using_SSE2() nogil
    int bshuf_using_AVX2() nogil

    size_t bshuf_default_block_size(const size_t elem_size) nogil

    int64_t bshuf_compress_lz4(const void* inp,
                               void* out,
                               const size_t size,
                               const size_t elem_size,
                               size_t block_size) nogil

    int64_t bshuf_decompress_lz4(const void* inp,
                                 void* out,
                                 const size_t size,
                                 const size_t elem_size,
                                 size_t block_size) nogil

    int64_t bshuf_bitshuffle(const void* inp,
                             void* out,
                             const size_t size,
                             const size_t elem_size,
                             size_t block_size) nogil

    int64_t bshuf_bitunshuffle(const void* inp,
                               void* out,
                               const size_t size,
                               const size_t elem_size,
                               size_t block_size) nogil

    size_t bshuf_compress_lz4_bound(const size_t size,
                                    const size_t elem_size,
                                    size_t block_size) nogil


class BitshuffleError(RuntimeError):
    """Bitshuffle Exceptions."""
    def __init__(self, func, err):
        msg = {
            0: 'No Error',
            -1: 'Failed to allocate memory',
            -11: 'Missing SSE',
            -12: 'Missing AVX',
            -80: 'Input size not a multiple of 8',
            -81: 'Block size not a multiple of 8',
            -91: 'Decompression error, wrong number of bytes processed',
        }.get(err, 'internal error %i' % err)
        msg = '%s returned %s' % (func, msg)
        RuntimeError.__init__(self, msg)


def bitshuffle_encode(data, level=None, itemsize=1, blocksize=0, out=None):
    """Bitshuffle.

    """
    cdef:
        const uint8_t[::1] src = _parse_input(data)
        const uint8_t[::1] dst  # must be const to write to bytes
        numpy.ndarray ndarr
        ssize_t srcsize
        ssize_t dstsize
        size_t elem_size
        size_t block_size = blocksize
        int64_t ret = 0

    if isinstance(data, numpy.ndarray):
        if data is out:
            raise ValueError('cannot bitshuffle in-place')
        out = _create_array(out, data.shape, data.dtype)
        ndarr = out
        srcsize = data.size
        elem_size = <size_t>data.itemsize
        with nogil:
            ret = bshuf_bitshuffle(<void *>&src[0], <void *>ndarr.data,
                                   <size_t>srcsize, elem_size, block_size)
        if ret < 0:
            raise BitshuffleError('bshuf_bitshuffle', ret)
        return out

    srcsize = src.size
    elem_size = itemsize

    if elem_size != 1 and elem_size != 2 and elem_size != 4 and elem_size != 8:
        raise ValueError('invalid item size')
    if srcsize % elem_size != 0:
        raise ValueError('data size not a multiple of item size')

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None or out is data:
        if dstsize < 0:
            dstsize = srcsize
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size

    if dstsize < srcsize:
        raise RuntimeError('output too small')

    with nogil:
        ret = bshuf_bitshuffle(<void *>&src[0], <void *>&dst[0],
                               <size_t>srcsize / elem_size,
                               elem_size, block_size)
    if ret < 0:
        raise BitshuffleError('bshuf_bitshuffle', ret)

    if ret < dstsize:
        out = memoryview(out)[:ret] if out_given else out[:ret]

    return out


def bitshuffle_decode(data, itemsize=1, blocksize=0, out=None):
    """Un-Bitshuffle.

    """
    cdef:
        const uint8_t[::1] src = _parse_input(data)
        const uint8_t[::1] dst  # must be const to write to bytes
        numpy.ndarray ndarr
        ssize_t srcsize
        ssize_t dstsize
        size_t elem_size
        size_t block_size = blocksize
        int64_t ret = 0

    if isinstance(data, numpy.ndarray):
        if data is out:
            raise ValueError('cannot un-bitshuffle in-place')
        out = _create_array(out, data.shape, data.dtype)
        ndarr = out
        srcsize = data.size
        elem_size = <size_t>data.itemsize
        with nogil:
            ret = bshuf_bitunshuffle(<void *>&src[0], <void *>ndarr.data,
                                     <size_t>srcsize, elem_size, block_size)
        if ret < 0:
            raise BitshuffleError('bshuf_bitunshuffle', ret)
        return out

    srcsize = src.size
    elem_size = itemsize

    if elem_size != 1 and elem_size != 2 and elem_size != 4 and elem_size != 8:
        raise ValueError('invalid item size')
    if srcsize % elem_size != 0:
        raise ValueError('data size not a multiple of item size')

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None or out is data:
        if dstsize < 0:
            dstsize = srcsize
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size

    if dstsize < srcsize:
        raise RuntimeError('output too small')

    with nogil:
        ret = bshuf_bitunshuffle(<void *>&src[0], <void *>&dst[0],
                                 <size_t>srcsize / elem_size,
                                 elem_size, block_size)
    if ret < 0:
        raise BitshuffleError('bshuf_bitunshuffle', ret)

    if ret < dstsize:
        out = memoryview(out)[:ret] if out_given else out[:ret]

    return out


# Zlib DEFLATE ################################################################

cdef extern from 'zlib.h':
    int ZLIB_VER_MAJOR
    int ZLIB_VER_MINOR
    int ZLIB_VER_REVISION
    int Z_OK
    int Z_MEM_ERROR
    int Z_BUF_ERROR
    int Z_DATA_ERROR
    int Z_STREAM_ERROR

    ctypedef unsigned char Bytef
    ctypedef unsigned long uLong
    ctypedef unsigned long uLongf
    ctypedef unsigned int uInt

    uLong crc32(uLong crc, const Bytef *buf, uInt len) nogil

    int uncompress2(Bytef *dst,
                    uLongf *dstLen,
                    const Bytef *src,
                    uLong *srcLen) nogil

    int compress2(Bytef *dst,
                  uLongf *dstLen,
                  const Bytef *src,
                  uLong srcLen,
                  int level) nogil


class ZlibError(RuntimeError):
    """Zlib Exceptions."""
    def __init__(self, func, err):
        msg = {
            Z_OK: 'Z_OK',
            Z_MEM_ERROR: 'Z_MEM_ERROR',
            Z_BUF_ERROR: 'Z_BUF_ERROR',
            Z_DATA_ERROR: 'Z_DATA_ERROR',
            Z_STREAM_ERROR: 'Z_STREAM_ERROR',
            }.get(err, 'unknown error %i' % err)
        msg = '%s returned %s' % (func, msg)
        RuntimeError.__init__(self, msg)


def zlib_encode(data, level=None, out=None):
    """Compress Zlib DEFLATE.

    """
    cdef:
        const uint8_t[::1] src = _parse_input(data)  # TODO: non-contiguous
        const uint8_t[::1] dst  # must be const to write to bytes
        ssize_t srcsize = src.size
        ssize_t dstsize
        unsigned long srclen, dstlen
        int ret = Z_OK
        int compresslevel = _default_level(level, 6, 0, 9)

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None and dstsize < 0:
        # use Python's zlib module
        import zlib
        return zlib.compress(data, compresslevel)

    if out is None or out is data:
        if dstsize < 0:
            raise ValueError('invalid output')
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size
    dstlen = <unsigned long>dstsize
    srclen = <unsigned long>srcsize

    with nogil:
        ret = compress2(<Bytef *>&dst[0], &dstlen,
                        &src[0], srclen, compresslevel)
    if ret != Z_OK:
        raise ZlibError('compress2', ret)

    if dstlen < dstsize:
        out = memoryview(out)[:dstlen] if out_given else out[:dstlen]

    return out


def zlib_decode(data, out=None):
    """Decompress Zlib DEFLATE.

    """
    cdef:
        const uint8_t[::1] src = data
        const uint8_t[::1] dst  # must be const to write to bytes
        ssize_t srcsize = src.size
        ssize_t dstsize
        unsigned long srclen, dstlen
        int ret

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None and dstsize < 0:
        # use Python's zlib module
        import zlib
        return zlib.decompress(data)

    if out is None or out is data:
        if dstsize < 0:
            raise ValueError('invalid output size')
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size
    dstlen = <unsigned long>dstsize
    srclen = <unsigned long>srcsize

    with nogil:
        ret = uncompress2(<Bytef *>&dst[0], &dstlen, &src[0], &srclen)
    if ret != Z_OK:
        raise ZlibError('uncompress2', ret)

    if dstlen < dstsize:
        out = memoryview(out)[:dstlen] if out_given else out[:dstlen]

    return out


def zlib_crc32(data):
    """Return cyclic redundancy checksum CRC-32 of data."""
    cdef:
        const uint8_t[::1] src = _parse_input(data)  # TODO: non-contiguous
        uInt srcsize = <uInt>src.size
        uLong crc = 0
    with nogil:
        crc = crc32(crc, NULL, 0)
        crc = crc32(crc, <Bytef *>&src[0], srcsize)
    return int(crc)


# ZStandard ###################################################################

cdef extern from 'zstd.h':
    int ZSTD_VERSION_MAJOR
    int ZSTD_VERSION_MINOR
    int ZSTD_VERSION_RELEASE
    int ZSTD_CONTENTSIZE_UNKNOWN
    int ZSTD_CONTENTSIZE_ERROR

    unsigned int ZSTD_isError(size_t code) nogil
    size_t ZSTD_compressBound(size_t srcSize) nogil
    const char* ZSTD_getErrorName(size_t code) nogil
    uint64_t ZSTD_getFrameContentSize(const void *src, size_t srcSize) nogil

    size_t ZSTD_decompress(void* dst,
                           size_t dstCapacity,
                           const void* src,
                           size_t compressedSize) nogil

    size_t ZSTD_compress(void* dst,
                         size_t dstCapacity,
                         const void* src,
                         size_t srcSize,
                         int compressionLevel) nogil


class ZstdError(RuntimeError):
    """ZStandard Exceptions."""
    def __init__(self, func, msg='', err=0):
        cdef const char* errmsg
        if msg:
            RuntimeError.__init__(self, "%s returned '%s'" % (func, msg))
        else:
            errmsg = ZSTD_getErrorName(err)
            RuntimeError.__init__(
                self, u"%s returned '%s'" % (func, errmsg.decode('utf-8')))


def zstd_encode(data, level=None, out=None):
    """Compress ZStandard.

    """
    cdef:
        const uint8_t[::1] src = _parse_input(data)
        const uint8_t[::1] dst  # must be const to write to bytes
        size_t srcsize = src.size
        size_t dstsize
        ssize_t dstlen
        size_t ret = 0
        char* errmsg
        int compresslevel = _default_level(level, 5, 1, 22)

    out, dstlen, out_given, out_type = _parse_output(out)

    if out is None or out is data:
        if dstlen < 0:
            dstlen = <ssize_t>ZSTD_compressBound(srcsize)
            if dstlen < 0:
                raise ZstdError('ZSTD_compressBound', '%i' % dstlen)
        if dstlen < 64:
            dstlen = 64
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstlen)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstlen)

    dst = out
    dstsize = <size_t>dst.size

    with nogil:
        ret = ZSTD_compress(<void *>&dst[0], dstsize,
                            <void *>&src[0], srcsize, compresslevel)
    if ZSTD_isError(ret):
        raise ZstdError('ZSTD_compress', err=ret)
    if ret < dstsize:
        out = memoryview(out)[:ret] if out_given else out[:ret]

    return out


def zstd_decode(data, out=None):
    """Decompress ZStandard.

    """
    cdef:
        const uint8_t[::1] src = data
        const uint8_t[::1] dst  # must be const to write to bytes
        size_t srcsize = <size_t>src.size
        size_t dstsize
        ssize_t dstlen
        size_t ret
        uint64_t cntsize
        char* errmsg

    out, dstlen, out_given, out_type = _parse_output(out)

    if out is None or out is data:
        if dstlen < 0:
            cntsize = ZSTD_getFrameContentSize(<void *>&src[0], srcsize)
            if (cntsize == ZSTD_CONTENTSIZE_UNKNOWN or
                    cntsize == ZSTD_CONTENTSIZE_ERROR):
                cntsize = max(1048576, srcsize*2)  # 1 MB; arbitrary
            # TODO: better use stream interface
            # if cntsize == ZSTD_CONTENTSIZE_UNKNOWN:
            #     raise ZstdError('ZSTD_getFrameContentSize',
            #                     'ZSTD_CONTENTSIZE_UNKNOWN')
            # if cntsize == ZSTD_CONTENTSIZE_ERROR:
            #     raise ZstdError('ZSTD_getFrameContentSize',
            #                     'ZSTD_CONTENTSIZE_ERROR')
            dstlen = <ssize_t>cntsize
            if dstlen < 0:
                raise ZstdError('ZSTD_getFrameContentSize', '%i' % dstlen)

        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstlen)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstlen)

    dst = out
    dstsize = <size_t>dst.size

    with nogil:
        ret = ZSTD_decompress(<void *>&dst[0], dstsize,
                              <void *>&src[0], srcsize)
    if ZSTD_isError(ret):
        raise ZstdError('ZSTD_decompress', err=ret)

    if ret < dstsize:
        out = memoryview(out)[:ret] if out_given else out[:ret]

    return out


# LZ4 #########################################################################

cdef extern from 'lz4.h':
    int LZ4_VERSION_MAJOR
    int LZ4_VERSION_MINOR
    int LZ4_VERSION_RELEASE
    int LZ4_MAX_INPUT_SIZE

    int LZ4_compressBound(int isize) nogil

    int LZ4_compress_fast(const char* src,
                          char* dst,
                          int srcSize,
                          int dstCapacity,
                          int acceleration) nogil

    int LZ4_decompress_safe(const char* src,
                            char* dst,
                            int compressedSize,
                            int dstCapacity) nogil


def lz4_encode(data, level=None, header=False, out=None):
    """Compress LZ4.

    """
    cdef:
        const uint8_t[::1] src = _parse_input(data)
        const uint8_t[::1] dst  # must be const to write to bytes
        int srcsize = src.size
        int dstsize
        int offset = 4 if header else 0
        int ret = 0
        uint8_t *pdst
        int acceleration = _default_level(level, 1, 1, 1000)

    if src.size > LZ4_MAX_INPUT_SIZE:
        raise ValueError('data too large')

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None or out is data:
        if dstsize < 0:
            dstsize = LZ4_compressBound(srcsize) + offset
            if dstsize < 0:
                raise RuntimeError('LZ4_compressBound returned %i' % dstsize)
        if dstsize < offset:
            dstsize = offset
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = <int>dst.size - offset

    if dst.size > 2**31:
        raise ValueError('output too large')

    with nogil:
        ret = LZ4_compress_fast(<char *>&src[0], <char *>&dst[offset],
                                srcsize, dstsize, acceleration)
    if ret <= 0:
        raise RuntimeError('LZ4_compress_fast returned %i' % ret)

    if header:
        pdst = <uint8_t *>&dst[0]
        pdst[0] = srcsize & 255
        pdst[1] = (srcsize >> 8) & 255
        pdst[2] = (srcsize >> 16) & 255
        pdst[3] = (srcsize >> 24) & 255

    if ret < dstsize:
        out = memoryview(out)[:ret+offset] if out_given else out[:ret+offset]

    return out


def lz4_decode(data, header=False, out=None):
    """Decompress LZ4.

    """
    cdef:
        const uint8_t[::1] src = data
        const uint8_t[::1] dst  # must be const to write to bytes
        int srcsize = <int>src.size
        int dstsize
        int offset = 4 if header else 0
        int ret = 0

    if src.size > 2**31:
        raise ValueError('data too large')

    out, dstsize, out_given, out_type = _parse_output(out)

    if header and dstsize < 0:
        if srcsize < offset:
            raise ValueError('invalid data size')
        dstsize = src[0] | (src[1] << 8) | (src[2] << 16) | (src[3] << 24)

    if out is None or out is data:
        if dstsize < 0:
            dstsize = max(24, 24 + 255 * (srcsize - offset - 10))  # ugh
            if dstsize < 0:
                raise RuntimeError('invalid output size %i' % dstsize)
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = <int>dst.size

    if dst.size > 2**31:
        raise ValueError('output too large')

    with nogil:
        ret = LZ4_decompress_safe(<char *>&src[offset], <char *>&dst[0],
                                  srcsize-offset, dstsize)
    if ret < 0:
        raise RuntimeError('LZ4_decompress_safe returned %i' % ret)

    if ret < dstsize:
        out = memoryview(out)[:ret] if out_given else out[:ret]

    return out


# LZF #########################################################################

cdef extern from 'lzf.h':
    int LZF_VERSION

    unsigned int lzf_compress(const void *const in_data,
                              unsigned int in_len,
                              void *out_data,
                              unsigned int out_len) nogil

    unsigned int lzf_decompress(const void *const in_data,
                                unsigned int in_len,
                                void *out_data,
                                unsigned int out_len) nogil


def lzf_encode(data, level=None, header=False, out=None):
    """Compress LZF.

    """
    cdef:
        const uint8_t[::1] src = _parse_input(data)
        const uint8_t[::1] dst  # must be const to write to bytes
        int srcsize = <int>src.size
        int dstsize
        unsigned int ret = 0
        uint8_t *pdst
        int offset = 4 if header else 0

    if src.size > 2**31:
        raise ValueError('data too large')

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None or out is data:
        if dstsize < 0:
            # dstsize = ((srcsize * 33) >> 5 ) + 1 + offset
            dstsize = srcsize + srcsize // 20 + 32
        else:
            dstsize += 1  # bug in liblzf ?
        if dstsize < offset:
            dstsize = offset
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = <int>dst.size - offset

    if dst.size > 2**31:
        raise ValueError('output too large')

    with nogil:
        ret = lzf_compress(<void *>&src[0], <unsigned int>srcsize,
                           <void *>&dst[offset], <unsigned int>dstsize)
    if ret == 0:
        raise RuntimeError('lzf_compress returned 0')

    if header:
        pdst = <uint8_t *>&dst[0]
        pdst[0] = srcsize & 255
        pdst[1] = (srcsize >> 8) & 255
        pdst[2] = (srcsize >> 16) & 255
        pdst[3] = (srcsize >> 24) & 255

    if ret < <unsigned int>dstsize:
        out = memoryview(out)[:ret+offset] if out_given else out[:ret+offset]

    return out


def lzf_decode(data, header=False, out=None):
    """Decompress LZF.

    """
    cdef:
        const uint8_t[::1] src = data
        const uint8_t[::1] dst  # must be const to write to bytes
        int dstsize
        int srcsize = <unsigned int>src.size
        unsigned int ret = 0
        int offset = 4 if header else 0

    if src.size > 2**31:
        raise ValueError('data too large')

    out, dstsize, out_given, out_type = _parse_output(out)

    if header and dstsize < 0:
        if srcsize < offset:
            raise ValueError('invalid data size')
        dstsize = src[0] | (src[1] << 8) | (src[2] << 16) | (src[3] << 24)

    if out is None or out is data:
        if dstsize < 0:
            dstsize = srcsize
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = <int>dst.size

    if dst.size > 2**31:
        raise ValueError('output too large')

    with nogil:
        ret = lzf_decompress(<void *>&src[offset], srcsize-offset,
                             <void *>&dst[0], dstsize)
    if ret == 0:
        raise RuntimeError('lzf_decompress returned %i' % ret)

    if ret < <unsigned int>dstsize:
        out = memoryview(out)[:ret] if out_given else out[:ret]

    return out


# LZMA ########################################################################

cdef extern from 'lzma.h':
    int LZMA_VERSION_MAJOR
    int LZMA_VERSION_MINOR
    int LZMA_VERSION_PATCH
    int LZMA_CONCATENATED
    int LZMA_STREAM_HEADER_SIZE

    ctypedef uint64_t lzma_vli

    ctypedef struct lzma_stream_flags:
        uint32_t version
        lzma_vli backward_size

    ctypedef struct lzma_index:
        pass

    ctypedef struct lzma_allocator:
        pass

    ctypedef struct lzma_internal:
        pass

    ctypedef enum lzma_reserved_enum:
        LZMA_RESERVED_ENUM

    ctypedef enum lzma_check:
        LZMA_CHECK_NONE
        LZMA_CHECK_CRC32
        LZMA_CHECK_CRC64
        LZMA_CHECK_SHA256

    ctypedef struct lzma_stream:
        uint8_t *next_in
        size_t avail_in
        uint64_t total_in
        uint8_t *next_out
        size_t avail_out
        uint64_t total_out
        lzma_allocator *allocator
        lzma_internal *internal
        void *reserved_ptr1
        void *reserved_ptr2
        void *reserved_ptr3
        void *reserved_ptr4
        uint64_t reserved_int1
        uint64_t reserved_int2
        size_t reserved_int3
        size_t reserved_int4
        lzma_reserved_enum reserved_enum1
        lzma_reserved_enum reserved_enum2

    ctypedef enum lzma_action:
        LZMA_RUN
        LZMA_SYNC_FLUSH
        LZMA_FULL_FLUSH
        LZMA_FULL_BARRIER
        LZMA_FINISH

    ctypedef enum lzma_ret:
        LZMA_OK
        LZMA_STREAM_END
        LZMA_NO_CHECK
        LZMA_UNSUPPORTED_CHECK
        LZMA_GET_CHECK
        LZMA_MEM_ERROR
        LZMA_MEMLIMIT_ERROR
        LZMA_FORMAT_ERROR
        LZMA_OPTIONS_ERROR
        LZMA_DATA_ERROR
        LZMA_BUF_ERROR
        LZMA_PROG_ERROR

    lzma_ret lzma_easy_encoder(lzma_stream *strm,
                               uint32_t preset,
                               lzma_check check) nogil

    lzma_ret lzma_stream_decoder(lzma_stream *strm,
                                 uint64_t memlimit,
                                 uint32_t flags) nogil

    lzma_ret lzma_stream_footer_decode(lzma_stream_flags *options,
                                       const uint8_t *in_) nogil

    lzma_ret lzma_index_buffer_decode(lzma_index **i,
                                      uint64_t *memlimit,
                                      const lzma_allocator *allocator,
                                      const uint8_t *in_,
                                      size_t *in_pos,
                                      size_t in_size) nogil

    lzma_ret lzma_code(lzma_stream *strm, lzma_action action) nogil
    void lzma_end(lzma_stream *strm) nogil
    size_t lzma_stream_buffer_bound(size_t uncompressed_size) nogil
    lzma_vli lzma_index_uncompressed_size(const lzma_index *i) nogil
    lzma_index * lzma_index_init(const lzma_allocator *allocator) nogil
    void lzma_index_end(lzma_index *i, const lzma_allocator *allocator) nogil


class LzmaError(RuntimeError):
    """LZMA Exceptions."""
    def __init__(self, func, err):
        msg = {
            LZMA_OK: 'LZMA_OK',
            LZMA_STREAM_END: 'LZMA_STREAM_END',
            LZMA_NO_CHECK: 'LZMA_NO_CHECK',
            LZMA_UNSUPPORTED_CHECK: 'LZMA_UNSUPPORTED_CHECK',
            LZMA_GET_CHECK: 'LZMA_GET_CHECK',
            LZMA_MEM_ERROR: 'LZMA_MEM_ERROR',
            LZMA_MEMLIMIT_ERROR: 'LZMA_MEMLIMIT_ERROR',
            LZMA_FORMAT_ERROR: 'LZMA_FORMAT_ERROR',
            LZMA_OPTIONS_ERROR: 'LZMA_OPTIONS_ERROR',
            LZMA_DATA_ERROR: 'LZMA_DATA_ERROR',
            LZMA_BUF_ERROR: 'LZMA_BUF_ERROR',
            LZMA_PROG_ERROR: 'LZMA_PROG_ERROR',
            }.get(err, 'unknown error %i' % err)
        msg = '%s returned %s' % (func, msg)
        RuntimeError.__init__(self, msg)


def _lzma_uncompressed_size(const uint8_t[::1] data, ssize_t size):
    """Return size of decompressed LZMA data."""
    cdef:
        lzma_ret ret = LZMA_OK
        lzma_index *index
        lzma_stream_flags options
        lzma_vli usize = 0
        uint64_t memlimit = UINT64_MAX
        ssize_t offset
        size_t pos = 0

    if size < LZMA_STREAM_HEADER_SIZE:
        raise ValueError('invalid LZMA data')
    try:
        index = lzma_index_init(NULL)
        offset = size - LZMA_STREAM_HEADER_SIZE
        ret = lzma_stream_footer_decode(&options, &data[offset])
        if ret != LZMA_OK:
            raise LzmaError('lzma_stream_footer_decode', ret)
        offset -= options.backward_size
        ret = lzma_index_buffer_decode(&index, &memlimit, NULL,
                                       &data[offset], &pos,
                                       options.backward_size)
        if ret != LZMA_OK or pos != options.backward_size:
            raise LzmaError('lzma_index_buffer_decode', ret)
        usize = lzma_index_uncompressed_size(index)
    finally:
        lzma_index_end(index, NULL)
    return <ssize_t>usize


def lzma_decode(data, out=None):
    """Decompress LZMA.

    """
    cdef:
        const uint8_t[::1] src = data
        const uint8_t[::1] dst  # must be const to write to bytes
        ssize_t srcsize = src.size
        ssize_t dstsize
        ssize_t dstlen
        lzma_ret ret = LZMA_OK
        lzma_stream strm

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None or out is data:
        if dstsize < 0:
            dstsize = _lzma_uncompressed_size(src, srcsize)
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size

    memset(&strm, 0, sizeof(lzma_stream))
    ret = lzma_stream_decoder(&strm, UINT64_MAX, LZMA_CONCATENATED)
    if ret != LZMA_OK:
        raise LzmaError('lzma_stream_decoder', ret)

    try:
        with nogil:
            strm.next_in = &src[0]
            strm.avail_in = <size_t>srcsize
            strm.next_out = <uint8_t*>&dst[0]
            strm.avail_out = <size_t>dstsize
            ret = lzma_code(&strm, LZMA_RUN)
            dstlen = dstsize - <ssize_t>strm.avail_out
        if ret != LZMA_OK and ret != LZMA_STREAM_END:
            raise LzmaError('lzma_code', ret)
    finally:
        lzma_end(&strm)

    if dstlen < dstsize:
        out = memoryview(out)[:dstlen] if out_given else out[:dstlen]

    return out


def lzma_encode(data, level=None, out=None):
    """Compress LZMA.

    """
    cdef:
        const uint8_t[::1] src = _parse_input(data)
        const uint8_t[::1] dst  # must be const to write to bytes
        ssize_t srcsize = src.size
        ssize_t dstsize
        ssize_t dstlen
        uint32_t preset = _default_level(level, 6, 0, 9)
        lzma_stream strm
        lzma_ret ret = LZMA_OK

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None or out is data:
        if dstsize < 0:
            dstsize = lzma_stream_buffer_bound(srcsize)
            if dstsize == 0:
                raise RuntimeError('lzma_stream_buffer_bound returned 0')
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size

    memset(&strm, 0, sizeof(lzma_stream))
    ret = lzma_easy_encoder(&strm, preset, LZMA_CHECK_CRC64)
    if ret != LZMA_OK:
        raise LzmaError('lzma_easy_encoder', ret)

    try:
        with nogil:
            strm.next_in = &src[0]
            strm.avail_in = <size_t>srcsize
            strm.next_out = <uint8_t*>&dst[0]
            strm.avail_out = <size_t>dstsize
            ret = lzma_code(&strm, LZMA_RUN)
            if ret == LZMA_OK or ret == LZMA_STREAM_END:
                ret = lzma_code(&strm, LZMA_FINISH)
            dstlen = dstsize - <ssize_t>strm.avail_out
        if ret != LZMA_STREAM_END:
            raise LzmaError('lzma_code', ret)
    finally:
        lzma_end(&strm)

    if dstlen < dstsize:
        out = memoryview(out)[:dstlen] if out_given else out[:dstlen]

    return out


# BZ2 #########################################################################

cdef extern from 'bzlib.h':
    int BZ_RUN
    int BZ_FLUSH
    int BZ_FINISH

    int BZ_OK
    int BZ_RUN_OK
    int BZ_FLUSH_OK
    int BZ_FINISH_OK
    int BZ_STREAM_END
    int BZ_SEQUENCE_ERROR
    int BZ_PARAM_ERROR
    int BZ_MEM_ERROR
    int BZ_DATA_ERROR
    int BZ_DATA_ERROR_MAGIC
    int BZ_IO_ERROR
    int BZ_UNEXPECTED_EOF
    int BZ_OUTBUFF_FULL
    int BZ_CONFIG_ERROR

    ctypedef struct bz_stream:
        char *next_in
        unsigned int avail_in
        unsigned int total_in_lo32
        unsigned int total_in_hi32
        char *next_out
        unsigned int avail_out
        unsigned int total_out_lo32
        unsigned int total_out_hi32
        void *state
        void *(*bzalloc)(void *, int, int)
        void (*bzfree)(void *, void *)
        void *opaque

    int BZ2_bzCompressInit(bz_stream* strm,
                           int blockSize100k,
                           int verbosity,
                           int workFactor) nogil

    int BZ2_bzCompress(bz_stream* strm, int action) nogil
    int BZ2_bzCompressEnd(bz_stream* strm) nogil
    int BZ2_bzDecompressInit(bz_stream *strm, int verbosity, int small) nogil
    int BZ2_bzDecompress(bz_stream* strm) nogil
    int BZ2_bzDecompressEnd(bz_stream *strm) nogil
    const char* BZ2_bzlibVersion() nogil


class Bz2Error(RuntimeError):
    """BZ2 Exceptions."""
    def __init__(self, func, err):
        msg = {
            BZ_OK: 'BZ_OK',
            BZ_RUN_OK: 'BZ_RUN_OK',
            BZ_FLUSH_OK: 'BZ_FLUSH_OK',
            BZ_FINISH_OK: 'BZ_FINISH_OK',
            BZ_STREAM_END: 'BZ_STREAM_END',
            BZ_SEQUENCE_ERROR: 'BZ_SEQUENCE_ERROR',
            BZ_PARAM_ERROR: 'BZ_PARAM_ERROR',
            BZ_MEM_ERROR: 'BZ_MEM_ERROR',
            BZ_DATA_ERROR: 'BZ_DATA_ERROR',
            BZ_DATA_ERROR_MAGIC: 'BZ_DATA_ERROR_MAGIC',
            BZ_IO_ERROR: 'BZ_IO_ERROR',
            BZ_UNEXPECTED_EOF: 'BZ_UNEXPECTED_EOF',
            BZ_OUTBUFF_FULL: 'BZ_OUTBUFF_FULL',
            BZ_CONFIG_ERROR: 'BZ_CONFIG_ERROR',
            }.get(err, 'unknown error %i' % err)
        msg = '%s returned %s' % (func, msg)
        RuntimeError.__init__(self, msg)


def bz2_encode(data, level=None, out=None):
    """Compress BZ2.

    """
    cdef:
        const uint8_t[::1] src = _parse_input(data)
        const uint8_t[::1] dst  # must be const to write to bytes
        ssize_t srcsize = src.size
        ssize_t dstsize
        ssize_t dstlen = 0
        int ret = BZ_OK
        bz_stream strm
        int compresslevel = _default_level(level, 9, 1, 9)

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None and dstsize < 0:
        # use Python's bz2 module
        import bz2
        return bz2.compress(data, compresslevel)

    if out is None or out is data:
        if dstsize < 0:
            raise ValueError('invalid output')
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size

    memset(&strm, 0, sizeof(bz_stream))
    ret = BZ2_bzCompressInit(&strm, compresslevel, 0, 0)
    if ret != BZ_OK:
        raise Bz2Error('BZ2_bzCompressInit', ret)

    try:
        with nogil:
            strm.next_in = <char *>&src[0]
            strm.avail_in = <unsigned int>srcsize
            strm.next_out = <char *>&dst[0]
            strm.avail_out = <unsigned int>dstsize
            # while True
            ret = BZ2_bzCompress(&strm, BZ_FINISH)
            #    if ret == BZ_STREAM_END:
            #        break
            #    elif ret != BZ_OK:
            #        break
            dstlen = dstsize - <ssize_t>strm.avail_out
        if ret != BZ_STREAM_END:
            raise Bz2Error('BZ2_bzCompress', ret)
    finally:
        ret = BZ2_bzCompressEnd(&strm)

    if dstlen < dstsize:
        out = memoryview(out)[:dstlen] if out_given else out[:dstlen]

    return out


def bz2_decode(data, out=None):
    """Decompress BZ2.

    """
    cdef:
        const uint8_t[::1] src = data
        const uint8_t[::1] dst  # must be const to write to bytes
        ssize_t srcsize = src.size
        ssize_t dstsize
        ssize_t dstlen = 0
        int ret = BZ_OK
        bz_stream strm

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None and dstsize < 0:
        # use Python's bz2 module
        import bz2
        return bz2.decompress(data)

    if out is None or out is data:
        if dstsize < 0:
            raise ValueError('invalid output')
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size

    memset(&strm, 0, sizeof(bz_stream))
    ret = BZ2_bzDecompressInit(&strm, 0, 0)
    if ret != BZ_OK:
        raise Bz2Error('BZ2_bzDecompressInit', ret)

    try:
        with nogil:
            strm.next_in = <char *>&src[0]
            strm.avail_in = <unsigned int>srcsize
            strm.next_out = <char *>&dst[0]
            strm.avail_out = <unsigned int>dstsize
            ret = BZ2_bzDecompress(&strm)
            dstlen = dstsize - <ssize_t>strm.avail_out
        if ret == BZ_OK:
            pass  # output buffer too small
        elif ret != BZ_STREAM_END:
            raise Bz2Error('BZ2_bzDecompress', ret)
    finally:
        ret = BZ2_bzDecompressEnd(&strm)

    if dstlen < dstsize:
        out = memoryview(out)[:dstlen] if out_given else out[:dstlen]

    return out


# Blosc #######################################################################

cdef extern from 'blosc.h':
    char* BLOSC_VERSION_STRING

    int BLOSC_MAX_OVERHEAD
    int BLOSC_NOSHUFFLE
    int BLOSC_SHUFFLE
    int BLOSC_BITSHUFFLE

    int blosc_compress_ctx(int clevel,
                           int doshuffle,
                           size_t typesize,
                           size_t nbytes,
                           const void* src,
                           void* dest,
                           size_t destsize,
                           const char* compressor,
                           size_t blocksize,
                           int numinternalthreads) nogil

    int blosc_decompress_ctx(const void *src,
                             void *dest,
                             size_t destsize,
                             int numinternalthreads) nogil

    void blosc_cbuffer_sizes(const void *cbuffer,
                             size_t *nbytes,
                             size_t *cbytes,
                             size_t *blocksize) nogil

    int blosc_get_blocksize() nogil


def blosc_decode(data, numthreads=1, out=None):
    """Decode Blosc.

    """
    cdef:
        const uint8_t[::1] src = data
        const uint8_t[::1] dst  # must be const to write to bytes
        ssize_t dstsize
        ssize_t srcsize = <unsigned int>src.size
        size_t nbytes, cbytes, blocksize
        int numinternalthreads = numthreads
        int ret = 0

    if data is out:
        raise ValueError('cannot decode in-place')

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None:
        if dstsize < 0:
            blosc_cbuffer_sizes(<const void *>&src[0],
                                &nbytes, &cbytes, &blocksize)
            if nbytes == 0 and blocksize == 0:
                raise RuntimeError('invalid blosc data')
            dstsize = <ssize_t>nbytes
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size

    with nogil:
        ret = blosc_decompress_ctx(<const void *>&src[0], <void *>&dst[0],
                                   dstsize, numinternalthreads)
    if ret < 0:
        raise RuntimeError('blosc_decompress_ctx returned %i' % ret)

    if ret < dstsize:
        out = memoryview(out)[:ret] if out_given else out[:ret]

    return out


def blosc_encode(data, level=None, compressor='blosclz', typesize=8,
                 blocksize=0, shuffle=None, numthreads=1, out=None):
    """Encode Blosc.

    """
    cdef:
        const uint8_t[::1] src = _parse_input(data)
        const uint8_t[::1] dst  # must be const to write to bytes
        ssize_t srcsize = src.size
        ssize_t dstsize
        size_t blocksize_ = blocksize
        size_t typesize_ = typesize
        char* compressor_ = NULL
        int clevel = _default_level(level, 9, 0, 9)
        int doshuffle = BLOSC_SHUFFLE
        int numinternalthreads = numthreads
        int ret = 0

    if data is out:
        raise ValueError('cannot encode in-place')

    compressor = compressor.encode('utf-8')
    compressor_ = compressor

    if shuffle is not None:
        if shuffle == 'noshuffle' or shuffle == BLOSC_NOSHUFFLE:
            doshuffle = BLOSC_NOSHUFFLE
        elif shuffle == 'bitshuffle' or shuffle == BLOSC_BITSHUFFLE:
            doshuffle = BLOSC_BITSHUFFLE
        else:
            doshuffle = BLOSC_SHUFFLE

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None:
        if dstsize < 0:
            dstsize = srcsize + BLOSC_MAX_OVERHEAD
        if dstsize < 17:
            dstsize = 17
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size

    with nogil:
        ret = blosc_compress_ctx(clevel, doshuffle, typesize_,
                                 <size_t>srcsize, <const void *>&src[0],
                                 <void *>&dst[0], <size_t>dstsize,
                                 <const char*>compressor_, blocksize_,
                                 numinternalthreads)
    if ret <= 0:
        raise RuntimeError('blosc_compress_ctx returned %i' % ret)

    if ret < dstsize:
        out = memoryview(out)[:ret] if out_given else out[:ret]

    return out


# PNG #########################################################################

cdef extern from 'png.h':

    char* PNG_LIBPNG_VER_STRING
    int PNG_COLOR_TYPE_GRAY
    int PNG_COLOR_TYPE_PALETTE
    int PNG_COLOR_TYPE_RGB
    int PNG_COLOR_TYPE_RGB_ALPHA
    int PNG_COLOR_TYPE_GRAY_ALPHA
    int PNG_INTERLACE_NONE
    int PNG_COMPRESSION_TYPE_DEFAULT
    int PNG_FILTER_TYPE_DEFAULT
    int PNG_ZBUF_SIZE

    ctypedef struct png_struct:
        pass

    ctypedef struct png_info:
        pass

    ctypedef size_t png_size_t
    ctypedef unsigned int png_uint_32
    ctypedef unsigned char* png_bytep
    ctypedef unsigned char* png_const_bytep
    ctypedef unsigned char** png_bytepp
    ctypedef char* png_charp
    ctypedef char* png_const_charp
    ctypedef void* png_voidp
    ctypedef png_struct* png_structp
    ctypedef png_struct* png_structrp
    ctypedef png_struct* png_const_structp
    ctypedef png_struct* png_const_structrp
    ctypedef png_struct** png_structpp
    ctypedef png_info* png_infop
    ctypedef png_info* png_inforp
    ctypedef png_info* png_const_infop
    ctypedef png_info* png_const_inforp
    ctypedef png_info** png_infopp
    ctypedef void(*png_error_ptr)(png_structp, png_const_charp)
    ctypedef void(*png_rw_ptr)(png_structp, png_bytep, size_t)
    ctypedef void(*png_flush_ptr)(png_structp)
    ctypedef void(*png_read_status_ptr)(png_structp, png_uint_32, int)
    ctypedef void(*png_write_status_ptr)(png_structp, png_uint_32, int)

    int png_sig_cmp(png_const_bytep sig,
                    size_t start,
                    size_t num_to_check) nogil

    void png_set_sig_bytes(png_structrp png_ptr, int num_bytes) nogil

    png_uint_32 png_get_IHDR(png_const_structrp png_ptr,
                             png_const_inforp info_ptr,
                             png_uint_32 *width,
                             png_uint_32 *height,
                             int *bit_depth,
                             int *color_type,
                             int *interlace_method,
                             int *compression_method,
                             int *filter_method) nogil

    void png_set_IHDR(png_const_structrp png_ptr,
                      png_inforp info_ptr,
                      png_uint_32 width,
                      png_uint_32 height,
                      int bit_depth,
                      int color_type,
                      int interlace_method,
                      int compression_method,
                      int filter_method) nogil

    void png_read_row(png_structrp png_ptr,
                      png_bytep row,
                      png_bytep display_row) nogil

    void png_write_row(png_structrp png_ptr, png_const_bytep row) nogil
    void png_read_image(png_structrp png_ptr, png_bytepp image) nogil
    void png_write_image(png_structrp png_ptr, png_bytepp image) nogil
    png_infop png_create_info_struct(const png_const_structrp png_ptr) nogil

    png_structp png_create_write_struct(png_const_charp user_png_ver,
                                        png_voidp error_ptr,
                                        png_error_ptr error_fn,
                                        png_error_ptr warn_fn) nogil

    png_structp png_create_read_struct(png_const_charp user_png_ver,
                                       png_voidp error_ptr,
                                       png_error_ptr error_fn,
                                       png_error_ptr warn_fn) nogil

    void png_destroy_write_struct(png_structpp png_ptr_ptr,
                                  png_infopp info_ptr_ptr) nogil

    void png_destroy_read_struct(png_structpp png_ptr_ptr,
                                 png_infopp info_ptr_ptr,
                                 png_infopp end_info_ptr_ptr) nogil

    void png_set_write_fn(png_structrp png_ptr,
                          png_voidp io_ptr,
                          png_rw_ptr write_data_fn,
                          png_flush_ptr output_flush_fn) nogil

    void png_set_read_fn(png_structrp png_ptr,
                         png_voidp io_ptr,
                         png_rw_ptr read_data_fn) nogil

    png_voidp png_get_io_ptr(png_const_structrp png_ptr) nogil
    void png_set_palette_to_rgb(png_structrp png_ptr) nogil
    void png_set_expand_gray_1_2_4_to_8(png_structrp png_ptr) nogil
    void png_read_info(png_structrp png_ptr, png_inforp info_ptr) nogil
    void png_write_info(png_structrp png_ptr, png_const_inforp info_ptr) nogil
    void png_write_end(png_structrp png_ptr, png_inforp info_ptr) nogil
    void png_read_update_info(png_structrp png_ptr, png_inforp info_ptr) nogil
    void png_set_expand_16(png_structrp png_ptr) nogil
    void png_set_swap(png_structrp png_ptr) nogil
    void png_set_compression_level(png_structrp png_ptr, int level) nogil


cdef void png_error_callback(png_structp png_ptr,
                             png_const_charp msg) with gil:
    raise RuntimeError(msg.decode('utf8').strip())


cdef void png_warn_callback(png_structp png_ptr,
                            png_const_charp msg) with gil:
    import logging
    logging.warning('PNG %s' % msg.decode('utf8').strip())


ctypedef struct png_memstream_t:
    png_bytep data
    png_size_t size
    png_size_t offset


cdef void png_read_data_fn(png_structp png_ptr,
                           png_bytep dst,
                           png_size_t size) nogil:
    """PNG read callback function."""
    cdef png_memstream_t* memstream = <png_memstream_t*>png_get_io_ptr(png_ptr)
    if memstream == NULL:
        return
    if memstream.offset >= memstream.size:
        return
    if size > memstream.size - memstream.offset:
        # size = memstream.size - memstream.offset
        raise RuntimeError('PNG input stream too small %i' % memstream.size)
    memcpy(<void*>dst, <const void*>&(memstream.data[memstream.offset]), size)
    memstream.offset += size


cdef void png_write_data_fn(png_structp png_ptr,
                            png_bytep src,
                            png_size_t size) nogil:
    """PNG write callback function."""
    cdef png_memstream_t* memstream = <png_memstream_t*>png_get_io_ptr(png_ptr)
    if memstream == NULL:
        return
    if memstream.offset >= memstream.size:
        return
    if size > memstream.size - memstream.offset:
        # size = memstream.size - memstream.offset
        raise RuntimeError('PNG output stream too small %i' % memstream.size)
    memcpy(<void*>&(memstream.data[memstream.offset]), <const void*>src, size)
    memstream.offset += size


cdef void png_output_flush_fn(png_structp png_ptr) nogil:
    """PNG flush callback function."""
    pass


cdef ssize_t png_size_max(ssize_t size):
    """Return upper bound size of PNG stream from uncompressed image size."""
    size += ((size + 7) >> 3) + ((size + 63) >> 6) + 11  # ZLIB compression
    size += 12 * (size / PNG_ZBUF_SIZE + 1)  # IDAT
    size += 8 + 25 + 16 + 44 + 12  # sig IHDR gAMA cHRM IEND
    return size


def png_decode(data, out=None):
    """Decode PNG image to numpy array.

    """
    cdef:
        numpy.ndarray dst
        const uint8_t[::1] src = data
        ssize_t srcsize = src.size * src.itemsize
        int samples = 0
        png_memstream_t memstream
        png_structp png_ptr = NULL
        png_infop info_ptr = NULL
        png_uint_32 ret = 0
        png_uint_32 width = 0
        png_uint_32 height = 0
        png_uint_32 row
        int bit_depth = 0
        int color_type = -1
        png_bytepp image = NULL  # row pointers
        png_bytep rowptr
        ssize_t rowstride

    if data is out:
        raise ValueError('cannot decode in-place')

    if png_sig_cmp(&src[0], 0, 8) != 0:
        raise ValueError('not a PNG image')

    try:
        with nogil:
            memstream.data = <png_bytep>&src[0]
            memstream.size = srcsize
            memstream.offset = 8

            png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL,
                                             png_error_callback,
                                             png_warn_callback)
            if png_ptr == NULL:
                raise RuntimeError('png_create_read_struct returned NULL')

            info_ptr = png_create_info_struct(png_ptr)
            if info_ptr == NULL:
                raise RuntimeError('png_create_info_struct returned NULL')

            png_set_read_fn(png_ptr, <png_voidp>&memstream, png_read_data_fn)
            png_set_sig_bytes(png_ptr, 8)
            png_read_info(png_ptr, info_ptr)
            ret = png_get_IHDR(png_ptr, info_ptr,
                               &width, &height, &bit_depth, &color_type,
                               NULL, NULL, NULL)
            if ret != 1:
                raise RuntimeError('png_get_IHDR returned %i' % ret)

            if bit_depth > 8:
                png_set_swap(png_ptr)

            if color_type == PNG_COLOR_TYPE_GRAY:
                samples = 1
                if bit_depth < 8:
                    png_set_expand_gray_1_2_4_to_8(png_ptr)
            elif color_type == PNG_COLOR_TYPE_GRAY_ALPHA:
                samples = 2
            elif color_type == PNG_COLOR_TYPE_RGB:
                samples = 3
            elif color_type == PNG_COLOR_TYPE_PALETTE:
                samples = 3
                png_set_palette_to_rgb(png_ptr)
            elif color_type == PNG_COLOR_TYPE_RGB_ALPHA:
                samples = 4
            else:
                raise ValueError(
                'PNG color type not supported %i' % color_type)

        dtype = numpy.dtype('u%i' % (1 if bit_depth//8 < 2 else 2))
        if samples > 1:
            shape = int(height), int(width), int(samples)
            strides = None, shape[2] * dtype.itemsize, dtype.itemsize
        else:
            shape = int(height), int(width)
            strides = None, dtype.itemsize

        out = _create_array(out, shape, dtype, strides)
        dst = out
        rowptr = <png_bytep>&dst.data[0]
        rowstride = dst.strides[0]

        with nogil:
            image = <png_bytepp>malloc(sizeof(png_bytep) * height)
            if image == NULL:
                raise MemoryError('failed to allocate row pointers')
            for row in range(height):
                image[row] = <png_bytep>rowptr
                rowptr += rowstride
            png_read_update_info(png_ptr, info_ptr)
            png_read_image(png_ptr, image)

    finally:
        if image != NULL:
            free(image)
        if png_ptr != NULL and info_ptr != NULL:
            png_destroy_read_struct(&png_ptr, &info_ptr, NULL)
        elif png_ptr != NULL:
            png_destroy_read_struct(&png_ptr, NULL, NULL)

    return out


def png_encode(data, level=None, out=None):
    """Encode numpy array to PNG image.

    """
    cdef:
        numpy.ndarray src = data
        const uint8_t[::1] dst  # must be const to write to bytes
        ssize_t dstsize
        ssize_t srcsize = src.size * src.itemsize
        ssize_t rowstride = src.strides[0]
        png_bytep rowptr = <png_bytep>&src.data[0]
        int color_type
        int bit_depth = src.itemsize * 8
        int samples = <int>src.shape[2] if src.ndim == 3 else 1
        int compresslevel = _default_level(level, 5, 0, 10)
        png_memstream_t memstream
        png_structp png_ptr = NULL
        png_infop info_ptr = NULL
        png_bytepp image = NULL  # row pointers
        png_uint_32 width = <png_uint_32>src.shape[1]
        png_uint_32 height = <png_uint_32>src.shape[0]
        png_uint_32 row

    if not (data.dtype in (numpy.uint8, numpy.uint16)
            and data.ndim in (2, 3)
            and data.shape[0] < 2**31-1
            and data.shape[1] < 2**31-1
            and samples <= 4
            and data.strides[data.ndim-1] == data.itemsize
            and (data.ndim == 2 or data.strides[1] == samples*data.itemsize)):
        raise ValueError('invalid input shape, strides, or dtype')

    if data is out:
        raise ValueError('cannot encode in-place')

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None:
        if dstsize < 0:
            dstsize = png_size_max(srcsize)
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size * dst.itemsize

    try:
        with nogil:

            memstream.data = <png_bytep>&dst[0]
            memstream.size = <png_size_t>dstsize
            memstream.offset = 0

            if samples == 1:
                color_type = PNG_COLOR_TYPE_GRAY
            elif samples == 2:
                color_type = PNG_COLOR_TYPE_GRAY_ALPHA
            elif samples == 3:
                color_type = PNG_COLOR_TYPE_RGB
            elif samples == 4:
                color_type = PNG_COLOR_TYPE_RGB_ALPHA
            else:
                raise ValueError('PNG color type not supported')

            png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL,
                                              png_error_callback,
                                              png_warn_callback)
            if png_ptr == NULL:
                raise RuntimeError('png_create_write_struct returned NULL')

            png_set_write_fn(png_ptr, <png_voidp>&memstream,
                             png_write_data_fn, png_output_flush_fn)

            info_ptr = png_create_info_struct(png_ptr)
            if info_ptr == NULL:
                raise RuntimeError('png_create_info_struct returned NULL')

            png_set_IHDR(png_ptr, info_ptr,
                         width, height, bit_depth, color_type,
                         PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT,
                         PNG_FILTER_TYPE_DEFAULT)

            png_write_info(png_ptr, info_ptr)
            png_set_compression_level(png_ptr, compresslevel)
            if bit_depth > 8:
                png_set_swap(png_ptr)

            image = <png_bytepp>malloc(sizeof(png_bytep) * height)
            if image == NULL:
                raise MemoryError('failed to allocate row pointers')
            for row in range(height):
                image[row] = rowptr
                rowptr += rowstride

            png_write_image(png_ptr, image)
            png_write_end(png_ptr, info_ptr)

    finally:
        if image != NULL:
            free(image)
        if png_ptr != NULL and info_ptr != NULL:
            png_destroy_write_struct(&png_ptr, &info_ptr)
        elif png_ptr != NULL:
            png_destroy_write_struct(&png_ptr, NULL)

    if memstream.offset < <png_size_t>dstsize:
        if out_given:
            out = memoryview(out)[:memstream.offset]
        else:
            out = out[:memstream.offset]

    return out


# WebP ########################################################################

cdef extern from 'webp/decode.h':

    ctypedef enum VP8StatusCode:
        VP8_STATUS_OK
        VP8_STATUS_OUT_OF_MEMORY
        VP8_STATUS_INVALID_PARAM
        VP8_STATUS_BITSTREAM_ERROR
        VP8_STATUS_UNSUPPORTED_FEATURE
        VP8_STATUS_SUSPENDED
        VP8_STATUS_USER_ABORT
        VP8_STATUS_NOT_ENOUGH_DATA

    ctypedef struct WebPBitstreamFeatures:
        int width
        int height
        int has_alpha
        int has_animation
        int format
        uint32_t[5] pad

    int WebPGetDecoderVersion() nogil

    int WebPGetInfo(const uint8_t* data,
                    size_t data_size,
                    int* width,
                    int* height) nogil

    VP8StatusCode WebPGetFeatures(const uint8_t* data,
                                  size_t data_size,
                                  WebPBitstreamFeatures* features) nogil

    uint8_t* WebPDecodeRGBAInto(const uint8_t* data,
                                size_t data_size,
                                uint8_t* output_buffer,
                                size_t output_buffer_size,
                                int output_stride) nogil

    uint8_t* WebPDecodeRGBInto(const uint8_t* data,
                               size_t data_size,
                               uint8_t* output_buffer,
                               size_t output_buffer_size,
                               int output_stride) nogil

    uint8_t* WebPDecodeYUVInto(const uint8_t* data,
                               size_t data_size,
                               uint8_t* luma,
                               size_t luma_size,
                               int luma_stride,
                               uint8_t* u,
                               size_t u_size,
                               int u_stride,
                               uint8_t* v,
                               size_t v_size,
                               int v_stride) nogil

cdef extern from 'webp/encode.h':

    int WEBP_MAX_DIMENSION

    int WebPGetEncoderVersion() nogil
    void WebPFree(void* ptr) nogil

    size_t WebPEncodeRGB(const uint8_t* rgb,
                         int width,
                         int height,
                         int stride,
                         float quality_factor,
                         uint8_t** output) nogil

    size_t WebPEncodeRGBA(const uint8_t* rgba,
                          int width,
                          int height,
                          int stride,
                          float quality_factor,
                          uint8_t** output) nogil

    size_t WebPEncodeLosslessRGB(const uint8_t* rgb,
                                 int width,
                                 int height,
                                 int stride,
                                 uint8_t** output) nogil

    size_t WebPEncodeLosslessRGBA(const uint8_t* rgba,
                                  int width,
                                  int height,
                                  int stride,
                                  uint8_t** output) nogil


class WebpError(RuntimeError):
    """WebP Exceptions."""
    def __init__(self, func, err):
        msg = {
            VP8_STATUS_OK: 'VP8_STATUS_OK',
            VP8_STATUS_OUT_OF_MEMORY: 'VP8_STATUS_OUT_OF_MEMORY',
            VP8_STATUS_INVALID_PARAM: 'VP8_STATUS_INVALID_PARAM',
            VP8_STATUS_BITSTREAM_ERROR: 'VP8_STATUS_BITSTREAM_ERROR',
            VP8_STATUS_UNSUPPORTED_FEATURE: 'VP8_STATUS_UNSUPPORTED_FEATURE',
            VP8_STATUS_SUSPENDED: 'VP8_STATUS_SUSPENDED',
            VP8_STATUS_USER_ABORT: 'VP8_STATUS_USER_ABORT',
            VP8_STATUS_NOT_ENOUGH_DATA: 'VP8_STATUS_NOT_ENOUGH_DATA',
            }.get(err, 'unknown error %i' % err)
        msg = '%s returned %s' % (func, msg)
        RuntimeError.__init__(self, msg)


def webp_encode(data, level=None, out=None):
    """Encode numpy array to WebP image.

    """
    cdef:
        const uint8_t[:, :, :] src = data
        const uint8_t[::1] dst  # must be const to write to bytes
        uint8_t* srcptr = <uint8_t*>&src[0, 0, 0]
        uint8_t* output
        ssize_t dstsize
        size_t ret = 0
        int width, height, stride
        float quality_factor = _default_level(level, 75.0, -1.0, 100.0)
        int lossless = quality_factor < 0.0
        int rgba = data.shape[2] == 4

    if not (data.ndim == 3
            and data.shape[0] < WEBP_MAX_DIMENSION
            and data.shape[1] < WEBP_MAX_DIMENSION
            and data.shape[2] in (3, 4)
            and data.strides[2] == 1
            and data.strides[1] in (3, 4)
            and data.strides[0] >= data.strides[1] * data.strides[2]
            and data.dtype == numpy.uint8):
        raise ValueError('invalid input shape, strides, or dtype')

    height, width = data.shape[:2]
    stride = data.strides[0]

    with nogil:
        if lossless:
            if rgba:
                ret = WebPEncodeLosslessRGBA(
                    <const uint8_t*>srcptr, width, height, stride, &output)
            else:
                ret = WebPEncodeLosslessRGB(
                    <const uint8_t*>srcptr, width, height, stride, &output)
        elif rgba:
            ret = WebPEncodeRGBA(
                <const uint8_t*>srcptr, width, height, stride, quality_factor,
                &output)
        else:
            ret = WebPEncodeRGB(
                <const uint8_t*>srcptr, width, height, stride, quality_factor,
                &output)

    if ret <= 0:
        raise RuntimeError('WebPEncode returned 0')

    if data is out:
        raise ValueError('cannot encode in-place')

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None:
        if dstsize < 0:
            dstsize = ret
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size
    if <size_t>dstsize < ret:
        raise ValueError('output too small')

    with nogil:
        memcpy(<void*>&dst[0], <const void*>output, ret)
        WebPFree(<void*>output)

    if ret < <size_t>dstsize:
        out = memoryview(out)[:ret] if out_given else out[:ret]

    return out


def webp_decode(data, out=None):
    """Decode WebP image to numpy array.

    """
    cdef:
        numpy.ndarray dst
        const uint8_t[::1] src = data
        ssize_t srcsize = src.size
        ssize_t dstsize
        int output_stride
        size_t data_size
        WebPBitstreamFeatures features
        int ret = VP8_STATUS_OK
        uint8_t* pout

    if data is out:
        raise ValueError('cannot decode in-place')

    ret = <int>WebPGetFeatures(&src[0], <size_t>srcsize, &features)
    if ret != VP8_STATUS_OK:
        raise WebpError('WebPGetFeatures', ret)

    if features.has_alpha:
        shape = features.height, features.width, 4
    else:
        shape = features.height, features.width, 3

    out = _create_array(out, shape, numpy.uint8, strides=(None, shape[2], 1))
    dst = out
    dstsize = dst.shape[0] * dst.strides[0]
    output_stride = <int>dst.strides[0]

    with nogil:
        if features.has_alpha:
            pout = WebPDecodeRGBAInto(&src[0],
                                      <size_t> srcsize,
                                      <uint8_t*> dst.data,
                                      <size_t> dstsize,
                                      output_stride)
        else:
            pout = WebPDecodeRGBInto(&src[0],
                                     <size_t> srcsize,
                                     <uint8_t*> dst.data,
                                     <size_t> dstsize,
                                     output_stride)
    if pout == NULL:
        raise RuntimeError('WebPDecodeRGBAInto returned NULL')

    return out


# JPEG 8-bit ##################################################################

cdef extern from 'jpeglib.h':
    int JPEG_LIB_VERSION
    int LIBJPEG_TURBO_VERSION
    int LIBJPEG_TURBO_VERSION_NUMBER

    ctypedef void noreturn_t
    ctypedef int boolean
    ctypedef char JOCTET
    ctypedef unsigned int JDIMENSION
    ctypedef unsigned short JSAMPLE
    ctypedef JSAMPLE* JSAMPROW
    ctypedef JSAMPROW* JSAMPARRAY

    ctypedef enum J_COLOR_SPACE:
        JCS_UNKNOWN
        JCS_GRAYSCALE
        JCS_RGB
        JCS_YCbCr
        JCS_CMYK
        JCS_YCCK
        JCS_EXT_RGB
        JCS_EXT_RGBX
        JCS_EXT_BGR
        JCS_EXT_BGRX
        JCS_EXT_XBGR
        JCS_EXT_XRGB
        JCS_EXT_RGBA
        JCS_EXT_BGRA
        JCS_EXT_ABGR
        JCS_EXT_ARGB
        JCS_RGB565

    ctypedef enum J_DITHER_MODE:
        JDITHER_NONE
        JDITHER_ORDERED
        JDITHER_FS

    ctypedef enum J_DCT_METHOD:
        JDCT_ISLOW
        JDCT_IFAST
        JDCT_FLOAT

    struct jpeg_source_mgr:
        pass

    struct jpeg_destination_mgr:
        pass

    struct jpeg_error_mgr:
        int msg_code
        const char** jpeg_message_table
        noreturn_t error_exit(jpeg_common_struct*)
        void output_message(jpeg_common_struct*)

    struct jpeg_common_struct:
        jpeg_error_mgr* err

    struct jpeg_component_info:
        int component_id
        int component_index
        int h_samp_factor
        int v_samp_factor

    struct jpeg_decompress_struct:
        jpeg_error_mgr* err
        void* client_data
        jpeg_source_mgr* src
        JDIMENSION image_width
        JDIMENSION image_height
        JDIMENSION output_width
        JDIMENSION output_height
        JDIMENSION output_scanline
        J_COLOR_SPACE jpeg_color_space
        J_COLOR_SPACE out_color_space
        J_DCT_METHOD dct_method
        J_DITHER_MODE dither_mode
        boolean buffered_image
        boolean raw_data_out
        boolean do_fancy_upsampling
        boolean do_block_smoothing
        boolean quantize_colors
        boolean two_pass_quantize
        unsigned int scale_num
        unsigned int scale_denom
        int num_components
        int out_color_components
        int output_components
        int rec_outbuf_height
        int desired_number_of_colors
        int actual_number_of_colors
        int data_precision
        double output_gamma

    struct jpeg_compress_struct:
        jpeg_error_mgr* err
        void* client_data
        jpeg_destination_mgr *dest
        JDIMENSION image_width
        JDIMENSION image_height
        int input_components
        J_COLOR_SPACE in_color_space
        J_COLOR_SPACE jpeg_color_space
        double input_gamma
        int data_precision
        int num_components
        int smoothing_factor
        boolean optimize_coding
        JDIMENSION next_scanline
        boolean progressive_mode
        jpeg_component_info *comp_info
        # JPEG_LIB_VERSION >= 70
        # unsigned int scale_num
        # unsigned int scale_denom
        # JDIMENSION jpeg_width
        # JDIMENSION jpeg_height
        # boolean do_fancy_downsampling

    jpeg_error_mgr* jpeg_std_error(jpeg_error_mgr*) nogil

    void jpeg_create_decompress(jpeg_decompress_struct*) nogil

    void jpeg_destroy_decompress(jpeg_decompress_struct*) nogil

    int jpeg_read_header(jpeg_decompress_struct*, boolean) nogil

    boolean jpeg_start_decompress(jpeg_decompress_struct*) nogil

    boolean jpeg_finish_decompress(jpeg_decompress_struct*) nogil

    JDIMENSION jpeg_read_scanlines(jpeg_decompress_struct*,
                                   JSAMPARRAY,
                                   JDIMENSION) nogil

    void jpeg_mem_src(jpeg_decompress_struct*,
                      unsigned char*,
                      unsigned long) nogil

    void jpeg_mem_dest(jpeg_compress_struct*,
                       unsigned char**,
                       unsigned long*) nogil

    void jpeg_create_compress(jpeg_compress_struct*) nogil

    void jpeg_destroy_compress(jpeg_compress_struct*) nogil

    void jpeg_set_defaults(jpeg_compress_struct*) nogil

    void jpeg_set_quality(jpeg_compress_struct*, int, boolean) nogil

    void jpeg_start_compress(jpeg_compress_struct*, boolean) nogil

    void jpeg_finish_compress(jpeg_compress_struct* cinfo) nogil

    JDIMENSION jpeg_write_scanlines(jpeg_compress_struct*,
                                    JSAMPARRAY,
                                    JDIMENSION) nogil


ctypedef struct my_error_mgr:
    jpeg_error_mgr pub
    jmp_buf setjmp_buffer


cdef void my_error_exit(jpeg_common_struct* cinfo):
    cdef my_error_mgr* error = <my_error_mgr*> deref(cinfo).err
    longjmp(deref(error).setjmp_buffer, 1)


cdef void my_output_message(jpeg_common_struct* cinfo):
    pass


def _jcs_colorspace(colorspace):
    """Return JCS colorspace value from user input."""
    return {
        'GRAY': JCS_GRAYSCALE,
        'GRAYSCALE': JCS_GRAYSCALE,
        'MINISWHITE': JCS_GRAYSCALE,
        'MINISBLACK': JCS_GRAYSCALE,
        'RGB': JCS_RGB,
        'RGBA': JCS_EXT_RGBA,
        'CMYK': JCS_CMYK,
        'YCCK': JCS_YCCK,
        'YCBCR': JCS_YCbCr,
        'UNKNOWN': JCS_UNKNOWN,
        None: JCS_UNKNOWN,
        JCS_UNKNOWN: JCS_UNKNOWN,
        JCS_GRAYSCALE: JCS_GRAYSCALE,
        JCS_RGB: JCS_RGB,
        JCS_YCbCr: JCS_YCbCr,
        JCS_CMYK: JCS_CMYK,
        JCS_YCCK: JCS_YCCK,
        JCS_EXT_RGB: JCS_EXT_RGB,
        JCS_EXT_RGBX: JCS_EXT_RGBX,
        JCS_EXT_BGR: JCS_EXT_BGR,
        JCS_EXT_BGRX: JCS_EXT_BGRX,
        JCS_EXT_XBGR: JCS_EXT_XBGR,
        JCS_EXT_XRGB: JCS_EXT_XRGB,
        JCS_EXT_RGBA: JCS_EXT_RGBA,
        JCS_EXT_BGRA: JCS_EXT_BGRA,
        JCS_EXT_ABGR: JCS_EXT_ABGR,
        JCS_EXT_ARGB: JCS_EXT_ARGB,
        JCS_RGB565: JCS_RGB565,
        }.get(colorspace, JCS_UNKNOWN)


def _jcs_colorspace_samples(colorspace):
    """Return expected number of samples in colorspace."""
    three = (3,)
    four = (4,)
    return {
        JCS_UNKNOWN: (1, 2, 3, 4),
        JCS_GRAYSCALE: (1,),
        JCS_RGB: three,
        JCS_YCbCr: three,
        JCS_CMYK: four,
        JCS_YCCK: four,
        JCS_EXT_RGB: three,
        JCS_EXT_RGBX: four,
        JCS_EXT_BGR: three,
        JCS_EXT_BGRX: four,
        JCS_EXT_XBGR: four,
        JCS_EXT_XRGB: four,
        JCS_EXT_RGBA: four,
        JCS_EXT_BGRA: four,
        JCS_EXT_ABGR: four,
        JCS_EXT_ARGB: four,
        JCS_RGB565: three,
        }[colorspace]


class Jpeg8Error(RuntimeError):
    """JPEG Exceptions."""


def jpeg8_encode(data, level=None, colorspace=None, outcolorspace=None,
                 subsampling=None, optimize=None, smoothing=None, out=None):
    """Return JPEG 8-bit image from numpy array.

    """
    cdef:
        numpy.ndarray src = data
        const uint8_t[::1] dst  # must be const to write to bytes
        ssize_t dstsize
        ssize_t srcsize = src.size * src.itemsize
        ssize_t rowstride = src.strides[0]
        int samples = <int>src.shape[2] if src.ndim == 3 else 1
        int quality = _default_level(level, 90, 0, 100)
        my_error_mgr err
        jpeg_compress_struct cinfo
        JSAMPROW rowpointer
        J_COLOR_SPACE in_color_space = JCS_UNKNOWN
        J_COLOR_SPACE jpeg_color_space = JCS_UNKNOWN
        unsigned long outsize = 0
        unsigned char* outbuffer = NULL
        const char* msg
        int h_samp_factor = 0
        int v_samp_factor = 0
        int smoothing_factor = _default_level(smoothing, -1, 0, 100)
        int optimize_coding = -1 if optimize is None else 1 if optimize else 0

    if data is out:
        raise ValueError('cannot encode in-place')

    if not (data.dtype == numpy.uint8
            and data.ndim in (2, 3)
            # and data.size * data.itemsize < 2**31-1  # limit to 2 GB
            and samples in (1, 3, 4)
            and data.strides[data.ndim-1] == data.itemsize
            and (data.ndim == 2 or data.strides[1] == samples*data.itemsize)):
        raise ValueError('invalid input shape, strides, or dtype')

    if colorspace is None:
        if samples == 1:
            in_color_space = JCS_GRAYSCALE
        elif samples == 3:
            in_color_space = JCS_RGB
        # elif samples == 4:
        #     in_color_space = JCS_CMYK
        else:
            in_color_space = JCS_UNKNOWN
    else:
        in_color_space = _jcs_colorspace(colorspace)
        if samples not in _jcs_colorspace_samples(in_color_space):
            raise ValueError('invalid input shape')

    jpeg_color_space = _jcs_colorspace(outcolorspace)

    if jpeg_color_space == JCS_YCbCr and subsampling is not None:
        if subsampling in ('444', (1, 1)):
            h_samp_factor = 1
            v_samp_factor = 1
        elif subsampling in ('422', (2, 1)):
            h_samp_factor = 2
            v_samp_factor = 1
        elif subsampling in ('420', (2, 2)):
            h_samp_factor = 2
            v_samp_factor = 2
        elif subsampling in ('411', (4, 1)):
            h_samp_factor = 4
            v_samp_factor = 1
        elif subsampling in ('440', (1, 2)):
            h_samp_factor = 1
            v_samp_factor = 2
        else:
            raise ValueError('invalid subsampling')

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None and dstsize > 0:
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    if out is not None:
        dst = out
        dstsize = dst.size * dst.itemsize
        outsize = <unsigned long>dstsize
        outbuffer = <unsigned char*>&dst[0]

    with nogil:
        cinfo.err = jpeg_std_error(&err.pub)
        err.pub.error_exit = my_error_exit
        err.pub.output_message = my_output_message

        if setjmp(err.setjmp_buffer):
            jpeg_destroy_compress(&cinfo)
            msg = err.pub.jpeg_message_table[err.pub.msg_code]
            raise Jpeg8Error(msg.decode('utf-8'))

        jpeg_create_compress(&cinfo)

        cinfo.image_height = <JDIMENSION>src.shape[0]
        cinfo.image_width = <JDIMENSION>src.shape[1]
        cinfo.input_components = samples

        if in_color_space != JCS_UNKNOWN:
            cinfo.in_color_space = in_color_space
        if jpeg_color_space != JCS_UNKNOWN:
            cinfo.jpeg_color_space = jpeg_color_space

        jpeg_set_defaults(&cinfo)
        jpeg_mem_dest(&cinfo, &outbuffer, &outsize)  # must call after defaults
        jpeg_set_quality(&cinfo, quality, 1)

        if smoothing_factor >= 0:
            cinfo.smoothing_factor = smoothing_factor
        if optimize_coding >= 0:
            cinfo.optimize_coding = <boolean>optimize_coding
        if h_samp_factor != 0:
            cinfo.comp_info[0].h_samp_factor = h_samp_factor
            cinfo.comp_info[0].v_samp_factor = v_samp_factor
            cinfo.comp_info[1].h_samp_factor = 1
            cinfo.comp_info[1].v_samp_factor = 1
            cinfo.comp_info[2].h_samp_factor = 1
            cinfo.comp_info[2].v_samp_factor = 1

        # TODO: add option to use or return JPEG tables

        jpeg_start_compress(&cinfo, 1)

        while cinfo.next_scanline < cinfo.image_height:
            rowpointer = <JSAMPROW>(<char*>src.data
                                    + cinfo.next_scanline * rowstride)
            jpeg_write_scanlines(&cinfo, &rowpointer, 1)

        jpeg_finish_compress(&cinfo)
        jpeg_destroy_compress(&cinfo)

    if out is None or outbuffer != <unsigned char*>&dst[0]:
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(<const char*>outbuffer,
                                            <ssize_t>outsize)
        else:
            out = PyByteArray_FromStringAndSize(<const char*>outbuffer,
                                                <ssize_t>outsize)
        free(outbuffer)
    elif outsize < dstsize:
        if out_given:
            out = memoryview(out)[:outsize]
        else:
            out = out[:outsize]

    return out


def jpeg8_decode(data, tables=None, colorspace=None, outcolorspace=None,
                 shape=None, out=None):
    """Decode JPEG 8-bit image to numpy array.

    """
    cdef:
        numpy.ndarray dst
        const uint8_t[::1] src = data
        const uint8_t[::1] tables_
        unsigned long tablesize = 0
        ssize_t srcsize = src.size
        ssize_t dstsize
        ssize_t rowstride
        int numlines
        my_error_mgr err
        jpeg_decompress_struct cinfo
        JSAMPROW rowpointer
        J_COLOR_SPACE jpeg_color_space
        J_COLOR_SPACE out_color_space
        JDIMENSION width = 0
        JDIMENSION height = 0
        const char *msg

    if data is out:
        raise ValueError('cannot decode in-place')

    if srcsize > 2**32-1:
        # limit to 4 GB
        raise ValueError('data too large')

    jpeg_color_space = _jcs_colorspace(colorspace)
    if outcolorspace is None:
        out_color_space = jpeg_color_space
    else:
        out_color_space = _jcs_colorspace(outcolorspace)

    if tables is not None:
        tables_ = tables
        tablesize = tables_.size

    if shape is not None and (shape[0] >= 65500 or shape[1] >= 65500):
        # enable decoding of large (JPEG_MAX_DIMENSION <= 2^20) JPEG
        # when using a patched jibjpeg-turbo
        height = <JDIMENSION>shape[0]
        width = <JDIMENSION>shape[1]

    with nogil:

        cinfo.err = jpeg_std_error(&err.pub)
        err.pub.error_exit = my_error_exit
        err.pub.output_message = my_output_message
        if setjmp(err.setjmp_buffer):
            jpeg_destroy_decompress(&cinfo)
            msg = err.pub.jpeg_message_table[err.pub.msg_code]
            raise Jpeg8Error(msg.decode('utf-8'))

        jpeg_create_decompress(&cinfo)
        cinfo.do_fancy_upsampling = True
        if width > 0:
            cinfo.image_width = width
            cinfo.image_height = height

        if tablesize > 0:
            jpeg_mem_src(&cinfo, &tables_[0], tablesize)
            jpeg_read_header(&cinfo, 0)

        jpeg_mem_src(&cinfo, &src[0], <unsigned long>srcsize)
        jpeg_read_header(&cinfo, 1)

        if jpeg_color_space != JCS_UNKNOWN:
            cinfo.jpeg_color_space = jpeg_color_space
        if out_color_space != JCS_UNKNOWN:
            cinfo.out_color_space = out_color_space

        jpeg_start_decompress(&cinfo)

        with gil:
            # if (cinfo.output_components not in
            #         _jcs_colorspace_samples(out_color_space)):
            #     raise ValueError('invalid output shape')

            shape = cinfo.output_height, cinfo.output_width
            if cinfo.output_components > 1:
                shape += cinfo.output_components,

            out = _create_array(out, shape, numpy.uint8)  # TODO: allow strides
            dst = out
            dstsize = dst.size * dst.itemsize
            rowstride = dst.strides[0]

        memset(<void *>dst.data, 0, dstsize)
        rowpointer = <JSAMPROW>dst.data
        while cinfo.output_scanline < cinfo.output_height:
            jpeg_read_scanlines(&cinfo, &rowpointer, 1)
            rowpointer += rowstride

        jpeg_finish_decompress(&cinfo)
        jpeg_destroy_decompress(&cinfo)

    return out


# JPEG SOF3 ###############################################################

# The "JPEG Lossless, Nonhierarchical, First Order Prediction" format is
# described at <http://www.w3.org/Graphics/JPEG/itu-t81.pdf>.
# The format is identified by a Start of Frame (SOF) code 0xC3.

cdef extern from 'jpeg_sof3.h':

    char* JPEG_SOF3_VERSION
    int JPEG_SOF3_OK
    int JPEG_SOF3_INVALID_OUTPUT
    int JPEG_SOF3_INVALID_SIGNATURE
    int JPEG_SOF3_INVALID_HEADER_TAG
    int JPEG_SOF3_SEGMENT_GT_IMAGE
    int JPEG_SOF3_INVALID_ITU_T81
    int JPEG_SOF3_INVALID_BIT_DEPTH
    int JPEG_SOF3_TABLE_CORRUPTED
    int JPEG_SOF3_TABLE_SIZE_CORRUPTED
    int JPEG_SOF3_INVALID_RESTART_SEGMENTS
    int JPEG_SOF3_NO_TABLE

    int jpeg_sof3_decode(unsigned char *lRawRA,
                         ssize_t lRawSz,
                         unsigned char *lImgRA8,
                         ssize_t lImgSz,
                         int *dimX,
                         int *dimY,
                         int *bits,
                         int *frames) nogil


class JpegSof3Error(RuntimeError):
    """JPEG SOF3 Exceptions."""
    def __init__(self, err):
        msg = {
            JPEG_SOF3_INVALID_OUTPUT:
                'output array is too small',
            JPEG_SOF3_INVALID_SIGNATURE:
                'JPEG signature 0xFFD8FF not found',
            JPEG_SOF3_INVALID_HEADER_TAG:
                'header tag must begin with 0xFF',
            JPEG_SOF3_SEGMENT_GT_IMAGE:
                'segment larger than image',
            JPEG_SOF3_INVALID_ITU_T81:
                'not a lossless (sequential) JPEG image (SoF must be 0xC3)',
            JPEG_SOF3_INVALID_BIT_DEPTH:
                'data must be 2..16 bit, 1..4 frames',
            JPEG_SOF3_TABLE_CORRUPTED:
                'Huffman table corrupted',
            JPEG_SOF3_TABLE_SIZE_CORRUPTED:
                'Huffman size array corrupted',
            JPEG_SOF3_INVALID_RESTART_SEGMENTS:
                'unsupported Restart Segments',
            JPEG_SOF3_NO_TABLE:
                'no Huffman tables',
            }.get(err, 'unknown error %i' % err)
        msg = "jpeg_0x3c_decode returned '%s'" % msg
        RuntimeError.__init__(self, msg)


def jpegsof3_encode(*args, **kwargs):
    """Not implemented."""
    # TODO: JPEG SOF3 encoding
    raise NotImplementedError('jpegsof3_encode')


def jpegsof3_decode(data, out=None):
    """Decode JPEG SOF3 image to numpy array.

    Beware, the input data is modified!

    RGB images are returned as non-contiguous arrays as samples are decoded
    into separate frames first (RRGGBB).

    """
    cdef:
        numpy.ndarray dst
        const uint8_t[::1] src = data
        ssize_t srcsize = src.size
        ssize_t dstsize
        int dimX, dimY, bits, frames
        int ret = JPEG_SOF3_OK

    if data is out:
        raise ValueError('cannot decode in-place')

    with nogil:
        ret = jpeg_sof3_decode(<unsigned char *>&src[0], srcsize,
                               NULL, 0, &dimX, &dimY, &bits, &frames)

    if ret != JPEG_SOF3_OK:
        raise JpegSof3Error(ret)

    if frames > 1:
        shape = frames, dimY, dimX
    else:
        shape = dimY, dimX

    if bits > 8:
        dtype = numpy.uint16
    else:
        dtype = numpy.uint8

    out = _create_array(out, shape, dtype)
    dst = out
    dstsize = dst.size * dst.itemsize

    with nogil:
        ret = jpeg_sof3_decode(<unsigned char *>&src[0], srcsize,
                               <unsigned char *>dst.data, dstsize,
                               &dimX, &dimY, &bits, &frames)

    if ret != JPEG_SOF3_OK:
        raise JpegSof3Error(ret)

    if frames > 1:
        out = numpy.moveaxis(out, 0, -1)

    return out


# JPEG Wrapper ################################################################

def jpeg_decode(data, bitspersample=None, tables=None, colorspace=None,
                outcolorspace=None, shape=None, out=None):
    """Decode JPEG 8-bit, 12-bit, SOF3 or LS.

    """
    if bitspersample is None:
        try:
            return jpeg8_decode(
                data, tables=tables, colorspace=colorspace,
                outcolorspace=outcolorspace, shape=shape, out=out)
        except Jpeg8Error as exception:
            msg = str(exception)
            if 'Empty JPEG image' in msg:
                # TODO: handle Hamamatsu NDPI slides with dimensions > 65500
                raise exception
            if 'Unsupported JPEG data precision' in msg:
                return jpeg12_decode(
                    data, tables=tables, colorspace=colorspace,
                    outcolorspace=outcolorspace, shape=shape, out=out)
            if 'SOF type' in msg:
                return jpegsof3_decode(data, out=out)
            # Unsupported marker type
            return jpegls_decode(data, out=out)
    try:
        if bitspersample == 8:
            return jpeg8_decode(
                data, tables=tables, colorspace=colorspace,
                outcolorspace=outcolorspace, shape=shape, out=out)
        if bitspersample == 12:
            return jpeg12_decode(
                data, tables=tables, colorspace=colorspace,
                outcolorspace=outcolorspace, shape=shape, out=out)
        try:
            return jpegls_decode(data, out=out)
        except Exception:
            return jpegsof3_decode(data, out=out)
    except (Jpeg8Error, Jpeg12Error, NotImplementedError) as exception:
        msg = str(exception)
        if 'Empty JPEG image' in msg:
            raise exception
        if 'SOF type' in msg:
            return jpegsof3_decode(data, out=out)
        return jpegls_decode(data, out=out)


def jpeg_encode(data, level=None, colorspace=None, outcolorspace=None,
                subsampling=None, optimize=None, smoothing=None, out=None):
    """Encode 8-bit or 12-bit JPEG.

    """
    if data.dtype == numpy.uint8:
        func = jpeg8_encode
    elif data.dtype == numpy.uint16:
        func = jpeg12_encode
    else:
        raise ValueError('invalid data dtype %s' % data.dtype)
    return func(data, level=level, colorspace=colorspace,
                outcolorspace=outcolorspace, subsampling=subsampling,
                optimize=optimize, smoothing=smoothing, out=out)


# JPEG 2000 ###################################################################

cdef extern from 'openjpeg.h':
    int OPJ_FALSE = 0
    int OPJ_TRUE = 1

    ctypedef int OPJ_BOOL
    ctypedef char OPJ_CHAR
    ctypedef float OPJ_FLOAT32
    ctypedef double OPJ_FLOAT64
    ctypedef unsigned char OPJ_BYTE
    ctypedef int8_t OPJ_INT8
    ctypedef uint8_t OPJ_UINT8
    ctypedef int16_t OPJ_INT16
    ctypedef uint16_t OPJ_UINT16
    ctypedef int32_t OPJ_INT32
    ctypedef uint32_t OPJ_UINT32
    ctypedef int64_t OPJ_INT64
    ctypedef uint64_t OPJ_UINT64
    ctypedef int64_t OPJ_OFF_T
    ctypedef size_t OPJ_SIZE_T

    ctypedef enum OPJ_CODEC_FORMAT:
        OPJ_CODEC_UNKNOWN
        OPJ_CODEC_J2K
        OPJ_CODEC_JPT
        OPJ_CODEC_JP2
        OPJ_CODEC_JPP
        OPJ_CODEC_JPX

    ctypedef enum OPJ_COLOR_SPACE:
        OPJ_CLRSPC_UNKNOWN
        OPJ_CLRSPC_UNSPECIFIED
        OPJ_CLRSPC_SRGB
        OPJ_CLRSPC_GRAY
        OPJ_CLRSPC_SYCC
        OPJ_CLRSPC_EYCC
        OPJ_CLRSPC_CMYK

    ctypedef struct opj_codec_t:
        pass

    ctypedef struct opj_stream_t:
        pass

    ctypedef struct opj_image_cmptparm_t:
        OPJ_UINT32 dx
        OPJ_UINT32 dy
        OPJ_UINT32 w
        OPJ_UINT32 h
        OPJ_UINT32 x0
        OPJ_UINT32 y0
        OPJ_UINT32 prec
        OPJ_UINT32 bpp
        OPJ_UINT32 sgnd

    ctypedef struct opj_cparameters_t:
        OPJ_BOOL tile_size_on
        int cp_tx0
        int cp_ty0
        int cp_tdx
        int cp_tdy
        int cp_disto_alloc
        int cp_fixed_alloc
        int cp_fixed_quality
        int *cp_matrice
        char *cp_comment
        int csty
        # OPJ_PROG_ORDER prog_order
        # opj_poc_t POC[32]
        OPJ_UINT32 numpocs
        int tcp_numlayers
        float tcp_rates[100]
        float tcp_distoratio[100]
        int numresolution
        int cblockw_init
        int cblockh_init
        int mode
        int irreversible

    ctypedef struct opj_dparameters_t:
        OPJ_UINT32 cp_reduce
        OPJ_UINT32 cp_layer
        # char infile[OPJ_PATH_LEN]
        # char outfile[OPJ_PATH_LEN]
        int decod_format
        int cod_format
        OPJ_UINT32 DA_x0
        OPJ_UINT32 DA_x1
        OPJ_UINT32 DA_y0
        OPJ_UINT32 DA_y1
        OPJ_BOOL m_verbose
        OPJ_UINT32 tile_index
        OPJ_UINT32 nb_tile_to_decode
        OPJ_BOOL jpwl_correct
        int jpwl_exp_comps
        int jpwl_max_tiles
        unsigned int flags

    ctypedef struct opj_image_comp_t:
        OPJ_UINT32 dx
        OPJ_UINT32 dy
        OPJ_UINT32 w
        OPJ_UINT32 h
        OPJ_UINT32 x0
        OPJ_UINT32 y0
        OPJ_UINT32 prec
        OPJ_UINT32 bpp
        OPJ_UINT32 sgnd
        OPJ_UINT32 resno_decoded
        OPJ_UINT32 factor
        OPJ_INT32* data
        OPJ_UINT16 alpha

    ctypedef struct opj_image_t:
        OPJ_UINT32 x0
        OPJ_UINT32 y0
        OPJ_UINT32 x1
        OPJ_UINT32 y1
        OPJ_UINT32 numcomps
        OPJ_COLOR_SPACE color_space
        opj_image_comp_t* comps
        OPJ_BYTE* icc_profile_buf
        OPJ_UINT32 icc_profile_len

    ctypedef OPJ_SIZE_T(* opj_stream_read_fn)(void*, OPJ_SIZE_T, void*)
    ctypedef OPJ_SIZE_T(* opj_stream_write_fn)(void*, OPJ_SIZE_T, void*)
    ctypedef OPJ_OFF_T(* opj_stream_skip_fn)(OPJ_OFF_T, void*)
    ctypedef OPJ_BOOL(* opj_stream_seek_fn)(OPJ_OFF_T, void*)
    ctypedef void(* opj_stream_free_user_data_fn)(void*)
    ctypedef void(*opj_msg_callback)(const char *msg, void *client_data)

    opj_stream_t* opj_stream_default_create(OPJ_BOOL p_is_input) nogil
    opj_codec_t* opj_create_compress(OPJ_CODEC_FORMAT format) nogil
    opj_codec_t* opj_create_decompress(OPJ_CODEC_FORMAT format) nogil
    void opj_destroy_codec(opj_codec_t* p_codec) nogil
    void opj_set_default_encoder_parameters(opj_cparameters_t*) nogil
    void opj_set_default_decoder_parameters(opj_dparameters_t *params) nogil
    void opj_image_destroy(opj_image_t* image) nogil
    void* opj_image_data_alloc(OPJ_SIZE_T size) nogil
    void opj_image_data_free(void* ptr) nogil
    void opj_stream_destroy(opj_stream_t* p_stream) nogil
    void color_sycc_to_rgb(opj_image_t* img) nogil
    void color_apply_icc_profile(opj_image_t* image) nogil
    void color_cielab_to_rgb(opj_image_t* image) nogil
    void color_cmyk_to_rgb(opj_image_t* image) nogil
    void color_esycc_to_rgb(opj_image_t* image) nogil
    const char* opj_version() nogil

    OPJ_BOOL opj_encode(opj_codec_t *p_codec, opj_stream_t *p_stream) nogil

    opj_image_t* opj_image_tile_create(OPJ_UINT32 numcmpts,
                                       opj_image_cmptparm_t *cmptparms,
                                       OPJ_COLOR_SPACE clrspc) nogil

    OPJ_BOOL opj_setup_encoder(opj_codec_t *p_codec,
                               opj_cparameters_t *parameters,
                               opj_image_t *image) nogil

    OPJ_BOOL opj_start_compress(opj_codec_t *p_codec,
                                opj_image_t * p_image,
                                opj_stream_t *p_stream) nogil

    OPJ_BOOL opj_end_compress(opj_codec_t *p_codec,
                              opj_stream_t *p_stream) nogil

    OPJ_BOOL opj_end_decompress(opj_codec_t *p_codec,
                                opj_stream_t *p_stream) nogil

    OPJ_BOOL opj_setup_decoder(opj_codec_t *p_codec,
                               opj_dparameters_t *params) nogil

    OPJ_BOOL opj_codec_set_threads(opj_codec_t *p_codec,
                                   int num_threads) nogil

    OPJ_BOOL opj_read_header(opj_stream_t *p_stream,
                             opj_codec_t *p_codec,
                             opj_image_t **p_image) nogil

    OPJ_BOOL opj_set_decode_area(opj_codec_t *p_codec,
                                 opj_image_t* p_image,
                                 OPJ_INT32 p_start_x,
                                 OPJ_INT32 p_start_y,
                                 OPJ_INT32 p_end_x,
                                 OPJ_INT32 p_end_y) nogil

    OPJ_BOOL opj_set_info_handler(opj_codec_t * p_codec,
                                  opj_msg_callback p_callback,
                                  void * p_user_data) nogil

    OPJ_BOOL opj_set_warning_handler(opj_codec_t * p_codec,
                                     opj_msg_callback p_callback,
                                     void * p_user_data) nogil

    OPJ_BOOL opj_set_error_handler(opj_codec_t * p_codec,
                                   opj_msg_callback p_callback,
                                   void * p_user_data) nogil

    OPJ_BOOL opj_decode(opj_codec_t *p_decompressor,
                        opj_stream_t *p_stream,
                        opj_image_t *p_image) nogil

    opj_image_t* opj_image_create(OPJ_UINT32 numcmpts,
                                  opj_image_cmptparm_t* cmptparms,
                                  OPJ_COLOR_SPACE clrspc) nogil

    void opj_stream_set_read_function(opj_stream_t* p_stream,
                                      opj_stream_read_fn p_func) nogil

    void opj_stream_set_write_function(opj_stream_t* p_stream,
                                       opj_stream_write_fn p_func) nogil

    void opj_stream_set_seek_function(opj_stream_t* p_stream,
                                      opj_stream_seek_fn p_func) nogil

    void opj_stream_set_skip_function(opj_stream_t* p_stream,
                                      opj_stream_skip_fn p_func) nogil

    void opj_stream_set_user_data(opj_stream_t* p_stream,
                                  void* p_data,
                                  opj_stream_free_user_data_fn p_func) nogil

    void opj_stream_set_user_data_length(opj_stream_t* p_stream,
                                         OPJ_UINT64 data_length) nogil

    OPJ_BOOL opj_write_tile(opj_codec_t *p_codec,
                            OPJ_UINT32 p_tile_index,
                            OPJ_BYTE * p_data,
                            OPJ_UINT32 p_data_size,
                            opj_stream_t *p_stream) nogil


cdef extern from 'opj_color.h':
    void color_sycc_to_rgb(opj_image_t *img) nogil
    void color_apply_icc_profile(opj_image_t *image) nogil
    void color_cielab_to_rgb(opj_image_t *image) nogil
    void color_cmyk_to_rgb(opj_image_t *image) nogil
    void color_esycc_to_rgb(opj_image_t *image) nogil


ctypedef struct opj_memstream_t:
    OPJ_UINT8* data
    OPJ_UINT64 size
    OPJ_UINT64 offset
    OPJ_UINT64 written


cdef OPJ_SIZE_T opj_mem_read(void* dst, OPJ_SIZE_T size, void* data) nogil:
    """opj_stream_set_read_function."""
    cdef:
        opj_memstream_t* memstream = <opj_memstream_t*>data
        OPJ_SIZE_T count = size
    if memstream.offset >= memstream.size:
        return <OPJ_SIZE_T>-1
    if size > memstream.size - memstream.offset:
        count = memstream.size - memstream.offset
    memcpy(<void*>dst, <const void*>&(memstream.data[memstream.offset]), count)
    memstream.offset += count
    return count


cdef OPJ_SIZE_T opj_mem_write(void* dst, OPJ_SIZE_T size, void* data) nogil:
    """opj_stream_set_write_function."""
    cdef:
        opj_memstream_t* memstream = <opj_memstream_t*>data
        OPJ_SIZE_T count = size
    if memstream.offset >= memstream.size:
        return <OPJ_SIZE_T>-1
    if size > memstream.size - memstream.offset:
        count = memstream.size - memstream.offset
        memstream.written = memstream.size + 1  # indicates error
    memcpy(<void*>&(memstream.data[memstream.offset]), <const void*>dst, count)
    memstream.offset += count
    if memstream.written < memstream.offset:
        memstream.written = memstream.offset
    return count


cdef OPJ_BOOL opj_mem_seek(OPJ_OFF_T size, void* data) nogil:
    """opj_stream_set_seek_function."""
    cdef:
        opj_memstream_t* memstream = <opj_memstream_t*>data
    if size < 0 or size >= <OPJ_OFF_T>memstream.size:
        return OPJ_FALSE
    memstream.offset = <OPJ_SIZE_T>size
    return OPJ_TRUE


cdef OPJ_OFF_T opj_mem_skip(OPJ_OFF_T size, void* data) nogil:
    """opj_stream_set_skip_function."""
    cdef:
        opj_memstream_t* memstream = <opj_memstream_t*>data
        OPJ_SIZE_T count
    if size < 0:
        return -1
    count = <OPJ_SIZE_T>size
    if count > memstream.size - memstream.offset:
        count = memstream.size - memstream.offset
    memstream.offset += count
    return count


cdef void opj_mem_nop(void* data) nogil:
    """opj_stream_set_user_data."""


cdef opj_stream_t* opj_memstream_create(opj_memstream_t* memstream,
                                        OPJ_BOOL isinput) nogil:
    """Return OPJ stream using memory as input or output."""
    cdef:
        opj_stream_t* stream = opj_stream_default_create(isinput)
    if stream == NULL:
        return NULL
    if isinput:
        opj_stream_set_read_function(stream, <opj_stream_read_fn>opj_mem_read)
    else:
        opj_stream_set_write_function(stream,
                                      <opj_stream_write_fn>opj_mem_write)
    opj_stream_set_seek_function(stream, <opj_stream_seek_fn>opj_mem_seek)
    opj_stream_set_skip_function(stream, <opj_stream_skip_fn>opj_mem_skip)
    opj_stream_set_user_data(stream, memstream,
                             <opj_stream_free_user_data_fn>opj_mem_nop)
    opj_stream_set_user_data_length(stream, memstream.size)
    return stream


class J2KError(RuntimeError):
    """OpenJPEG Exceptions."""
    def __init__(self, msg):
        RuntimeError.__init__(self, 'J2K %s' % msg)


cdef void j2k_error_callback(char* msg, void* client_data) with gil:
    raise J2KError(msg.decode('utf8').strip())


cdef void j2k_warning_callback(char* msg, void* client_data) with gil:
    import logging
    logging.warning('J2K warning: %s' % msg.decode('utf8').strip())


cdef void j2k_info_callback(char* msg, void* client_data) with gil:
    import logging
    logging.warning('J2K info: %s' % msg.decode('utf8').strip())


cdef OPJ_COLOR_SPACE opj_colorspace(colorspace):
    """Return OPJ colorspace value from user input."""
    return {
        'GRAY': OPJ_CLRSPC_GRAY,
        'GRAYSCALE': OPJ_CLRSPC_GRAY,
        'MINISWHITE': OPJ_CLRSPC_GRAY,
        'MINISBLACK': OPJ_CLRSPC_GRAY,
        'RGB': OPJ_CLRSPC_SRGB,
        'SRGB': OPJ_CLRSPC_SRGB,
        'RGBA': OPJ_CLRSPC_SRGB,  # ?
        'CMYK': OPJ_CLRSPC_CMYK,
        'SYCC': OPJ_CLRSPC_SYCC,
        'EYCC': OPJ_CLRSPC_EYCC,
        'UNSPECIFIED': OPJ_CLRSPC_UNSPECIFIED,
        'UNKNOWN': OPJ_CLRSPC_UNSPECIFIED,
        None: OPJ_CLRSPC_UNSPECIFIED,
        OPJ_CLRSPC_UNSPECIFIED: OPJ_CLRSPC_UNSPECIFIED,
        OPJ_CLRSPC_SRGB: OPJ_CLRSPC_SRGB,
        OPJ_CLRSPC_GRAY: OPJ_CLRSPC_GRAY,
        OPJ_CLRSPC_SYCC: OPJ_CLRSPC_SYCC,
        OPJ_CLRSPC_EYCC: OPJ_CLRSPC_EYCC,
        OPJ_CLRSPC_CMYK: OPJ_CLRSPC_CMYK,
        }.get(colorspace, OPJ_CLRSPC_UNSPECIFIED)


def j2k_encode(data, level=None, codecformat=None, colorspace=None, tile=None,
               verbose=0, out=None):
    """Return JPEG 2000 image from numpy array.

    This function is WIP, use at own risk.

    """
    cdef:
        numpy.ndarray src = data
        const uint8_t[::1] dst  # must be const to write to bytes
        ssize_t dstsize
        ssize_t srcsize = src.size * src.itemsize
        ssize_t byteswritten

        opj_memstream_t memstream
        opj_codec_t *codec = NULL
        opj_image_t *image = NULL
        opj_stream_t* stream = NULL
        opj_cparameters_t parameters
        opj_image_cmptparm_t cmptparms[4]

        OPJ_CODEC_FORMAT codec_format = (OPJ_CODEC_JP2 if codecformat == 'JP2'
                                         else OPJ_CODEC_J2K)
        OPJ_BOOL ret = OPJ_TRUE
        OPJ_COLOR_SPACE color_space
        OPJ_UINT32 signed, prec, width, height, samples
        ssize_t i, j
        int verbosity = verbose
        int tile_width = 0
        int tile_height = 0

        float rate = 100.0 / _default_level(level, 100, 1, 100)

    if data is out:
        raise ValueError('cannot encode in-place')

    if not (data.dtype in (numpy.int8, numpy.int16, numpy.int32,
                           numpy.uint8, numpy.uint16, numpy.uint32)
            and data.ndim in (2, 3)
            and numpy.PyArray_ISCONTIGUOUS(data)):
        raise ValueError('invalid input shape, strides, or dtype')

    signed = 1 if data.dtype in (numpy.int8, numpy.int16, numpy.int32) else 0
    prec = data.itemsize * 8
    width = data.shape[1]
    height = data.shape[0]
    samples = 1 if data.ndim == 2 else data.shape[2]

    if samples > 4 and height <= 4:
        # separate bands
        samples = data.shape[0]
        width = data.shape[1]
        height = data.shape[2]
    elif samples > 1:
        # contig
        # TODO: avoid full copy
        # TODO: doesn't work with e.g. contig (4, 4, 4)
        src = numpy.ascontiguousarray(numpy.moveaxis(data, -1, 0))

    if tile:
        tile_height, tile_width = tile
        # if width % tile_width or height % tile_height:
        #     raise ValueError('invalid tiles')
        raise NotImplementedError('writing tiles not implemented yet')
    else:
        tile_height = height
        tile_width = width

    if colorspace is None:
        if samples <= 2:
            color_space = OPJ_CLRSPC_GRAY
        elif samples <= 4:
            color_space = OPJ_CLRSPC_SRGB
        else:
            color_space = OPJ_CLRSPC_UNSPECIFIED
    else:
        color_space = opj_colorspace(colorspace)

    out, dstsize, out_given, out_type = _parse_output(out)

    if out is None:
        if dstsize < 0:
            dstsize = srcsize + 2048  # ?
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(NULL, dstsize)
        else:
            out = PyByteArray_FromStringAndSize(NULL, dstsize)

    dst = out
    dstsize = dst.size * dst.itemsize

    try:
        with nogil:

            # create memory stream
            memstream.data = <OPJ_UINT8*>&dst[0]
            memstream.size = dstsize
            memstream.offset = 0
            memstream.written = 0

            stream = opj_memstream_create(&memstream, OPJ_FALSE)
            if stream == NULL:
                raise J2KError('opj_memstream_create failed')

            # create image
            memset(&cmptparms, 0, sizeof(cmptparms))
            for i in range(samples):
                cmptparms[i].dx = 1  # subsampling
                cmptparms[i].dy = 1
                cmptparms[i].x0 = 0
                cmptparms[i].y0 = 0
                cmptparms[i].h = height
                cmptparms[i].w = width
                cmptparms[i].sgnd = signed
                cmptparms[i].prec = prec
                cmptparms[i].bpp = prec

            if tile_height > 0:
                image = opj_image_tile_create(samples, cmptparms, color_space)
                if image == NULL:
                    raise J2KError('opj_image_tile_create failed')
            else:
                image = opj_image_create(samples, cmptparms, color_space)
                if image == NULL:
                    raise J2KError('opj_image_create failed')

            image.x0 = 0
            image.y0 = 0
            image.x1 = width
            image.y1 = height
            image.color_space = color_space
            image.numcomps = samples

            # set parameters
            opj_set_default_encoder_parameters(&parameters)
            # TODO: this crashes
            # parameters.tcp_numlayers = 1  # single quality layer
            parameters.tcp_rates[0] = rate
            parameters.irreversible = 0
            parameters.numresolution = 1

            if tile_height > 0:
                parameters.tile_size_on = OPJ_TRUE
                parameters.cp_tx0 = 0
                parameters.cp_ty0 = 0
                parameters.cp_tdy = tile_height
                parameters.cp_tdx = tile_width
            else:
                parameters.tile_size_on = OPJ_FALSE
                parameters.cp_tx0 = 0
                parameters.cp_ty0 = 0
                parameters.cp_tdy = 0
                parameters.cp_tdx = 0

            # create and setup encoder
            codec = opj_create_compress(codec_format)
            if codec == NULL:
                raise J2KError('opj_create_compress failed')

            if verbosity > 0:
                opj_set_error_handler(
                    codec, <opj_msg_callback>j2k_error_callback, NULL)
                if verbosity > 1:
                    opj_set_warning_handler(
                        codec, <opj_msg_callback>j2k_warning_callback, NULL)
                if verbosity > 2:
                    opj_set_info_handler(
                        codec, <opj_msg_callback>j2k_info_callback, NULL)

            ret = opj_setup_encoder(codec, &parameters, image)
            if ret == OPJ_FALSE:
                raise J2KError('opj_setup_encoder failed')

            ret = opj_start_compress(codec, image, stream)
            if ret == OPJ_FALSE:
                raise J2KError('opj_start_compress failed')

            if tile_height > 0:
                # TODO: loop over tiles
                ret = opj_write_tile(codec, 0, <OPJ_BYTE*>src.data,
                                     <OPJ_UINT32>srcsize, stream)
            else:
                # TODO: copy data to image.comps[band].data[y, x]
                ret = opj_encode(codec, stream)

            if ret == OPJ_FALSE:
                raise J2KError('opj_encode or opj_write_tile failed')

            ret = opj_end_compress(codec, stream)
            if ret == OPJ_FALSE:
                raise J2KError('opj_end_compress failed')

            if memstream.written > memstream.size:
                raise J2KError('output buffer too small')

            byteswritten = memstream.written

    finally:
        if stream != NULL:
            opj_stream_destroy(stream)
        if codec != NULL:
            opj_destroy_codec(codec)
        if image != NULL:
            opj_image_destroy(image)

    if byteswritten < dstsize:
        if out_given:
            out = memoryview(out)[:byteswritten]
        else:
            out = out[:byteswritten]

    return out


def j2k_decode(data, verbose=0, out=None):
    """Decode JPEG 2000 J2K or JP2 image to numpy array.

    """
    cdef:
        numpy.ndarray dst
        const uint8_t[::1] src = data
        int32_t* band
        uint32_t* u4
        uint16_t* u2
        uint8_t* u1
        int32_t* i4
        int16_t* i2
        int8_t* i1
        ssize_t dstsize
        ssize_t itemsize
        opj_memstream_t memstream
        opj_codec_t* codec = NULL
        opj_image_t* image = NULL
        opj_stream_t* stream = NULL
        opj_image_comp_t* comp = NULL
        opj_dparameters_t parameters
        OPJ_BOOL ret = OPJ_FALSE
        OPJ_CODEC_FORMAT codecformat
        OPJ_UINT32 signed, prec, width, height, samples
        ssize_t i, j
        int verbosity = verbose

    if data is out:
        raise ValueError('cannot decode in-place')

    signature = bytearray(src[:12])
    if signature[:4] == b'\xff\x4f\xff\x51':
        codecformat = OPJ_CODEC_J2K
    elif (signature == b'\x00\x00\x00\x0c\x6a\x50\x20\x20\x0d\x0a\x87\x0a' or
          signature[:4] == b'\x0d\x0a\x87\x0a'):
        codecformat = OPJ_CODEC_JP2
    else:
        raise J2KError('not a J2K or JP2 data stream')

    try:
        memstream.data = <OPJ_UINT8*>&src[0]
        memstream.size = src.size
        memstream.offset = 0
        memstream.written = 0

        with nogil:
            stream = opj_memstream_create(&memstream, OPJ_TRUE)
            if stream == NULL:
                raise J2KError('opj_memstream_create failed')

            codec = opj_create_decompress(codecformat)
            if codec == NULL:
                raise J2KError('opj_create_decompress failed')

            if verbosity > 0:
                opj_set_error_handler(
                    codec, <opj_msg_callback>j2k_error_callback, NULL)
                if verbosity > 1:
                    opj_set_warning_handler(
                        codec, <opj_msg_callback>j2k_warning_callback, NULL)
                if verbosity > 2:
                    opj_set_info_handler(
                        codec, <opj_msg_callback>j2k_info_callback, NULL)

            opj_set_default_decoder_parameters(&parameters)

            ret = opj_setup_decoder(codec, &parameters)
            if ret == OPJ_FALSE:
                raise J2KError('opj_setup_decoder failed')

            ret = opj_read_header(stream, codec, &image)
            if ret == OPJ_FALSE:
                raise J2KError('opj_read_header failed')

            ret = opj_set_decode_area(codec, image,
                                      <OPJ_INT32>parameters.DA_x0,
                                      <OPJ_INT32>parameters.DA_y0,
                                      <OPJ_INT32>parameters.DA_x1,
                                      <OPJ_INT32>parameters.DA_y1)
            if ret == OPJ_FALSE:
                raise J2KError('opj_set_decode_area failed')

            # with nogil:
            ret = opj_decode(codec, stream, image)
            if ret != OPJ_FALSE:
                ret = opj_end_decompress(codec, stream)
            if ret == OPJ_FALSE:
                raise J2KError('opj_decode or opj_end_decompress failed')

            # handle subsampling and color profiles
            if (image.color_space != OPJ_CLRSPC_SYCC
                    and image.numcomps == 3
                    and image.comps[0].dx == image.comps[0].dy
                    and image.comps[1].dx != 1):
                image.color_space = OPJ_CLRSPC_SYCC
            elif image.numcomps <= 2:
                image.color_space = OPJ_CLRSPC_GRAY

            if image.color_space == OPJ_CLRSPC_SYCC:
                color_sycc_to_rgb(image)
            if image.icc_profile_buf:
                color_apply_icc_profile(image)
                free(image.icc_profile_buf)
                image.icc_profile_buf = NULL
                image.icc_profile_len = 0

            comp = &image.comps[0]
            signed = comp.sgnd
            prec = comp.prec
            height = comp.h * comp.dy
            width = comp.w * comp.dx
            samples = image.numcomps
            itemsize = (prec + 7) // 8

            for i in range(samples):
                comp = &image.comps[i]
                if comp.sgnd != signed or comp.prec != prec:
                    raise J2KError('components dtype mismatch')
                if comp.w != width or comp.h != height:
                    raise J2KError('subsampling not supported')
            if itemsize == 3:
                itemsize = 4
            elif itemsize < 1 or itemsize > 4:
                raise J2KError('unsupported itemsize %i' % int(itemsize))

        dtype = ('i' if signed else 'u') + ('%i' % itemsize)
        if samples > 1:
            shape = int(height), int(width), int(samples)
        else:
            shape = int(height), int(width)
        out = _create_array(out, shape, dtype)
        dst = out
        dstsize = dst.size * itemsize

        with nogil:
            # memset(<void *>dst.data, 0, dstsize)
            # TODO: support separate in addition to contig samples
            if itemsize == 1:
                if signed:
                    for i in range(samples):
                        i1 = <int8_t*>dst.data + i
                        band = <int32_t*>image.comps[i].data
                        for j in range(height * width):
                            i1[j * samples] = <int8_t>band[j]
                else:
                    for i in range(samples):
                        u1 = <uint8_t*>dst.data + i
                        band = <int32_t*>image.comps[i].data
                        for j in range(height * width):
                            u1[j * samples] = <uint8_t>band[j]
            elif itemsize == 2:
                if signed:
                    for i in range(samples):
                        i2 = <int16_t*>dst.data + i
                        band = <int32_t*>image.comps[i].data
                        for j in range(height * width):
                            i2[j * samples] = <int16_t>band[j]
                else:
                    for i in range(samples):
                        u2 = <uint16_t*>dst.data + i
                        band = <int32_t*>image.comps[i].data
                        for j in range(height * width):
                            u2[j * samples] = <uint16_t>band[j]
            elif itemsize == 4:
                if signed:
                    for i in range(samples):
                        i4 = <int32_t*>dst.data + i
                        band = <int32_t*>image.comps[i].data
                        for j in range(height * width):
                            i4[j * samples] = <int32_t>band[j]
                else:
                    for i in range(samples):
                        u4 = <uint32_t*>dst.data + i
                        band = <int32_t*>image.comps[i].data
                        for j in range(height * width):
                            u4[j * samples] = <uint32_t>band[j]

    finally:
        if stream != NULL:
            opj_stream_destroy(stream)
        if codec != NULL:
            opj_destroy_codec(codec)
        if image != NULL:
            opj_image_destroy(image)

    return out


# JPEG XR #####################################################################

cdef extern from 'windowsmediaphoto.h':
    ctypedef long ERR
    ctypedef int I32
    ctypedef int Bool
    ctypedef int PixelI
    ctypedef signed char I8
    ctypedef unsigned char U8
    ctypedef unsigned int U32
    ctypedef float Float

    int MAX_CHANNELS
    int MAX_TILES
    int MB_WIDTH_PIXEL
    int MB_HEIGHT_PIXEL
    int BLK_WIDTH_PIXEL
    int BLK_HEIGHT_PIXEL
    int MB_WIDTH_BLK
    int MB_HEIGHT_BLK
    int FRAMEBUFFER_ALIGNMENT

    ERR WMP_errSuccess
    ERR WMP_errFail
    ERR WMP_errNotYetImplemented
    ERR WMP_errAbstractMethod
    ERR WMP_errOutOfMemory
    ERR WMP_errFileIO
    ERR WMP_errBufferOverflow
    ERR WMP_errInvalidParameter
    ERR WMP_errInvalidArgument
    ERR WMP_errUnsupportedFormat
    ERR WMP_errIncorrectCodecVersion
    ERR WMP_errIndexNotFound
    ERR WMP_errOutOfSequence
    ERR WMP_errNotInitialized
    ERR WMP_errMustBeMultipleOf16LinesUntilLastCall
    ERR WMP_errPlanarAlphaBandedEncRequiresTempFile
    ERR WMP_errAlphaModeCannotBeTranscoded
    ERR WMP_errIncorrectCodecSubVersion

    ctypedef enum BITDEPTH_BITS:
        BD_1
        BD_8
        BD_16
        BD_16S
        BD_16F
        BD_32
        BD_32S
        BD_32F
        BD_5
        BD_10
        BD_565
        BDB_MAX
        BD_1alt

    ctypedef enum COLORFORMAT:
        Y_ONLY
        YUV_420
        YUV_422
        YUV_444
        CMYK
        BAYER
        N_CHANNEL
        CF_RGB
        CF_RGBE
        CF_PALLETIZED
        CFT_MAX

    ctypedef enum BITDEPTH:
        BD_SHORT
        BD_LONG
        BD_MAX

    ctypedef enum OVERLAP:
        OL_NONE
        OL_ONE
        OL_TWO
        OL_MAX

    ctypedef enum BITSTREAMFORMAT:
        SPATIAL
        FREQUENCY

    ctypedef enum SUBBAND:
        SB_ALL
        SB_NO_FLEXBITS
        SB_NO_HIGHPASS
        SB_DC_ONLY
        SB_ISOLATED

    ctypedef ERR (*WMPStream_Close)(WMPStream**) nogil
    ctypedef ERR (*WMPStream_Read)(WMPStream*, void* pv, size_t c) nogil
    ctypedef ERR (*WMPStream_Write)(WMPStream*, const void* pv, size_t c) nogil
    ctypedef ERR (*WMPStream_SetPos)(WMPStream*, size_t offPos) nogil
    ctypedef ERR (*WMPStream_GetPos)(WMPStream*, size_t* poffPos) nogil
    ctypedef Bool (*WMPStream_EOS)(WMPStream*) nogil

    cdef struct WMPStream_buf:
        U8* pbBuf
        size_t cbBuf
        size_t cbCur
        size_t cbBufCount

    cdef union WMPStream_state:
        WMPStream_buf buf

    cdef struct WMPStream:
        WMPStream_state state
        WMPStream_Close Close
        WMPStream_Read Read
        WMPStream_Write Write
        WMPStream_SetPos SetPos
        WMPStream_GetPos GetPos
        WMPStream_EOS EOS

    ctypedef struct CWMIStrCodecParam:
        Bool bVerbose
        U8 uiDefaultQPIndex
        U8 uiDefaultQPIndexYLP
        U8 uiDefaultQPIndexYHP
        U8 uiDefaultQPIndexU
        U8 uiDefaultQPIndexULP
        U8 uiDefaultQPIndexUHP
        U8 uiDefaultQPIndexV
        U8 uiDefaultQPIndexVLP
        U8 uiDefaultQPIndexVHP
        U8 uiDefaultQPIndexAlpha
        COLORFORMAT cfColorFormat
        BITDEPTH bdBitDepth
        OVERLAP olOverlap
        BITSTREAMFORMAT bfBitstreamFormat
        size_t cChannel  # number of color channels including alpha
        U8 uAlphaMode  # 0: no alpha, 1: alpha only, else: something + alpha
        SUBBAND sbSubband
        U8 uiTrimFlexBits
        WMPStream* pWStream
        size_t cbStream
        U32  cNumOfSliceMinus1V
        U32* uiTileX  # [MAX_TILES]
        U32  cNumOfSliceMinus1H
        U32* uiTileY  # [MAX_TILES]
        U8 nLenMantissaOrShift
        I8 nExpBias
        Bool bBlackWhite
        Bool bUseHardTileBoundaries
        Bool bProgressiveMode
        Bool bYUVData
        Bool bUnscaledArith
        Bool fMeasurePerf

    ERR CreateWS_Memory(WMPStream** ppWS, void* pv, size_t cb) nogil
    ERR CloseWS_Memory(WMPStream** ppWS) nogil


cdef extern from 'guiddef.h':
    ctypedef struct GUID:
        pass

    int IsEqualGUID(GUID*, GUID*) nogil


cdef extern from 'JXRGlue.h':
    int WMP_SDK_VERSION
    int PK_SDK_VERSION

    ctypedef U32 PKIID
    ctypedef unsigned long WMP_GRBIT
    ctypedef GUID PKPixelFormatGUID

    GUID GUID_PKPixelFormatDontCare
    # bool
    GUID GUID_PKPixelFormatBlackWhite
    # uint8
    GUID GUID_PKPixelFormat8bppGray
    GUID GUID_PKPixelFormat16bppRGB555
    GUID GUID_PKPixelFormat16bppRGB565
    GUID GUID_PKPixelFormat24bppBGR
    GUID GUID_PKPixelFormat24bppRGB
    GUID GUID_PKPixelFormat32bppRGB
    GUID GUID_PKPixelFormat32bppRGBA
    GUID GUID_PKPixelFormat32bppBGRA
    GUID GUID_PKPixelFormat32bppPRGBA
    GUID GUID_PKPixelFormat32bppRGBE
    GUID GUID_PKPixelFormat32bppCMYK
    GUID GUID_PKPixelFormat40bppCMYKAlpha
    GUID GUID_PKPixelFormat24bpp3Channels
    GUID GUID_PKPixelFormat32bpp4Channels
    GUID GUID_PKPixelFormat40bpp5Channels
    GUID GUID_PKPixelFormat48bpp6Channels
    GUID GUID_PKPixelFormat56bpp7Channels
    GUID GUID_PKPixelFormat64bpp8Channels
    GUID GUID_PKPixelFormat32bpp3ChannelsAlpha
    GUID GUID_PKPixelFormat40bpp4ChannelsAlpha
    GUID GUID_PKPixelFormat48bpp5ChannelsAlpha
    GUID GUID_PKPixelFormat56bpp6ChannelsAlpha
    GUID GUID_PKPixelFormat64bpp7ChannelsAlpha
    GUID GUID_PKPixelFormat72bpp8ChannelsAlpha
    # uint16
    GUID GUID_PKPixelFormat16bppGray
    GUID GUID_PKPixelFormat32bppRGB101010
    GUID GUID_PKPixelFormat48bppRGB
    GUID GUID_PKPixelFormat64bppRGBA
    GUID GUID_PKPixelFormat64bppPRGBA
    GUID GUID_PKPixelFormat64bppCMYK
    GUID GUID_PKPixelFormat80bppCMYKAlpha
    GUID GUID_PKPixelFormat48bpp3Channels
    GUID GUID_PKPixelFormat64bpp4Channels
    GUID GUID_PKPixelFormat80bpp5Channels
    GUID GUID_PKPixelFormat96bpp6Channels
    GUID GUID_PKPixelFormat112bpp7Channels
    GUID GUID_PKPixelFormat128bpp8Channels
    GUID GUID_PKPixelFormat64bpp3ChannelsAlpha
    GUID GUID_PKPixelFormat80bpp4ChannelsAlpha
    GUID GUID_PKPixelFormat96bpp5ChannelsAlpha
    GUID GUID_PKPixelFormat112bpp6ChannelsAlpha
    GUID GUID_PKPixelFormat128bpp7ChannelsAlpha
    GUID GUID_PKPixelFormat144bpp8ChannelsAlpha
    # float16
    GUID GUID_PKPixelFormat16bppGrayHalf
    GUID GUID_PKPixelFormat48bppRGBHalf
    GUID GUID_PKPixelFormat64bppRGBHalf
    GUID GUID_PKPixelFormat64bppRGBAHalf
    # float32
    GUID GUID_PKPixelFormat32bppGrayFloat
    GUID GUID_PKPixelFormat96bppRGBFloat
    GUID GUID_PKPixelFormat128bppRGBFloat
    GUID GUID_PKPixelFormat128bppRGBAFloat
    GUID GUID_PKPixelFormat128bppPRGBAFloat

    int PK_PI_W0
    int PK_PI_B0
    int PK_PI_RGB
    int PK_PI_RGBPalette
    int PK_PI_TransparencyMask
    int PK_PI_CMYK
    int PK_PI_YCbCr
    int PK_PI_CIELab
    int PK_PI_NCH
    int PK_PI_RGBE

    int PK_pixfmtNul
    int PK_pixfmtHasAlpha
    int PK_pixfmtPreMul
    int PK_pixfmtBGR
    int PK_pixfmtNeedConvert

    int LOOKUP_FORWARD
    int LOOKUP_BACKWARD_TIF

    ctypedef ERR (*decode_initialize)(
        PKImageDecode*, WMPStream*) nogil

    ctypedef ERR (*encode_initialize)(
        PKImageEncode*, WMPStream*, void*, size_t) nogil

    ctypedef ERR (*encode_set_pixel_format)(
        PKImageEncode* pIE, PKPixelFormatGUID enPixelFormat) nogil

    ctypedef ERR (*encode_set_size)(
        PKImageEncode* pIE, I32 iWidth, I32 iHeight) nogil

    ctypedef ERR (*encode_set_resolution)(
        PKImageEncode* pIE, Float rX, Float rY) nogil

    ctypedef ERR (*encode_write_pixels)(
        PKImageEncode* pIE, U32 cLine, U8* pbPixel, U32 cbStride) nogil

    ctypedef struct WMPstruct:
        CWMIStrCodecParam wmiSCP

    ctypedef struct PKImageDecode:
        int fStreamOwner
        decode_initialize Initialize
        WMPstruct WMP

    ctypedef struct PKImageEncode:
        encode_initialize Initialize
        encode_set_pixel_format SetPixelFormat
        encode_set_size SetSize
        encode_set_resolution SetResolution
        encode_write_pixels WritePixels
        WMPstruct WMP

    ctypedef struct PKPixelInfo:
        PKPixelFormatGUID* pGUIDPixFmt
        size_t cChannel
        COLORFORMAT cfColorFormat
        BITDEPTH_BITS bdBitDepth
        U32 cbitUnit
        WMP_GRBIT grBit
        U32 uInterpretation
        U32 uSamplePerPixel
        U32 uBitsPerSample
        U32 uSampleFormat

    ctypedef struct PKFactory:
        pass

    ctypedef struct PKCodecFactory:
        pass

    ctypedef struct PKFormatConverter:
        pass

    ctypedef struct PKRect:
        I32 X, Y, Width, Height

    ERR PKCreateCodecFactory(PKCodecFactory**, U32) nogil
    ERR PKCreateCodecFactory_Release(PKCodecFactory**) nogil
    ERR PKCodecFactory_CreateCodec(const PKIID* iid, void** ppv) nogil
    ERR PKCodecFactory_CreateFormatConverter(PKFormatConverter**) nogil
    ERR PKImageDecode_GetSize(PKImageDecode*, I32*, I32*) nogil
    ERR PKImageDecode_Release(PKImageDecode**) nogil
    ERR PKImageDecode_GetPixelFormat(PKImageDecode*, PKPixelFormatGUID*) nogil
    ERR PKFormatConverter_Release(PKFormatConverter**) nogil

    ERR PKFormatConverter_Initialize(PKFormatConverter*,
                                     PKImageDecode*,
                                     char*,
                                     PKPixelFormatGUID) nogil

    ERR PKFormatConverter_Copy(PKFormatConverter*,
                               const PKRect*,
                               U8*,
                               U32) nogil

    ERR PKFormatConverter_Convert(PKFormatConverter*,
                                  const PKRect*,
                                  U8*,
                                  U32) nogil

    ERR GetImageEncodeIID(const char* szExt, const PKIID** ppIID) nogil
    ERR GetImageDecodeIID(const char* szExt, const PKIID** ppIID) nogil
    ERR PixelFormatLookup(PKPixelInfo* pPI, U8 uLookupType) nogil
    PKPixelFormatGUID* GetPixelFormatFromHash(const U8 uPFHash) nogil

    ERR PKImageEncode_Create_WMP(PKImageEncode** ppIE) nogil
    ERR PKImageEncode_Release(PKImageEncode** ppIE) nogil


class WmpError(RuntimeError):
    """WMP Exceptions."""
    def __init__(self, func, err):
        msg = {
            WMP_errFail: 'WMP_errFail',
            WMP_errNotYetImplemented: 'WMP_errNotYetImplemented',
            WMP_errAbstractMethod: 'WMP_errAbstractMethod',
            WMP_errOutOfMemory: 'WMP_errOutOfMemory',
            WMP_errFileIO: 'WMP_errFileIO',
            WMP_errBufferOverflow: 'WMP_errBufferOverflow',
            WMP_errInvalidParameter: 'WMP_errInvalidParameter',
            WMP_errInvalidArgument: 'WMP_errInvalidArgument',
            WMP_errUnsupportedFormat: 'WMP_errUnsupportedFormat',
            WMP_errIncorrectCodecVersion: 'WMP_errIncorrectCodecVersion',
            WMP_errIndexNotFound: 'WMP_errIndexNotFound',
            WMP_errOutOfSequence: 'WMP_errOutOfSequence',
            WMP_errNotInitialized: 'WMP_errNotInitialized',
            WMP_errAlphaModeCannotBeTranscoded:
                'WMP_errAlphaModeCannotBeTranscoded',
            WMP_errIncorrectCodecSubVersion:
                'WMP_errIncorrectCodecSubVersion',
            WMP_errMustBeMultipleOf16LinesUntilLastCall:
                'WMP_errMustBeMultipleOf16LinesUntilLastCall',
            WMP_errPlanarAlphaBandedEncRequiresTempFile:
                'WMP_errPlanarAlphaBandedEncRequiresTempFile',
            }.get(err, 'unknown error %i' % err)
        msg = '%s returned %s' % (func, msg)
        RuntimeError.__init__(self, msg)


cdef ERR WriteWS_Memory(WMPStream* pWS, const void* pv, size_t cb) nogil:
    """Relpacement for WriteWS_Memory to keep track of bytes written."""
    if pWS.state.buf.cbCur + cb < pWS.state.buf.cbCur:
        return WMP_errBufferOverflow
    if pWS.state.buf.cbBuf < pWS.state.buf.cbCur + cb:
        return WMP_errBufferOverflow

    memmove(pWS.state.buf.pbBuf + pWS.state.buf.cbCur, pv, cb)
    pWS.state.buf.cbCur += cb

    # keep track of bytes written
    if pWS.state.buf.cbCur > pWS.state.buf.cbBufCount:
        pWS.state.buf.cbBufCount = pWS.state.buf.cbCur

    return WMP_errSuccess


cdef ERR WriteWS_Realloc(WMPStream* pWS, const void* pv, size_t cb) nogil:
    """Relpacement for WriteWS_Memory to realloc buffers on overflow.

    Only use with buffers allocated by malloc.

    """
    cdef:
        size_t newsize = pWS.state.buf.cbCur + cb
    if newsize < pWS.state.buf.cbCur:
        return WMP_errBufferOverflow
    if pWS.state.buf.cbBuf < newsize:
        if newsize <= pWS.state.buf.cbBuf * 1.125:
            # moderate upsize: overallocate
            newsize = newsize + newsize // 8
            newsize = (((newsize-1) // 4096) + 1) * 4096
        else:
            # major upsize: resize to exact size
            newsize = newsize + 1
        pWS.state.buf.pbBuf = <U8*>realloc(<void*>pWS.state.buf.pbBuf, newsize)
        if pWS.state.buf.pbBuf  == NULL:
            return WMP_errOutOfMemory
        pWS.state.buf.cbBuf = newsize

    memmove(pWS.state.buf.pbBuf + pWS.state.buf.cbCur, pv, cb)
    pWS.state.buf.cbCur += cb

    # keep track of bytes written
    if pWS.state.buf.cbCur > pWS.state.buf.cbBufCount:
        pWS.state.buf.cbBufCount = pWS.state.buf.cbCur

    return WMP_errSuccess


cdef Bool EOSWS_Realloc(WMPStream* pWS) nogil:
    """Relpacement for EOSWS_Memory."""
    # return pWS.state.buf.cbBuf <= pWS.state.buf.cbCur
    return 1


cdef ERR PKCodecFactory_CreateDecoderFromBytes(void* bytes, size_t len,
                                               PKImageDecode** ppDecode) nogil:
    """Create PKImageDecode from byte string."""
    cdef:
        char *pExt = NULL
        const PKIID* pIID = NULL
        WMPStream* stream = NULL
        PKImageDecode* decoder = NULL
        ERR err

    # get decode PKIID
    err = GetImageDecodeIID('.jxr', &pIID)
    if err:
        return err
    # create stream
    err = CreateWS_Memory(&stream, bytes, len)
    if err:
        return err
    # create decoder
    err = PKCodecFactory_CreateCodec(pIID, <void **>ppDecode)
    if err:
        return err
    # attach stream to decoder
    decoder = ppDecode[0]
    err = decoder.Initialize(decoder, stream)
    if err:
        return err
    decoder.fStreamOwner = 1
    return WMP_errSuccess


cdef ERR jxr_decode_guid(PKPixelFormatGUID* pixelformat, int *typenum,
                         ssize_t *samples, U8 *alpha) nogil:
    """Return dtype, samples, alpha from GUID.

    Change pixelformat to output format in-place.

    """
    alpha[0] = 0
    samples[0] = 1

    # bool
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormatBlackWhite):
        pixelformat[0] = GUID_PKPixelFormat8bppGray
        typenum[0] = numpy.NPY_BOOL
        return WMP_errSuccess

    # uint8
    typenum[0] = numpy.NPY_UINT8
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat8bppGray):
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat24bppRGB):
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat16bppRGB555):
        pixelformat[0] = GUID_PKPixelFormat24bppRGB
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat16bppRGB565):
        pixelformat[0] = GUID_PKPixelFormat24bppRGB
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat24bppBGR):
        pixelformat[0] = GUID_PKPixelFormat24bppRGB
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat32bppRGB):
        pixelformat[0] = GUID_PKPixelFormat24bppRGB
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat32bppBGRA):
        pixelformat[0] = GUID_PKPixelFormat32bppRGBA
        alpha[0] = 2
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat32bppRGBA):
        alpha[0] = 2
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat32bppPRGBA):
        alpha[0] = 2
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat32bppRGBE):
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat32bppCMYK):
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat40bppCMYKAlpha):
        alpha[0] = 2
        samples[0] = 5
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat24bpp3Channels):
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat32bpp4Channels):
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat40bpp5Channels):
        samples[0] = 5
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat48bpp6Channels):
        samples[0] = 6
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat56bpp7Channels):
        samples[0] = 7
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat64bpp8Channels):
        samples[0] = 8
        return WMP_errSuccess

    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat32bpp3ChannelsAlpha):
        alpha[0] = 2
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat40bpp4ChannelsAlpha):
        alpha[0] = 2
        samples[0] = 5
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat48bpp5ChannelsAlpha):
        alpha[0] = 2
        samples[0] = 6
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat56bpp6ChannelsAlpha):
        alpha[0] = 2
        samples[0] = 7
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat64bpp7ChannelsAlpha):
        alpha[0] = 2
        samples[0] = 8
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat72bpp8ChannelsAlpha):
        alpha[0] = 2
        samples[0] = 9
        return WMP_errSuccess

    # uint16
    typenum[0] = numpy.NPY_UINT16
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat16bppGray):
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat32bppRGB101010):
        pixelformat[0] = GUID_PKPixelFormat48bppRGB
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat48bppRGB):
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat64bppRGBA):
        alpha[0] = 2
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat64bppPRGBA):
        alpha[0] = 2
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat64bppCMYK):
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat80bppCMYKAlpha):
        alpha[0] = 2
        samples[0] = 5
        return WMP_errSuccess

    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat48bpp3Channels):
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat64bpp4Channels):
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat80bpp5Channels):
        samples[0] = 5
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat96bpp6Channels):
        samples[0] = 6
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat112bpp7Channels):
        samples[0] = 7
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat128bpp8Channels):
        samples[0] = 8
        return WMP_errSuccess

    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat64bpp3ChannelsAlpha):
        alpha[0] = 2
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat80bpp4ChannelsAlpha):
        alpha[0] = 2
        samples[0] = 5
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat96bpp5ChannelsAlpha):
        alpha[0] = 2
        samples[0] = 6
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat112bpp6ChannelsAlpha):
        alpha[0] = 2
        samples[0] = 7
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat128bpp7ChannelsAlpha):
        alpha[0] = 2
        samples[0] = 8
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat144bpp8ChannelsAlpha):
        alpha[0] = 2
        samples[0] = 9
        return WMP_errSuccess

    # float32
    typenum[0] = numpy.NPY_FLOAT32
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat32bppGrayFloat):
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat96bppRGBFloat):
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat128bppRGBFloat):
        pixelformat[0] = GUID_PKPixelFormat96bppRGBFloat
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat128bppRGBAFloat):
        alpha[0] = 2
        samples[0] = 4
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat128bppPRGBAFloat):
        alpha[0] = 2
        samples[0] = 4
        return WMP_errSuccess

    # float16
    typenum[0] = numpy.NPY_FLOAT16
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat16bppGrayHalf):
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat48bppRGBHalf):
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat64bppRGBHalf):
        pixelformat[0] = GUID_PKPixelFormat48bppRGBHalf
        samples[0] = 3
        return WMP_errSuccess
    if IsEqualGUID(pixelformat, &GUID_PKPixelFormat64bppRGBAHalf):
        alpha[0] = 2
        samples[0] = 4
        return WMP_errSuccess

    return WMP_errUnsupportedFormat


cdef PKPixelFormatGUID jxr_encode_guid(numpy.dtype dtype, ssize_t samples,
                                       int photometric, int* alpha) nogil:
    """Return pixel format GUID from dtype, samples, and photometric."""
    cdef int typenum = dtype.type_num
    if samples == 1:
        if typenum == numpy.NPY_UINT8:
            return GUID_PKPixelFormat8bppGray
        if typenum == numpy.NPY_UINT16:
            return GUID_PKPixelFormat16bppGray
        if typenum == numpy.NPY_FLOAT32:
            return GUID_PKPixelFormat32bppGrayFloat
        if typenum == numpy.NPY_FLOAT16:
            return GUID_PKPixelFormat16bppGrayHalf
        if typenum == numpy.NPY_BOOL:
            return GUID_PKPixelFormatBlackWhite
    if samples == 3:
        if typenum == numpy.NPY_UINT8:
            if photometric < 0 or photometric == PK_PI_RGB:
                return GUID_PKPixelFormat24bppRGB
            return GUID_PKPixelFormat24bpp3Channels
        if typenum == numpy.NPY_UINT16:
            if photometric < 0 or photometric == PK_PI_RGB:
                return GUID_PKPixelFormat48bppRGB
            return GUID_PKPixelFormat48bpp3Channels
        if typenum == numpy.NPY_FLOAT32:
            return GUID_PKPixelFormat96bppRGBFloat
        if typenum == numpy.NPY_FLOAT16:
            return GUID_PKPixelFormat48bppRGBHalf
    if samples == 4:
        if typenum == numpy.NPY_UINT8:
            if photometric < 0 or photometric == PK_PI_RGB:
                alpha[0] = 1
                return GUID_PKPixelFormat32bppRGBA
            if photometric == PK_PI_CMYK:
                return GUID_PKPixelFormat32bppCMYK
            if alpha:
                return GUID_PKPixelFormat32bpp3ChannelsAlpha
            return GUID_PKPixelFormat32bpp4Channels
        if typenum == numpy.NPY_UINT16:
            if photometric < 0 or photometric == PK_PI_RGB:
                alpha[0] = 1
                return GUID_PKPixelFormat64bppRGBA
            if photometric == PK_PI_CMYK:
                return GUID_PKPixelFormat64bppCMYK
            if alpha:
                return GUID_PKPixelFormat64bpp3ChannelsAlpha
            return GUID_PKPixelFormat64bpp4Channels
        alpha[0] = 1
        if typenum == numpy.NPY_FLOAT32:
            return GUID_PKPixelFormat128bppRGBAFloat
        if typenum == numpy.NPY_FLOAT16:
            return GUID_PKPixelFormat64bppRGBAHalf
    if samples == 5:
        if photometric == PK_PI_CMYK:
            alpha[0] = 1
            if typenum == numpy.NPY_UINT8:
                return GUID_PKPixelFormat40bppCMYKAlpha
            if typenum == numpy.NPY_UINT16:
                return GUID_PKPixelFormat80bppCMYKAlpha
        if alpha[0]:
            if typenum == numpy.NPY_UINT8:
                return GUID_PKPixelFormat40bpp4ChannelsAlpha
            if typenum == numpy.NPY_UINT16:
                return GUID_PKPixelFormat80bpp4ChannelsAlpha
        if typenum == numpy.NPY_UINT8:
            return GUID_PKPixelFormat40bpp5Channels
        if typenum == numpy.NPY_UINT16:
            return GUID_PKPixelFormat80bpp5Channels
    if samples == 6:
        if alpha[0]:
            if typenum == numpy.NPY_UINT8:
                return GUID_PKPixelFormat48bpp5ChannelsAlpha
            if typenum == numpy.NPY_UINT16:
                return GUID_PKPixelFormat96bpp5ChannelsAlpha
        if typenum == numpy.NPY_UINT8:
            return GUID_PKPixelFormat48bpp6Channels
        if typenum == numpy.NPY_UINT16:
            return GUID_PKPixelFormat96bpp6Channels
    if samples == 7:
        if alpha[0]:
            if typenum == numpy.NPY_UINT8:
                return GUID_PKPixelFormat56bpp6ChannelsAlpha
            if typenum == numpy.NPY_UINT16:
                return GUID_PKPixelFormat112bpp6ChannelsAlpha
        if typenum == numpy.NPY_UINT8:
            return GUID_PKPixelFormat56bpp7Channels
        if typenum == numpy.NPY_UINT16:
            return GUID_PKPixelFormat112bpp7Channels
    if samples == 8:
        if alpha[0]:
            if typenum == numpy.NPY_UINT8:
                return GUID_PKPixelFormat64bpp7ChannelsAlpha
            if typenum == numpy.NPY_UINT16:
                return GUID_PKPixelFormat128bpp7ChannelsAlpha
        if typenum == numpy.NPY_UINT8:
            return GUID_PKPixelFormat64bpp8Channels
        elif typenum == numpy.NPY_UINT16:
            return GUID_PKPixelFormat128bpp8Channels
    if samples == 9:
        alpha[0] = 1
        if typenum == numpy.NPY_UINT8:
            return GUID_PKPixelFormat72bpp8ChannelsAlpha
        if typenum == numpy.NPY_UINT16:
            return GUID_PKPixelFormat144bpp8ChannelsAlpha
    return GUID_PKPixelFormatDontCare


cdef int jxr_encode_photometric(photometric):
    """Return PK_PI value from photometric argument."""
    if photometric is None:
        return -1
    if isinstance(photometric, int):
        if photometric not in (-1, PK_PI_W0, PK_PI_B0, PK_PI_RGB, PK_PI_CMYK):
            raise ValueError('photometric interpretation not supported')
        return photometric
    photometric = photometric.upper()
    if photometric[:3] == 'RGB':
        return PK_PI_RGB
    if photometric == 'WHITEISZERO' or photometric == 'MINISWHITE':
        return PK_PI_W0
    if photometric in ('BLACKISZERO', 'MINISBLACK', 'GRAY'):
        return PK_PI_B0
    if photometric == 'CMYK' or photometric == 'SEPARATED':
        return PK_PI_CMYK
    # TODO: support more photometric modes
    # if photometric == 'YCBCR':
    #     return PK_PI_YCbCr
    # if photometric == 'CIELAB':
    #     return PK_PI_CIELab
    # if photometric == 'TRANSPARENCYMASK' or photometric == 'MASK':
    #     return PK_PI_TransparencyMask
    # if photometric == 'RGBPALETTE' or photometric == 'PALETTE':
    #     return PK_PI_RGBPalette
    raise ValueError('photometric interpretation not supported')


# Y, U, V, YHP, UHP, VHP
# optimized for PSNR
cdef int *DPK_QPS_420 = [
    66, 65, 70, 72, 72, 77, 59, 58, 63, 64, 63, 68, 52, 51, 57, 56, 56, 61, 48,
    48, 54, 51, 50, 55, 43, 44, 48, 46, 46, 49, 37, 37, 42, 38, 38, 43, 26, 28,
    31, 27, 28, 31, 16, 17, 22, 16, 17, 21, 10, 11, 13, 10, 10, 13, 5, 5, 6, 5,
    5, 6, 2, 2, 3, 2, 2, 2]

cdef int *DPK_QPS_8 = [
    67, 79, 86, 72, 90, 98, 59, 74, 80, 64, 83, 89, 53, 68, 75, 57, 76, 83, 49,
    64, 71, 53, 70, 77, 45, 60, 67, 48, 67, 74, 40, 56, 62, 42, 59, 66, 33, 49,
    55, 35, 51, 58, 27, 44, 49, 28, 45, 50, 20, 36, 42, 20, 38, 44, 13, 27, 34,
    13, 28, 34, 7, 17, 21, 8, 17, 21, 2, 5, 6, 2, 5, 6]

cdef int *DPK_QPS_16 = [
    197, 203, 210, 202, 207, 213, 174, 188, 193, 180, 189, 196, 152, 167, 173,
    156, 169, 174, 135, 152, 157, 137, 153, 158, 119, 137, 141, 119, 138, 142,
    102, 120, 125, 100, 120, 124, 82, 98, 104, 79, 98, 103, 60, 76, 81, 58, 76,
    81, 39, 52, 58, 36, 52, 58, 16, 27, 33, 14, 27, 33, 5, 8, 9, 4, 7, 8]

cdef int *DPK_QPS_16f = [
    148, 177, 171, 165, 187, 191, 133, 155, 153, 147, 172, 181, 114, 133, 138,
    130, 157, 167, 97, 118, 120, 109, 137, 144, 76, 98, 103, 85, 115, 121, 63,
    86, 91, 62, 96, 99, 46, 68, 71, 43, 73, 75, 29, 48, 52, 27, 48, 51, 16, 30,
    35, 14, 29, 34, 8, 14, 17, 7,  13, 17, 3, 5, 7, 3, 5, 6]

cdef int *DPK_QPS_32f = [
    194, 206, 209, 204, 211, 217, 175, 187, 196, 186, 193, 205, 157, 170, 177,
    167, 180, 190, 133, 152, 156, 144, 163, 168, 116, 138, 142, 117, 143, 148,
    98, 120, 123,  96, 123, 126, 80, 99, 102, 78, 99, 102, 65, 79, 84, 63, 79,
    84, 48, 61, 67, 45, 60, 66, 27, 41, 46, 24, 40, 45, 3, 22, 24,  2, 21, 22]


cdef U8 jxr_quantization(int *qps, double quality, ssize_t i) nogil:
    """Return quantization from DPK_QPS table."""
    cdef:
        ssize_t qi = <ssize_t>(10.0 * quality)
        double qf = 10.0 * quality - <double>qi
        int *qps0 = qps + qi * 6
        int *qps1 = qps0 + 6
    return <U8>(<double>qps0[i] * (1.0 - qf) + <double>qps1[i] * qf + 0.5)


cdef ERR jxr_set_encoder(CWMIStrCodecParam *wmiscp, PKPixelInfo *pixelinfo,
                         double quality, int alpha, int pi) nogil:
    """Set encoder compression parameters from level argument and pixel format.

    Code and tables adapted from jxrlib's JxrEncApp.c.

    ImageQuality Q(BD==1) Q(BD==8)    Q(BD==16)   Q(BD==32F)  Subsample Overlap
    [0.0, 0.5)   8-IQ*5   (see table) (see table) (see table) 4:2:0     2
    [0.5, 1.0)   8-IQ*5   (see table) (see table) (see table) 4:4:4     1
    [1.0, 1.0]   1        1           1           1           4:4:4     0

    """
    cdef:
        int *qps

    # default: lossless, no tiles
    wmiscp.uiDefaultQPIndex = 1
    wmiscp.uiDefaultQPIndexAlpha = 1
    wmiscp.olOverlap = OL_NONE
    wmiscp.cfColorFormat = YUV_444
    wmiscp.sbSubband = SB_ALL
    wmiscp.bfBitstreamFormat = SPATIAL
    wmiscp.bProgressiveMode = 0
    wmiscp.cNumOfSliceMinus1H = 0
    wmiscp.cNumOfSliceMinus1V = 0
    wmiscp.uAlphaMode = 2 if alpha else 0
    # wmiscp.bdBitDepth = BD_LONG

    if pi == PK_PI_CMYK:
        wmiscp.cfColorFormat = CMYK

    if quality <= 0.0 or quality == 1.0 or quality >= 100.0:
        return WMP_errSuccess
    if quality > 1.0:
        quality /= 100.0
    if quality >= 1.0:
        return WMP_errSuccess
    if quality < 0.5:
        # overlap
        wmiscp.olOverlap = OL_TWO

    if quality < 0.5 and pixelinfo.uBitsPerSample <= 8 and pi != PK_PI_CMYK:
        # chroma sub-sampling
        wmiscp.cfColorFormat = YUV_420

    # bit depth
    if pixelinfo.bdBitDepth == BD_1:
        wmiscp.uiDefaultQPIndex = <U8>(8 - 5.0 * quality + 0.5)
    else:
        # remap [0.8, 0.866, 0.933, 1.0] to [0.8, 0.9, 1.0, 1.1]
        # to use 8-bit DPK QP table (0.933 == Photoshop JPEG 100)
        if quality > 0.8 and (pixelinfo.bdBitDepth == BD_8 and
                              wmiscp.cfColorFormat != YUV_420 and
                              wmiscp.cfColorFormat != YUV_422):
            quality = 0.8 + (quality - 0.8) * 1.5

        if wmiscp.cfColorFormat == YUV_420 or wmiscp.cfColorFormat == YUV_422:
            qps = DPK_QPS_420
        elif pixelinfo.bdBitDepth == BD_8:
            qps = DPK_QPS_8
        elif pixelinfo.bdBitDepth == BD_16:
            qps = DPK_QPS_16
        elif pixelinfo.bdBitDepth == BD_16F:
            qps = DPK_QPS_16f
        else:
            qps = DPK_QPS_32f

        wmiscp.uiDefaultQPIndex = jxr_quantization(qps, quality, 0)
        wmiscp.uiDefaultQPIndexU = jxr_quantization(qps, quality, 1)
        wmiscp.uiDefaultQPIndexV = jxr_quantization(qps, quality, 2)
        wmiscp.uiDefaultQPIndexYHP = jxr_quantization(qps, quality, 3)
        wmiscp.uiDefaultQPIndexUHP = jxr_quantization(qps, quality, 4)
        wmiscp.uiDefaultQPIndexVHP = jxr_quantization(qps, quality, 5)

    return WMP_errSuccess


def jxr_encode(data, level=None, photometric=None, hasalpha=None,
               resolution=None, out=None):
    """Encode numpy array to JPEG XR image."""
    cdef:
        numpy.ndarray src = data
        numpy.dtype dtype = src.dtype
        const uint8_t[::1] dst  # must be const to write to bytes
        U8* outbuffer = NULL
        ssize_t dstsize
        ssize_t srcsize = src.size * src.itemsize
        size_t byteswritten = 0
        ssize_t samples
        int pi = jxr_encode_photometric(photometric)
        int alpha = 1 if hasalpha else 0
        float quality = 1.0 if level is None else level

        WMPStream* stream = NULL
        PKImageEncode* encoder = NULL
        PKPixelFormatGUID pixelformat
        PKPixelInfo pixelinfo
        float rx = 96.0
        float ry = 96.0
        I32 width
        I32 height
        U32 stride
        ERR err

    if not (dtype in (numpy.uint8, numpy.uint16, numpy.bool,
                      numpy.float16, numpy.float32)
            and data.ndim in (2, 3)
            and numpy.PyArray_ISCONTIGUOUS(data)):
        raise ValueError('invalid data shape, strides, or dtype')

    if resolution:
        rx, ry = resolution

    width = <I32>data.shape[1]
    height = <I32>data.shape[0]
    stride = <U32>data.strides[0]
    samples = 1 if data.ndim == 2 else data.shape[2]

    if width < MB_WIDTH_PIXEL or height < MB_HEIGHT_PIXEL:
        raise ValueError('invalid data shape')

    if dtype == numpy.bool:
        if data.ndim != 2:
            raise ValueError('invalid data shape, strides, or dtype')
        src = numpy.packbits(data, axis=-1)
        stride = <U32>src.strides[0]
        srcsize //= 8

    out, dstsize, out_given, out_type = _parse_output(out)
    if out is None:
        if dstsize <= 0:
            dstsize = srcsize // 2
            dstsize = (((dstsize - 1) // 4096) + 1) * 4096
        elif dstsize < 4096:
            dstsize = 4096
        outbuffer = <U8*>malloc(dstsize)
        if outbuffer == NULL:
            raise MemoryError('failed to allocate ouput buffer')
    else:
        dst = out
        dstsize = dst.size * dst.itemsize

    try:
        with nogil:
            pixelformat = jxr_encode_guid(dtype, samples, pi, &alpha)
            if IsEqualGUID(&pixelformat, &GUID_PKPixelFormatDontCare):
                raise ValueError('PKPixelFormatGUID not found')
            pixelinfo.pGUIDPixFmt = &pixelformat

            err = PixelFormatLookup(&pixelinfo, LOOKUP_FORWARD)
            if err:
                raise WmpError('PixelFormatLookup', err)

            if outbuffer == NULL:
                err = CreateWS_Memory(&stream, <void*>&dst[0], dstsize)
                if err:
                    raise WmpError('CreateWS_Memory', err)
                stream.Write = WriteWS_Memory
            else:
                err = CreateWS_Memory(&stream, <void*>outbuffer, dstsize)
                if err:
                    raise WmpError('CreateWS_Memory', err)
                stream.Write = WriteWS_Realloc
                stream.EOS = EOSWS_Realloc

            err = PKImageEncode_Create_WMP(&encoder)
            if err:
                raise WmpError('PKImageEncode_Create_WMP', err)

            err = encoder.Initialize(encoder, stream, &encoder.WMP.wmiSCP,
                                     sizeof(CWMIStrCodecParam))
            if err:
                raise WmpError('PKImageEncode_Initialize', err)

            jxr_set_encoder(&encoder.WMP.wmiSCP, &pixelinfo,
                            quality, alpha, pi)

            err = encoder.SetPixelFormat(encoder, pixelformat)
            if err:
                raise WmpError('PKImageEncode_SetPixelFormat', err)

            err = encoder.SetSize(encoder, width, height)
            if err:
                raise WmpError('PKImageEncode_SetSize', err)

            err = encoder.SetResolution(encoder, rx, ry)
            if err:
                raise WmpError('PKImageEncode_SetResolution', err)

            err = encoder.WritePixels(encoder, height, <U8*>src.data, stride)
            if err:
                raise WmpError('PKImageEncode_WritePixels', err)

            byteswritten = stream.state.buf.cbBufCount
            dstsize = stream.state.buf.cbBuf
            if outbuffer != NULL:
                outbuffer = stream.state.buf.pbBuf

    except Exception:
        if outbuffer != NULL:
            if stream != NULL:
                outbuffer = stream.state.buf.pbBuf
            free(outbuffer)
        raise
    finally:
        if encoder != NULL:
            PKImageEncode_Release(&encoder)
        elif stream != NULL:
            stream.Close(&stream)

    if outbuffer != NULL:
        if out_type is bytes:
            out = PyBytes_FromStringAndSize(<char*>outbuffer, byteswritten)
        else:
            out = PyByteArray_FromStringAndSize(<char*>outbuffer, byteswritten)
            free(outbuffer)
    elif byteswritten < <size_t>dstsize:
        if out_given:
            out = memoryview(out)[:byteswritten]
        else:
            out = out[:byteswritten]

    return out


def jxr_decode(data, out=None):
    """Decode JPEG XR image to numpy array.

    """
    cdef:
        numpy.ndarray dst
        numpy.dtype dtype
        const uint8_t[::1] src = data
        PKImageDecode* decoder = NULL
        PKFormatConverter* converter = NULL
        PKPixelFormatGUID pixelformat
        PKRect rect
        I32 width
        I32 height
        U32 stride
        ERR err
        U8 alpha
        ssize_t srcsize = src.size
        ssize_t dstsize
        ssize_t samples
        int typenum

    if data is out:
        raise ValueError('cannot decode in-place')

    try:
        with nogil:
            err = PKCodecFactory_CreateDecoderFromBytes(<void*>&src[0],
                                                        srcsize, &decoder)
            if err:
                raise WmpError('PKCodecFactory_CreateDecoderFromBytes', err)

            err = PKImageDecode_GetSize(decoder, &width, &height)
            if err:
                raise WmpError('PKImageDecode_GetSize', err)

            err = PKImageDecode_GetPixelFormat(decoder, &pixelformat)
            if err:
                raise WmpError('PKImageDecode_GetPixelFormat', err)

            err = jxr_decode_guid(&pixelformat, &typenum, &samples, &alpha)
            if err:
                raise WmpError('jxr_decode_guid', err)
            decoder.WMP.wmiSCP.uAlphaMode = alpha

            err = PKCodecFactory_CreateFormatConverter(&converter)
            if err:
                raise WmpError('PKCodecFactory_CreateFormatConverter', err)

            err = PKFormatConverter_Initialize(converter, decoder, NULL,
                                               pixelformat)
            if err:
                raise WmpError('PKFormatConverter_Initialize', err)

            with gil:
                shape = height, width
                if samples > 1:
                    shape += samples,
                dtype = PyArray_DescrNewFromType(typenum)
                out = _create_array(out, shape, dtype)
                dst = out
                dstsize = dst.size * dst.itemsize

            rect.X = 0
            rect.Y = 0
            rect.Width = <I32>dst.shape[1]
            rect.Height = <I32>dst.shape[0]
            stride = <U32>dst.strides[0]

            memset(<void *>dst.data, 0, dstsize)  # TODO: still necessary?
            # TODO: check alignment issues
            err = PKFormatConverter_Copy(converter, &rect, <U8*>dst.data,
                                         stride)
        if err:
            raise WmpError('PKFormatConverter_Copy', err)

    finally:
        if converter != NULL:
            PKFormatConverter_Release(&converter)
        if decoder != NULL:
            PKImageDecode_Release(&decoder)

    return out


# JPEG 12-bit #################################################################

# JPEG 12-bit codecs are implemented in a separate extension module
# due to header and link conflicts with JPEG 8-bit.

try:
    from ._jpeg12 import jpeg12_decode, jpeg12_encode, Jpeg12Error
except ImportError:
    Jpeg12Error = RuntimeError

    def jpeg12_decode(*args, **kwargs):
        """Not implemented."""
        raise NotImplementedError('jpeg12_decode')

    def jpeg12_encode(*args, **kwargs):
        """Not implemented."""
        raise NotImplementedError('jpeg12_encode')


# JPEG LS #################################################################

# JPEG-LS codecs are implemented in a separate extension module
#   because CharLS-2.x is not commonly available yet.
# TODO: move implementation here once charls2 is available in Debian and
#   Python 2.7 is dropped

try:
    from ._jpegls import (jpegls_decode, jpegls_encode, JpegLsError,
                          _CHARLS_VERSION)
except ImportError:
    _CHARLS_VERSION = 'n/a'
    JpegLsError = RuntimeError

    def jpegls_decode(*args, **kwargs):
        """Not implemented."""
        raise NotImplementedError('jpegls_decode')

    def jpegls_encode(*args, **kwargs):
        """Not implemented."""
        raise NotImplementedError('jpegls_encode')


# ZFP #########################################################################

# ZFP codecs are implemented in a separate extension module
#   because ZFP is not commonly available yet and might require OpenMP/CUDA.
# TODO: move implementation here once libzfp is available in Debian

try:
    from ._zfp import zfp_decode, zfp_encode, _ZFP_VERSION
except ImportError:
    _ZFP_VERSION = b'n/a'

    def zfp_decode(*args, **kwargs):
        """Not implemented."""
        raise NotImplementedError('zfp_decode')

    def zfp_encode(*args, **kwargs):
        """Not implemented."""
        raise NotImplementedError('zfp_encode')


# Imagecodecs Lite ############################################################

# Imagecodecs_lite contains all codecs that do not depend on 3rd party
# external C libraries.

from ._imagecodecs_lite import (
    none_decode, none_encode,
    numpy_decode, numpy_encode,
    delta_decode, delta_encode,
    xor_decode, xor_encode,
    floatpred_decode, floatpred_encode,
    bitorder_decode, bitorder_encode,
    packbits_decode, packbits_encode,
    packints_decode, packints_encode,
    lzw_decode, lzw_encode,
    _ICD_VERSION
)


###############################################################################

# TODO: add option not to release GIL
# TODO: split into individual extensions?
# TODO: Base64
# TODO: BMP
# TODO: CCITT and JBIG; JBIG-KIT is GPL
# TODO: LZO; http://www.oberhumer.com/opensource/lzo/ is GPL
# TODO: SZIP via libaec
# TODO: TIFF via libtiff
# TODO: LERC via https://github.com/Esri/lerc; patented but Apache licensed.
# TODO: OpenEXR via ILM's library
