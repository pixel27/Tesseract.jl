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
# tess_pipeline_pdf() => Filename
@testset "tess_pipeline_pdf(textOnly = $textOnly) => Filename" for textOnly in [ true, false ]
    local inst       = TessInst("eng", datadir)
    local pipeline   = TessPipeline(inst)
    local output, io = mktemp(;cleanup=false); close(io)

    @test tess_pipeline_pdf(pipeline, output; dataDir=datadir, textOnly = textOnly) == true

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test isfile(output) == true
    @test filesize(output) > 0

    rm(output)
end

# =========================================================================================
# tess_pipeline_pdf() => Vector{UInt8}
@testset "tess_pipeline_pdf(textOnly = $textOnly) => Vector{UInt8}" for textOnly in [ true, false ]
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local output   = tess_pipeline_pdf(pipeline; dataDir=datadir)

    @test is_available(output) == false

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test is_available(output) == true
    @test output[] != nothing

    @test length(output[]) > 0
end
