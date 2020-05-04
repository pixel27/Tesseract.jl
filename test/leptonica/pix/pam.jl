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
# Test writing a PAM image.
@testset "pix_write_pam" begin
    local pix = pix_with()

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test pix_write_pam(filename, pix) == true
    @test filesize(filename) > 0
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_pam(buffer, pix) == true
    @test length(take!(buffer)) > 0

    # ---------------------------------------------------------------------------------------------
    # To an IOStream
    local filename = safe_tmp_file()
    local file     = open(filename, read=true, write=true)
    @test pix_write_pam(file, pix) == true
    @test position(file) != 0
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    local bytes = pix_write_pam(pix)
    @test length(bytes) > 0
end

# =================================================================================================
# Test writing a Pix that has been freed.
@testset "pix_write_pam /w freed Pix" begin
    local err = "Pix has been freed."
    local pix = pix_with()
    pix_delete!(pix)

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_pam(filename, pix)) == false
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_pam(buffer, pix)) == false

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_pam(pix)) == nothing
end
