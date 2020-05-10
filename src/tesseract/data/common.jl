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
using HTTP
using HTTP.IOExtras
using SHA

# =================================================================================================
"""
    get_json_safe(
        ::Type{T},
        json::AbstractDict,
        key::AbstractString
    )::Union{T, nothing}

Return a value from a JSON dictionary of the specified type.  Returns `false` if the item doesn't
exist or is not of the specified type.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | ::Type{T} |         | The data type expected for the value.
| R | json      |         | The JSON dictionary to pull the value from.
| R | key       |         | Key to look for in the dictionary.
"""
function get_json_safe(
            ::Type{T},
            json::AbstractDict,
            key::AbstractString
        )::Union{T, Nothing} where T

    if haskey(json, key) == false
        return nothing
    end

    local value = json[key]

    if isa(value, T) == false
        return nothing
    end

    return value
end

# =================================================================================================
"""
    create_data_dir(
        dir::AbstractString
    )::Bool

Return a value from a JSON dictionary of the specified type.  Returns `false` if the item doesn't
exist or is not of the specified type.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | ::Type{T} |         | The data type expected for the value.
| R | json      |         | The JSON dictionary to pull the value from.
| R | key       |         | Key to look for in the dictionary.
"""
function create_data_dir(
            dir::AbstractString
        )::Bool

    # ---------------------------------------------------------------------------------------------
    # Directory exists, our work is done.
    if isdir(dir) == true
        return true
    end

    # ---------------------------------------------------------------------------------------------
    # Make sure the path isn't something else
    if ispath(dir) == true
        @warn("Data directory is not a directory: $(abspath(dir))")
        return false
    end

    # ---------------------------------------------------------------------------------------------
    # Create the directory.
    local retval = false

    try
        mkpath(dir)
        retval = true
    catch ex
        if isa(ex, Base.IOError) == false
            rethrow(ex)
        end
        @warn("Could not create data directory: $(abspath(dir))")
    end

    return retval
end

# =================================================================================================
"""
    calc_sha1(
        fullPath::AbstractString
    )::String

Calculate the GitHub SHA1 for a file on disk.  Returns the SHA1 code for the file.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | fullpath |         | The full path to the file we want to read.

__Exceptions:__

| Name         | Reason
| :----------- | :-----
| FileError    | There was an issue reading from the file.

__Details:__

GitHub's SHA1 value is slightly different from a sha1sum calculated locally.  First the text:
"blob $size\0" is hashed followed by the contents of the file.  Size is replaced by the file
size in decimal.
"""
function calc_sha1(
            fullpath::AbstractString
        )::String
    local sha1 = SHA1_CTX()
    local size = filesize(fullpath)
    update!(sha1, Vector{UInt8}("blob $size\0"))

    try
        open(fullpath; read = true) do io
            local buffer = Vector{UInt8}(undef, 8192)

            while eof(io) == false
                local bytes = readbytes!(io, buffer)
                update!(sha1, buffer, bytes)
            end
        end
    catch ex
        if isa(ex, SystemError)
            @warn "Could not read file: $(fullpath)"
            throw(FileError(fullpath))
        end
        rethrow(ex)
    end

    return bytes2hex(digest!(sha1))
end

# =================================================================================================
"""
    download(
        url::AbstractString,
        filename::AbstractString
    )::String

Download the file at the specified URL and save it to the specified file name.  Returns the GitHub
SHA1 value.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | url      |         | The URL to download.
| R | filename |         | The file to save the contents to.

__Exceptions:__

| Name         | Reason
| :----------- | :-----
| FileError    | There was an issue writing to the file.
| NetworkError | There was an issue downloading the file.

__Details:__

If the file exists it is overwritten.  The GitHub SHA1 is slightly different that a sha1sum
calculated locally.  First "blob $size\0" is hashed followed by the contents of the file.
"""
function download(
            url::AbstractString,
            filename::AbstractString
        )::String
    local sha1 = SHA1_CTX()

    try
        # -----------------------------------------------------------------------------------------
        # Open the file for writing, and make the HTTP request.
        open(filename; create = true, write = true) do output

            HTTP.open("GET", url; redirect = false) do incoming
                startread(incoming)

                local size = parse(Int, HTTP.header(incoming, "Content-Length"))
                update!(sha1, Vector{UInt8}("blob $size\0"))

                # ---------------------------------------------------------------------------------
                # Download the file if the server responded with a 200.
                if incoming.message.status == 200
                    local buffer = Vector{UInt8}(undef, 8192)

                    while eof(incoming) == false
                        local bytes = readbytes!(incoming, buffer)
                        write(output, view(buffer, 1:bytes))
                        update!(sha1, buffer, bytes)
                    end
                else
                    @warn "Failed to download $url, HTTP error: $(incoming.message.status)"
                    throw(NetworkError(url))
                end
            end
        end
    catch ex
        # ---------------------------------------------------------------------------------------------
        # We had an error nuke the file.
        if isfile(filename)
            rm(filename)
        end

        # ---------------------------------------------------------------------------------------------
        # SystemError means we had an file error.
        if isa(ex, SystemError)
            throw(FileError(filename))
        end

        # ---------------------------------------------------------------------------------------------
        # Unknown error, rethrow it.
        rethrow(ex)
    end

    # ---------------------------------------------------------------------------------------------
    # Return the DataFile object.
    return bytes2hex(digest!(sha1))
end
