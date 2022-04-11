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
module DataFiles

using Dates

const INDEX_VERSION = 2
const LANGUAGES_FILE = ".languages"
const PDF_FONT_INFO_FILE = ".pdffont"

const DATA_FILE_EXT = ".traineddata"
const DATE_FORMAT = @dateformat_str("HH:MM:SS dd-mm-yyyy")

const GITHUB_CONTENTS_BASE = "https://api.github.com/repos"

const DATA_URL  = "https://raw.githubusercontent.com/tesseract-ocr/tessdata_best/main/"
const PDF_FONT_URL  = "https://raw.githubusercontent.com/tesseract-ocr/tessconfigs/main/"
                       
include("errors.jl")
include("common.jl")
include("download.jl")
include("github_file.jl")
include("github_project.jl")
include("languages.jl")
include("pdf_font_info.jl")

const DATA_REPO     = GitHubProject("tesseract-ocr", "tessdata_best", "main", "")
const PDF_FONT_REPO = GitHubProject("tesseract-ocr", "tessconfigs", "main", "")

export DATA_FILE_EXT, DATA_URL, PDF_FONT_URL, DATA_REPO, PDF_FONT_REPO
export Languages, GitHubProject, FileError, NetworkError
export load_languages, save_languages, refresh_languages
export has_language, has_all_languages, get_language_file
export file_out_of_date
export load_pdf_font_info, save_pdf_font_info, refresh_pdf_font_info

export download_file


end
