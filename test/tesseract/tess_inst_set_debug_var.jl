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
# Test the tess_set_debug_param(inst, name, Int) method.
@testset "tess_set_debug_param(inst, name, $type)" for type in [ UInt8, Int16, Int32, Int64, Int]
    local inst = TessInst("eng", datadir)

    @test tess_set_debug_param(inst, "matcher_debug_level", type(3)) == true
    @test tess_set_debug_param(inst, "classify_class_pruner_threshold", type(100)) == true
    @test tess_get_param(inst, "classify_class_pruner_threshold", type) == type(229)

    tess_delete!(inst)

    local err  = "Instance has been freed."
    @test (@test_logs (:error, err) tess_set_debug_param(inst, "matcher_debug_level", type(100))) == false
end

# -----------------------------------------------------------------------------------------
# Test the tess_set_debug_param(inst, name, Bool) method.
@testset "tess_set_debug_param(inst, name, Bool)" begin
    local inst = TessInst("eng", datadir)

    @test tess_set_debug_param(inst, "tessedit_display_outwords", true) == true
    @test tess_get_param(inst, "tessedit_display_outwords", Bool) == true
    @test tess_set_debug_param(inst, "tessedit_unrej_any_wd", true) == true
    @test tess_get_param(inst, "tessedit_unrej_any_wd", Bool) == false

    tess_delete!(inst)

    local err  = "Instance has been freed."
    @test (@test_logs (:error, err) tess_set_debug_param(inst, "matcher_debug_flags", true)) == false
end

# -----------------------------------------------------------------------------------------
# Test the tess_set_debug_param(inst, name, String) method.
@testset "tess_set_debug_param(inst, name, String)" begin
    local inst = TessInst("eng", datadir)

    @test tess_set_debug_param(inst, "debug_file", "test.log") == true
    @test tess_get_param(inst, "debug_file", String) == "test.log"
    @test tess_set_debug_param(inst, "page_separator", "\n* * *\n") == true
    @test tess_get_param(inst, "page_separator", String) == "\f"

    tess_delete!(inst)

    local err  = "Instance has been freed."
    @test (@test_logs (:error, err) tess_set_debug_param(inst, "debug_file", "abc")) == false
end
