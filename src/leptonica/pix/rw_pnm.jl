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
    pix_read_pnm(
        filename::AbstractString
    )::Union{Pix, Nothing}

Read a PNG image from the specified file.  Returns `nothing` on error.

__Arguments:__

| T | Name     | Default  | Description
|:--| :------- | :------- | :----------
| R | filename |          | The name of the PNM file to load.
"""
function pix_read_pnm(
            filename::AbstractString
        )::Union{Pix, Nothing}
    local result = nothing
    local data = read(filename)

    result = pix_read_pnm(data)

    return result
end

# =================================================================================================
"""
    pix_read_pnm(
        stream::IO
    )::Union{Pix, Nothing}

Read a PNM image from the specified stream.  Returns `nothing` on error.

__Arguments:__

| T | Name   | Default  | Description
|:--| :----- | :------- | :----------
| R | stream |          | The IO stream to read the PNM file from.

__Details:__

This implementation mirrors the API provided by Leptonica when you pass in a FILE pointer. This
assumes that the remainder of the stream contains a PNM image.
"""
function pix_read_pnm(
            stream::IO
        )::Union{Pix, Nothing}
    local data = read(stream)
    return pix_read_pnm(data)
end

# =================================================================================================
"""
    pix_read_pnm(
        data::AbstractArray{UInt8}
    )::Union{Pix, Nothing}

Read a PNM image from the byte array.  Returns `nothing` on error.

__Arguments:__

| T | Name | Default  | Description
|:--| :--- | :------- | :----------
| R | data |          | The byte array to read the PNM image from.
"""
function pix_read_pnm(
            data::AbstractArray{UInt8}
        )::Union{Pix, Nothing}
    local ptr = ccall(
        (:pixReadMemPnm, LEPTONICA),
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
    pix_write_pnm_i(
        pix::Pix
    )::Tuple{Ptr{UInt8}, Csize_t}

Write an image to memory in the PNM image format.  If there is an error `(C_NULL, 0)` is returned.

__Arguments:__

| T | Name     | Default  | Description
|:--| :------- | :------- | :----------
| R | pix      |          | The image to write to memory.

__Details:__

**This method is meant for internal use only.**  It returns the memory pointer and number of bytes
allocated by the Leptonica library to write out the image.  The caller is responsible for freeing
this memory with a call to `lept_free()`.
"""
function pix_write_pnm_i(
            pix::Pix
        )::Tuple{Ptr{UInt8}, Csize_t}
    local temp = Ref(Ptr{UInt8}(C_NULL))
    local size = Ref(Csize_t(0))

    if is_valid(pix) == false
        @error "Pix has been freed."
        return (C_NULL, 0)
    end

    local retval = ccall(
        (:pixWriteMemPnm, LEPTONICA),
        Cint,
        (Ptr{Ptr{UInt8}}, Ptr{Csize_t}, Ptr{Cvoid}),
        temp,
        size,
        pix.ptr
    )

    if retval == 1
        return (C_NULL, 0)
    end

    return (temp[], size[])
end

# =================================================================================================
"""
    pix_write_pnm(
        filename::AbstractString,
        pix::Pix
    )::Bool

Write an image to a file in the PNM image format.  If there is an error `false` is returned.

__Arguments:__

| T | Name     | Default  | Description
|:--| :------- | :------- | :----------
| R | filename |          | The name of the file to write to.
| R | pix      |          | The image to write to the file.

__Details:__

If the file exists it will be overwritten.
"""
function pix_write_pnm(
            filename::AbstractString,
            pix::Pix
        )::Bool
    local result = false
    local file = nothing
    local data, size = pix_write_pnm_i(pix)

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
    pix_write_pnm(
        stream::IO,
        pix::Pix
    )::Bool

Write an image to an IO stream in the PNM image format.  If there is an error `false` is returned.

__Arguments:__

| T | Name   | Default  | Description
|:--| :----- | :------- | :----------
| R | stream |          | The IO stream to write the image to.
| R | pix    |          | The image to write to the IO stream.
"""
function pix_write_pnm(
            stream::IO,
            pix::Pix
        )::Bool
    local result = false
    local data, size = pix_write_pnm_i(pix)

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
    pix_write_pnm(
        pix::Pix
    )::Union{Vector{UInt8}, Nothing}

Write an image to a byte array in the PNM image format.  If there is an error `false` is returned.

__Arguments:__

| T | Name | Default  | Description
|:--| :--- | :------- | :----------
| R | pix  |          | The image to write to a byte array.
"""
function pix_write_pnm(
            pix::Pix
        )::Union{Vector{UInt8}, Nothing}
    local output     = nothing
    local data, size = pix_write_pnm_i(pix)

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
