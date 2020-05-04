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
# Test tess_image()
@testset "tess_image" begin
    local inst = TessInst()
    local pix = pix_with()

    @test tess_init(inst) == true
    @test_nowarn tess_image(inst, pix)

    local err  = "Instance has been freed."
    tess_delete!(inst)
    @test_logs (:error, err) tess_image(inst, pix)

    local err  = "Pix object has been freed."
    local inst = TessInst()
    pix_delete!(pix)
    @test_logs (:error, err) tess_image(inst, pix)
end

# -------------------------------------------------------------------------------------------------
# Test tess_resolution()
@testset "tess_resolution" begin
    local inst = TessInst()
    local pix = pix_with()

    @test tess_init(inst) == true
    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)

    local err  = "Instance has been freed."
    tess_delete!(inst)
    @test_logs (:error, err) tess_resolution(inst, 72)
end
