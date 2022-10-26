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
# Test reading/writing a J2K image.
@testset "pix_write_jp2k/pix_read_jp2k" begin

    local pix = pix_with()

    @suppress begin
        # -----------------------------------------------------------------------------------------
        # To/From a file.
        local filename = safe_tmp_file()
        @test pix_write_jp2k(filename, pix) == true
        @test pix_read_jp2k(filename) !== nothing
        rm(filename)

        # -----------------------------------------------------------------------------------------
        # To/From an IOBuffer.
        local buffer = IOBuffer()
        @test pix_write_jp2k(buffer, pix) == true
        @test position(buffer) != 0
        seekstart(buffer)
        @test pix_read_jp2k(buffer) !== nothing

        # -----------------------------------------------------------------------------------------
        # To/From an IOStream
        local filename = safe_tmp_file()
        local file     = open(filename, read=true, write=true)
        @test pix_write_jp2k(file, pix) == true
        @test position(file) != 0
        seekstart(file)
        @test pix_read_jp2k(file) !== nothing
        close(file)
        rm(filename)

        # -----------------------------------------------------------------------------------------
        # To/From a byte array.
        local data  = jp2k_with()
        local bytes = pix_write_jp2k(pix)
        @test length(bytes) > 0
        @test pix_read_jp2k(bytes) !== nothing
    end
end

# =================================================================================================
# Test writing a J2K image at various qualities.
@testset "pix_write_jp2k | quality = $quality, levels = $levels" for
        quality in [ 20, 34, 40, 45, 100  ], levels in [ 1, 5, 8 ]

    local pix = pix_with()
    @suppress begin
        # -----------------------------------------------------------------------------------------
        # To/From a file.
        local filename = safe_tmp_file()
        @test pix_write_jp2k(filename, pix; quality = quality, levels = levels) == true
        for i in 1:levels
            @test pix_read_jp2k(filename; reduction = 2^(i-1)) !== nothing
        end
        rm(filename)

        # -----------------------------------------------------------------------------------------
        # To/From an IOBuffer.
        local buffer = IOBuffer()
        @test pix_write_jp2k(buffer, pix; quality = quality, levels = levels) == true
        @test position(buffer) != 0
        for i in 1:levels
            seekstart(buffer)
            @test pix_read_jp2k(buffer; reduction = 2^(i-1)) !== nothing
        end

        # -----------------------------------------------------------------------------------------
        # To/From a byte array.
        local data  = jp2k_with()
        local bytes = pix_write_jp2k(pix; quality = quality, levels = levels)
        @test length(bytes) > 0
        for i in 1:levels
            @test pix_read_jp2k(bytes; reduction = 2^(i-1)) !== nothing
        end
    end
end

# =================================================================================================
# Test reading a J2K image /w box
@testset "pix_read_jp2k /w box | level = $level" for level in [1, 3 ]

    local pix = pix_with()
    local box = PixBox(
        IMAGE_WIDTH / 2,
        IMAGE_HEIGHT / 2,
        IMAGE_WIDTH / 2,
        IMAGE_HEIGHT / 2
    )
    @suppress begin
        # -----------------------------------------------------------------------------------------
        # To/From a file.
        local filename = safe_tmp_file()
        @test pix_write_jp2k(filename, pix) == true
        @test pix_read_jp2k(filename; box = box, reduction=2^(level-1)) !== nothing
        rm(filename)

        # -----------------------------------------------------------------------------------------
        # To/From an IOBuffer.
        local buffer = IOBuffer()
        @test pix_write_jp2k(buffer, pix) == true
        @test position(buffer) != 0
        seekstart(buffer)
        @test pix_read_jp2k(buffer; box = box, reduction=2^(level-1)) !== nothing

        # -----------------------------------------------------------------------------------------
        # To/From a byte array.
        local data  = jp2k_with()
        local bytes = pix_write_jp2k(pix)
        @test length(bytes) > 0
        @test pix_read_jp2k(bytes; box = box, reduction=2^(level-1)) !== nothing
    end

end

# =================================================================================================
# Test reading empty data.
@testset "pix_read_jp2k empty data" begin
    @suppress begin
        # -----------------------------------------------------------------------------------------
        # From a file.
        local filename = safe_tmp_file()
        @test pix_read_jp2k(filename) === nothing
        @test pix_read_jp2k("xyzzy.j2k") === nothing
        rm(filename)

        # -----------------------------------------------------------------------------------------
        # From an IOBuffer.
        local buffer = IOBuffer()
        @test pix_read_jp2k(buffer) === nothing

        # -----------------------------------------------------------------------------------------
        # To/From a byte array.
        local bytes = Vector{UInt8}()
        @test pix_read_jp2k(bytes) === nothing
    end
end

# =================================================================================================
# Test pix_write_jp2k supplying bad quality.
@testset "pix_write_jp2k /w invalid quality" begin
    local pix = pix_with()
    local err = "Quality must be between 1 and 100 inclusive."

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_jp2k(filename, pix; quality = -1)) == false
    @test filesize(filename) == 0
    @test (@test_logs (:error, err) pix_write_jp2k(filename, pix; quality = 0)) == false
    @test filesize(filename) == 0
    @test (@test_logs (:error, err) pix_write_jp2k(filename, pix; quality = 101)) == false
    @test filesize(filename) == 0
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_jp2k(buffer, pix; quality = -1)) == false
    @test length(take!(buffer)) == 0
    @test (@test_logs (:error, err) pix_write_jp2k(buffer, pix; quality = 0)) == false
    @test length(take!(buffer)) == 0
    @test (@test_logs (:error, err) pix_write_jp2k(buffer, pix; quality = 101)) == false
    @test length(take!(buffer)) == 0
    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_jp2k(pix; quality = -1)) === nothing
    @test (@test_logs (:error, err) pix_write_jp2k(pix; quality = 0)) === nothing
    @test (@test_logs (:error, err) pix_write_jp2k(pix; quality = 101)) === nothing
end

# =================================================================================================
# Test pix_write_jp2k supplying bad level.
@testset "pix_write_jp2k /w invalid level" begin
    local pix = pix_with()
    local err = "Levels must be between 1 and 10 inclusive."

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_jp2k(filename, pix; levels = -1)) == false
    @test filesize(filename) == 0
    @test (@test_logs (:error, err) pix_write_jp2k(filename, pix; levels = 0)) == false
    @test filesize(filename) == 0
    @test (@test_logs (:error, err) pix_write_jp2k(filename, pix; levels = 11)) == false
    @test filesize(filename) == 0
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_jp2k(buffer, pix; levels = -1)) == false
    @test length(take!(buffer)) == 0
    @test (@test_logs (:error, err) pix_write_jp2k(buffer, pix; levels = 0)) == false
    @test length(take!(buffer)) == 0
    @test (@test_logs (:error, err) pix_write_jp2k(buffer, pix; levels = 11)) == false
    @test length(take!(buffer)) == 0
    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_jp2k(pix; levels = -1)) === nothing
    @test (@test_logs (:error, err) pix_write_jp2k(pix; levels = 0)) === nothing
    @test (@test_logs (:error, err) pix_write_jp2k(pix; levels = 11)) === nothing
end

# =================================================================================================
# Test reading with invalid values.
@testset "pix_read_jp2k /w invalid values" begin
    local pix = pix_with()
    local err = "Reduction must be a factor of 2."

    # ---------------------------------------------------------------------------------------------
    # To/From a file.
    local filename = safe_tmp_file()
    @test pix_write_jp2k(filename, pix) == true
    @test (@test_logs (:error, err) pix_read_jp2k(filename; reduction = -1)) === nothing
    @test (@test_logs (:error, err) pix_read_jp2k(filename; reduction = 0)) === nothing
    @test (@test_logs (:error, err) pix_read_jp2k(filename; reduction = 13)) === nothing
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To/From an IOBuffer.
    local buffer = IOBuffer()
    @test pix_write_jp2k(buffer, pix) == true
    @test position(buffer) != 0
    seekstart(buffer)
    @test (@test_logs (:error, err) pix_read_jp2k(buffer; reduction = -1)) === nothing
    seekstart(buffer)
    @test (@test_logs (:error, err) pix_read_jp2k(buffer; reduction = 0)) === nothing
    seekstart(buffer)
    @test (@test_logs (:error, err) pix_read_jp2k(buffer; reduction = 9)) === nothing

    # ---------------------------------------------------------------------------------------------
    # To/From a byte array.
    local bytes = pix_write_jp2k(pix)
    @test length(bytes) > 0
    @test (@test_logs (:error, err) pix_read_jp2k(bytes; reduction = -1)) === nothing
    @test (@test_logs (:error, err) pix_read_jp2k(bytes; reduction = 0)) === nothing
    @test (@test_logs (:error, err) pix_read_jp2k(bytes; reduction = 6)) === nothing
end

# =================================================================================================
# Test writing a Pix that has been freed.
@testset "pix_write_jp2k /w freed Pix" begin
    local err = "Pix has been freed."
    local pix = pix_with()
    pix_delete!(pix)

    # ---------------------------------------------------------------------------------------------
    # To a file.
    local filename = safe_tmp_file()
    @test (@test_logs (:error, err) pix_write_jp2k(filename, pix)) == false
    rm(filename)

    # ---------------------------------------------------------------------------------------------
    # To an IOBuffer.
    local buffer = IOBuffer()
    @test (@test_logs (:error, err) pix_write_jp2k(buffer, pix)) == false

    # ---------------------------------------------------------------------------------------------
    # To a byte array.
    @test (@test_logs (:error, err) pix_write_jp2k(pix)) === nothing
end
