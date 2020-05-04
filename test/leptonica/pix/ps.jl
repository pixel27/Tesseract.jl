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
# Test writing a PostScript file.
@testset "pix_write_ps" begin
    local pix = pix_with()
    local box = PixBox(IMAGE_WIDTH÷4, IMAGE_HEIGHT÷4, IMAGE_WIDTH÷2, IMAGE_HEIGHT÷2)

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test pix_write_ps(filename, pix) == true
    @test filesize(filename) > 0
    @test pix_write_ps(filename, pix; box = box) == true
    @test filesize(filename) > 0
    @test pix_write_ps(filename, pix; ppi = 600) == true
    @test filesize(filename) > 0
    @test pix_write_ps(filename, pix; scale = 3.0) == true
    @test filesize(filename) > 0
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_ps(buffer, pix) == true
    @test length(take!(buffer)) > 0
    @test pix_write_ps(buffer, pix; box = box) == true
    @test length(take!(buffer)) > 0
    @test pix_write_ps(buffer, pix; ppi = 150) == true
    @test length(take!(buffer)) > 0
    @test pix_write_ps(buffer, pix; scale = 3.0) == true
    @test length(take!(buffer)) > 0

    # ---------------------------------------------------------------------------------------------
    # To an IOStream
    local filename = safe_tmp_file()
    local file     = open(filename, read=true, write=true)
    @test pix_write_ps(file, pix) == true
    @test position(file) != 0
    seekstart(file)
    @test pix_write_ps(file, pix; box = box) == true
    seekstart(file)
    @test pix_write_ps(file, pix; ppi = 600) == true
    seekstart(file)
    @test pix_write_ps(file, pix; scale = 0.5) == true
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    local data  = png_with()
    local bytes = pix_write_ps(pix)
    @test length(bytes) > 0
    local bytes = pix_write_ps(pix)
    @test length(bytes) > 0

    # ---------------------------------------------------------------------------------------------
    # With a boxed region
    local data = png_with()
    local bytes = pix_write_ps(pix)
    @test length(bytes) > 0
    local bytes = pix_write_ps(pix; box = box)
    @test length(bytes) > 0
    local bytes = pix_write_ps(pix; ppi = 600)
    @test length(bytes) > 0
    local bytes = pix_write_ps(pix; scale = 0.5)
    @test length(bytes) > 0
end

# =================================================================================================
# Test writing a PostScript file /w invalid values.
@testset "pix_write_ps /w invalid values" begin
    local pix = pix_with()
    local box = PixBox(2000, 2000, 8000, 4000)
    local errPpi = "PPI must be positive."
    local errScale = "Scale must be positive."

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, errPpi) pix_write_ps(filename, pix; ppi = -300)) == false
    @test (@test_logs (:error, errScale) pix_write_ps(filename, pix; scale = -1.0)) == false
    @test (@test_logs (:error, errPpi) pix_write_ps(filename, pix; box = box, ppi = -300)) == false
    @test (@test_logs (:error, errScale) pix_write_ps(filename, pix; box = box, scale = -1.0)) == false
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, errPpi) pix_write_ps(buffer, pix; ppi = -300)) == false
    @test (@test_logs (:error, errScale) pix_write_ps(buffer, pix; scale = -1.0)) == false
    @test (@test_logs (:error, errPpi) pix_write_ps(buffer, pix; box = box, ppi = -300)) == false
    @test (@test_logs (:error, errScale) pix_write_ps(buffer, pix; box = box, scale = -1.0)) == false

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, errPpi) pix_write_ps(pix; ppi = -300)) == nothing
    @test (@test_logs (:error, errScale) pix_write_ps(pix; scale = -1.0)) == nothing
    @test (@test_logs (:error, errPpi) pix_write_ps(pix; box=box, ppi = -300)) == nothing
    @test (@test_logs (:error, errScale) pix_write_ps(pix; box=box, scale = -1.0)) == nothing
end

# =================================================================================================
# Test writing a Pix that has been freed.
@testset "pix_write_ps /w freed Pix" begin
    local err = "Pix has been freed."
    local pix = pix_with()
    pix_delete!(pix)

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_ps(filename, pix)) == false
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_ps(buffer, pix)) == false

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_ps(pix)) == nothing
end
