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
using .DataFiles

# =========================================================================================
"""
    download_languages(
        languages::AbstractString = "eng";
        target::AbstractString = "tessdata",
        baseUrl::AbstractString = DATA_URL,
        force::Bool = false
    )::Bool

Download the data files for the specified languages.  Returns `false` if there is a problem
downloading the files.

__Arguments:__

| T | Name      | Default    | Description
|:--| :-------- | :--------- | :----------
| O | languages | `eng`      | The languages to download separated with "+".
| K | target    | `tessdata` | The directory to save the data files in.
| K | baseUrl   | ...        | The base URL to download the files from.
| K | force     | `false`    | Should the files be downloaded even if they exist?

__Details:__

By default the data files are saved in a "tessdata" directory under the current directory,
and the files are downloaded from https://github.com/tesseract-ocr/tessdata_best.

Normally if the file has already been downloaded then it is not downloaded again.  However
if `force` is true then the file is downloaded and the existing file is overwritten.

See also: [`update_languages`](@ref)
"""
function download_languages(
            languages::AbstractString = "eng";
            target::AbstractString = "tessdata",
            baseUrl::AbstractString = DATA_URL,
            force::Bool = false
        )::Bool
    local result = false
    local index = load_languages(target)

    try
        for lang in split(languages, "+")
            local filename = string(lang, DATA_FILE_EXT)
            local fullpath = joinpath(target, filename)
            local file     = get_language_file(index, lang)

            if force == true || ispath(fullpath) == false
                local url  = string(baseUrl, filename)
                local sha1 = download_file(url, fullpath)

                file.localsha1  = sha1
                file.timestamp  = mtime(fullpath)
            end
        end

        result = true
    catch ex
        if isa(ex, FileError) == false && isa(ex, NetworkError) == false
            rethrow(ex)
        end
    end
    save_languages(index, target)

    return result
end

# =================================================================================================
"""
    download_pdf_font(;
        target::AbstractString = "tessdata"
        baseUrl::AbstractString = PDF_FONT_URL,
        force::Bool = false
    )::Bool

Download the PDF font file.  Returns `false` if there is a problem downloading the files.

__Arguments:__

| T | Name    | Default    | Description
|:--| :------ | :--------- | :----------
| K | target  | `tessdata` | The directory to save the PDF font to.
| K | baseUrl | ...        | The base URL to download the file from.
| K | force   | `false`    | Should the file be downloaded even it it exists?

__Details:__

By default "pdf.ttf" is downloaded from https://github.com/tesseract-ocr/tessconfigs.
The client can specify a different URL to download the file from.  This file is needed when
asking Tesseract to generate a PDF.

Normally if the file has already been downloaded then it is not downloaded again.  However
if `force` is true then the file is downloaded and the existing file is overwritten.

See also: [`update_pdf_font`](@ref)
"""
function download_pdf_font(;
            target::AbstractString = "tessdata",
            baseUrl::AbstractString = PDF_FONT_URL,
            force::Bool = false
        )::Bool
    local result = false
    local index = load_pdf_font_info(target)

    try
        local fullpath = joinpath(target, "pdf.ttf")

        if force == true || ispath(fullpath) == false
            local fullurl = string(baseUrl, "pdf.ttf")
            local sha1    = download_file(fullurl, fullpath)

            index.font.localsha1  = sha1
            index.font.timestamp  = mtime(fullpath)
        end

        result = true
    catch ex
        if isa(ex, FileError) == false && isa(ex, NetworkError) == false
            rethrow(ex)
        end
    end

    save_pdf_font_info(index, target)

    return result
end
