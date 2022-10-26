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
# Test writing a PDF image.
@testset "pix_write_pdf" begin
    local pix = pix_with()

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test pix_write_pdf(filename, pix) == true
    @test filesize(filename) > 0
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_pdf(buffer, pix) == true
    @test length(take!(buffer)) > 0

    # ---------------------------------------------------------------------------------------------
    # To an IOStream
    local filename = safe_tmp_file()
    local file     = open(filename, read=true, write=true)
    @test pix_write_pdf(file, pix) == true
    @test position(file) != 0
    close(file)
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    local bytes = pix_write_pdf(pix)
    @test length(bytes) > 0
end

# =================================================================================================
# Test writing a PDF image.
@testset "pix_write_pdf | ppi = $ppi, title = $title" for
        ppi in [ 300, 600, 1200 ], title in [ "", "My Title"]
    local pix = pix_with()

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test pix_write_pdf(filename, pix; ppi = ppi, title = title) == true
    @test filesize(filename) > 0
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_pdf(buffer, pix; ppi = ppi, title = title) == true
    @test length(take!(buffer)) > 0

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    local bytes = pix_write_pdf(pix; ppi = ppi, title = title)
    @test length(bytes) > 0
end

# =================================================================================================
# Test writing a PDF image.
@testset "pix_write_pdf /w invalid values" begin
    local pix = pix_with()
    local err = "PPI needs to be greater than 0."

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_pdf(filename, pix; ppi = 0)) == false
    @test filesize(filename) == 0
    @test (@test_logs (:error, err) pix_write_pdf(filename, pix; ppi = -300)) == false
    @test filesize(filename) == 0
    @test (@test_logs (:error, err) pix_write_pdf(filename, pix; ppi = 0, title = "Testing the test")) == false
    @test filesize(filename) == 0
    @test (@test_logs (:error, err) pix_write_pdf(filename, pix; ppi = -300, title = "Testing the test")) == false
    @test filesize(filename) == 0
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_pdf(buffer, pix; ppi = 0)) == false
    @test length(take!(buffer)) == 0
    @test (@test_logs (:error, err) pix_write_pdf(buffer, pix; ppi = -300)) == false
    @test length(take!(buffer)) == 0
    @test (@test_logs (:error, err) pix_write_pdf(buffer, pix; ppi = 0, title = "Testing the test")) == false
    @test length(take!(buffer)) == 0
    @test (@test_logs (:error, err) pix_write_pdf(buffer, pix; ppi = -300, title = "Testing the test")) == false
    @test length(take!(buffer)) == 0

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    local bytes = Vector{UInt8}()
    @test (@test_logs (:error, err) pix_write_pdf(pix; ppi = 0)) === nothing
    @test (@test_logs (:error, err) pix_write_pdf(pix; ppi = -300)) === nothing
    @test (@test_logs (:error, err) pix_write_pdf(pix; ppi = 0, title = "Testing the test")) === nothing
    @test (@test_logs (:error, err) pix_write_pdf(pix; ppi = -300, title = "Testing the test")) === nothing
    @test length(bytes) == 0
end

# =================================================================================================
# Test writing a Pix that has been freed.
@testset "pix_write_pdf /w freed Pix" begin
    local err = "Pix has been freed."
    local pix = pix_with()
    pix_delete!(pix)

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_pdf(filename, pix)) == false
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_pdf(buffer, pix)) == false

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_pdf(pix)) === nothing
end
