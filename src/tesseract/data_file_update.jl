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
    update_languages(
        languages::AbstractString = "eng";
        target::AbstractString = "tessdata",
        frequency::Integer = 7,
        source::GitHubProject = DATA_REPO
    )::Bool

Update the training data files for the specified languages.  Returns false if there was an
error updating the files.

__Arguments:__

| T | Name      | Default    | Description
|:--| :-------- | :----------| :----------
| O | languages | `eng`      | The languages to update separated with "+".
| K | target    | `tessdata` | The directory to save the data files in.
| K | frequency | `7`        | How often to check for updates on the server in days.
| K | source    | ...        | The GitHub project to download the training data from.

__Details:__

By default the data files are saved in a "tessdata" directory under the current directory.
The training data is normally downloaded from the
https://github.com/tesseract-ocr/tessdata_best GitHub project.

See also: [`download_languages`](@ref)
"""
function update_languages(
            languages::AbstractString = "eng";
            target::AbstractString = "tessdata",
            frequency::Integer = 7,
            source::GitHubProject = DATA_REPO
        )::Bool
    local result = true
    local index = load_languages(target)

    try
        local list  = split(languages, "+")
        local force = !has_all_languages(index, list)

        refresh_languages(index, source, frequency, force)

        for lang in list
            if has_language(index, lang) == true
                local file = get_language_file(index, lang)

                if file_out_of_date(file, target)
                    local fullpath = joinpath(target, file.filename)
                    file.localsha1 = download_file(file.url, fullpath)
                    file.timestamp = mtime(fullpath)
                end
            else
                @warn "Could not find training data for language: $(lang)"
                result = false
            end

        end

    catch ex
        if isa(ex, FileError) == false && isa(ex, NetworkError) == false
            rethrow(ex)
        end
        result = false
    end

    save_languages(index, target)

    return result
end

# =========================================================================================
"""
    update_pdf_font(;
        target::AbstractString = "tessdata",
        frequency::Integer = 7,
        source::GitHubProject = PDF_FONT_REPO
    )::Bool

Update the PDF font file.  This is only needed when generating PDF files.  Returns false if
there was an error updating the files.

__Arguments:__

| T | Name      | Default    | Description
|:--| :-------- | :----------| :----------
| K | target    | `tessdata` | The directory to save the font file in.
| K | frequency | `7`        | How often to check for updates on the server in days.
| K | source    | ...        | The GitHub project to download the font file from.

__Details:__

By default the data files are saved in a "tessdata" directory under the current directory.
The training data is normally downloaded from the
https://github.com/tesseract-ocr/tessdata_best GitHub project.

See also: [`download_pdf_font`](@ref)
"""
function update_pdf_font(;
            target::AbstractString = "tessdata",
            frequency::Integer = 7,
            source::GitHubProject = PDF_FONT_REPO
        )::Bool
    local result = true
    local info = load_pdf_font_info(target)

    try
        refresh_pdf_font_info(info, source, frequency)

        if file_out_of_date(info.font, target)
            local fullpath = joinpath(target, info.font.filename)
            info.font.localsha1 = download_file(info.font.url, fullpath)
            info.font.timestamp = mtime(fullpath)
        end

    catch ex
        if isa(ex, FileError) == false && isa(ex, NetworkError) == false
            rethrow(ex)
        end
        result = false
    end

    save_pdf_font_info(info, target)

    return result
end
