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
# pix_write() basic test.
@testset "pix_write(filename)" begin
    local filename = safe_tmp_file()
    local pix      = pix_with()

    @test pix_write(filename, pix) == true
    @test pix_read(filename) !== nothing

    rm(filename)
end

# =================================================================================================
# Test writing various formats with the generic image writer.
@testset "pix_write(filename) | format = $format" for format in [
            IFF_BMP, IFF_JFIF_JPEG, IFF_PNG, IFF_TIFF, IFF_TIFF_LZW, IFF_TIFF_ZIP, IFF_PNM, IFF_PS,
            IFF_GIF, IFF_JP2, IFF_WEBP, IFF_LPDF, IFF_TIFF_JPEG, IFF_DEFAULT, IFF_SPIX
        ]
    local filename = safe_tmp_file()
    local pix      = pix_with()

    @test pix_write(filename, pix, format) == true
    @test filesize(filename) > 0

    local err = "Pix has been freed."
    pix_delete!(pix)
    @test (@test_logs (:error, err) pix_write(filename, pix, format)) == false

    rm(filename)
end

# =================================================================================================
# Test writing various formats with the generic image writer.
@testset "pix_write(IO) | format = $format" for format in [
            IFF_BMP, IFF_JFIF_JPEG, IFF_PNG, IFF_TIFF, IFF_TIFF_LZW, IFF_TIFF_ZIP, IFF_PNM, IFF_PS,
            IFF_GIF, IFF_JP2, IFF_WEBP, IFF_LPDF, #= IFF_TIFF_JPEG, =# IFF_DEFAULT, IFF_SPIX
        ]
    local pix = pix_with()

    local filename = safe_tmp_file()
    local stream = open(filename; write = true, read = true)
    @test pix_write(stream, pix, format) == true
    close(stream)
    @test filesize(filename) > 0
    rm(filename)

    local buffer = IOBuffer()
    @test pix_write(buffer, pix, format) == true
    @test length(take!(buffer)) > 0

    local err = "Pix has been freed."
    pix_delete!(pix)
    @test (@test_logs (:error, err) pix_write(IOBuffer(), pix, format)) == false
end

# =================================================================================================
# Test writing various formats with the generic image writer to a byte array.
@testset "pix_write() | format = $format" for format in [
            IFF_BMP, IFF_JFIF_JPEG, IFF_PNG, IFF_TIFF, IFF_TIFF_LZW, IFF_TIFF_ZIP, IFF_PNM, IFF_PS,
            IFF_GIF, IFF_WEBP, IFF_LPDF, #= IFF_TIFF_JPEG, =# IFF_DEFAULT, IFF_SPIX
        ]
    local pix = pix_with()

    @test length(pix_write(pix, format)) > 0

    local err = "Pix has been freed."
    pix_delete!(pix)
    @test (@test_logs (:error, err) pix_write(pix, format)) === nothing
end

# =================================================================================================
# Test pix_write_implied_format() with various extensions.
@testset "pix_write_implied_format() | ext = $ext" for ext in [
            "bmp", "jpg", "jpeg", "png", "tif", "tiff", "pnm", "gif", "ps", "pdf", "webp"
        ]
    local filename = safe_tmp_file()
    local pix = pix_with()
    @test pix_write_implied_format("$filename.$ext", pix) == true
    @test filesize("$filename.$ext") > 0

    rm("$filename.$ext")
    rm(filename)

    local err = "Pix has been freed."
    pix_delete!(pix)
    @test (@test_logs (:error, err) pix_write_implied_format("$filename.$ext", pix)) == false
end

# =================================================================================================
# Test pix_write_implied_format() with a JPG file and parameters.
@testset "pix_write_implied_format() | ext = jpg /w parameters" begin

    local filename = safe_tmp_file()
    local pix = pix_with()
    @test pix_write_implied_format("$filename.jpg", pix; quality = 10) == true
    @test filesize("$filename.jpg") > 0
    @test pix_write_implied_format("$filename.jpg", pix; quality = 50) == true
    @test filesize("$filename.jpg") > 0
    @test pix_write_implied_format("$filename.jpg", pix; quality = 100) == true
    @test filesize("$filename.jpg") > 0
    @test pix_write_implied_format("$filename.jpg", pix; progressive = false) == true
    @test filesize("$filename.jpg") > 0
    @test pix_write_implied_format("$filename.jpg", pix; quality = 50, progressive = false) == true
    @test filesize("$filename.jpg") > 0

    local err = "Quality must be between 1 and 100 inclusive."
    @test (@test_logs (:error, err) pix_write_implied_format("$filename.jpg", pix; quality = 0)) == false
    @test (@test_logs (:error, err) pix_write_implied_format("$filename.jpg", pix; quality = -1)) == false
    @test (@test_logs (:error, err) pix_write_implied_format("$filename.jpg", pix; quality = 101)) == false

    local err = "Pix has been freed."
    pix_delete!(pix)
    @test (@test_logs (:error, err) pix_write_implied_format("$filename.jpg", pix)) == false

    rm("$filename.jpg")
    rm(filename)
end
