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
# Test tess_pipeline(Image List File).
@testset "tess_pipeline(Image List File)" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local result   = tess_pipeline_text(pipeline)

    local pix1, io = mktemp(;cleanup=false); close(io)
    local pix2, io = mktemp(;cleanup=false); close(io)
    local pix3, Io = mktemp(;cleanup=false); close(io)
    local output, io = mktemp(;cleanup=false);

    pix_write(pix1, pix_with([Line("One 1")]), IFF_TIFF); println(io, pix1);
    pix_write(pix2, pix_with([Line("Two 2")]), IFF_TIFF); println(io, pix2);
    pix_write(pix3, pix_with([Line("Three 3")]), IFF_TIFF); println(io, pix3);

    close(io)

    @test tess_run_pipeline(pipeline, output) == true

    @test result[] == "One 1\n\fTwo 2\n\fThree 3\n"

    rm(pix1)
    rm(pix2)
    rm(pix3)
    rm(output)
end

# =========================================================================================
# Test tess_pipeline(TIFF File).
@testset "tess_pipeline(TIFF File)" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local result   = tess_pipeline_text(pipeline)
    local pix, io = mktemp(;cleanup=false); close(io)

    pix_write_tiff(pix, pix_with([Line("One 1")]); append = true)
    pix_write_tiff(pix, pix_with([Line("Two 2")]); append = true)
    pix_write_tiff(pix, pix_with([Line("Three 3")]); append = true)

    @test tess_run_pipeline(pipeline, pix) == true

    @test result[] == "One 1\n\fTwo 2\n\fThree 3\n"

    rm(pix)
end

# =========================================================================================
# Test tess_run_pipeline(IImage List File) /w no renderers.
@testset "tess_run_pipeline(Image List File) /w no renderers" begin
    local inst       = TessInst("eng", datadir)
    local pipeline   = TessPipeline(inst)
    local err        = "No renderers attached to the pipeline."
    local pix1, io = mktemp(;cleanup=false); close(io)
    local pix2, io = mktemp(;cleanup=false); close(io)
    local pix3, Io = mktemp(;cleanup=false); close(io)
    local output, io = mktemp(;cleanup=false);

    pix_write(pix1, pix_with(), IFF_TIFF); println(io, pix1);
    pix_write(pix2, pix_with(), IFF_TIFF); println(io, pix2);
    pix_write(pix3, pix_with(), IFF_TIFF); println(io, pix3);

    close(io)

    @test (@test_logs (:error, err) tess_run_pipeline(pipeline, output)) == false
    rm(pix1)
    rm(pix2)
    rm(pix3)
    rm(output)
end

# =========================================================================================
# Test tess_pipeline(Image List File) delete instance before run.
@testset "tess_pipeline(Image List File) delete instance before run" begin
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local err      = "Instance has been freed."

    @test tess_pipeline_text(pipeline) !== nothing

    local pix1, io = mktemp(;cleanup=false); close(io)
    local pix2, io = mktemp(;cleanup=false); close(io)
    local pix3, Io = mktemp(;cleanup=false); close(io)
    local output, io = mktemp(;cleanup=false);

    pix_write(pix1, pix_with(), IFF_TIFF); println(io, pix1);
    pix_write(pix2, pix_with(), IFF_TIFF); println(io, pix2);
    pix_write(pix3, pix_with(), IFF_TIFF); println(io, pix3);

    close(io)

    tess_delete!(inst)

    @test (@test_logs (:error, err) tess_run_pipeline(pipeline, output)) == false

    rm(pix1)
    rm(pix2)
    rm(pix3)
    rm(output)
end
