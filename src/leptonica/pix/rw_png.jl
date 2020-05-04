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
    pix_read_png(
        filename::AbstractString
    )::Union{Pix, Nothing}

Read a PNG image from the specified file.  Returns `nothing` on error.

__Parameters:__

| T | Name     | Default  | Description
|:--| :------- | :------- | :----------
| R | filename |          | The name of the PNG file to load.
"""
function pix_read_png(
            filename::AbstractString
        )::Union{Pix, Nothing}
    try
        local data = read(filename)
        return pix_read_png(data)
    catch
        return nothing
    end
end

# =================================================================================================
"""
    pix_read_png(
        stream::IO
    )::Union{Pix, Nothing}

Read a PNG image from the specified stream.  Returns `nothing` on error.

__Parameters:__

| T | Name   | Default  | Description
|:--| :----- | :------- | :----------
| R | stream |          | The IO stream to read the PNG file from.

__Details:__

This implementation mirrors the API provided by Leptonica when you pass in a FILE pointer. This
assumes that the remainder of the stream contains a PNG image.
"""
function pix_read_png(
            stream::IO
        )::Union{Pix, Nothing}
    local data = read(stream)
    return pix_read_png(data)
end

# =================================================================================================
"""
    pix_read_png(
        data::AbstractArray{UInt8}
    )::Union{Pix, Nothing}

Read a PNG image from the byte array.  Returns `nothing` on error.

__Parameters:__

| T | Name | Default  | Description
|:--| :--- | :------- | :----------
| R | data |          | The byte array to read the PNG image from.
"""
function pix_read_png(
            data::AbstractArray{UInt8}
        )::Union{Pix, Nothing}
    local ptr = ccall(
        (:pixReadMemPng, LEPTONICA),
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
    pix_write_png_i(
        pix::Pix,
        gamma::AbstractFloat
    )::Tuple{Ptr{UInt8}, Csize_t}

Write an image to memory in the PNG image format. If there is an error `(C_NULL, 0)` is returned.

__Parameters:__

| T | Name     | Default  | Description
|:--| :------- | :------- | :----------
| R | pix      |          | The image to write to memory.
| R | gamma    |          | The gamma value to write to the header.

__Restrictions:__

  * `gamma` - Must be in the range 0.0 to 1.0 inclusively.

__Details:__

**This method is meant for internal use only.**  It returns the memory pointer and number of bytes
allocated by the Leptonica library to write out the image.  The caller is responsible for freeing
this memory with a call to `lept_free()`.

If gamma is 0 then no gamma is used.
"""
function pix_write_png_i(
            pix::Pix,
            gamma::AbstractFloat
        )::Tuple{Ptr{UInt8}, Csize_t}
    local temp = Ref(Ptr{UInt8}(C_NULL))
    local size = Ref(Csize_t(0))

    if is_valid(pix) == false
        @error "Pix has been freed."
        return (C_NULL, 0)
    end

    if (gamma < Float32(0.0) || gamma > Float32(1.0))
        @error "Gamma must be in the range of 0.0 to 1.0 inclusive."
        return (C_NULL, 0)
    end

    local retval = ccall(
        (:pixWriteMemPng, LEPTONICA),
        Cint,
        (Ptr{Ptr{UInt8}}, Ptr{Csize_t}, Ptr{Cvoid}, Cfloat),
        temp,
        size,
        pix,
        gamma
    )

    if retval == 1
        return (C_NULL, 0)
    end

    return (temp[], size[])
end

# =================================================================================================
"""
    pix_write_png(
        filename::AbstractString,
        pix::Pix
        gamma::AbstractFloat = Float32(0.0)
    )::Bool

Write an image to a file in the PNG image format.  If there is an error `false` is returned.

__Parameters:__

| T | Name     | Default        | Description
|:--| :------- | :------------- | :----------
| R | filename |                | The name of the file to write to.
| R | pix      |                | The image to write to the file.
| O | gamma    | `Float32(0.0)` | The gamma value to write to the header.

__Restrictions:__

  * `gamma` - Must be in the range 0.0 to 1.0 inclusively.

__Details:__

If the file exists it will be overwritten.  If gamma is set to `0.0` then no gamma value will be
written to the file.
"""
function pix_write_png(
            filename,
            pix::Pix;
            gamma::AbstractFloat = Float32(0.0)
        )::Bool
    local result = false
    local file = nothing
    local data, size = pix_write_png_i(pix, gamma)

    if data != C_NULL
        try
            if size > 0
                file = open(filename, create=true, write=true)
                unsafe_write(file, data, size)
                result = true
            end
        catch ex
            if isa(ex, SystemError) == false
                rethrow(ex)
            end
        finally
            lept_free(data)

            if file != nothing
                close(file)
            end
        end
    end

    return result
end

# =================================================================================================
"""
    pix_write_png(
        stream::IO,
        pix::Pix
        gamma::AbstractFloat = Float32(0.0)
    )::Bool

Write an image to a stream in the PNG image format.  If there is an error `false` is returned.

__Parameters:__

| T | Name   | Default        | Description
|:--| :----- | :------------- | :----------
| R | stream |                | The stream to write the data to.
| R | pix    |                | The image to write to the stream.
| O | gamma  | `Float32(0.0)` | The gamma value to write to the header.

__Restrictions:__

  * `gamma` - Must be in the range 0.0 to 1.0 inclusively.

__Details:__

If gamma is set to `0.0` then no gamma value will be written in the image header.
"""
function pix_write_png(
            stream::IO,
            pix::Pix;
            gamma::AbstractFloat = Float32(0.0)
        )::Bool
    local result = false
    local data, size = pix_write_png_i(pix, gamma)

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
    pix_write_png(
        pix::Pix
        gamma::AbstractFloat = Float32(0.0)
    )::Union{Vector{UInt8}, Nothing}

Write an image to a byte array in the PNG image format.  If there is an error `false` is returned.

__Parameters:__

| T | Name  | Default        | Description
|:--| :---- | :------------- | :----------
| R | pix   |                | The image to write to a byte array.
| O | gamma | `Float32(0.0)` | The gamma value to write to the header.

__Restrictions:__

  * `gamma` - Must be in the range 0.0 to 1.0 inclusively.

__Details:__

If gamma is set to `0.0` then no gamma value will be written in the image header.
"""
function pix_write_png(
            pix::Pix;
            gamma::AbstractFloat = Float32(0.0)
        )::Union{Vector{UInt8}, Nothing}
    local output     = nothing
    local data, size = pix_write_png_i(pix, gamma)

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
