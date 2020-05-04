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
# Test writing a PNM image.
@testset "pix_write_pnm/pix_read_pnm" begin
    local pix = pix_with()

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_pnm(filename, pix) == true
    @test pix_read_pnm(filename) != nothing
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_pnm(buffer, pix) == true
    @test position(buffer) != 0
    seekstart(buffer)
    @test pix_read_pnm(buffer) != nothing

    # ---------------------------------------------------------------------------------------------
    # To/From an IOStream
    local filename = safe_tmp_file()
    local file     = open(filename, read=true, write=true)
    @test pix_write_pnm(file, pix) == true
    @test position(file) != 0
    seekstart(file)
    @test pix_read_pnm(file) != nothing
    close(file)
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    local bytes = pix_write_pnm(pix)
    @test length(bytes) > 0
    @test pix_read_pnm(bytes) != nothing
end

# =================================================================================================
# Test writing a Pix that has been freed.
@testset "pix_write_pnm /w freed Pix" begin
    local err = "Pix has been freed."
    local pix = pix_with()
    pix_delete!(pix)

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_pnm(filename, pix)) == false
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_pnm(buffer, pix)) == false

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_pnm(pix)) == nothing
end
