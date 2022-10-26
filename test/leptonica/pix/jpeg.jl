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
# Test reading/writing a JPG image.
@testset "pix_write_jpeg/pix_read_jpeg" begin

    local pix = pix_with()

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_jpeg(filename, pix) == true
    @test pix_read_jpeg(filename) !== nothing
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_jpeg(buffer, pix) == true
    @test position(buffer) != 0
    seekstart(buffer)
    @test pix_read_jpeg(buffer) !== nothing

    # ---------------------------------------------------------------------------------------------
    # To/From an IOStream
    local filename = safe_tmp_file()
    local file     = open(filename, read=true, write=true)
    @test pix_write_jpeg(file, pix) == true
    @test position(file) != 0
    seekstart(file)
    @test pix_read_jpeg(file) !== nothing
    close(file)
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    local data  = jpeg_with()
    local bytes = pix_write_jpeg(pix)
    @test length(bytes) > 0
    @test pix_read_jpeg(bytes) !== nothing
end

# =================================================================================================
# Test writing a JPG image at various qualities.
@testset "pix_write_jpeg | quality = $quality, progressive = $progressive" for
        quality in [ 1, 25, 50, 75, 100 ], progressive in [ true, false ]

    local pix = pix_with()

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_jpeg(filename, pix; quality = quality, progressive = progressive) == true
    @test pix_read_jpeg(filename) !== nothing
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_jpeg(buffer, pix; quality = quality, progressive = progressive) == true
    @test position(buffer) != 0
    seekstart(buffer)
    @test pix_read_jpeg(buffer) !== nothing

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    local data  = jpeg_with()
    local bytes = pix_write_jpeg(pix; quality = quality, progressive = progressive)
    @test length(bytes) > 0
    @test pix_read_jpeg(bytes) !== nothing
end

# =================================================================================================
# Test reading a JPG image /w parameters
@testset "pix_read_jpeg | cmap = $cmap, reduction = $reduction, luminance = $luminance" for
        cmap in [ true, false ], reduction in [ 1, 2, 4, 8 ], luminance in [ true, false ]

    local pix = pix_with()
    @suppress begin
        # -----------------------------------------------------------------------------------------
        # To/From a file.
        local filename = safe_tmp_file()
        @test pix_write_jpeg(filename, pix) == true
        @test pix_read_jpeg(filename; cmap = cmap, reduction = reduction, luminance = luminance) !== nothing
        rm(filename)

        # -----------------------------------------------------------------------------------------
        # To/From an IOBuffer.
        local buffer = IOBuffer()
        @test pix_write_jpeg(buffer, pix) == true
        @test position(buffer) != 0
        seekstart(buffer)
        @test pix_read_jpeg(buffer; cmap = cmap, reduction = reduction, luminance = luminance) !== nothing

        # -----------------------------------------------------------------------------------------
        # To/From a byte array.
        local data  = jpeg_with()
        local bytes = pix_write_jpeg(pix)
        @test length(bytes) > 0
        @test pix_read_jpeg(bytes; cmap = cmap, reduction = reduction, luminance = luminance) !== nothing
    end
end

# =================================================================================================
# Test reading empty data.
@testset "pix_read_jpeg empty data" begin
    @suppress begin
        # -----------------------------------------------------------------------------------------
        # From a file.
        local filename = safe_tmp_file()
        @test pix_read_jpeg(filename) === nothing
        @test pix_read_jpeg("xyzzy.jpg") === nothing
        rm(filename)

        # -----------------------------------------------------------------------------------------
        # From an IOBuffer.
        local buffer = IOBuffer()
        @test pix_read_jpeg(buffer) === nothing

        # -----------------------------------------------------------------------------------------
        # To/From a byte array.
        local bytes = Vector{UInt8}()
        @test pix_read_jpeg(bytes) === nothing
    end
end

# =================================================================================================
# Test pix_write_jpeg supplying bad qualities.
@testset "pix_write_jpeg /w invalid values" begin
    local pix = pix_with()
    local err = "Quality must be between 1 and 100 inclusive."

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_jpeg(filename, pix; quality = 0)) == false
    @test filesize(filename) == 0
    @test (@test_logs (:error, err) pix_write_jpeg(filename, pix; quality = -1)) == false
    @test filesize(filename) == 0
    @test (@test_logs (:error, err) pix_write_jpeg(filename, pix; quality = 200)) == false
    @test filesize(filename) == 0
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_jpeg(buffer, pix; quality = 0)) == false
    @test length(take!(buffer)) == 0
    @test (@test_logs (:error, err) pix_write_jpeg(buffer, pix; quality = -1)) == false
    @test length(take!(buffer)) == 0
    @test (@test_logs (:error, err) pix_write_jpeg(buffer, pix; quality = 200)) == false
    @test length(take!(buffer)) == 0
    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_jpeg(pix; quality = 0)) === nothing
    @test (@test_logs (:error, err) pix_write_jpeg(pix; quality = -1)) === nothing
    @test (@test_logs (:error, err) pix_write_jpeg(pix; quality = 200)) === nothing
end

# =================================================================================================
# Test reading/writing a JPG image.
@testset "pix_read_jpeg /w invalid values" begin
    local pix = pix_with()
    local err = "Reduction must be 1, 2, 4, or 8."

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_jpeg(filename, pix) == true
    @test (@test_logs (:error, err) pix_read_jpeg(filename; reduction = 0)) === nothing
    @test (@test_logs (:error, err) pix_read_jpeg(filename; reduction = 7)) === nothing
    @test (@test_logs (:error, err) pix_read_jpeg(filename; reduction = 16)) === nothing
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_jpeg(buffer, pix) == true
    @test position(buffer) != 0
    seekstart(buffer)
    @test (@test_logs (:error, err) pix_read_jpeg(buffer; reduction = 0)) === nothing
    seekstart(buffer)
    @test (@test_logs (:error, err) pix_read_jpeg(buffer; reduction = 7)) === nothing
    seekstart(buffer)
    @test (@test_logs (:error, err) pix_read_jpeg(buffer; reduction = 16)) === nothing

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    local bytes = pix_write_jpeg(pix)
    @test length(bytes) > 0
    @test (@test_logs (:error, err) pix_read_jpeg(bytes; reduction = 0)) === nothing
    @test (@test_logs (:error, err) pix_read_jpeg(bytes; reduction = 7)) === nothing
    @test (@test_logs (:error, err) pix_read_jpeg(bytes; reduction = 16)) === nothing
end

# =================================================================================================
# Test writing a Pix that has been freed.
@testset "pix_write_jpeg /w freed Pix" begin
    local err = "Pix has been freed."
    local pix = pix_with()
    pix_delete!(pix)

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_jpeg(filename, pix)) == false
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_jpeg(buffer, pix)) == false

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_jpeg(pix)) === nothing
end
