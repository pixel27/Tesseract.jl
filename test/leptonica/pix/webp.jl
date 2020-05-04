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
# Test reading/writing a WEBP image.
@testset "pix_write_webp/pix_read_webp" begin
    local pix      = pix_with()
    local original = pix_write_pam(pix)

    function unchanged(test)
        test != nothing && pix_write_pam(test) == original
    end

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_webp(filename, pix) == true
    @test unchanged(pix_read_webp(filename)) == true
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_webp(buffer, pix) == true
    @test position(buffer) != 0
    seekstart(buffer)
    @test unchanged(pix_read_webp(buffer)) == true

    # ---------------------------------------------------------------------------------------------
    # To/From an IOStream
    local filename = safe_tmp_file()
    local file     = open(filename, read=true, write=true)
    @test pix_write_webp(file, pix) == true
    @test position(file) != 0
    seekstart(file)
    @test unchanged(pix_read_webp(file)) == true
    close(file)
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    local data  = webp_with()
    local bytes = pix_write_webp(pix)
    @test length(bytes) > 0
    @test unchanged(pix_read_webp(bytes)) == true
end

# =================================================================================================
# Test writing a WEBP image with lossless at various qualities.
@testset "pix_write_webp | lossless = true, quality = $quality" for quality in [ 1, 50, 100 ]
    local pix      = pix_with()
    local original = pix_write_pam(pix)

    function unchanged(test)
        test != nothing && pix_write_pam(test) == original
    end

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_webp(filename, pix; quality = quality, lossless = true) == true
    @test unchanged(pix_read_webp(filename)) == true
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_webp(buffer, pix; quality = quality, lossless = true) == true
    @test position(buffer) != 0
    seekstart(buffer)
    @test unchanged(pix_read_webp(buffer)) == true

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    local data  = webp_with()
    local bytes = pix_write_webp(pix; quality = quality, lossless = true)
    @test bytes != nothing
    @test length(bytes) > 0
    @test unchanged(pix_read_webp(bytes)) == true
end

# =================================================================================================
# Test writing a WEBP image as lossy at various qualities.
@testset "pix_write_webp | lossless = true, quality = $quality" for quality in [ 1, 50, 100 ]
    local pix = pix_with()

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_webp(filename, pix; quality = quality, lossless = true) == true
    @test pix_read_webp(filename) != nothing
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_webp(buffer, pix; quality = quality, lossless = true) == true
    @test position(buffer) != 0
    seekstart(buffer)
    @test pix_read_webp(buffer) != nothing

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    local data  = webp_with()
    local bytes = pix_write_webp(pix; quality = quality, lossless = true)
    @test bytes != nothing
    @test length(bytes) > 0
    @test pix_read_webp(bytes) != nothing
end

# =================================================================================================
# Test reading empty data.
@testset "pix_read_webp empty data" begin
    @suppress begin
        # -----------------------------------------------------------------------------------------
        # From a file.
        local filename = safe_tmp_file()
        @test pix_read_webp(filename) == nothing
        @test pix_read_webp("xyzzy.webp") == nothing
        rm(filename)

        # -----------------------------------------------------------------------------------------
        # From an IOBuffer.
        local buffer = IOBuffer()
        @test pix_read_webp(buffer) == nothing

        # -----------------------------------------------------------------------------------------
        # To/From a byte array.
        local bytes = Vector{UInt8}()
        @test pix_read_webp(bytes) == nothing
    end
end

# =================================================================================================
# Test pix_write_webp supplying bad qualities.
@testset "pix_write_webp /w invalid values" begin
    local pix = pix_with()
    local err = "Quality must be in the range of 1 to 100 inclusive."

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_webp(filename, pix; lossless = false, quality = 0)) == false
    @test filesize(filename) == 0
    @test (@test_logs (:error, err) pix_write_webp(filename, pix; lossless = false, quality = 101)) == false
    @test filesize(filename) == 0
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_webp(buffer, pix; lossless = false, quality = 0)) == false
    @test length(take!(buffer)) == 0
    @test (@test_logs (:error, err) pix_write_webp(buffer, pix; lossless = false, quality = 101)) == false
    @test length(take!(buffer)) == 0

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_webp(pix; lossless = false, quality = 0)) == nothing
    @test (@test_logs (:error, err) pix_write_webp(pix; lossless = false, quality = 101)) == nothing
end

# =================================================================================================
# Test writing a Pix that has been freed.
@testset "pix_write_webp /w freed Pix" begin
    local err = "Pix has been freed."
    local pix = pix_with()
    pix_delete!(pix)

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_webp(filename, pix)) == false
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_webp(buffer, pix)) == false

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_webp(pix)) == nothing
end
