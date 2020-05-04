# MIT License
#
# Copyright (c) 2020 Joshua E Gentry

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# =================================================================================================
"""
    @enum IFF begin
        IFF_UNKNOWN        = 0
        IFF_BMP            = 1
        IFF_JFIF_JPEG      = 2
        IFF_PNG            = 3
        IFF_TIFF           = 4
        IFF_TIFF_PACKBITS  = 5
        IFF_TIFF_RLE       = 6
        IFF_TIFF_G3        = 7
        IFF_TIFF_G4        = 8
        IFF_TIFF_LZW       = 9
        IFF_TIFF_ZIP       = 10
        IFF_PNM            = 11
        IFF_PS             = 12
        IFF_GIF            = 13
        IFF_JP2            = 14
        IFF_WEBP           = 15
        IFF_LPDF           = 16
        IFF_TIFF_JPEG      = 17
        IFF_DEFAULT        = 18
        IFF_SPIX           = 19
    end

Various constants used by leptonica to specify image types.

__Details:__

| Value             | Description
| :---------------- | :----------
| IFF_UNKNOWN       | Unknown image type.
| IFF_BMP           | BMP image.
| IFF_JFIF_JPEG     | JPEG image.
| IFF_PNG           | PNG image.
| IFF_TIFF          | TIFF image with no compression.
| IFF_TIFF_PACKBITS | TIFF image with pack bits compression.
| IFF_TIFF_RLE      | TIFF image with RLE compression.
| IFF_TIFF_G3       | TIFF image with G3 compression.
| IFF_TIFF_G4       | TIFF image with G4 compression.
| IFF_TIFF_LZW      | TIFF image with LZW compression.
| IFF_TIFF_ZIP      | TIFF image with ZIP compression.
| IFF_PNM           | PNM image.
| IFF_PS            | PostScript file.
| IFF_GIF           | GIF image.
| IFF_JP2           | JP2K image.
| IFF_WEBP          | WEBP image.
| IFF_LPDF          | PDF file.
| IFF_TIFF_JPEG     | TIFF image with JPEG compression.
| IFF_DEFAULT       | Default image type (used in saving).
| IFF_SPIX          | SPIX image.
"""
@enum IFF begin
    IFF_UNKNOWN        = 0
    IFF_BMP            = 1
    IFF_JFIF_JPEG      = 2
    IFF_PNG            = 3
    IFF_TIFF           = 4
    IFF_TIFF_PACKBITS  = 5
    IFF_TIFF_RLE       = 6
    IFF_TIFF_G3        = 7
    IFF_TIFF_G4        = 8
    IFF_TIFF_LZW       = 9
    IFF_TIFF_ZIP       = 10
    IFF_PNM            = 11
    IFF_PS             = 12
    IFF_GIF            = 13
    IFF_JP2            = 14
    IFF_WEBP           = 15
    IFF_LPDF           = 16
    IFF_TIFF_JPEG      = 17
    IFF_DEFAULT        = 18
    IFF_SPIX           = 19
end

# =================================================================================================
"""
    const TIFF_FORMATS = Set([
        IFF_TIFF, IFF_TIFF_RLE, IFF_TIFF_PACKBITS, IFF_TIFF_G3,
        IFF_TIFF_G4, IFF_TIFF_LZW, IFF_TIFF_ZIP, IFF_TIFF_JPEG
    ])

The set of ways an image can be encoded in a TIFF image.
"""
const TIFF_FORMATS = Set([
    IFF_TIFF, IFF_TIFF_RLE, IFF_TIFF_PACKBITS, IFF_TIFF_G3,
    IFF_TIFF_G4, IFF_TIFF_LZW, IFF_TIFF_ZIP, IFF_TIFF_JPEG
])
