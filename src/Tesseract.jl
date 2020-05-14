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

module Tesseract
using Tesseract_jll
using Leptonica_jll

const TESSERACT = Tesseract_jll.libtesseract
const LEPTONICA = Leptonica_jll.liblept
const TESS_VERSION = "4.1.1"
const LEPT_VERSION = "leptonica-1.79.0"
const TESS_DATA = "tessdata"

include("leptonica/_package.jl")

include("sample.jl")

include("tesseract/_package.jl")

#include("tess_result_renderer.jl")

export tess_version
export TessInst, TessParam, Tsv
export tess_delete!, tess_image, tess_recognize, tess_text, tess_hocr, tess_alto,
       tess_tsv, tess_text_box, tess_word_box, tess_lstm_box, tess_unlv, tess_unlv_latin1,
       tess_confidences, tess_parsed_tsv, tess_resolution
export tess_init, tess_initialized_languages, tess_loaded_languages,
       tess_available_languages, tess_params, tess_read_config,
       tess_read_debug_config, tess_params_parsed
export tess_get_param, tess_set_param, tess_set_debug_param
export sample_tiff, sample_pix

export Pix, PixBox
export IFF, IFF_UNKNOWN, IFF_BMP, IFF_JFIF_JPEG, IFF_PNG, IFF_TIFF, IFF_TIFF_PACKBITS,
       IFF_TIFF_RLE, IFF_TIFF_G3, IFF_TIFF_G4, IFF_TIFF_LZW, IFF_TIFF_ZIP, IFF_PNM, IFF_PS,
       IFF_GIF, IFF_JP2, IFF_WEBP, IFF_LPDF, IFF_TIFF_JPEG, IFF_DEFAULT, IFF_SPIX
export pix_read_bmp, pix_write_bmp, pix_read_gif, pix_write_gif, pix_read_jp2k,
       pix_write_jp2k, pix_read_jpeg, pix_write_jpeg, pix_write_pdf, pix_write_pam,
       pix_read_png, pix_write_png, pix_read_pnm, pix_write_pnm, pix_write_ps,
       pix_read_spix, pix_write_spix, pix_read_tiff, pix_write_tiff, pix_read_webp,
       pix_write_webp, pix_read, pix_write, pix_write_implied_format
export pix_get_depth, pix_get_dimensions
export pix_delete!, lept_version

export GitHubProject
export update_languages, download_languages, update_pdf_font, download_pdf_font

#include("tess_result_renderer.jl")
export TessPipeline, TessOutput

export tess_run_pipeline, is_available, tess_pipeline_alto, tess_pipeline_hocr,
       tess_pipeline_lstm_box, tess_pipeline_pdf, tess_pipeline_text, tess_pipeline_tsv,
       tess_pipeline_unlv, tess_pipeline_unlv_latin1, tess_pipeline_word_box
end
