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
module Data

using Dates

const INDEX_VERSION = 1
const INDEX_FILE = ".tesseract"
const DATA_FILE_EXT = ".traineddata"
const DATE_FORMAT = @dateformat_str("HH:MM:SS dd-mm-yyyy")
const GITHUB_TRAINING_OWNER = "tesseract-ocr"
const GITHUB_TRAINING_PACKAGE = "tessdata_best"
const GITHUB_DOWNLOAD_BASE = "https://raw.githubusercontent.com"
const GITHUB_CONTENTS_BASE = "https://api.github.com/repos"

include("errors.jl")
include("common.jl")
include("github.jl")
include("data_file.jl")
include("data_file_index.jl")

export update_languages, download_languages

# =================================================================================================
"""
    update_languages(
        languages::AbstractString = "eng",
        path::AbstractString = "tessdata";
        frequency::Integer = 7,
        source::GithubTrainingData = GithubTrainingData()
    )::Bool

Update the training data files for the specified languages.  Returns false if there was an error
updating the files.

__Arguments:__

| T | Name      | Default    | Description
|:--| :-------- | :----------| :----------
| O | languages | `eng`      | The languages to update separated with "+".
| O | path      | `tessdata` | The directory to save the data files in.
| O | frequency | `7`        | How often to check for updates on the server in days.
| O | source    | ...        | The GitHub project to download from.

__Details:__

By default the data files are saved in a "tessdata" directory under the current directory, and the
files are downloaded from https://github.com/tesseract-ocr/tessdata_best.
"""
function update_languages(
            languages::AbstractString = "eng",
            path::AbstractString = "tessdata";
            frequency::Integer = 7,
            source::GithubTrainingData = GithubTrainingData()
        )::Bool
    local result = true
    local index = dfi_load(path)

    try
        local url   = gh_url(source)
        local list  = split(languages, "+")
        local force = (dfi_has(index, list) == false)

        dfi_refresh(index, source, frequency, force)

        for lang in list

            if dfi_has(index, lang) == true
                local file = dfi_get(index, lang)

                if df_update_needed(file, path)
                    local fullurl = string(url, file.filename)
                    local fullpath = joinpath(path, file.filename)

                    file.localsha1 = download(fullurl, fullpath)
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

    dfi_save(index, path)

    return result
end

# =================================================================================================
"""
    download_languages(
        languages::AbstractString = "eng",
        path::AbstractString = "tessdata",
        url::AbstractString = gh_url(GithubTrainingData());
        force::Bool = false
    )::Bool

Download the data files for the specified languages.  Returns `false` if there is a problem
downloading the files.

__Arguments:__

| T | Name      | Default    | Description
|:--| :-------- | :--------- | :----------
| O | languages | `eng`      | The languages to download separated with "+".
| O | path      | `tessdata` | The directory to save the data files in.
| O | url       | ...        | The base URL to download the files from.
| O | force     | `false`    | Should the files be downloaded even if they exist?

__Details:__

By default the data files are saved in a "tessdata" directory under the current directory, and the
files are downloaded from https://github.com/tesseract-ocr/tessdata_best.

Normally if the file has already been downloaded then it is not downloaded again.  However if
`force` is true then the file is downloaded and the existing file is overwritten.
"""
function download_languages(
            languages::AbstractString = "eng",
            path::AbstractString = "tessdata",
            url::AbstractString = gh_url(GithubTrainingData());
            force::Bool = false
        )::Bool
    local result = false
    local index = dfi_load(path)

    try
        for lang in split(languages, "+")
            local file     = dfi_get(index, lang)
            local filename = joinpath(path, file.filename)

            if force == true || ispath(filename) == false
                local fullurl = string(url, file.filename)
                local fullpath = joinpath(path, file.filename)
                local sha1 = download(fullurl, fullpath)

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
    dfi_save(index, path)

    return result
end

end
