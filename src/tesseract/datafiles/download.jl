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
using JSON
using SHA

# =========================================================================================
"""
    download_file(
        fromUrl::AbstractString,
        toFile::AbstractString
    )::String

Download the the URL and safe it to the file.  Returns the GitHub SHA1 value for the file
that was downloaded.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | fromUrl  |         | The URL to download.
| R | toFile   |         | The file to save the contents to.

__Exceptions:__

| Name         | Reason
| :----------- | :-----
| FileError    | There was an issue writing to the file.
| NetworkError | There was an issue downloading the file.

__Details:__

If the file exists it is overwritten.  The GitHub SHA1 is slightly different that a sha1sum
calculated locally.  First "blob $size\0" is hashed followed by the contents of the file.
"""
function download_file(
            fromUrl::AbstractString,
            toFile::AbstractString
        )::String
    local sha1 = SHA1_CTX()

    try
        # ---------------------------------------------------------------------------------
        # Open the file for writing, and make the HTTP request.
        open(toFile; create = true, write = true) do output

            HTTP.open("GET", fromUrl; redirect = false) do incoming

                # -------------------------------------------------------------------------
                # Start reading the data.
                startread(incoming)

                # -------------------------------------------------------------------------
                # Check for an error.
                if incoming.message.status != 200
                    @warn "Failed to download $fromUrl, HTTP error: $(incoming.message.status)"
                    throw(NetworkError(fromUrl))
                end

                # -------------------------------------------------------------------------
                # Start the hash.
                local size = parse(Int, HTTP.header(incoming, "Content-Length"))
                update!(sha1, Vector{UInt8}("blob $size\0"))

                # -------------------------------------------------------------------------
                # Download the file.
                local buffer = Vector{UInt8}(undef, 8192)

                while eof(incoming) == false
                    local bytes = readbytes!(incoming, buffer)
                    write(output, view(buffer, 1:bytes))
                    update!(sha1, buffer, bytes)
                end
            end
        end
    catch ex
        # ---------------------------------------------------------------------------------
        # We had an error nuke the file.
        if isfile(toFile)
            rm(toFile)
        end

        # ---------------------------------------------------------------------------------
        # SystemError means we had an file error.
        if isa(ex, SystemError)
            throw(FileError(toFile))
        end

        # ---------------------------------------------------------------------------------
        # Unknown error, rethrow it.
        rethrow(ex)
    end

    # -------------------------------------------------------------------------------------
    # Return the DataFile object.
    return bytes2hex(digest!(sha1))
end

# =========================================================================================
"""
    download_json(
        url::AbstractString,
    )::String

Download the the URL and parse the response as JSON.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | url  |         | The URL to download.

__Exceptions:__

| Name         | Reason
| :----------- | :-----
| NetworkError | There was an issue downloading the JSON object.
"""
function download_json(
            url::AbstractString
        )::Union{AbstractDict, AbstractArray}
    local response = HTTP.request("GET",  url)

    if response.status != 200
        @warn "Failed to download $url, HTTP error: $(response.status)"
        throw(NetworkError(url))
    end

    local raw = String(response.body)
    local json

    try
        json = JSON.parse(raw)
    catch ex
        if isa(ex, ErrorException)
            @warn "Unexpected response from the server: $raw"
            throw(NetworkError(url))
        end
        rethrow(ex)
    end

    return json
end
