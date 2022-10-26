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
# tess_pipeline_hocr() => Filename
@testset "tess_pipeline_hocr(fontInfo = $font) => Filename" for font in [ true, false ]
    local inst       = TessInst("eng", datadir)
    local pipeline   = TessPipeline(inst)
    local output, io = mktemp(;cleanup=false); close(io)

    @test tess_pipeline_hocr(pipeline, output, font) == true

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test isfile(output) == true
    @test filesize(output) > 0

    local text  = read(output, String)
    local lines = split(text, "\n"; keepempty=false)
    @test length(lines) == 62

    @test strip(lines[1]) == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    if font == true
        @test strip(lines[9]) == "<meta name='ocr-capabilities' content='ocr_page ocr_carea ocr_par ocr_line ocrx_word ocrp_wconf ocrp_lang ocrp_dir ocrp_font ocrp_fsize'/>"
    else
        @test strip(lines[9]) == "<meta name='ocr-capabilities' content='ocr_page ocr_carea ocr_par ocr_line ocrx_word ocrp_wconf'/>"
    end
    @test strip(lines[20]) == "<span class='ocrx_word' id='word_1_5' title='bbox 161 8 173 20; x_wconf 93'>®</span>"
    @test strip(lines[31]) == "<span class='ocrx_word' id='word_2_3' title='bbox 65 8 113 23; x_wconf 96'>image</span>"
    @test strip(lines[41]) == "<span class='ocrx_word' id='word_3_1' title='bbox 10 8 42 20; x_wconf 95'>This</span>"
    @test strip(lines[51]) == """<p class='ocr_par' id='par_4_1' lang='eng' title="bbox 10 8 152 23">"""
    @test strip(lines[61]) == "</body>"

    rm(output)
end

# =========================================================================================
# tess_pipeline_hocr() => String
@testset "tess_pipeline_hocr(fontInfo = $font) => String" for font in [ true, false ]
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local output   = tess_pipeline_hocr(pipeline, font)

    @test is_available(output) == false

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test is_available(output) == true
    @test output[] !== nothing

    local lines = split(output[], "\n"; keepempty=false)
    @test length(lines) == 62

    @test strip(lines[1]) == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    if font == true
        @test strip(lines[9]) == "<meta name='ocr-capabilities' content='ocr_page ocr_carea ocr_par ocr_line ocrx_word ocrp_wconf ocrp_lang ocrp_dir ocrp_font ocrp_fsize'/>"
    else
        @test strip(lines[9]) == "<meta name='ocr-capabilities' content='ocr_page ocr_carea ocr_par ocr_line ocrx_word ocrp_wconf'/>"
    end
    @test strip(lines[20]) == "<span class='ocrx_word' id='word_1_5' title='bbox 161 8 173 20; x_wconf 93'>®</span>"
    @test strip(lines[31]) == "<span class='ocrx_word' id='word_2_3' title='bbox 65 8 113 23; x_wconf 96'>image</span>"
    @test strip(lines[41]) == "<span class='ocrx_word' id='word_3_1' title='bbox 10 8 42 20; x_wconf 95'>This</span>"
    @test strip(lines[51]) == """<p class='ocr_par' id='par_4_1' lang='eng' title="bbox 10 8 152 23">"""
    @test strip(lines[61]) == "</body>"
end

# =========================================================================================
# tess_pipeline_hocr() => Callback
@testset "tess_pipeline_hocr(fontInfo = $font) => Callback" for font in [ true, false ]
    local inst     = TessInst("eng", datadir)
    local pipeline = TessPipeline(inst)
    local lines    = Vector{String}()

    tess_pipeline_hocr(pipeline, font) do line
        push!(lines, line)
    end

    @test (tess_run_pipeline(pipeline) do add
        @test add(pix_with([Line("This is image one. ®")]), 72) == true
        @test add(pix_with([Line("This is image two.")]), 72) == true
        @test add(pix_with([Line("This is image three.")]), 72) == true
        @test add(pix_with([Line("This is image four.")]), 72) == true
    end) == true

    @test length(lines) == 62

    @test strip(lines[1]) == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    if font == true
        @test strip(lines[9]) == "<meta name='ocr-capabilities' content='ocr_page ocr_carea ocr_par ocr_line ocrx_word ocrp_wconf ocrp_lang ocrp_dir ocrp_font ocrp_fsize'/>"
    else
        @test strip(lines[9]) == "<meta name='ocr-capabilities' content='ocr_page ocr_carea ocr_par ocr_line ocrx_word ocrp_wconf'/>"
    end
    @test strip(lines[20]) == "<span class='ocrx_word' id='word_1_5' title='bbox 161 8 173 20; x_wconf 93'>®</span>"
    @test strip(lines[31]) == "<span class='ocrx_word' id='word_2_3' title='bbox 65 8 113 23; x_wconf 96'>image</span>"
    @test strip(lines[41]) == "<span class='ocrx_word' id='word_3_1' title='bbox 10 8 42 20; x_wconf 95'>This</span>"
    @test strip(lines[51]) == """<p class='ocr_par' id='par_4_1' lang='eng' title="bbox 10 8 152 23">"""
    @test strip(lines[61]) == "</body>"
end
