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
using Test
using Tesseract

# -------------------------------------------------------------------------------------------------
# Test tess_init()
@testset "tess_init" begin
    local inst = TessInst("eng", datadir)
    @test tess_init(inst, "eng", datadir) == true

    @suppress begin
        local inst = TessInst("eng", datadir)
        @test tess_init(inst, "eng", ".") == false

        local inst = TessInst("eng", datadir)
        @test tess_init(inst, "zzzz", datadir) == false

        local inst = TessInst("eng", datadir)
        @test tess_init(inst, "zzzz", ".") == false
    end

    local err  = "Instance has been freed."
    local inst = TessInst("eng", datadir)
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_init(inst, "eng", datadir)) == false
end

# -------------------------------------------------------------------------------------------------
# Test tess_initialized_languages()
@testset "tess_initialized_languages" begin
    local inst = TessInst("eng", datadir)

    @test tess_initialized_languages(inst) == "eng"

    local err  = "Instance has been freed."
    local inst = TessInst("eng", datadir)
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_initialized_languages(inst)) === nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_loaded_languages()
@testset "tess_loaded_languages" begin
    local inst = TessInst("eng", datadir)

    @test tess_loaded_languages(inst) == [ "eng" ]

    local err  = "Instance has been freed."
    local inst = TessInst("eng", datadir)
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_loaded_languages(inst)) === nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_available_languages()
@testset "tess_available_languages" begin
    local inst = TessInst("eng", datadir)

    @test length(tess_available_languages(inst)) > 0

    local err  = "Instance has been freed."
    local inst = TessInst("eng", datadir)
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_available_languages(inst)) === nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_params()
@testset "tess_params()" begin
    local inst = TessInst("eng", datadir)

    @test isempty(tess_params(inst)) == false

    local err  = "Instance has been freed."
    local inst = TessInst("eng", datadir)
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_params(inst)) === nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_params(filename)
@testset "tess_params(filename)" begin
    local inst = TessInst("eng", datadir)
    local file = safe_tmp_file()

    @test tess_params(inst, file) == true
    @test filesize(file) > 0
    rm(file)

    local err  = "Instance has been freed."
    local file = safe_tmp_file()
    local inst = TessInst("eng", datadir)
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_params(inst, file)) == false
    @test filesize(file) == 0
    rm(file)
end

# -------------------------------------------------------------------------------------------------
# Test tess_params(IO)
@testset "tess_default_params(IO)" begin
    local inst = TessInst("eng", datadir)

    local buffer = IOBuffer()
    @test tess_params(inst, buffer) == true
    @test length(take!(buffer)) > 0

    local err  = "Instance has been freed."
    local inst = TessInst("eng", datadir)
    local buffer = IOBuffer()
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_params(inst, buffer)) == false
    @test length(take!(buffer)) == 0
end

# -------------------------------------------------------------------------------------------------
# Test tess_params_parsed()
@testset "tess_params_parsed()" begin
    local inst = TessInst("eng", datadir)

    @test isempty(tess_params_parsed(inst)) == false

    local err  = "Instance has been freed."
    local inst = TessInst("eng", datadir)
    tess_delete!(inst)
    @test (@test_logs (:error, err) isempty(tess_params_parsed(inst))) == true
end

# -------------------------------------------------------------------------------------------------
# Test tess_read_config()
@testset "tess_read_config" begin
    local inst = TessInst("eng", datadir)

    local filename, io = mktemp(;cleanup=false)

    try
        println(io, "tessedit_char_blacklist amz")
        println(io, "dawg_debug_level 3")
        close(io)
        @test_nowarn tess_read_config(inst, filename)
    finally
        rm(filename)
    end

    local err  = "Instance has been freed."
    local inst = TessInst("eng", datadir)
    tess_delete!(inst)
    @test_logs (:error, err) tess_read_config(inst, filename)
end

# -------------------------------------------------------------------------------------------------
# Test tess_read_debug_config()
@testset "tess_read_debug_config" begin
    local inst = TessInst("eng", datadir)

    local filename, io = mktemp(;cleanup=false)

    try
        println(io, "tessedit_char_blacklist amz")
        println(io, "dawg_debug_level 3")
        close(io)
        @test_nowarn tess_read_debug_config(inst, filename)
    finally
        rm(filename)
    end

    local err  = "Instance has been freed."
    local inst = TessInst("eng", datadir)
    tess_delete!(inst)
    @test_logs (:error, err) tess_read_debug_config(inst, filename)
end
