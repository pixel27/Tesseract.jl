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
# tess_pipeline_text() => Filename
@testset "tess_pipeline_text() => Filename" begin
    local inst       = TessInst("eng", datadir)
    local pipeline   = TessPipeline(inst)
    local output, io = mktemp(;cleanup=false); close(io)

    @test tess_pipeline_text(pipeline, output) == true

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test isfile(output) == true
    @test filesize(output) > 0

    local text  = read(output, String)
    local lines = split(text, r"[\n\f]"; keepempty=false)
    @test length(lines) == 4

    @test lines[1] == "This is image one. ®"
    @test lines[2] == "This is image two."
    @test lines[3] == "This is image three."
    @test lines[4] == "This is image four."

    rm(output)
end

# =========================================================================================
# tess_pipeline_text() => String
@testset "tess_pipeline_text() => String" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local output   = tess_pipeline_text(pipeline)

    @test is_available(output) == false

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test is_available(output) == true
    @test output[] !== nothing

    local lines = split(output[], r"[\n\f]"; keepempty=false)
    @test length(lines) == 4

    @test lines[1] == "This is image one. ®"
    @test lines[2] == "This is image two."
    @test lines[3] == "This is image three."
    @test lines[4] == "This is image four."
end

# =========================================================================================
# tess_pipeline_text() => Callback
@testset "tess_pipeline_text() => Callback" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local lines    = Vector{String}()

    tess_pipeline_text(pipeline) do line
        push!(lines, line)
    end

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test length(lines) == 7

    @test lines[1] == "This is image one. ®\n"
    @test lines[2] == "\f"
    @test lines[3] == "This is image two.\n"
    @test lines[4] == "\f"
    @test lines[5] == "This is image three.\n"
    @test lines[6] == "\f"
    @test lines[7] == "This is image four.\n"
end

# =========================================================================================
# tess_pipeline_text() -> Filename/String/Callback
@testset "tess_pipeline_text() -> Filename/String/Callback" begin
    local inst       = TessInst("eng", datadir)
    local pipeline   = TessPipeline(inst)
    local filename, io = mktemp(;cleanup=false); close(io)

    @test tess_pipeline_text(pipeline, filename) == true
    local str = tess_pipeline_text(pipeline)
    local callback = Vector{String}()
    tess_pipeline_text(pipeline) do line
        push!(callback, line)
    end

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test length(split(read(filename, String), r"[\n\f]"; keepempty=false)) == 4
    @test length(split(str[], r"[\n\f]"; keepempty=false)) == 4
    @test length(callback) == 7

    rm(filename)
end
