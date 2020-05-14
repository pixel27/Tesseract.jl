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
using JSON

# =========================================================================================
"""
    mutable struct Languages
        version::Int64
        lastcheck::String
        server::String
        files::Dict{String, GitHubFile}
    end

This structure holds details about the language files used by Tesseract

__Values:__

| Name       | Description
| :--------- | :----------
| version    | The version number of the file on disk.
| lastcheck  | The time when we last checked with the server.
| server     | The URL of the server.
| files      | The details about all the training data files.

__Constructors:__

    Languages()

Create a new instance of the object.
"""
mutable struct Languages
    version::Int64
    lastcheck::String
    server::String
    files::Dict{String, GitHubFile}
    Languages() = new(INDEX_VERSION, "", "", Dict{String, GitHubFile}())
    Languages(version, lastcheck, server, files) = new(version, lastcheck, server, files)
end

# =========================================================================================
"""
    get_language_file(
        langs::Languages,
        language::AbstractString
    )::GitHubFile

Retrieve the file information for the specified file.  If the file is not found then a new
record is created an returned.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | langs    |         | The `Languages` structure to look for the file in.
| R | language |         | The language to get the file for.
"""
function get_language_file(
            langs::Languages,
            language::AbstractString
        )::GitHubFile
    return get!(langs.files, language) do
        GitHubFile(string(language, DATA_FILE_EXT), 0.0, "", "", "")
    end
end

# =========================================================================================
"""
has_all_languages(
        langs::Languages,
        languages::AbstractVector
    )::Bool

Check if we have all the specified languages defined.  If we don't have a definition for
one of the languages `false` is returned.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | langs     |         | The `Languages` object to look for the languages in.
| R | languages |         | The languages we're looking for.
"""
function has_all_languages(
            langs::Languages,
            languages::AbstractVector
        )::Bool
    for language in languages
        if haskey(langs.files, language) == false
            return false
        end
    end
    return true
end

# =========================================================================================
"""
    has_language(
        langs::Languages,
        language::AbstractString
    )::Bool

Check if we know about the specified language.  Returns `false` if the language file is is
not in the index.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | langs    |         | The `Languages` object to look for the language in.
| R | language |         | The language to check for.
"""
function has_language(
            langs::Languages,
            language::AbstractString
        )::Bool
    return haskey(langs.files, language)
end

# =========================================================================================
"""
    is_expired(
        langs::Languages,
        frequency::Integer
    )::Bool

Check if our languages index data is older than `frequency` days.  Returns `true` if the
data is older.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | langs     |         | The object to check.
| R | frequency |         | How old our data should be before we synchronize again.
"""
function is_expired(
            langs::Languages,
            frequency::Integer
        )::Bool
    if isempty(langs.lastcheck)
        return true
    elseif langs.server == ""
        return true
    elseif now() > DateTime(langs.lastcheck, DATE_FORMAT) + Day(frequency)
        return true
    end

    return false
end

# =========================================================================================
"""
    update_languages(
        lang::Languages
        source::GitHubProject,
    )::Nothing

Grab the latest URLs and SHA1 codes for the language data files from GitHub and update the
index file with them.

__Arguments:__

| T | Name   | Default | Description
|:--| :----- | :------ | :----------
| R | langs  |         | The language data to sync with the server.
| R | source |         | The GitHub project to sync the files with.

__Exceptions:__

| Name         | Reason
| :----------- | :-----
| NetworkError | There was a network error retrieving the contents from GitHub.
"""
function update_languages(
            langs::Languages,
            source::GitHubProject
        )::Nothing
    local data = gh_contents(source)

    if isa(data, AbstractArray) == false
        @warn "Unexpected response from the server: $(JSON.json(data))"
        throw(NetworkError(gh_url(source)))
    end

    local regex = r"^(.+)\.traineddata$"

    for file in data
        local name = get_json_safe(String, file, "name")
        local sha  = get_json_safe(String, file, "sha")
        local url  = get_json_safe(String, file, "download_url")

        if name === nothing
            @warn "Directory entry has no name!"
            continue
        elseif sha === nothing
            @warn "Directory entry has no sha!"
            continue
        end
        local m = match(regex, name)

        if m !== nothing && url !== nothing
            local language = m.captures[1]
            local details  = get_language_file(langs, language)

            details.remotesha1 = sha
            details.url        = url

            found = true
        elseif m !== nothing && url === nothing

            @warn "Data file has no download_url!"

        end
    end

    langs.server = gh_url(source)
    langs.lastcheck = Dates.format(now(), DATE_FORMAT)

    nothing
end

# =========================================================================================
"""
    refresh_languages(
        langs::Languages,
        source::GitHubProject,
        frequency::Integer,
        force::Bool
    )::Bool

Refresh our language data with the server if we are out of date.  Returns true if we
refreshed with the server.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | langs     |         | The `Languages` object to refresh.
| R | source    |         | The GitHub project/directory to synchronize with.
| R | frequency |         | How old our data should be before we synchronize again.
| R | force     |         | Flag that indicates we should refresh no mater what.

__Details:__

This method returns true under the following conditions:

  * We've never synchronized with the server.
  * The URL for the server is different from the URL we synchronized with last.
  * The last synchronization was more than `frequency` days ago.
"""
function refresh_languages(
            langs::Languages,
            source::GitHubProject,
            frequency::Integer,
            force::Bool
        )::Bool
    local result = false

    try
        # ---------------------------------------------------------------------------------
        # Update the training information if needed.
        if force || is_expired(langs, frequency)
            update_languages(langs, source)
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
    parse_languages(
        json::AbstractDict
    )::Languages

Create and populate a Languages object from a JSON object.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | json |         | The JSON object to extract the values from.

__Details:__

If JSON contains invalid information then an empty Languages structure is returned.
"""
function parse_languages(
            json::AbstractDict
        )::Languages

    # -------------------------------------------------------------------------------------
    # Grab the values we're interested in from the JSON.
    local version   = get_json_safe(Int64, json, "version")
    local lastcheck = get_json_safe(AbstractString, json, "lastcheck")
    local server    = get_json_safe(AbstractString, json, "server")
    local files     = get_json_safe(AbstractVector, json, "files")

    version === nothing && return Languages()
    lastcheck == nothing && return Languages()
    server == nothing && return Languages()
    files == nothing && return Languages()

    # -------------------------------------------------------------------------------------
    # Check the version.
    if version != INDEX_VERSION
        return Languages()
    end

    # -------------------------------------------------------------------------------------
    # Create the file map.
    local filemap = Dict{String, GitHubFile}()
    local regex   = r"^(.+)\.traineddata$"

    for f in files
        local file = parse_github_file(f)

        if file === nothing
            @warn "$LANGUAGES_FILE corrupt."
            return Languages()
        end
        local m = match(regex, file.filename)

        if m !== nothing
            filemap[m.captures[1]] = file
        end
    end

    return Languages(version, lastcheck, server, filemap)
end

# =========================================================================================
"""
    load_languages(
        path::AbstractString
    )::Languages

Load the languages data file from the specified directory.  If the file doesn't exist or is
corrupt a new empty object is returned.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | path |         | The path to load the languages file from.
"""
function load_languages(
            path::AbstractString
        )::Languages
    local result   = nothing
    local filename = joinpath(path, LANGUAGES_FILE)

    if create_data_dir(path) == true && isfile(filename) == true
        try
            # -----------------------------------------------------------------------------
            # Load and parse the file.
            local file = read(filename, String)
            local data = JSON.parse(file)

            if isa(data, AbstractDict) == true
                result = parse_languages(data)
            else
                # -------------------------------------------------------------------------
                # Bad JSON file.
                @warn "Could not parse: $filename"
                result = Languages()
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
            result = Languages()
        end
    else
        # ---------------------------------------------------------------------------------
        # File does not exist.
        result = Languages()
    end

    return result
end

# =========================================================================================
"""
    save_languages(
        langs::Languages,
        path::AbstractString
    )::Bool

Save languages file to the specified directory.  Returns `false` if the the operations
fails.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | langs |         | The languages data to save.
| R | path  |         | The path to save the file to.
"""
function save_languages(
            langs::Languages,
            path::AbstractString
        )::Bool
    local result   = false
    local filename = joinpath(path, LANGUAGES_FILE)
    local data     = Dict{String, Any}()

    data["version"]    = INDEX_VERSION
    data["lastcheck"]  = langs.lastcheck
    data["server"]     = langs.server
    data["files"]      = collect(values(langs.files))

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
