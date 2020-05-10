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
# Test tess_text()
@testset "tess_text" begin
    local inst = TessInst("eng", datadir)
    local pix = pix_with()

    @suppress @test tess_text(inst) == nothing
    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)
    @test tess_text(inst) != nothing

    local err = "Instance has been freed."
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_text(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_text()
@testset "tess_hocr" begin
    local inst = TessInst("eng", datadir)
    local pix = pix_with()

    @suppress @test tess_hocr(inst) == nothing
    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)
    @test tess_hocr(inst) != nothing

    local err = "Instance has been freed."
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_hocr(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_alto()
@testset "tess_alto" begin
    local inst = TessInst("eng", datadir)
    local pix = pix_with()

    @suppress @test tess_alto(inst) == nothing
    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)
    @test tess_alto(inst) != nothing

    local err = "Instance has been freed."
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_alto(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_tsv()
@testset "tess_tsv" begin
    local inst = TessInst("eng", datadir)
    local pix = pix_with()

    @suppress @test tess_tsv(inst) == nothing
    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)
    @test tess_tsv(inst) != nothing

    local err = "Instance has been freed."
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_tsv(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_tsv()
@testset "tess_parsed_tsv" begin
    local inst = TessInst("eng", datadir)
    local pix = pix_with()

    @suppress @test tess_parsed_tsv(inst) == nothing
    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)
    local result = tess_parsed_tsv(inst)
    @test result != nothing
    @test isempty(result) == false
    @suppress @test_nowarn show(result[1])

    local result = tess_parsed_tsv(inst, 2) == nothing

    local err = "Instance has been freed."
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_parsed_tsv(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_text_box()
@testset "tess_text_box" begin
    local inst = TessInst("eng", datadir)
    local pix = pix_with()

    @suppress @test tess_text_box(inst) == nothing
    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)
    @test tess_text_box(inst) != nothing

    local err = "Instance has been freed."
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_text_box(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_word_box()
@testset "tess_word_box" begin
    local inst = TessInst("eng", datadir)
    local pix = pix_with()

    @suppress @test tess_word_box(inst) == nothing
    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)
    @test tess_word_box(inst) != nothing

    local err = "Instance has been freed."
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_word_box(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_lstm_box()
@testset "tess_lstm_box" begin
    local inst = TessInst("eng", datadir)
    local pix = pix_with()

    @suppress @test tess_lstm_box(inst) == nothing
    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)
    @test tess_lstm_box(inst) != nothing

    local err = "Instance has been freed."
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_lstm_box(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_unlv()
@testset "tess_unlv" begin
    local inst = TessInst("eng", datadir)
    local pix = pix_with()

    @suppress @test tess_unlv(inst) == nothing
    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)
    @test tess_unlv(inst) != nothing

    local err = "Instance has been freed."
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_unlv(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_confidences()
@testset "tess_confidences" begin
    local inst = TessInst("eng", datadir)
    local pix = pix_with()

    @suppress @test tess_confidences(inst) == nothing
    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)
    @test tess_recognize(inst) == true
    @test tess_confidences(inst) != nothing

    local err = "Instance has been freed."
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_confidences(inst)) == nothing
end

# -------------------------------------------------------------------------------------------------
# Test tess_resolution()
@testset "tess_resolution" begin
    local inst = TessInst("eng", datadir)
    local pix = pix_with()

    @test_nowarn tess_image(inst, pix)
    @test_nowarn tess_resolution(inst, 72)

    local err = "Instance has been freed."
    tess_delete!(inst)
    @test (@test_logs (:error, err) tess_resolution(inst, 72)) == nothing
end
