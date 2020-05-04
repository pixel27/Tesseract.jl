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
    pix_read(
        filename::AbstractString;
        jpgLuminance::Bool = false,
        jpgFailOnBadData::Bool = false
    )::Union{Pix, Nothing}

Load an image from from disk of an unspecified type.  Returns `nothing` if the file could not be
loaded.

__Parameters:__

| T | Name             | Default | Description
|:--| :--------------- | :------ | :----------
| R | filename         |         | The filename of the image to load.
| O | jpgLuminance     | `false` | If the image is a JPEG should we only load luminance data?
| O | jpgFailOnBadData | `false` | If the image is a JPEG should we ignore bit errors?

__Details:__

The two optional parameters are obviously ignored if the image is not a JPEG.
"""
function pix_read(
            filename::AbstractString;
            jpgLuminance::Bool = false,
            jpgFailOnBadData::Bool = false
        )::Union{Pix, Nothing}
    local hint = Int32(0)

    if jpgLuminance == true
        hint |= 0x1
    end
    if jpgFailOnBadData == true
        hint |= 0x2
    end

    local ptr = @threadcall(
        (:pixReadWithHint, LEPTONICA),
        Ptr{Cvoid},
        (Cstring, Cint),
        filename,
        hint
    )

    if ptr == C_NULL
        return nothing
    end

    return Pix(ptr)
end

# =================================================================================================
"""
    pix_read(
        stream::IO
    )::Union{Pix, Nothing}

Load an image from from a stream.  Returns `nothing` if the file could not be loaded.

__Parameters:__

| T | Name   | Default | Description
|:--| :----- | :------ | :----------
| R | stream |         | The stream to read the image from.

__Details:__

This implementation mirrors the API provided by Leptonica when you pass in a FILE pointer. This
assumes that the remainder of the stream contains an image, so the remainder of the stream will be
read and decoded as an image.
"""
function pix_read(
            stream::IO
        )::Union{Pix, Nothing}
    local data = read(stream)
    return pix_read(data)
end

# =================================================================================================
"""
    pix_read(
        data::AbstractArray{UInt8}
    )::Union{Pix, Nothing}

Load an image from from a byte array.  Returns `nothing` if the file could not be loaded.

__Parameters:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | data |         | The byte array to read the image from.
"""
function pix_read(
            data::AbstractArray{UInt8}
        )::Union{Pix, Nothing}
    local ptr = ccall(
        (:pixReadMem, LEPTONICA),
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
    pix_write_i(
        pix::Pix,
        format::IFF
    )::Union{Pix, Nothing}

Write an image to memory in the specified format.  If there is an error `(C_NULL, 0)` is returned.

__Parameters:__

| T | Name   | Default  | Description
|:--| :----- | :------- | :----------
| R | pix    |          | The image to write to memory.
| R | format |          | The image format to write the image out as.

__Details:__

**This method is meant for internal use only.**  It returns the memory pointer and number of bytes
allocated by the Leptonica library to write out the image.  The caller is responsible for freeing
this memory with a call to `lept_free()`.
"""
function pix_write_i(
            pix::Pix,
            format::IFF
        )::Tuple{Ptr{UInt8}, Csize_t}
    local temp = Ref(Ptr{UInt8}(C_NULL))
    local size = Ref(Csize_t(0))

    if is_valid(pix) == false
        @error "Pix has been freed."
        return (C_NULL, 0)
    end

    local retval = ccall(
        (:pixWriteMem, LEPTONICA),
        Cint,
        (Ptr{Ptr{UInt8}}, Ptr{Csize_t}, Ptr{Cvoid}, Cint),
        temp,
        size,
        pix,
        format
    )

    if retval == 1
        return (C_NULL, 0)
    end

    return (temp[], size[])
end

# =================================================================================================
"""
    pix_write(
        filename::String,
        pix::Pix,
        format::IFF = IFF_DEFAULT
    )::Bool

Write an image to disk in the specified format.  If there is an error `false` is returned.

__Parameters:__

| T | Name     | Default       | Description
|:--| :------- | :------------ | :----------
| R | filename |               | The filename to write the image to.
| R | pix      |               | The image to write to disk.
| O | format   | `IFF_DEFAULT` | The image format to write the image out as.

__Details:__

If the file exists it will be overwritten.

If format isn't specified Leptonica will choose the correct format to write the image as based on
the input format.
"""
function pix_write(
            filename::String,
            pix::Pix,
            format::IFF = IFF_DEFAULT
        )::Bool

    if is_valid(pix) == false
        @error "Pix has been freed."
        return false
    end

    local retval = @threadcall(
        (:pixWrite, LEPTONICA),
        Cint,
        (Cstring, Ptr{Cvoid}, Cint),
        filename,
        pix,
        format
    )

    return retval == 0
end

# =================================================================================================
"""
    pix_write(
        stream::IO,
        pix::Pix,
        format::IFF = IFF_DEFAULT
    )::Bool

Write an image to the IO stream in the specified format.  If there is an error `false` is returned.

__Parameters:__

| T | Name   | Default       | Description
|:--| :----- | :------------ | :----------
| R | stream |               | The stream to write the image to.
| R | pix    |               | The image to write to the stream.
| O | format | `IFF_DEFAULT` | The image format to write the image out as.

__Details:__

If format isn't specified Leptonica will choose the correct format to write the image as based on
the input format.
"""
function pix_write(
            stream::IO,
            pix::Pix,
            format::IFF = IFF_DEFAULT
        )::Bool
    local result = false
    local data, size = pix_write_i(pix, format)

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
    pix_write(
        pix::Pix,
        format::IFF = IFF_DEFAULT
    ):::Union{Vector{UInt8}, Nothing}

Write an image to a byte array in the specified format.  If there is an error `nothing` is returned.

__Parameters:__

| T | Name   | Default       | Description
|:--| :----- | :------------ | :----------
| R | pix    |               | The image to write to the stream.
| O | format | `IFF_DEFAULT` | The image format to write the image out as.

__Details:__

If format isn't specified Leptonica will choose the correct format to write the image as based on
the input format.
"""
function pix_write(
            pix::Pix,
            format::IFF = IFF_DEFAULT
        )::Union{Vector{UInt8}, Nothing}
    local output     = nothing
    local data, size = pix_write_i(pix, format)

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

# =================================================================================================
"""
    pix_write_implied_format(
        filename::AbstractString,     # The name of the file to write to.
        pix::Pix;                     # The image to write.
        quality::Integer  = Int32(75), # If the image is JPEG the quality to encode as.
        progressive::Bool = false     # If the image is JEPG use progressive encoding?
    )::Bool

Write the image to a file based on the file extension.  The quality and progressive parameters are
only used if the image type is JPEG.  Returns true on success or false on failure.
"""
function pix_write_implied_format(
            filename::AbstractString,
            pix::Pix;
            quality::Integer = Int32(75),
            progressive::Bool = false
        )::Bool
    if is_valid(pix) == false
        @error "Pix has been freed."
        return false
    end
    if quality < 1 || quality > 100
        @error "Quality must be between 1 and 100 inclusive."
        return false
    end

    local retval = @threadcall(
        (:pixWriteImpliedFormat, LEPTONICA),
        Cint,
        (Cstring, Ptr{Cvoid}, Cint, Cint),
        filename,
        pix,
        quality,
        progressive ? 1 : 0
    )

    return retval == 0
end
