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
# Test tess_run_pipeline(Callback) /w no renderers.
@testset "tess_pipeline(Callback) /w no renderers" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local err      = "No renderers attached to the pipeline."

    @test (@test_logs (:error, err) tess_run_pipeline(pipeline) do add
        add(pix_with([Line("This is image one.")]), 72)
    end) == false
end

# =========================================================================================
# Test tess_pipeline(Callback) delete instance before run.
@testset "tess_pipeline(Callback) delete instance before run" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)

    @test tess_pipeline_text(pipeline) != nothing

    tess_delete!(inst)

    @suppress begin
        @test (tess_run_pipeline(pipeline) do add
            @test add(pix_with([Line("This is image one.")]), 72) == false
            return true
        end) == false
    end
end

# =========================================================================================
# Test tess_pipeline(Callback) delete instance inside pipeline.
@testset "tess_pipeline(Callback) delete instance inside pipeline" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)

    @test tess_pipeline_text(pipeline) != nothing

    @suppress begin
        @test (tess_run_pipeline(pipeline) do add
            @test add(pix_with([Line("This is image one.")]), 72) == true
            tess_delete!(inst)
            @test add(pix_with([Line("This is image two.")]), 72) == false
        end) == false
    end
end

# =========================================================================================
# Test tess_pipeline(Callback) delete pipeline inside pipeline.
@testset "tess_pipeline(Callback) delete pipeline inside pipeline" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)

    @test tess_pipeline_text(pipeline) != nothing

    @suppress begin
        @test (tess_run_pipeline(pipeline) do add
            @test add(pix_with([Line("This is image one.")]), 72) == true
            tess_delete!(pipeline)
            @test add(pix_with([Line("This is image two.")]), 72) == false
        end) == false
    end
end

# =========================================================================================
# Test tess_pipeline(Callback) /w failure.
@testset "tess_pipeline(Callback) /w failure" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)

    @test tess_pipeline_text(pipeline) != nothing

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one.")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        return false
    end) == false
end
