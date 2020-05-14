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

include("utils.jl")
include("common.jl")

include("tess_inst.jl")
include("tess_inst_config.jl")
include("tess_inst_config_vars.jl")
include("tess_inst_image.jl")
include("tess_inst_output.jl")
include("tess_inst_output_tsv.jl")
include("tess_inst_get_param.jl")
include("tess_inst_set_param.jl")
include("tess_inst_set_debug_param.jl")

include("datafiles/_package.jl")
include("data_file_download.jl")
include("data_file_update.jl")

include("tess_output.jl")
include("pipeline/_package.jl")
include("tess_pipeline.jl")
include("tess_pipeline_add_alto.jl")
include("tess_pipeline_add_hocr.jl")
include("tess_pipeline_add_lstm_box.jl")
include("tess_pipeline_add_pdf.jl")
include("tess_pipeline_add_text.jl")
include("tess_pipeline_add_tsv.jl")
include("tess_pipeline_add_unlv.jl")
include("tess_pipeline_add_word_box.jl")
