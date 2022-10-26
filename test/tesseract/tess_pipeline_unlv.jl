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

# =========================================================================================
# tess_pipeline_unlv(utf8 = true) => Filename
@testset "tess_pipeline_unlv(utf8 = true) => Filename" begin
    local inst       = TessInst("eng", datadir)
    local pipeline   = TessPipeline(inst)
    local output, io = mktemp(;cleanup=false); close(io)

    @test tess_pipeline_unlv(pipeline, output, true) == true

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two. ®")]), 72) == true
        @test add(pix_with([Line("This is image three. ®")]), 72) == true
        @test add(pix_with([Line("This is image four. ®")]), 72) == true
    end) == true

    @test isfile(output) == true
    @test filesize(output) > 0

    local text  = read(output, String)
    local lines = split(text, "\n"; keepempty=false)
    @test length(lines) == 4

    @test lines[1] == "This is image one. ®"
    @test lines[2] == "This is image two. ®"
    @test lines[3] == "This is image three. ®"
    @test lines[4] == "This is image four. ®"

    rm(output)
end

# =========================================================================================
# tess_pipeline_unlv(utf8 = true) => Filename
@testset "tess_pipeline_unlv(utf8 = false) => Filename" begin
    local inst       = TessInst("eng", datadir)
    local pipeline   = TessPipeline(inst)
    local output, io = mktemp(;cleanup=false); close(io)

    @test tess_pipeline_unlv(pipeline, output, false) == true

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two. ®")]), 72) == true
        @test add(pix_with([Line("This is image three. ®")]), 72) == true
        @test add(pix_with([Line("This is image four. ®")]), 72) == true
    end) == true

    @test isfile(output) == true
    @test filesize(output) > 0

    local text  = read(output, String)
    local lines = split(text, "\n"; keepempty=false)
    @test length(lines) == 4

    @test lines[1] == "This is image one. \xae"
    @test lines[2] == "This is image two. \xae"
    @test lines[3] == "This is image three. \xae"
    @test lines[4] == "This is image four. \xae"

    rm(output)
end

# =========================================================================================
# tess_pipeline_unlv() => String
@testset "tess_pipeline_unlv() => String" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local output   = tess_pipeline_unlv(pipeline)

    @test is_available(output) == false

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two. ®")]), 72) == true
        @test add(pix_with([Line("This is image three. ®")]), 72) == true
        @test add(pix_with([Line("This is image four. ®")]), 72) == true
    end) == true

    @test is_available(output) == true
    @test output[] !== nothing

    local lines = split(output[], "\n"; keepempty=false)
    @test length(lines) == 4

    @test lines[1] == "This is image one. ®"
    @test lines[2] == "This is image two. ®"
    @test lines[3] == "This is image three. ®"
    @test lines[4] == "This is image four. ®"
end

# =========================================================================================
# tess_pipeline_text() => Dispatch
@testset "tess_pipeline_text() => Dispatch" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local lines    = Vector{String}()

    tess_pipeline_unlv(pipeline) do line
        local clean = strip(line)
        if isempty(clean) == false
            push!(lines, clean)
        end
    end

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two. ®")]), 72) == true
        @test add(pix_with([Line("This is image three. ®")]), 72) == true
        @test add(pix_with([Line("This is image four. ®")]), 72) == true
    end) == true

    @test length(lines) == 4

    @test lines[1] == "This is image one. ®"
    @test lines[2] == "This is image two. ®"
    @test lines[3] == "This is image three. ®"
    @test lines[4] == "This is image four. ®"
end

# =========================================================================================
# tess_pipeline_unlv_latin1() => Byte Array
@testset "tess_pipeline_unlvlatin1() => Byte Array" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local output   = tess_pipeline_unlv_latin1(pipeline)

    @test is_available(output) == false

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two. ®")]), 72) == true
        @test add(pix_with([Line("This is image three. ®")]), 72) == true
        @test add(pix_with([Line("This is image four. ®")]), 72) == true
    end) == true

    @test is_available(output) == true
    @test output[] !== nothing

    local lines = split(String(output[]), "\n"; keepempty=false)
    @test length(lines) == 4

    @test lines[1] == "This is image one. \xae"
    @test lines[2] == "This is image two. \xae"
    @test lines[3] == "This is image three. \xae"
    @test lines[4] == "This is image four. \xae"
end
