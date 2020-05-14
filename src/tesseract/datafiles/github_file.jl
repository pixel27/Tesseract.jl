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

# ========================================================================================+
"""
    mutable struct GitHubFile
        filename::String
        timestamp::Float64
        localsha1::String
        remotesha1::String
        url::String
    end

This object holds details about a file that is downloaded from GitHub.  It stores the SHA1
(as calculated by GitHub) for both the server version and the local version.  Along with
with the timestamp of when the local file was last modified.

__Values:__

| Name        | Description
| :---------- | :----------
| filename    | The full name (without the path) of the training data file.
| timestamp   | The last time we modifed the file.
| localsha1   | The local SHA1 for the file.
| remotesha1  | The remote SHA1 for the same file.
| url         | The URL that can be used to download the file.
"""
mutable struct GitHubFile
    filename::String
    timestamp::Float64
    localsha1::String
    remotesha1::String
    url::String
    GitHubFile() = new("", 0.0, "", "", "")
    GitHubFile(filename, timestamp, localsha, remotesha, url) = new(filename, timestamp, localsha, remotesha, url)
end

# =================================================================================================
"""
    parse_github_file(
        record
    )::Union{DfFGitHubFileile, Nothing}

Construct a GitHubFile object from a JSON record.  If the JSON is invalid returns
`nothing`.

__Arguments:__

| T | Name   | Default | Description
|:--| :----- | :------ | :----------
| R | record |         | The JSON object to pull the values from.
"""
function parse_github_file(
            record
        )::Union{GitHubFile, Nothing}

    if isa(record, AbstractDict) == false
        return nothing
    end

    # -------------------------------------------------------------------------------------
    # Extract the values.
    local filename    = get_json_safe(AbstractString, record, "filename")
    local timestamp   = get_json_safe(Float64, record, "timestamp")
    local localsha1   = get_json_safe(AbstractString, record, "localsha1")
    local remotesha1  = get_json_safe(AbstractString, record, "remotesha1")
    local url         = get_json_safe(AbstractString, record, "url")

    # -------------------------------------------------------------------------------------
    # Make sure the values exist.
    filename === nothing && return nothing
    timestamp === nothing && return nothing
    localsha1 === nothing && return nothing
    remotesha1 === nothing && return nothing
    url === nothing && return nothing

    # -------------------------------------------------------------------------------------
    # Create the GitHubFile object.
    return GitHubFile(filename, timestamp, localsha1, remotesha1, url)
end

# =================================================================================================
"""
file_out_of_date(
        file::GitHubFile,
        path::AbstractString
    )::Bool

Check if the file is out of date with the server.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | file |         | The file to check if it's out of date.
| R | path |         | The directory to look for the file in.

__Exceptions:__

| Name         | Reason
| :----------- | :-----
| FileError    | There was an issue reading from the file.

__Details:__

Primarily this method checks if the local sha1 matches the server's sha1.  If they match no
update is needed.  However if the local training data file is missing, then we need to
update it.  Also if the timestamp of the file is different than the timestamp we have we
need to re-calculate the sha1 because it might have changed.

This method will update the localsh1 and timestamp properties if they are out of sync with
the local file system.
"""
function file_out_of_date(
            file::GitHubFile,
            path::AbstractString
        )::Bool
    local fullpath = joinpath(path, file.filename)

    # ---------------------------------------------------------------------------------------------
    # If the file doesn't exist, then it needs to be updated.
    if isfile(fullpath) == false
        return true
    end

    # ---------------------------------------------------------------------------------------------
    # If the timestamp doesn't match our timestamp, recalculate the sha1.
    local timestamp = mtime(fullpath)
    if timestamp != file.timestamp
        file.localsha1 = calc_sha1(fullpath)
        file.timestamp = timestamp
    end

    # ---------------------------------------------------------------------------------------------
    # Compare our sha1 with the server's.
    return file.localsha1 != file.remotesha1
end
