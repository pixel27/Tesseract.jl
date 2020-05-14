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

mutable struct PdfFontInfo
    version::Int64
    lastcheck::String
    server::String
    font::GitHubFile
    PdfFontInfo() = new(INDEX_VERSION, "", "", GitHubFile("pdf.ttf", 0.0, "", "", ""))
    PdfFontInfo(version, lastcheck, server, font) = new(version, lastcheck, server, font)
end

# =========================================================================================
"""
    is_expired(
        info::PdfFontInfo,
        frequency::Integer
    )::Bool

Check if our pdf font info data is older than `frequency` days.  Returns `true` if the
data is older.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | info      |         | The object to check.
| R | frequency |         | How old our data should be before we synchronize again.
"""
function is_expired(
            info::PdfFontInfo,
            frequency::Integer
        )::Bool
    if isempty(info.lastcheck)
        return true
    elseif info.server == ""
        return true
    elseif now() > DateTime(info.lastcheck, DATE_FORMAT) + Day(frequency)
        return true
    end

    return false
end

# =================================================================================================
"""
    update_pdf_font_info(
        info::PdfFontInfo,
        source::GitHubProject,
    )::Nothing

Grab the latest URL and SHA1 code for the PDF font file from GitHub and update the index
file with them.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | gh   |         | The GitHub project to sync the font file with.
| R | info |         | The object to synchronize with GitHub.

__Exceptions:__

| Name         | Reason
| :----------- | :-----
| NetworkError | There was a network error retrieving the contents from GitHub.
"""
function update_pdf_font_info(
            info::PdfFontInfo,
            source::GitHubProject
        )::Nothing
    local data = gh_contents(source)

    if isa(data, AbstractArray) == false
        @warn "Unexpected response from the server: $(JSON.json(data))"
        throw(NetworkError(gh_url(source)))
    end

    local found = false

    for file in data
        local name = get_json_safe(String, file, "name")

        if name !== nothing && name == "pdf.ttf"
            local sha  = get_json_safe(String, file, "sha")
            local url  = get_json_safe(String, file, "download_url")

            if sha !== nothing && url !== nothing

                info.font.remotesha1 = sha
                info.font.url        = url
                info.server          = gh_url(source)
                info.lastcheck       = Dates.format(now(), DATE_FORMAT)

                found = true

            elseif sha === nothing

                @warn "Directory entry has no sha!"

            else

                @warn "Directory entry has no download_url!"

            end
        end
    end

    if found == false
        @error "Could not fid pdf.ttf in the specified repository."
    end

    nothing
end

# =========================================================================================
"""
    refresh_pdf_font_info(
        info::PdfFontInfo,
        source::GitHubProject,
        frequency::Integer
    )::Bool

Refresh our data with the server if it's out of date.  Returns true if we refreshed with
the server.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | info      |         | The `PdfFontINfo` object to refresh.
| R | source    |         | The GitHub project/directory to synchronize with.
| R | frequency |         | How old our data should be before we synchronize again.

__Details:__

This method returns true under the following conditions:

  * We've never synchronized with the server.
  * The URL for the server is different from the URL we synchronized with last.
  * The last synchronization was more than `frequency` days ago.
"""
function refresh_pdf_font_info(
            info::PdfFontInfo,
            source::GitHubProject,
            frequency::Integer
        )::Bool
    local result = false

    try
        # ---------------------------------------------------------------------------------
        # Update the training information if needed.
        if is_expired(info, frequency)
            update_pdf_font_info(info, source)
            result = true
        end

    catch ex
        # ---------------------------------------------------------------------------------
        # If the exception is NOT a NetworkError rethrow it.
        if isa(ex, NetworkError) == false
            rethrow(ex)
        end
    end

    return result
end

# =========================================================================================
"""
parse_pdf_font_info(
        json::AbstractDict
    )::PdfFontInfo

Populate the `PdfFontInfo` object from a JSON object loaded from disk.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | json |         | The JSON object to extract the values from.

__Details:__

If JSON contains invalid information then an empty `PdfFontInfo` structure is returned.
"""
function parse_pdf_font_info(
            json::AbstractDict
        )::PdfFontInfo

    # -------------------------------------------------------------------------------------
    # Grab the values we're interested in from the JSON.
    local version    = get_json_safe(Int64, json, "version")
    local lastcheck  = get_json_safe(AbstractString, json, "lastcheck")
    local server     = get_json_safe(AbstractString, json, "server")
    local file       = parse_github_file(get_json_safe(AbstractDict, json, "font"))

    version === nothing && return PdfFontInfo()
    lastcheck === nothing && return PdfFontInfo()
    server === nothing && return PdfFontInfo()
    file === nothing && return PdfFontInfo()

    # -------------------------------------------------------------------------------------
    # Check the version.
    if version != INDEX_VERSION
        return PdfFontInfo()
    end

    # -------------------------------------------------------------------------------------
    # Create the object.
    return PdfFontInfo(version, lastcheck, server, file)
end

# =========================================================================================
"""
    load_pdf_font_info(
        path::AbstractString
    )::PdfFontInfo

Load the contents of the PdfFontInfo object from the specified directory.  If the file
doesn't exist or is corrupt a new empty object is returned.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | path |         | The path to load the file from.
"""
function load_pdf_font_info(
            path::AbstractString
        )::PdfFontInfo
    local result   = nothing
    local filename = joinpath(path, PDF_FONT_INFO_FILE)

    if create_data_dir(path) == true && isfile(filename) == true
        try
            # -----------------------------------------------------------------------------
            # Load and parse the file.
            local file = read(filename, String)
            local data = JSON.parse(file)

            if isa(data, AbstractDict) == true
                result = parse_pdf_font_info(data)
            else
                # -------------------------------------------------------------------------
                # Bad JSON file.
                @warn "Could not parse: $filename"
                result = PdfFontInfo()
            end
        catch ex
            # -----------------------------------------------------------------------------
            # Error reading the file.
            if isa(ex, SystemError) == true
                @warn "Could not read: $filename"
            elseif isa(ex, ErrorException) == false
                @warn "Could not parse: $filename"
            else
                rethrow(ex)
            end
            result = PdfFontInfo()
        end
    else
        # ---------------------------------------------------------------------------------
        # File does not exist.
        result = PdfFontInfo()
    end

    return result
end

# =========================================================================================
"""
save_pdf_font_info(
        info::PdfFontInfo,
        path::AbstractString
    )::Bool

Save pdf font info file to the specified directory.  Returns `false` if the the operation
fails.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | info |         | The `PdfFontInfo` object to save.
| R | path |         | The path to save the file to.
"""
function save_pdf_font_info(
            info::PdfFontInfo,
            path::AbstractString
        )::Bool
    local result   = false
    local filename = joinpath(path, PDF_FONT_INFO_FILE)
    local data     = Dict{String, Any}()

    data["version"]    = INDEX_VERSION
    data["lastcheck"]  = info.lastcheck
    data["server"]     = info.server
    data["font"]       = info.font

    try
        write(filename, JSON.json(data))
        result = true
    catch ex
        if isa(ex, SystemError) == false
            rethrow(ex)
        end
    end

    return result
end
