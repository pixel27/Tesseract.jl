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
using Dates
using JSON
using SHA

# =================================================================================================
"""
    mutable struct DataFileIndex
        version::Int64
        lastcheck::String
        server::String
        files::Dict{String, DataFile}
    end

The DataFileIndex object holds details about the server and the training data files.

__Values:__

| Name      | Description
| :-------- | :----------
| version   | The version number of the file on disk.
| lastcheck | The time when we last checked with the server.
| server    | The URL of the server.
| files     | The details about all the training data files.

__Constructors:__

    DataFileIndex()

Create a new instance of the DataFileIndex object.
"""
mutable struct DataFileIndex
    version::Int64
    lastcheck::String
    server::String
    files::Dict{String, DataFile}
    DataFileIndex() = new(INDEX_VERSION, "", "", Dict{String, DataFile}())
    DataFileIndex(version, lastcheck, server, files) = new(version, lastcheck, server, files)
end

# =================================================================================================
"""
    dfi_get(
        index::DataFileIndex,
        lang::AbstractString
    )::DataFile

Retrieve the file information for the specified language.  If the language is not found then a new
record is created an returned.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | idx  |         | The index to look for the language in.
| R | lang |         | The language we're looking for.
"""
function dfi_get(
            idx::DataFileIndex,
            lang::AbstractString
        )::Union{DataFile, Nothing}
    local key = string(lang, DATA_FILE_EXT)

    return get!(idx.files, key) do
        DataFile(key)
    end
end

# =================================================================================================
"""
    dfi_has(
        idx::DataFileIndex,
        languages::AbstractVector
    )::Bool

Check if we have all the specified languages defined.  If we don't have a definition for any of the
languages `false` is returned.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | idx       |         | The index to look for the languages in.
| R | languages |         | The languages we're looking for.
"""
function dfi_has(
            idx::DataFileIndex,
            languages::AbstractVector
        )::Bool
    for lang in languages
        local key = string(lang, DATA_FILE_EXT)
        if haskey(idx.files, key) == false
            return false
        end
    end
    return true
end

# =================================================================================================
"""
    dfi_has(
        idx::DataFileIndex,
        lang::AbstractString
    )::Bool

Check if we have the specified language definition.  Returns `false` if the definition is not
found.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | idx  |         | The index to look for the languages in.
| R | lang |         | The language we're looking for.
"""
function dfi_has(
            idx::DataFileIndex,
            lang::AbstractString
        )::Bool
    local key = string(lang, DATA_FILE_EXT)

    return haskey(idx.files, key)
end

# =================================================================================================
"""
    dfi_parse(
        json::AbstractDict
    )::DataFileIndex

Create and populate a DataFileIndex from the dictionary created by the JSON package.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | json |         | The dictionary to extract the values from.

__Details:__

If JSON contains invalid information then an empty DataFileIndex structure is returned.
"""
function dfi_parse(
            json::AbstractDict
        )::DataFileIndex
    if isa(json, AbstractDict) == false
        @warn "$INDEX_FILE corrupt.)"
        return nothing
    end

    local version   = get_json_safe(Int64, json, "version")
    local lastcheck = get_json_safe(String, json, "lastcheck")
    local server    = get_json_safe(String, json, "server")
    local files     = get_json_safe(AbstractVector, json, "files")

    if (version == nothing || lastcheck == nothing || server == nothing || files == nothing)
        @warn "$INDEX_FILE corrupt.)"
        return DataFile()
    end

    local filemap = Dict{String, DataFile}()

    for f in files
        local file = df_parse(f)

        if file == nothing
            return DataFile()
        end

        filemap[file.filename] = file
    end

    return DataFileIndex(version, lastcheck, server, filemap)
end

# =================================================================================================
"""
    dfi_load(
        path::AbstractString
    )::DataFileIndex

Load our data file index from the specified directory.  If the file doesn't exist or is corrupt a
new empty object is returned.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | path |         | The path to load the data file index from.
"""
function dfi_load(
            path::AbstractString
        )::DataFileIndex
    local result   = nothing
    local filename = joinpath(path, INDEX_FILE)

    if create_data_dir(path) == true && isfile(filename) == true
        try
            local file = read(filename, String)
            local data = JSON.parse(file)

            if isa(data, AbstractDict) == true
                result = dfi_parse(data)
            else
                @warn "Could not parse data file index: $filename"
            end
        catch ex
            if isa(ex, SystemError) == false
                rethrow(ex)
            end
        end
    end

    if result == nothing
        result = DataFileIndex()
    end

    return result
end

# =================================================================================================
"""
    dfi_update_needed(
        index::DataFileIndex,
        source::GithubTrainingData,
        frequency::Integer
    )::Bool

Check if we should synchronize our data with the github server.  Returns false if the data we have
is good enough.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | idx       |         | The index file to check.
| R | source    |         | The GitHub project/directory to synchronize with.
| R | frequency |         | How old our data should be before we synchronize again.

__Details:__

This method returns true under the following conditions:

  * We've never synchronized with the server.
  * The URL for the server is different from the URL we synchronized with last.
  * The last synchronization was more than `frequency` days ago.
"""
function dfi_update_needed(
            idx::DataFileIndex,
            source::GithubTrainingData,
            frequency::Integer
        )::Bool
    local update = false

    if idx.server != gh_url(source)
        update = true
    elseif idx.lastcheck == ""
        update = true
    elseif now() > DateTime(idx.lastcheck, DATE_FORMAT) + Day(frequency)
        update = true
    end

    return update
end

# =================================================================================================
"""
    dfi_refresh(
        idx::DataFileIndex,
        source::GithubTrainingData,
        frequency::Integer,
        force::Bool
    )::Bool

Refresh our data with the server if it's out of date.  Returns true if we refreshed with the
server.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | idx       |         | The index file to refresh if needed.
| R | source    |         | The GitHub project/directory to synchronize with.
| R | frequency |         | How old our data should be before we synchronize again.
| R | force     |         | Flag that indicates we should refresh no mater what.

__Details:__

This method returns true under the following conditions:

  * We've never synchronized with the server.
  * The URL for the server is different from the URL we synchronized with last.
  * The last synchronization was more than `frequency` days ago.
"""
function dfi_refresh(
            idx::DataFileIndex,
            source::GithubTrainingData,
            frequency::Integer,
            force::Bool
        )::Bool
    local result = false

    try
        # -----------------------------------------------------------------------------------------
        # Update the remotesha1 values if needed.
        if force || dfi_update_needed(idx, source, frequency)

            for (filename, sha1) in gh_contents(source)
                local lang = chop(filename; tail=length(DATA_FILE_EXT))
                local file = dfi_get(idx, lang)
                file.remotesha1 = sha1
            end

                idx.server    = gh_url(source)
                idx.lastcheck = Dates.format(now(), DATE_FORMAT)

            result = true
        end
    catch ex
        # -----------------------------------------------------------------------------------------
        # If the exception is NOT a NetworkError rethrow it.
        if isa(ex, NetworkError) == false
            rethrow(ex)
        end
    end

    return result
end

# =================================================================================================
"""
    dfi_save(
        idx::DataFileIndex,
        path::AbstractString
    )::Bool

Save data file index to the specified directory.  Returns `false` if the the operations fails.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | idx  |         | The index to save.
| R | path |         | The path to save the file to.
"""
function dfi_save(
            idx::DataFileIndex,
            path::AbstractString
        )::Bool
    local result   = false
    local filename = joinpath(path, INDEX_FILE)
    local data     = Dict{String, Any}()

    data["version"] = INDEX_VERSION
    data["lastcheck"] = idx.lastcheck
    data["server"]    = idx.server
    data["files"]     = collect(values(idx.files))

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
