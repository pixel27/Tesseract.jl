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

# =================================================================================================
# Test pix_get_depth()
@testset "pix_get_depth" begin
    local err = "Pix has been freed."
    local pix = pix_with()

    @test pix_get_depth(pix) == 32

    pix_delete!(pix)

    @test (@test_logs (:error, err) pix_get_depth(pix)) == 0
end

# =================================================================================================
# Test pix_get_dimensions()
@testset "pix_get_dimensions" begin
    local err = "Pix has been freed."
    local pix = pix_with()

    @test pix_get_dimensions(pix).w == 300
    @test pix_get_dimensions(pix).h == 600
    @test pix_get_dimensions(pix).d == 32

    pix_delete!(pix)

    @test (@test_logs (:error, err) pix_get_dimensions(pix)) === nothing
end
