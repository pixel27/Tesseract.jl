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
# tess_pipeline_alto() => Filename
@testset "tess_pipeline_alto() => Filename" begin
    local inst       = TessInst("eng", datadir)
    local pipeline   = TessPipeline(inst)
    local output, io = mktemp(;cleanup=false); close(io)

    @test tess_pipeline_alto(pipeline, output) == true

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
    @test length(lines) == 75

    @test strip(lines[1])  == """<?xml version="1.0" encoding="UTF-8"?>"""
    @test strip(lines[10]) == """<processingSoftware>"""
    @test strip(lines[21]) == """<TextLine ID="line_0" HPOS="10" VPOS="9" WIDTH="160" HEIGHT="14">"""
    @test strip(lines[26]) == """<String ID="string_4" HPOS="162" VPOS="11" WIDTH="8" HEIGHT="9" WC="0.69" CONTENT="®"/>"""
    @test strip(lines[41]) == """</TextLine>"""
    @test strip(lines[51]) == """<String ID="string_0" HPOS="10" VPOS="9" WIDTH="31" HEIGHT="11" WC="0.95" CONTENT="This"/><SP WIDTH="10" VPOS="9" HPOS="41"/>"""
    @test strip(lines[61]) == """<PrintSpace HPOS="0" VPOS="0" WIDTH="300" HEIGHT="600">"""
    @test strip(lines[71]) == """</ComposedBlock>"""

    rm(output)
end

# =========================================================================================
# tess_pipeline_alto() => String
@testset "tess_pipeline_alto() => String" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local output   = tess_pipeline_alto(pipeline)

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
    @test length(lines) == 75

    @test strip(lines[1])  == """<?xml version="1.0" encoding="UTF-8"?>"""
    @test strip(lines[10]) == """<processingSoftware>"""
    @test strip(lines[21]) == """<TextLine ID="line_0" HPOS="10" VPOS="9" WIDTH="160" HEIGHT="14">"""
    @test strip(lines[26]) == """<String ID="string_4" HPOS="162" VPOS="11" WIDTH="8" HEIGHT="9" WC="0.69" CONTENT="®"/>"""
    @test strip(lines[41]) == """</TextLine>"""
    @test strip(lines[51]) == """<String ID="string_0" HPOS="10" VPOS="9" WIDTH="31" HEIGHT="11" WC="0.95" CONTENT="This"/><SP WIDTH="10" VPOS="9" HPOS="41"/>"""
    @test strip(lines[61]) == """<PrintSpace HPOS="0" VPOS="0" WIDTH="300" HEIGHT="600">"""
    @test strip(lines[71]) == """</ComposedBlock>"""
end

# =========================================================================================
# tess_pipeline_alto() => Callback
@testset "tess_pipeline_alto() => Callback" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local lines    = Vector{String}()

    tess_pipeline_alto(pipeline) do line
        push!(lines, line)
    end

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test length(lines) == 75

    @test strip(lines[1])  == """<?xml version="1.0" encoding="UTF-8"?>"""
    @test strip(lines[10]) == """<processingSoftware>"""
    @test strip(lines[21]) == """<TextLine ID="line_0" HPOS="10" VPOS="9" WIDTH="160" HEIGHT="14">"""
    @test strip(lines[26]) == """<String ID="string_4" HPOS="162" VPOS="11" WIDTH="8" HEIGHT="9" WC="0.69" CONTENT="®"/>"""
    @test strip(lines[41]) == """</TextLine>"""
    @test strip(lines[51]) == """<String ID="string_0" HPOS="10" VPOS="9" WIDTH="31" HEIGHT="11" WC="0.95" CONTENT="This"/><SP WIDTH="10" VPOS="9" HPOS="41"/>"""
    @test strip(lines[61]) == """<PrintSpace HPOS="0" VPOS="0" WIDTH="300" HEIGHT="600">"""
    @test strip(lines[71]) == """</ComposedBlock>"""
end
