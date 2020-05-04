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

# -------------------------------------------------------------------------------------------------
# Test tess_init()
@testset "tess_init" begin
    local inst = TessInst()
    @test tess_init(inst) == true

    local inst = TessInst()
    @test tess_init(inst; dataPath = DATA_PATH) == true

    local inst = TessInst()
    @test tess_init(inst; dataPath = DATA_PATH) == true

    local inst = TessInst()
    @test tess_init(inst; language = "eng") == true

    local inst = TessInst()
    @test tess_init(inst; dataPath = DATA_PATH, language = "eng") == true

    @suppress begin
        local inst = TessInst()
        @test tess_init(inst; dataPath = ".") == false

        local inst = TessInst()
        @test tess_init(inst; language = "zzzz") == false

        local inst = TessInst()
        @test tess_init(inst; dataPath = ".", language = "zzzz") == false
    end

    local err  = "Instance has been freed."
    local inst = TessInst()
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_init(inst)) == false
end

# -------------------------------------------------------------------------------------------------
# Test tess_initialized_languages()
@testset "tess_initialized_languages" begin
    local inst = TessInst()

    @test tess_initialized_languages(inst) == ""
    @test tess_init(inst) == true
    @test tess_initialized_languages(inst) == "eng"

    local err  = "Instance has been freed."
    local inst = TessInst()
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_initialized_languages(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_loaded_languages()
@testset "tess_loaded_languages" begin
    local inst = TessInst()

    @test isempty(tess_loaded_languages(inst))
    @test tess_init(inst) == true
    @test tess_loaded_languages(inst) == [ "eng" ]

    local err  = "Instance has been freed."
    local inst = TessInst()
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_loaded_languages(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_available_languages()
@testset "tess_available_languages" begin
    local inst = TessInst()

    @test tess_available_languages(inst) == Vector{String}()
    @test tess_init(inst) == true
    @test length(tess_available_languages(inst)) > 0

    local err  = "Instance has been freed."
    local inst = TessInst()
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_available_languages(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_default_params()
@testset "tess_default_params" begin
    local inst = TessInst()

    @test tess_init(inst) == true
    @test isempty(tess_available_languages(inst)) == false

    local err  = "Instance has been freed."
    local inst = TessInst()
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_available_languages(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_read_config()
@testset "tess_read_config" begin
    local inst = TessInst()

    @test tess_init(inst) == true

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
    local inst = TessInst()
    tess_delete!(inst)
    @test_logs (:error, err) tess_read_config(inst, filename)
end

# -------------------------------------------------------------------------------------------------
# Test tess_read_debug_config()
@testset "tess_read_debug_config" begin
    local inst = TessInst()

    @test tess_init(inst) == true

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
    local inst = TessInst()
    tess_delete!(inst)
    @test_logs (:error, err) tess_read_debug_config(inst, filename)
end
