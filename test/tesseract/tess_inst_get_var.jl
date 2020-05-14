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

# -----------------------------------------------------------------------------------------
# Test the tess_get_param(inst, name, Int) method.
@testset "tess_get_param(inst, name, $type)" for type in [ Int16, Int32, Int64, Int]
    local inst = TessInst("eng", datadir)

    @test tess_get_param(inst, "editor_image_xpos", type) == 590
    @test tess_get_param(inst, "textord_testregion_top", type) == -1
    @test tess_get_param(inst, "edges_debug", type) === nothing
    @test tess_get_param(inst, "textord_skew_lag", type) === nothing
    @test tess_get_param(inst, "chs_trailing_punct1", type) === nothing

    tess_delete!(inst)

    local err  = "Instance has been freed."
    @test (@test_logs (:error, err) tess_get_param(inst, "editor_image_xpos", type)) === nothing
end

# -----------------------------------------------------------------------------------------
# Test the tess_get_param(inst, name, Bool) method.
@testset "tess_get_param(inst, name, Bool)" begin
    local inst = TessInst("eng", datadir)

    @test tess_get_param(inst, "textord_noise_debug", Bool) == false
    @test tess_get_param(inst, "textord_noise_rejwords", Bool) == true
    @test tess_get_param(inst, "textord_test_x", Bool) === nothing
    @test tess_get_param(inst, "classify_cp_side_pad_loose", Bool) === nothing
    @test tess_get_param(inst, "chs_leading_punct", Bool) === nothing

    tess_delete!(inst)

    local err  = "Instance has been freed."
    @test (@test_logs (:error, err) tess_get_param(inst, "classify_debug_level", Bool)) === nothing
end

# -----------------------------------------------------------------------------------------
# Test the tess_get_param(inst, name, Float64) method.
@testset "tess_get_param(inst, name, Float64)" begin
    local inst = TessInst("eng", datadir)

    @test tess_get_param(inst, "classify_pico_feature_length", Float64) == 0.05
    @test tess_get_param(inst, "classify_enable_adaptive_debugger", Float64) === nothing
    @test tess_get_param(inst, "tosp_few_samples", Float64) === nothing
    @test tess_get_param(inst, "outlines_2", Float64) === nothing

    tess_delete!(inst)

    local err  = "Instance has been freed."
    @test (@test_logs (:error, err) tess_get_param(inst, "rating_scale", Float64)) === nothing
end

# -----------------------------------------------------------------------------------------
# Test the tess_get_param(inst, name, String) method.
@testset "tess_get_param(inst, name, String)" begin
    local inst = TessInst("eng", datadir)

    @test tess_get_param(inst, "page_separator", String) == "\f"
    @test tess_get_param(inst, "classify_char_norm_range", String) === nothing
    @test tess_get_param(inst, "matcher_avg_noise_size", String) === nothing
    @test tess_get_param(inst, "textord_noise_debug", String) === nothing
    @test tess_get_param(inst, "tessedit_char_blacklist", String) == ""

    tess_delete!(inst)

    local err  = "Instance has been freed."
    @test (@test_logs (:error, err) tess_get_param(inst, "tessedit_char_blacklist", String)) === nothing
end
