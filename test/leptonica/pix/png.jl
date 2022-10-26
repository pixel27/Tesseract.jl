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
# Test writing a PNG image.
@testset "pix_write_png/pix_read_png" begin
    local pix      = pix_with()
    local original = pix_write_pam(pix)

    function unchanged(test)
        test !== nothing && pix_write_pam(test) == original
    end

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_png(filename, pix) == true
    @test unchanged(pix_read_png(filename))
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_png(buffer, pix) == true
    @test position(buffer) != 0
    seekstart(buffer)
    @test unchanged(pix_read_png(buffer))

    # ---------------------------------------------------------------------------------------------
    # To/From an IOStream
    local filename = safe_tmp_file()
    local file     = open(filename, read=true, write=true)
    @test pix_write_png(file, pix) == true
    @test position(file) != 0
    seekstart(file)
    @test unchanged(pix_read_png(file))
    close(file)
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    local bytes = pix_write_png(pix)
    @test length(bytes) > 0
    @test unchanged(pix_read_png(bytes))
end

# =================================================================================================
# Test reading empty data.
@testset "pix_read_png empty data" begin

    @suppress begin
        # -----------------------------------------------------------------------------------------
        # From a file.
        local filename = safe_tmp_file()
        @test pix_read_png(filename) === nothing
        @test pix_read_png("xyzzy.png") === nothing
        rm(filename)

        # -----------------------------------------------------------------------------------------
        # From an IOBuffer.
        local buffer = IOBuffer()
        @test pix_read_png(buffer) === nothing

        # -----------------------------------------------------------------------------------------
        # From an IOStream
        local filename = safe_tmp_file()
        local file     = open(filename, read=true, write=true)
        @test pix_read_png(file) === nothing
        close(file)
        rm(filename)

        # -----------------------------------------------------------------------------------------
        # To/From a byte array.
        local bytes = Vector{UInt8}()
        @test pix_read_png(bytes) === nothing
    end
end

# =================================================================================================
# Test writing a PNG image with a gamma value.
@testset "pix_write_png/pix_read_png | gamma = $gamma" for gamma in [0.0, 0.5, 1.0]
    local pix = pix_with()

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_png(filename, pix; gamma = gamma) == true
    @test pix_read_png(filename) !== nothing
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_png(buffer, pix; gamma = gamma) == true
    @test position(buffer) != 0
    seekstart(buffer)
    @test pix_read_png(buffer) !== nothing

    # ---------------------------------------------------------------------------------------------
    # To/From an IOStream
    local filename = safe_tmp_file()
    local file     = open(filename, read=true, write=true)
    @test pix_write_png(file, pix; gamma = gamma) == true
    @test position(file) != 0
    seekstart(file)
    @test pix_read_png(file) !== nothing
    close(file)
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    local bytes = pix_write_png(pix; gamma = gamma)
    @test length(bytes) > 0
    @test pix_read_png(bytes) !== nothing
end

# =================================================================================================
# Test writing a PNG with an invalid gamma value.
@testset "pix_write_png /w invalid values | gamma = $gamma" for gamma in [ -1.0, 2.0, 1.00001, -0.0000001 ]
    local pix = pix_with()
    local err = "Gamma must be in the range of 0.0 to 1.0 inclusive."

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_png(filename, pix; gamma = gamma)) == false
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_png(buffer, pix; gamma = gamma)) == false
    @test position(buffer) == 0

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    @test (@test_logs (:error, err) pix_write_png(pix; gamma = gamma)) === nothing
end

# =================================================================================================
# Test writing a Pix that has been freed.
@testset "pix_write_png /w freed Pix" begin
    local err = "Pix has been freed."
    local pix = pix_with()
    pix_delete!(pix)

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_png(filename, pix)) == false
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_png(buffer, pix)) == false

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_png(pix)) === nothing
end
