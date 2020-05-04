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
# Test reading various formats with the generic image reader.
@testset "pix_read(filename) | type = $type" for (type, generator) in [
            ("bmp", bmp_file_with), ("gif", gif_file_with), ("jpeg", jpeg_file_with),
            ("png", png_file_with), ("pnm", pnm_file_with), ("spix", spix_file_with),
            ("tiff", tiff_file_with), ("webp", webp_file_with)
        ]
    local filename = generator()

    @test pix_read(filename) != nothing

    rm(filename)
end

# =================================================================================================
# Test reading a JPEG with parameters.
@testset "pix_read(filename) | type = jpeg /w parameters" begin
    local filename = jpeg_file_with()

    @test pix_read(filename) != nothing
    @suppress @test pix_read(filename; jpgLuminance = true) != nothing
    @test pix_read(filename; jpgFailOnBadData = true) != nothing
    @suppress @test pix_read(filename; jpgLuminance = true, jpgFailOnBadData = true) != nothing

    rm(filename)
end

# =================================================================================================
# Test reading with bad parameters.
@testset "pix_read(filename) /w bad parameters" begin

    local filename = safe_tmp_file()
    @suppress begin
        @test pix_read(filename) == nothing
        @test pix_read("xyzzy.dat") == nothing
        @test pix_read(filename; jpgFailOnBadData = true) == nothing
        @test pix_read("xyzzy.dat"; jpgFailOnBadData = true) == nothing
        @test pix_read(filename; jpgLuminance = true) == nothing
        @test pix_read("xyzzy.dat"; jpgLuminance = true) == nothing
        @test pix_read(filename; jpgLuminance = true, jpgFailOnBadData = true) == nothing
        @test pix_read("xyzzy.dat"; jpgLuminance = true, jpgFailOnBadData = true) == nothing
    end
    rm(filename)
end

# =================================================================================================
# Test reading various formats with pix_read(IO..) method.
@testset "pix_read(IO) | type = $type" for (type, generator) in [
            ("bmp", bmp_with), ("gif", gif_with), ("jpeg", jpeg_with), ("jp2k", jpeg_with),
            ("png", png_with), ("pnm", pnm_with), ("spix", spix_with), ("tiff", tiff_with),
            ("webp", webp_with)
        ]
    local data = generator()

    @test pix_read(IOBuffer(data)) != nothing

    local filename = safe_tmp_file()
    write(filename, data)

    local file = open(filename; read = true)

    @test pix_read(file) != nothing

    close(file)
    rm(filename)
end

# =================================================================================================
# Test reading with bad parameters.
@testset "pix_read(IO) /w empty stream" begin
    @test pix_read(IOBuffer()) == nothing
end

# =================================================================================================
# Test reading various formats with pix_read(Vector..) method.
@testset "pix_read(Vector{UInt8}) | type = $type" for (type, generator) in [
            ("bmp", bmp_with), ("gif", gif_with), ("jpeg", jpeg_with), ("jp2k", jp2k_with),
            ("png", png_with), ("pnm", pnm_with), ("spix", spix_with), ("tiff", tiff_with),
            ("webp", webp_with)
        ]
    local data = generator()
    @test pix_read(data) != nothing
end

# =================================================================================================
# Test reading with bad parameters.
@testset "pix_read(Vector{UInt8}) /w empty stream" begin
    @test pix_read(Vector{UInt8}()) == nothing
end
