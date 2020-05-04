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
# Test constructing and freeing an instance.
@testset "TessInst constructor" begin
    @test_nowarn TessInst()

    local inst = TessInst()
    @suppress @test_nowarn show(inst)
    tess_delete!(inst)
    @suppress @test_nowarn show(inst)
end

# -------------------------------------------------------------------------------------------------
# Test tess_delete!()
@testset "TessInst tess_delete!" begin
    local tess = TessInst()

    @test_nowarn tess_delete!(tess)
    @test_nowarn tess_delete!(tess)
end

# -------------------------------------------------------------------------------------------------
# Test tess_recognize()
@testset "tess_recognize" begin
    local inst = TessInst()
    local pix  = pix_with()

    # ---------------------------------------------------------------------------------------------
    # Normal tests.
    @test tess_init(inst) == true
    @suppress @test tess_recognize(inst) == false
    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)
    @test tess_recognize(inst) == true

    # ---------------------------------------------------------------------------------------------
    # Test being called with a freed instance.
    local err = "Instance has been freed."
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_recognize(inst)) == false
end
