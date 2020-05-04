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

# =================================================================================================
"""
    pix_read_webp(
        filename::AbstractString
    )::Union{Pix, Nothing}

Read a WEBP image from the specified file.  Returns `nothing` on error.

__Parameters:__

| T | Name     | Default    | Description
|:--| :------- | :--------- | :----------
| R | filename |            | The name of the WEBP file to load.
"""
function pix_read_webp(
            filename::AbstractString
        )::Union{Pix, Nothing}
    try
        local data = read(filename)
        return pix_read_webp(data)
    catch
        return nothing
    end
end

# =================================================================================================
"""
    pix_read_webp(
        stream::IO
    )::Union{Pix, Nothing}

Read a WEBP image from the specified stream.  Returns `nothing` on error.

__Parameters:__

| T | Name   | Default  | Description
|:--| :----- | :------- | :----------
| R | stream |          | The IO stream to read the WEBP file from.

__Details:__

This implementation mirrors the API provided by Leptonica when you pass in a FILE pointer. This
assumes that the remainder of the stream contains a WEBP image.
"""
function pix_read_webp(
            stream::IO
        )::Union{Pix, Nothing}
    local data = read(stream)
    return pix_read_webp(data)
end

# =================================================================================================
"""
    pix_read_webp(
        data::AbstractArray{UInt8}
    )::Union{Pix, Nothing}

Read a WEBP image from the byte array.  Returns `nothing` on error.

__Parameters:__

| T | Name | Default  | Description
|:--| :--- | :------- | :----------
| R | data |          | The byte array to read the WEBP image from.
"""
function pix_read_webp(
            data::AbstractArray{UInt8}
        )::Union{Pix, Nothing}
    local ptr = ccall(
        (:pixReadMemWebP, LEPTONICA),
        Ptr{Cvoid},
        (Ptr{Cvoid}, Csize_t),
        data,
        length(data)
    )

    if ptr == C_NULL
        return nothing
    end

    return Pix(ptr)
end

# =================================================================================================
"""
    pix_write_webp(
        filename::AbstractString,
        pix::Pix;
        quality::Integer = Int32(80),
        lossless::Bool = true
    )::Bool

Write an image to a file in the WEBP image format.  If there is an error `false` is returned.

__Parameters:__

| T | Name     | Default     | Description
|:--| :------- | :---------- | :----------
| r | filename |             | The name of the file to write to.
| R | pix      |             | The image to write to disk.
| O | quality  | `Int32(80)` | The quality to encode the image at.
| O | lossless | `false`     | Should the lossless algorithm be used?

__Restrictions:__

  * `quality` - Must be in the range `1` to `100`.

__Details:__

If the file exists it will be overwritten.

If lossless is set to true then the quality is ignored.
"""
function pix_write_webp(
            filename::AbstractString,
            pix::Pix;
            quality::Integer = Int32(80),
            lossless::Bool    = true
        )::Bool
    local result = false

    if is_valid(pix) == false
        @error "Pix has been freed."
        return false
    end

    if quality < 1 || quality > 100
        @error "Quality must be in the range of 1 to 100 inclusive."
        return false
    end

    local retval = @threadcall(
        (:pixWriteWebP, LEPTONICA),
        Cint,
        (Cstring, Ptr{Cvoid}, Cint, Cint),
        filename,
        pix,
        quality,
        lossless ? 1 : 0
    )

    return retval == 0
end

# =================================================================================================
"""
    pix_write_webp_i(
        pix::Pix
        quality::Integer,
        lossless::Bool
    )::Tuple{Ptr{UInt8}, Csize_t}

Write an image to memory in the WEBP image format.  If there is an error `(C_NULL, 0)` is returned.

__Parameters:__

| T | Name     | Default  | Description
|:--| :------- | :------- | :----------
| R | pix      |          | The image to write to memory.
| R | quality  |          | The quality to encode the image at.
| R | lossless |          | Should the lossless algorithm be used?

__Restrictions:__

  * `quality` - Must be in the range `1` to `100`.

__Details:__

**This method is meant for internal use only.**  It returns the memory pointer and number of bytes
allocated by the Leptonica library to write out the image.  The caller is responsible for freeing
this memory with a call to `lept_free()`.

For `quality` a value of `80` is considered a default value.  If lossless is set to true then the
quality is ignored.
"""
function pix_write_webp_i(
            pix::Pix,
            quality::Integer,
            lossless::Bool
        )::Tuple{Ptr{UInt8}, Csize_t}
    local temp = Ref(Ptr{UInt8}(C_NULL))
    local size = Ref(Csize_t(0))

    if is_valid(pix) == false
        @error "Pix has been freed."
        return (C_NULL, 0)
    end

    if quality < 1 || quality > 100
        @error "Quality must be in the range of 1 to 100 inclusive."
        return (C_NULL, 0)
    end

    local retval = ccall(
        (:pixWriteMemWebP, LEPTONICA),
        Cint,
        (Ptr{Ptr{UInt8}}, Ptr{Csize_t}, Ptr{Cvoid}, Cint, Cint),
        temp,
        size,
        pix,
        quality,
        lossless ? 1 : 0
    )

    if retval == 1
        return (C_NULL, 0)
    end

    return (temp[], size[])
end

# =================================================================================================
"""
    pix_write_webp(
        stream::IO,
        pix::Pix;
        quality::Integer = Int32(80),
        lossless::Bool = true
    )::Bool

Write an image to a stream in the WEBP image format.  If there is an error `false` is returned.

__Parameters:__

| T | Name     | Default     | Description
|:--| :------- | :---------- | :----------
| R | stream   |             | The IO stream to write to.
| R | pix      |             | The image to write to the stream.
| O | quality  | `Int32(80)` | The quality to encode the image at.
| O | lossless | `false`     | Should the lossless algorithm be used?

__Restrictions:__

  * `quality` - Must be in the range `1` to `100`.

__Details:__

If the file exists it will be overwritten.

If lossless is set to true then the quality is ignored.
"""
function pix_write_webp(
            stream::IO,
            pix::Pix;
            quality::Integer = Int32(80),
            lossless::Bool   = true
        )::Bool
    local result = false
    local data, size = pix_write_webp_i(pix, quality, lossless)

    if data != C_NULL
        try
            if size > 0
                unsafe_write(stream, data, size)
                result = true
            end
        finally
            lept_free(data)
        end
    end
    return result
end

# =================================================================================================
"""
    pix_write_webp(
        pix::Pix;
        quality::Integer = Int32(80),
        lossless::Bool = true
    )::Union{Vector{UInt8}, Nothing}

Write an image to a byte array in the WEBP image format.  If there is an error `nothing` is
returned.

__Parameters:__

| T | Name     | Default     | Description
|:--| :------- | :---------- | :----------
| R | pix      |             | The image to write to the stream.
| O | quality  | `Int32(80)` | The quality to encode the image at.
| O | lossless | `false`     | Should the lossless algorithm be used?

__Restrictions:__

  * `quality` - Must be in the range `1` to `100`.

__Details:__

If the file exists it will be overwritten.

If lossless is set to true then the quality is ignored.
"""
function pix_write_webp(
            pix::Pix;
            quality::Integer = Int32(80),
            lossless::Bool   = true
        )::Union{Vector{UInt8}, Nothing}
    local output     = nothing
    local data, size = pix_write_webp_i(pix, quality, lossless)

    if data != C_NULL
        try
            if size > 0
                output = Vector{UInt8}(undef, size)
                unsafe_copyto!(pointer(output), data, size)
            end
        finally
            lept_free(data)
        end
    end

    return output
end
