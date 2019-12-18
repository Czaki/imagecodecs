# -*- coding: utf-8 -*-
# _jpegls.pyx
# distutils: language = c
# cython: language_level = 3
# cython: boundscheck=False
# cython: wraparound=False
# cython: cdivision=True
# cython: nonecheck=False

# Copyright (c) 2019, Christoph Gohlke
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
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

"""JPEG-LS codec for the imagecodecs package.

:Author:
  `Christoph Gohlke <https://www.lfd.uci.edu/~gohlke/>`_

:Organization:
  Laboratory for Fluorescence Dynamics. University of California, Irvine

:License: BSD 3-Clause

:Version: 2019.12.16

"""

__version__ = '2019.12.16'

include '_imagecodecs.pxi'

from libc.stdint cimport uint8_t, int32_t, uint32_t
from libc.string cimport memset


# JPEG LS #####################################################################

from charls cimport *


class JpegLsError(RuntimeError):
    """JPEG-LS Exceptions."""
    def __init__(self, func, err):
        cdef:
            char *error_message
            charls_jpegls_errc error_value
        try:
            error_value = int(err)
            error_message = charls_get_error_message(error_value)
            msg = error_message.decode('utf8').strip()
        except Exception:
            msg = 'NULL' if err is None else 'unknown error %s' % err
        msg = "%s returned '%s'" % (func, msg)
        RuntimeError.__init__(self, msg)


def jpegls_encode(data, level=None, out=None):
    """Return JPEG-LS image from numpy array.

    """
    cdef:
        numpy.ndarray src = data
        const uint8_t[::1] dst  # must be const to write to bytes
        ssize_t dstsize
        ssize_t srcsize = src.size * src.itemsize
        charls_jpegls_errc ret
        charls_jpegls_encoder *encoder = NULL
        charls_frame_info frameinfo
        # charls_jpegls_pc_parameters preset_coding_parameters
        charls_interleave_mode interleave_mode
        int32_t near_lossless = _default_value(level, 0, 0, 9)
        uint32_t rowstride = src.strides[0]
        size_t byteswritten
        size_t size_in_bytes

    if data is out:
        raise ValueError('cannot encode in-place')

    if not (data.dtype in (numpy.uint8, numpy.uint16)
            and data.ndim in (2, 3)
            and numpy.PyArray_ISCONTIGUOUS(data)):
        raise ValueError('invalid input shape, strides, or dtype')

    out, dstsize, outgiven, outtype = _parse_output(out)

    if out is not None:
        dst = out
        dstsize = dst.size * dst.itemsize
    elif dstsize > 0:
        out = _create_output(outtype, dstsize)
        dst = out
        dstsize = dst.size * dst.itemsize

    # memset(&preset_coding_parameters, 0, sizeof(charls_jpegls_pc_parameters))
    # preset_coding_parameters.maximum_sample_value = 0
    # preset_coding_parameters.threshold1 = 0
    # preset_coding_parameters.threshold2 = 0
    # preset_coding_parameters.threshold3 = 0
    # preset_coding_parameters.reset_value = 0

    # memset(&frameinfo, 0, sizeof(charls_frame_info))
    frameinfo.width = <uint32_t>src.shape[1]
    frameinfo.height = <uint32_t>src.shape[0]
    frameinfo.bits_per_sample = <int32_t>(src.itemsize * 8)

    if src.ndim == 2 or src.shape[2] == 1:
        frameinfo.component_count = 1
        interleave_mode = CHARLS_INTERLEAVE_MODE_NONE
    elif src.shape[2] == 3:
        frameinfo.component_count = 3
        interleave_mode = CHARLS_INTERLEAVE_MODE_SAMPLE
    elif src.shape[2] == 4:
        frameinfo.component_count = 4
        interleave_mode = CHARLS_INTERLEAVE_MODE_LINE
    else:
        raise ValueError('invalid shape')

    try:
        with nogil:
            encoder = charls_jpegls_encoder_create()
            if encoder == NULL:
                raise JpegLsError('charls_jpegls_encoder_create', None)

            ret = charls_jpegls_encoder_set_frame_info(encoder, &frameinfo)
            if ret:
                raise JpegLsError('charls_jpegls_encoder_set_frame_info', ret)

            ret = charls_jpegls_encoder_set_near_lossless(
                encoder,
                near_lossless)
            if ret:
                raise JpegLsError(
                    'charls_jpegls_encoder_set_near_lossless', ret)

            ret = charls_jpegls_encoder_set_interleave_mode(
                encoder,
                interleave_mode)
            if ret:
                raise JpegLsError(
                    'charls_jpegls_encoder_set_interleave_mode', ret)

            # ret = charls_jpegls_encoder_set_color_transformation(
            #     encoder,
            #     color_transformation)
            # if ret:
            #     raise JpegLsError(
            #         'charls_jpegls_encoder_set_color_transformation', ret)

            # ret charls_jpegls_encoder_set_preset_coding_parameters(
            #     encoder,
            #     &preset_coding_parameters)
            # if ret:
            #    raise JpegLsError(
            #        'charls_jpegls_encoder_set_preset_coding_parameters', ret)

            if dstsize < 0:
                ret = charls_jpegls_encoder_get_estimated_destination_size(
                    encoder,
                    &size_in_bytes
                )
                if ret:
                    raise JpegLsError(
                        'charls_jpegls_encoder_get_estimated_destination_size',
                        ret)
                dstsize = size_in_bytes + sizeof(charls_spiff_header)
                with gil:
                    out = _create_output(outtype, dstsize)
                    dst = out
                    dstsize = dst.size * dst.itemsize

            ret = charls_jpegls_encoder_set_destination_buffer(
                encoder,
                <void*>&dst[0],
                <size_t>dstsize)
            if ret:
                raise JpegLsError(
                    'charls_jpegls_encoder_set_destination_buffer', ret)

            ret = charls_jpegls_encoder_write_standard_spiff_header(
                encoder,
                CHARLS_SPIFF_COLOR_SPACE_RGB,
                CHARLS_SPIFF_RESOLUTION_UNITS_DOTS_PER_INCH,
                300,
                300)
            if ret:
                raise JpegLsError(
                    'charls_jpegls_encoder_write_standard_spiff_header', ret)

            ret = charls_jpegls_encoder_encode_from_buffer(
                encoder,
                <const void*>src.data,
                <size_t>srcsize,
                <uint32_t>rowstride)
            if ret:
                raise JpegLsError(
                    'charls_jpegls_encoder_encode_from_buffer', ret)

            ret = charls_jpegls_encoder_get_bytes_written(
                encoder,
                &byteswritten)
            if ret:
                raise JpegLsError(
                    'charls_jpegls_encoder_get_bytes_written', ret)
    finally:
        if encoder != NULL:
            charls_jpegls_encoder_destroy(encoder)

    del dst
    return _return_output(out, dstsize, byteswritten, outgiven)


def jpegls_decode(data, out=None):
    """Return numpy array from JPEG LS image.

    """
    cdef:
        numpy.ndarray dst
        const uint8_t[::1] src = data
        ssize_t srcsize = src.size
        ssize_t dstsize
        ssize_t itemsize = 0
        charls_jpegls_errc ret
        charls_jpegls_decoder *decoder = NULL
        charls_interleave_mode interleave_mode
        charls_frame_info frameinfo
        # charls_spiff_header spiff_header
        # int32_t header_found

    if data is out:
        raise ValueError('cannot decode in-place')

    try:
        with nogil:
            decoder = charls_jpegls_decoder_create()
            if decoder == NULL:
                raise JpegLsError('charls_jpegls_decoder_create', None)

            ret = charls_jpegls_decoder_set_source_buffer(
                decoder,
                <void*>&src[0],
                <size_t>srcsize)
            if ret:
                raise JpegLsError(
                    'charls_jpegls_decoder_set_source_buffer', ret)

            # ret = charls_jpegls_decoder_read_spiff_header(
            #     decoder,
            #     &spiff_header,
            #     &header_found)
            # if ret:
            #     raise JpegLsError(
            #         'charls_jpegls_decoder_read_spiff_header', ret)

            ret = charls_jpegls_decoder_read_header(decoder)
            if ret:
                raise JpegLsError('charls_jpegls_decoder_read_header', ret)

            ret = charls_jpegls_decoder_get_frame_info(decoder, &frameinfo)
            if ret:
                raise JpegLsError('charls_jpegls_decoder_get_frame_info', ret)

            ret = charls_jpegls_decoder_get_interleave_mode(
                decoder,
                &interleave_mode)
            if ret:
                raise JpegLsError(
                    'charls_jpegls_decoder_get_interleave_mode', ret)

            with gil:
                if frameinfo.bits_per_sample <= 8:
                    dtype = numpy.uint8
                    itemsize = 1
                elif frameinfo.bits_per_sample <= 16:
                    dtype = numpy.uint16
                    itemsize = 2
                else:
                    raise ValueError(
                        'JpegLs bits_per_sample not supported: %i'
                        % frameinfo.bits_per_sample)

                if frameinfo.component_count == 1:
                    shape = (
                        frameinfo.height,
                        frameinfo.width
                    )
                    strides = (
                        frameinfo.width * itemsize,
                        itemsize
                    )
                elif interleave_mode == CHARLS_INTERLEAVE_MODE_NONE:
                    # planar
                    shape = (
                        frameinfo.component_count,
                        frameinfo.height,
                        frameinfo.width
                    )
                    strides = (
                        itemsize * frameinfo.width * frameinfo.height,
                        itemsize * frameinfo.width,
                        itemsize
                    )
                else:
                    # contig
                    # CHARLS_INTERLEAVE_MODE_LINE or
                    # CHARLS_INTERLEAVE_MODE_SAMPLE
                    shape = (
                        frameinfo.height,
                        frameinfo.width,
                        frameinfo.component_count
                    )
                    strides = (
                        itemsize * frameinfo.component_count * frameinfo.width,
                        itemsize * frameinfo.component_count,
                        itemsize
                    )
                out = _create_array(out, shape, dtype, strides=strides)
                dst = out
                dstsize = dst.size * dst.itemsize

            ret = charls_jpegls_decoder_decode_to_buffer(
                decoder,
                <void*>dst.data,
                <size_t>dstsize,
                0)

        if ret:
            raise JpegLsError('charls_jpegls_decoder_decode_to_buffer', ret)

    finally:
        if decoder != NULL:
            charls_jpegls_decoder_destroy(decoder)

    if (
        frameinfo.component_count > 1
        and interleave_mode == CHARLS_INTERLEAVE_MODE_NONE
    ):
        out = numpy.moveaxis(out, 0, -1)

    return out


def jpegls_version():
    """Return CharLS version string."""
    return 'charls %i.%i.%i' % (
        CHARLS_VERSION_MAJOR, CHARLS_VERSION_MINOR, CHARLS_VERSION_PATCH)
