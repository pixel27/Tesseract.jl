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
# Test writing a (single) TIFF image.
@testset "pix_write_tiff/pix_read_tiff (single/$compression)" for compression in
        [IFF_TIFF, IFF_TIFF_JPEG, IFF_TIFF_LZW, IFF_TIFF_ZIP]
    local pix = pix_with()

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_tiff(filename, pix; compression = compression) == true
    @test pix_read_tiff(filename) != nothing
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_tiff(buffer, pix; compression = compression) == true
    @test position(buffer) != 0
    seekstart(buffer)
    @test pix_read_tiff(buffer) != nothing

    # ---------------------------------------------------------------------------------------------
    # To/From an IOStream
    local filename = safe_tmp_file()
    local file     = open(filename, read=true, write=true)
    @test pix_write_tiff(file, pix; compression = compression) == true
    @test position(file) != 0
    seekstart(file)
    @test pix_read_tiff(file) != nothing
    close(file)
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    local data  = tiff_with()
    local bytes = pix_write_tiff(pix; compression = compression)
    @test length(bytes) > 0
    @test pix_read_tiff(bytes) != nothing
end

# =================================================================================================
# Test reading empty data.
@testset "pix_read_tiff empty data" begin

    @suppress begin
        # -----------------------------------------------------------------------------------------
        # From a file.
        local filename = safe_tmp_file()
        @test pix_read_tiff(filename) == nothing
        @test pix_read_tiff("xyzzy.tiff") == nothing
        rm(filename)

        # -----------------------------------------------------------------------------------------
        # From an IOBuffer.
        local buffer = IOBuffer()
        @test pix_read_tiff(buffer) == nothing

        # -----------------------------------------------------------------------------------------
        # From an IOStream
        local filename = safe_tmp_file()
        local file     = open(filename, read=true, write=true)
        @test pix_read_tiff(file) == nothing
        close(file)
        rm(filename)

        # -----------------------------------------------------------------------------------------
        # To/From a byte array.
        local bytes = Vector{UInt8}()
        @test pix_read_tiff(bytes) == nothing
    end
end

# =================================================================================================
# Test for failure when TIFF compression requires a bit depth of 1.
@testset "pix_write_tiff invalid $compression when bit depth > 1" for compression in
        [IFF_TIFF_RLE, IFF_TIFF_G3, IFF_TIFF_G4, IFF_TIFF_PACKBITS]
    local err = "Invalid compression, bit depth must be 1 for compression $compression."
    local pix = pix_with()

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test (
        @test_logs (:error, err) pix_write_tiff(filename, pix; compression = compression)
        ) == false
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test (
        @test_logs (:error, err) pix_write_tiff(buffer, pix; compression = compression)
        ) == false

    # ---------------------------------------------------------------------------------------------
    # To/From an IOStream
    local filename = safe_tmp_file()
    local file     = open(filename, read=true, write=true)
    @test (
        @test_logs (:error, err) pix_write_tiff(file, pix; compression = compression)
        ) == false
    close(file)
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    local data  = tiff_with()
    @test (
        @test_logs (:error, err) pix_write_tiff(pix; compression = compression)
        ) == nothing
end

# =================================================================================================
# Test reading/writing multiple TIFF images to/from a file.
@testset "pix_write_tiff/pix_read_tiff (multiple/$compression)" for compression in
        [IFF_TIFF, IFF_TIFF_LZW, IFF_TIFF_ZIP]
    local pixs = [
        pix_with([Line("The quick brown fox jumped over the lazy dog.")]),
        pix_with([Line("Suzy sells sea shells by the sea shore.", italic=true)]),
        pix_with([Line("The sixth sick sheik's sixth sheep's sick.", bold=true)])
    ]

    function equal(pic, i)
        pic != nothing && pix_write_pam(pic) == pix_write_pam(pixs[i])
    end

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_tiff(filename, pixs[1]; compression=compression, append=false) == true
    @test pix_write_tiff(filename, pixs[2]; compression=compression, append=true) == true
    @test pix_write_tiff(filename, pixs[3]; compression=compression, append=true) == true
    @test pix_read_tiff(filename; page=0) == nothing
    @test equal(pix_read_tiff(filename; page=1), 1) == true
    @test equal(pix_read_tiff(filename; page=2), 2) == true
    @test equal(pix_read_tiff(filename; page=3), 3) == true
    @test pix_read_tiff(filename; page=4) == nothing

    # ---------------------------------------------------------------------------------------------
    # From an IOBuffer.
    local buffer = IOBuffer(read(filename))
    @test equal(pix_read_tiff(buffer), 1) == true
    seekstart(buffer)
    @test pix_read_tiff(buffer; page=0) == nothing
    seekstart(buffer)
    @test equal(pix_read_tiff(buffer; page=1), 1) == true
    seekstart(buffer)
    @test equal(pix_read_tiff(buffer; page=2), 2) == true
    seekstart(buffer)
    @test equal(pix_read_tiff(buffer; page=3), 3) == true
    seekstart(buffer)
    @test pix_read_tiff(buffer; page=4) == nothing

    # ---------------------------------------------------------------------------------------------
    # From an IOStream
    local file = open(filename, read=true, write=true)
    @test equal(pix_read_tiff(file), 1) == true
    seekstart(file)
    @test pix_read_tiff(file; page=0) == nothing
    seekstart(file)
    @test equal(pix_read_tiff(file; page=1), 1) == true
    seekstart(file)
    @test equal(pix_read_tiff(file; page=2), 2) == true
    seekstart(file)
    @test equal(pix_read_tiff(file; page=3), 3) == true
    seekstart(file)
    @test pix_read_tiff(file; page=4) == nothing
    close(file)

    # ---------------------------------------------------------------------------------------------
    # From a byte array.
    local data = read(filename)
    @test equal(pix_read_tiff(data), 1) == true
    @test pix_read_tiff(filename; page=0) == nothing
    @test equal(pix_read_tiff(data; page=1), 1) == true
    @test equal(pix_read_tiff(data; page=2), 2) == true
    @test equal(pix_read_tiff(data; page=3), 3) == true
    @test pix_read_tiff(filename; page=4) == nothing

    rm(filename)
end

# =================================================================================================
# Test writing mutliple TIFF images to a file with the IFF_TIFF_JPEG encoding.
@testset "pix_write_tiff/pix_read_tiff (multiple/IFF_TIFF_JPEG)" begin
    local pixs = [
        pix_with([Line("The quick brown fox jumped over the lazy dog.")]),
        pix_with([Line("Suzy sells sea shells by the sea shore.", italic=true)]),
        pix_with([Line("The sixth sick sheik's sixth sheep's sick.", bold=true)])
    ]

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_tiff(filename, pixs[1]; compression=IFF_TIFF_JPEG, append=false) == true
    @test pix_write_tiff(filename, pixs[2]; compression=IFF_TIFF_JPEG, append=true) == true
    @test pix_write_tiff(filename, pixs[3]; compression=IFF_TIFF_JPEG, append=true) == true
    @test pix_read_tiff(filename; page=0) == nothing
    @test pix_read_tiff(filename; page=1) != nothing
    @test pix_read_tiff(filename; page=2) != nothing
    @test pix_read_tiff(filename; page=3) != nothing
    @test pix_read_tiff(filename; page=4) == nothing

    # ---------------------------------------------------------------------------------------------
    # From an IOBuffer.
    local buffer = IOBuffer(read(filename))
    @test pix_read_tiff(buffer) != nothing
    seekstart(buffer)
    @test pix_read_tiff(buffer; page=0) == nothing
    seekstart(buffer)
    @test pix_read_tiff(buffer; page=1) != nothing
    seekstart(buffer)
    @test pix_read_tiff(buffer; page=2) != nothing
    seekstart(buffer)
    @test pix_read_tiff(buffer; page=3) != nothing
    seekstart(buffer)
    @test pix_read_tiff(buffer; page=4) == nothing

    # ---------------------------------------------------------------------------------------------
    # From an IOStream
    local file = open(filename, read=true, write=true)
    @test pix_read_tiff(file) != nothing
    seekstart(file)
    @test pix_read_tiff(file; page=0) == nothing
    seekstart(file)
    @test pix_read_tiff(file; page=1) != nothing
    seekstart(file)
    @test pix_read_tiff(file; page=2) != nothing
    seekstart(file)
    @test pix_read_tiff(file; page=3) != nothing
    seekstart(file)
    @test pix_read_tiff(file; page=4) == nothing
    close(file)

    # ---------------------------------------------------------------------------------------------
    # From a byte array.
    local data = read(filename)
    @test pix_read_tiff(data) != nothing
    @test pix_read_tiff(data; page=0) == nothing
    @test pix_read_tiff(data; page=1) != nothing
    @test pix_read_tiff(data; page=2) != nothing
    @test pix_read_tiff(data; page=3) != nothing
    @test pix_read_tiff(data; page=4) == nothing

    rm(filename)
end

# =================================================================================================
# Test writing a Pix that has been freed.
@testset "pix_write_tiff /w freed Pix" begin
    local err = "Pix has been freed."
    local pix = pix_with()
    pix_delete!(pix)

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_tiff(filename, pix)) == false
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_tiff(buffer, pix)) == false

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_tiff(pix)) == nothing
end
