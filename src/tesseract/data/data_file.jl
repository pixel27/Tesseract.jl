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
    mutable struct DataFile
        filename::String
        timestamp::Float64
        localsha1::String
        remotesha1::String
    end

The DataFile object holds details about a training data file so we can determine if it needs to be
updated.

__Values:__

| Name       | Description
| :--------- | :----------
| filename   | The full name (without the path) of the training data file.
| timestamp  | The last time we modifed the file.
| localsha1  | The local SHA1 for the file.
| remotesha1 | The remote SHA1 for the same file.

__Constructors:__

    DataFile(
        filename
    )

Create an empty instance with only the file name.

    DataFile(
        filename,
        timestamp,
        localsha1,
        remotesha1
    )

Create an instance with all the values.
"""
mutable struct DataFile
    filename::String
    timestamp::Float64
    localsha1::String
    remotesha1::String
    DataFile(filename) = new(filename, 0.0, "", "")
    DataFile(filename, timestamp, localsha1, remotesha1) = new(filename, timestamp, localsha1, remotesha1)
end

# =================================================================================================
"""
    df_parse(
        record
    )::Union{DataFile, Nothing}

Extract the values from a JSON object and create the associated DataFile object.  Returns `nothing`
if the JSON object isn't correct.

__Arguments:__

| T | Name   | Default | Description
|:--| :----- | :------ | :----------
| R | record |         | The JSON object to pull the values from.

__Details:__

This method ensures that all the data types in the JSON object are correct before creating the
DataFile object.
"""
function df_parse(
            record
        )::Union{DataFile, Nothing}

    if isa(record, AbstractDict) == false
        return nothing
    end

    local filename   = get_json_safe(AbstractString, record, "filename")
    local timestamp  = get_json_safe(Float64, record, "timestamp")
    local localsha1  = get_json_safe(AbstractString, record, "localsha1")
    local remotesha1 = get_json_safe(AbstractString, record, "remotesha1")

    if filename == nothing || timestamp == nothing || localsha1 == nothing || remotesha1 == nothing
        @warn "$INDEX_FILE corrupt, could not parse record: $(JSON.json(record))"
        return nothing
    end

    return DataFile(filename, timestamp, localsha1, remotesha1)
end

# =================================================================================================
"""
    df_update_needed(
        file::DataFile,
        path::AbstractString
    )::Bool

Check if the training data needs to be updated.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | df   |         | The file to determine if we need to check with the server.
| R | path |         | The directory to look for the training data under.

__Exceptions:__

| Name         | Reason
| :----------- | :-----
| FileError    | There was an issue reading from the file.

__Details:__

Primarily this method checks if the local sha1 matches the server's sha1.  If they match no update
is needed.  However if the local training data file is missing, then we need to update it.  Also
if the timestamp of the file is different than the timestamp we have we need to recalculate the
sha1 because it might have changed.

This method may update the localsh1 and timestamp properties if they are out of sync with the
local file system.
"""
function df_update_needed(
            df::DataFile,
            path::AbstractString
        )::Bool
    local fullpath = joinpath(path, df.filename)

    # ---------------------------------------------------------------------------------------------
    # If the file doesn't exist, then it needs to be updated.
    if isfile(fullpath) == false
        return true
    end

    # ---------------------------------------------------------------------------------------------
    # If the timestamp doesn't match our timestamp, recalculate the sha1.
    local timestamp = mtime(fullpath)
    if timestamp != df.timestamp
        df.localsha1 = calc_sha1(fullpath)
        df.timestamp = timestamp
    end

    # ---------------------------------------------------------------------------------------------
    # Compare our sha1 with the server's.
    return df.localsha1 != df.remotesha1
end
