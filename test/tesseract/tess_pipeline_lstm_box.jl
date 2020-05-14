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
# tess_pipeline_lstm_box() => Filename
@testset "tess_pipeline_lstm_box() => Filename" begin
    local inst       = TessInst("eng", datadir)
    local pipeline   = TessPipeline(inst)
    local output, io = mktemp(;cleanup=false); close(io)

    @test tess_pipeline_lstm_box(pipeline, output) == true

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test isfile(output) == true
    @test filesize(output) > 0

    local text  = read(output, String)
    local lines = split(text, "\n"; keepempty=false)
    @test length(lines) == 81

    @test strip(lines[1]) == "T 10 577 175 591 0"
    @test strip(lines[11]) == "a 10 577 175 591 0"
    @test strip(lines[20]) == "® 10 577 175 591 0"
    @test strip(lines[31]) == "m 10 577 156 591 1"
    @test strip(lines[41]) == "T 10 577 172 591 2"
    @test strip(lines[51]) == "a 10 577 172 591 2"
    @test strip(lines[61]) == "10 577 172 591 2"
    @test strip(lines[71]) == "m 10 577 164 591 3"
    @test strip(lines[81]) == "10 577 164 591 3"

    rm(output)
end

# =========================================================================================
# tess_pipeline_lstm_box() => String
@testset "tess_pipeline_lstm_box() => String" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local output   = tess_pipeline_lstm_box(pipeline)

    @test is_available(output) == false

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test is_available(output) == true
    @test output[] != nothing

    local lines = split(output[], "\n"; keepempty=false)
    @test length(lines) == 81

    @test strip(lines[1]) == "T 10 577 175 591 0"
    @test strip(lines[11]) == "a 10 577 175 591 0"
    @test strip(lines[20]) == "® 10 577 175 591 0"
    @test strip(lines[31]) == "m 10 577 156 591 1"
    @test strip(lines[41]) == "T 10 577 172 591 2"
    @test strip(lines[51]) == "a 10 577 172 591 2"
    @test strip(lines[61]) == "10 577 172 591 2"
    @test strip(lines[71]) == "m 10 577 164 591 3"
    @test strip(lines[81]) == "10 577 164 591 3"
end

# =========================================================================================
# tess_pipeline_lstm_box() => Callback
@testset "tess_pipeline_lstm_box() => Callback" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local lines    = Vector{String}()

    tess_pipeline_lstm_box(pipeline) do line
        push!(lines, line)
    end

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test length(lines) == 81

    @test strip(lines[1]) == "T 10 577 175 591 0"
    @test strip(lines[11]) == "a 10 577 175 591 0"
    @test strip(lines[20]) == "® 10 577 175 591 0"
    @test strip(lines[31]) == "m 10 577 156 591 1"
    @test strip(lines[41]) == "T 10 577 172 591 2"
    @test strip(lines[51]) == "a 10 577 172 591 2"
    @test strip(lines[61]) == "10 577 172 591 2"
    @test strip(lines[71]) == "m 10 577 164 591 3"
    @test strip(lines[81]) == "10 577 164 591 3"
end
