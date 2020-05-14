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
using Documenter, Pkg

push!(LOAD_PATH,"../src/")

using Tesseract

test = true
deploy = true

for arg in ARGS
    if arg == "nodeploy"
        global deploy = false
    elseif arg == "notest"
        global test = false
    else
        println("Argument: $arg")
    end
end

println("Testing: $test")
println("Deploying: $deploy")

makedocs(
    sitename="Tesseract.jl",
    doctest=test,
    pages = [
        "index.md",
        "download.md",
        "load.md",
        "single.md",
        "multiple.md",
        "Reference" => [
            "reference.md",
            hide("Tesseract.download\\_languages" => "ref/download_languages.md"),
            hide("Tesseract.download\\_pdf\\_font" => "ref/download_pdf_font.md"),
            hide("Tesseract.IFF" => "ref/iff.md"),
            hide("Tesseract.lept\\_version" => "ref/lept_version.md"),
            hide("Tesseract.Pix" => "ref/pix.md"),
            hide("Tesseract.PixBox" => "ref/pix_box.md"),
            hide("Tesseract.pix\\_delete" => "ref/pix_delete.md"),
            hide("Tesseract.pix\\_get\\_depth" => "ref/pix_get_depth.md"),
            hide("Tesseract.pix\\_get\\_dimensions" => "ref/pix_get_dimensions.md"),
            hide("Tesseract.pix\\_read" => "ref/pix_read.md"),
            hide("Tesseract.pix\\_read\\_bmp" => "ref/pix_read_bmp.md"),
            hide("Tesseract.pix\\_read\\_gif" => "ref/pix_read_gif.md"),
            hide("Tesseract.pix\\_read\\_jp2k" => "ref/pix_read_jp2k.md"),
            hide("Tesseract.pix\\_read\\_jpeg" => "ref/pix_read_jpeg.md"),
            hide("Tesseract.pix\\_read\\_png" => "ref/pix_read_png.md"),
            hide("Tesseract.pix\\_read\\_pnm" => "ref/pix_read_pnm.md"),
            hide("Tesseract.pix\\_read\\_spix" => "ref/pix_read_spix.md"),
            hide("Tesseract.pix\\_read\\_tiff" => "ref/pix_read_tiff.md"),
            hide("Tesseract.pix\\_read\\_webp" => "ref/pix_read_webp.md"),
            hide("Tesseract.pix\\_write" => "ref/pix_write.md"),
            hide("Tesseract.pix\\_write\\_implied\\_format" => "ref/pix_write_implied_format.md"),
            hide("Tesseract.pix\\_write\\_bmp" => "ref/pix_write_bmp.md"),
            hide("Tesseract.pix\\_write\\_gif" => "ref/pix_write_gif.md"),
            hide("Tesseract.pix\\_write\\_jp2k" => "ref/pix_write_jp2k.md"),
            hide("Tesseract.pix\\_write\\_jpeg" => "ref/pix_write_jpeg.md"),
            hide("Tesseract.pix\\_write\\_pam" => "ref/pix_write_pam.md"),
            hide("Tesseract.pix\\_write\\_pdf" => "ref/pix_write_pdf.md"),
            hide("Tesseract.pix\\_write\\_png" => "ref/pix_write_png.md"),
            hide("Tesseract.pix\\_write\\_pnm" => "ref/pix_write_pnm.md"),
            hide("Tesseract.pix\\_write\\_ps" => "ref/pix_write_ps.md"),
            hide("Tesseract.pix\\_write\\_spix" => "ref/pix_write_spix.md"),
            hide("Tesseract.pix\\_write\\_tiff" => "ref/pix_write_tiff.md"),
            hide("Tesseract.pix\\_write\\_webp" => "ref/pix_write_webp.md"),
            hide("Tesseract.sample\\_pix" => "ref/sample_pix.md"),
            hide("Tesseract.sample\\_tiff" => "ref/sample_tiff.md"),
            hide("Tesseract.TessInst" => "ref/tess_inst.md"),
            hide("Tesseract.TessOutput" => "ref/tess_output.md"),
            hide("Tesseract.TessParam" => "ref/tess_param.md"),
            hide("Tesseract.TessPipeline" => "ref/tess_pipeline.md"),
            hide("Tesseract.tess\\_alto" => "ref/tess_alto.md"),
            hide("Tesseract.tess\\_available\\_languages" => "ref/tess_available_languages.md"),
            hide("Tesseract.tess\\_confidences" => "ref/tess_confidences.md"),
            hide("Tesseract.tess\\_delete" => "ref/tess_delete.md"),
            hide("Tesseract.tess\\_get\\_param" => "ref/tess_get_param.md"),
            hide("Tesseract.tess\\_hocr" => "ref/tess_hocr.md"),
            hide("Tesseract.tess\\_image" => "ref/tess_image.md"),
            hide("Tesseract.tess\\_init" => "ref/tess_init.md"),
            hide("Tesseract.tess\\_initialized\\_languages" => "ref/tess_initialized_languages.md"),
            hide("Tesseract.tess\\_loaded\\_languages" => "ref/tess_loaded_languages.md"),
            hide("Tesseract.tess\\_lstm\\_box" => "ref/tess_lstm_box.md"),
            hide("Tesseract.tess\\_params" => "ref/tess_params.md"),
            hide("Tesseract.tess\\_params\\_parsed" => "ref/tess_params_parsed.md"),
            hide("Tesseract.tess\\_parsed\\_tsv" => "ref/tess_parsed_tsv.md"),
            hide("Tesseract.tess\\_pipeline\\_alto" => "ref/tess_pipeline_alto.md"),
            hide("Tesseract.tess\\_pipeline\\_hocr" => "ref/tess_pipeline_hocr.md"),
            hide("Tesseract.tess\\_pipeline\\_lstm\\_box" => "ref/tess_pipeline_lstm_box.md"),
            hide("Tesseract.tess\\_pipeline\\_pdf" => "ref/tess_pipeline_pdf.md"),
            hide("Tesseract.tess\\_pipeline\\_text" => "ref/tess_pipeline_text.md"),
            hide("Tesseract.tess\\_pipeline\\_tsv" => "ref/tess_pipeline_tsv.md"),
            hide("Tesseract.tess\\_pipeline\\_unlv" => "ref/tess_pipeline_unlv.md"),
            hide("Tesseract.tess\\_pipeline\\_unlv\\_latin1" => "ref/tess_pipeline_unlv_latin1.md"),
            hide("Tesseract.tess\\_pipeline\\_word\\_box" => "ref/tess_pipeline_word_box.md"),
            hide("Tesseract.tess\\_run\\_pipeline" => "ref/tess_run_pipeline.md"),
            hide("Tesseract.tess\\_read\\_config" => "ref/tess_read_config.md"),
            hide("Tesseract.tess\\_read\\_debug\\_config" => "ref/tess_read_debug_config.md"),
            hide("Tesseract.tess\\_recognize" => "ref/tess_recognize.md"),
            hide("Tesseract.tess\\_resolution" => "ref/tess_resolution.md"),
            hide("Tesseract.tess\\_set\\_param" => "ref/tess_set_param.md"),
            hide("Tesseract.tess\\_text" => "ref/tess_text.md"),
            hide("Tesseract.tess\\_text\\_box" => "ref/tess_text_box.md"),
            hide("Tesseract.tess\\_tsv" => "ref/tess_tsv.md"),
            hide("Tesseract.tess\\_unlv" => "ref/tess_unlv.md"),
            hide("Tesseract.tess\\_unlv\\_latin1" => "ref/tess_unlv_latin1.md"),
            hide("Tesseract.tess\\_version" => "ref/tess_version.md"),
            hide("Tesseract.tess\\_word\\_box" => "ref/tess_word_box.md"),
            hide("Tesseract.Tsv" => "ref/tsv.md"),
            hide("Tesseract.update\\_languages" => "ref/update_languages.md"),
            hide("Tesseract.update\\_pdf\\_font" => "ref/update_pdf_font.md"),
            hide("Tesseract.DataFiles.GitHubProject" => "ref/git_hub_project.md")
        ]
    ]
)
if deploy == true
    deploydocs(repo = "github.com/pixel27/Tesseract.jl.git")
end
