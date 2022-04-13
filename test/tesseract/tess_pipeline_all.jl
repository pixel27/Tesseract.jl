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
# tess_pipeline_*() -> Filename
@testset "tess_pipeline_*() -> Filename" begin
    local inst       = TessInst("eng", datadir)
    local pipeline   = TessPipeline(inst)

    local alto, io = mktemp(;cleanup=false); close(io)
    local hocr, io = mktemp(;cleanup=false); close(io)
    local lstm, io = mktemp(;cleanup=false); close(io)
    local pdf,  io = mktemp(;cleanup=false); close(io)
    local text, io = mktemp(;cleanup=false); close(io)
    local tsv,  io = mktemp(;cleanup=false); close(io)
    local unlv, io = mktemp(;cleanup=false); close(io)
    local box,  io = mktemp(;cleanup=false); close(io)

    @test tess_pipeline_alto(pipeline, alto) == true
    @test tess_pipeline_hocr(pipeline, hocr) == true
    @test tess_pipeline_lstm_box(pipeline, lstm) == true
    @test tess_pipeline_pdf(pipeline, pdf; dataDir=datadir) == true
    @test tess_pipeline_text(pipeline, text) == true
    @test tess_pipeline_tsv(pipeline, tsv) == true
    @test tess_pipeline_unlv(pipeline, unlv) == true
    @test tess_pipeline_word_box(pipeline, box) == true

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test length(split(read(alto, String), "\n"; keepempty=false)) == 75
    @test length(split(read(hocr, String), "\n"; keepempty=false)) == 62
    @test length(split(read(lstm, String), "\n"; keepempty=false)) == 81
    @test filesize(pdf) > 0
    @test length(split(read(text, String), "\n\f"; keepempty=false)) == 4
    @test length(split(read(unlv, String), "\n"; keepempty=false)) == 4
    @test length(split(read(box, String), "\n"; keepempty=false)) == 8

    rm(alto)
    rm(hocr)
    rm(lstm)
    rm(pdf)
    rm(text)
    rm(tsv)
    rm(unlv)
    rm(box)
end

# =========================================================================================
# tess_pipeline_*() -> String
@testset "tess_pipeline_*() -> String" begin
    local inst       = TessInst("eng", datadir)
    local pipeline   = TessPipeline(inst)

    alto = tess_pipeline_alto(pipeline)
    hocr = tess_pipeline_hocr(pipeline)
    lstm = tess_pipeline_lstm_box(pipeline)
    pdf  = tess_pipeline_pdf(pipeline; dataDir=datadir)
    text = tess_pipeline_text(pipeline)
    tsv  = tess_pipeline_tsv(pipeline)
    unlv = tess_pipeline_unlv(pipeline)
    box  = tess_pipeline_word_box(pipeline)

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test length(split(alto[], "\n"; keepempty=false)) == 75
    @test length(split(hocr[], "\n"; keepempty=false)) == 62
    @test length(split(lstm[], "\n"; keepempty=false)) == 81
    @test length(pdf[]) == 15035
    @test length(split(text[], "\n\f"; keepempty=false)) == 4
    @test length(split(unlv[], "\n"; keepempty=false)) == 4
    @test length(split(box[], "\n"; keepempty=false)) == 8
end
