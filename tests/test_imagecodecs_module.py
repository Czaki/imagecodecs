import os

import pytest

try:
    import imagecodecs
    import imagecodecs.imagecodecs as imagecodecs_py
    from imagecodecs.imagecodecs import (lzma, zlib, bz2, zstd, lz4, lzf,
                                         blosc, bitshuffle)
    from imagecodecs import _imagecodecs  # noqa
except ImportError:
    pytest.exit('the imagecodec package is not installed')

try:
    from imagecodecs import _jpeg12
except ImportError:
    _jpeg12 = None

try:
    from imagecodecs import _jpegls
except ImportError:
    _jpegls = None

try:
    from imagecodecs import _zfp
except ImportError:
    _zfp = None


@pytest.mark.parametrize("name", [
    "_jpegls", "_zfp", "_jpeg12", "lzma", "zlib",
    "bz2", "zstd", "lz4", "lzf", "blosc", "bitshuffle"])
def test_module_exist(name):
    if name == "_jpeg12" and 'CG-' not in os.environ.get('COMPUTERNAME', ''):
        pytest.skip("_jpeg12 not supported in unix build")
    if name in ["_jpegls", "_zfp"] and 'CG-' not in os.environ.get('COMPUTERNAME', '') and \
            not os.environ.get("CIBUILDWHEEL", False):
        pytest.skip(name + " not supported in this build")
    assert globals()[name] is not None
