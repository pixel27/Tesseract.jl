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
    pix_read_jpeg(
        filename::AbstractString;
        cmap::Bool = false,
        reduction::Integer = Int32(1),
        luminance::Bool = false,
        ignoreErrors::Bool = false
    )::Union{Pix, Nothing}

Read a JPEG image from the specified file.  Returns `nothing` on error.

__Parameters:__

| T | Name         | Default    | Description
|---| :----------- | :--------- | -----------
| R | filename     |            | The name of the JPEG file to load.
| O | cmap         | `false`    | Load the image as color mapped.
| O | reduction    | `Int32(1)` | Load a reduced resolution image.
| O | luminance    | `false`    | Only load the luminace data from the image.
| O | ignoreErrors | `false`    | Ignore errors in the file.

__Restrictions:__

  * `cmap` - Requires that SPP be 3 or 4 in the image, so not all JPEG images can be loaded as
             color mapped.
  * `reduction` - Must be 1, 2, 4, or 8.

__Details:__

The `reduction` parameter can be used to load the image faster but at a reduced resolution.  The
JPEG specifification allows the reader to recover from bit errors. Setting
`ignoreErrors` to true will allow files with bit errors to be loaded but the image may not be
correct.
"""
function pix_read_jpeg(
            filename::AbstractString;
            cmap::Bool         = false,
            reduction::Integer = Int32(1),
            luminance::Bool    = false,
            ignoreErrors::Bool = false
        )::Union{Pix, Nothing}
    local retval = nothing
    local hint   = Int32(0)

    if reduction ∉ Set([Int32(1), Int32(2), Int32(4), Int32(8)])
        @error "Reduction must be 1, 2, 4, or 8."
        return nothing
    end

    if luminance
        hint |= 0x1
    end
    if ignoreErrors
        hint |= 0x2
    end

    local result = @threadcall(
        (:pixReadJpeg, LEPTONICA),
        Ptr{Cvoid},
        (Cstring, Cint, Cint, Ptr{Cint}, Cint),
        filename,
        cmap ? Int32(1) : Int32(0),
        reduction,
        C_NULL,
        hint
    )

    if result != C_NULL
        retval = Pix(result)
    end

    return retval
end

# =================================================================================================
"""
    pix_read_jpeg(
        stream::IO;
        cmap::Bool = false,
        reduction::Integer = Int32(1),
        luminance::Bool = false,
        ignoreErrors::Bool = false
    )::Union{Pix, Nothing}

Read a JPEG image from the specified stream.  Returns `nothing` on error.

__Parameters:__

| T | Name         | Default    | Description
|:--| :----------- | :--------- | :----------
| R | stream       |            | The IO stream to read the JPEG file from.
| O | cmap         | `false`    | Load the image as color mapped.
| O | reduction    | `Int32(1)` | Load a reduced resolution image.
| O | luminance    | `false`    | Only load the luminace data from the image.
| O | ignoreErrors | `false`    | Ignore errors in the file.

__Restrictions:__

  * `cmap` - Requires that SPP be 3 or 4 in the image, so not all JPEG images can be loaded as
             color mapped.
  * `reduction` - Must be 1, 2, 4, or 8.

__Details:__

This implementation mirrors the API provided by Leptonica when you pass in a FILE pointer. This
assumes that the remainder of the stream contains a JPEG image.

The `reduction` parameter can be used to load the image faster but at a reduced resolution.  The
JPEG specifification allows the reader to recover from bit errors. Setting
`ignoreErrors` to true will allow files with bit errors to be loaded but the image may not be
correct.
"""
function pix_read_jpeg(
            stream::IO;
            cmap::Bool         = false,
            reduction::Integer = Int32(1),
            luminance::Bool    = false,
            ignoreErrors::Bool = false
        )::Union{Pix, Nothing}
    local data = read(stream)
    return pix_read_jpeg(
        data;
        cmap = cmap,
        reduction = reduction,
        luminance = luminance,
        ignoreErrors = ignoreErrors
    )
end

# =================================================================================================
"""
    pix_read_jpeg(
        data::AbstractArray{UInt8};
        cmap::Bool = false,
        reduction::Integer = Int32(1),
        luminance::Bool = false,
        ignoreErrors::Bool = false
    )::Union{Pix, Nothing}

Read a JPEG image from the byte array.  Returns `nothing` on error.

__Parameters:__

| T | Name          | Default   | Description
|:--| :----------- | :--------- | :----------
| R | data         |            | The byte array to read the JPEG image from.
| O | cmap         | `false`    | Load the image as color mapped.
| O | reduction    | `Int32(1)` | Load a reduced resolution image.
| O | luminance    | `false`    | Only load the luminace data from the image.
| O | ignoreErrors | `false`    | Ignore errors in the file.

__Restrictions:__

  * `cmap` - Requires that SPP be 3 or 4 in the image, so not all JPEG images can be loaded as
             color mapped.
  * `reduction` - Must be 1, 2, 4, or 8.

__Details:__

The `reduction` parameter can be used to load the image faster but at a reduced resolution.  The
JPEG specifification allows the reader to recover from bit errors. Setting
`ignoreErrors` to true will allow files with bit errors to be loaded but the image may not be
correct.
"""
function pix_read_jpeg(
            data::AbstractArray{UInt8};
            cmap::Bool         = false,
            reduction::Integer = Int32(1),
            luminance::Bool    = false,
            ignoreErrors::Bool = false
        )::Union{Pix, Nothing}
    local retval = nothing
    local hint   = Int32(0)

    if reduction ∉ Set([Int32(1), Int32(2), Int32(4), Int32(8)])
        @error "Reduction must be 1, 2, 4, or 8."
        return nothing
    end

    if luminance
        hint |= 0x1
    end
    if ignoreErrors
        hint |= 0x2
    end

    local result = ccall(
        (:pixReadMemJpeg, LEPTONICA),
        Ptr{Cvoid},
        (Ptr{UInt8}, Csize_t, Cint, Cint, Ptr{Cint}, Cint),
        data,
        length(data),
        cmap ? Int32(1) : Int32(0),
        reduction,
        C_NULL,
        hint
    )

    if result != C_NULL
        retval = Pix(result)
    end

    return retval
end

# =================================================================================================
"""
    pix_write_jpeg_i(
        pix::Pix,
        quality::Integer,
        progressive::Bool
    )::Tuple{Ptr{UInt8}, Csize_t}

Write an image to memory in the JPEG image format.  If there is an error `(C_NULL, 0)` is returned.

__Parameters:__

| T | Name        | Default  | Description
|:--| :---------- | :------- | :----------
| R | pix         |          | The image to write to memory.
| R | quality     |          | The quality to encode the image at.
| R | progressive |          | Should the progressive encoding algorithm be used?

__Restriction:__

  * `quality` - Must be in the range 1 to 100.

__Details:__

**This method is meant for internal use only.**  It returns the memory pointer and number of bytes
allocated by the Leptonica library to write out the image.  The caller is responsible for freeing
this memory with a call to `lept_free()`.

For the `quality` parameter, `75` is usually considered a good default value.
"""
function pix_write_jpeg_i(
            pix::Pix,
            quality::Integer,
            progressive::Bool
        )::Tuple{Ptr{UInt8}, Csize_t}
    local temp = Ref(Ptr{UInt8}(C_NULL))
    local size = Ref(Csize_t(0))

    if quality < 1 || quality > 100
        @error "Quality must be between 1 and 100 inclusive."
        return (C_NULL, 0)
    end

    if is_valid(pix) == false
        @error "Pix has been freed."
        return (C_NULL, 0)
    end

    local retval = ccall(
        (:pixWriteMemJpeg, LEPTONICA),
        Cint,
        (Ptr{Ptr{UInt8}}, Ptr{Csize_t}, Ptr{Cvoid}, Cint, Cint),
        temp,
        size,
        pix,
        quality,
        progressive ? Int32(1) : Int32(0)
    )

    if retval == 1
        return (C_NULL, 0)
    end

    return (temp[], size[])
end

# =================================================================================================
"""
    pix_write_jpeg(
        filename::AbstractString,
        pix::Pix;
        quality::Integer = Int32(75),
        progressive::Bool = false
    )::Bool

Write an image to a file in the JPEG image format.  If there is an error `false` is returned.

__Parameters:__

| T | Name        | Default     | Description
|:--| :---------- | :---------- | :----------
| R | filename    |             | The name of the file to write to.
| R | pix         |             | The image to write to the file.
| O | quality     | `Int32(75)` | The quality to encode the image at.
| O | progressive | `false`     | Should the progressive encoding algorithm be used?

__Restriction:__

  * `quality` - Must be in the range 1 to 100.

__Details:__

If the file exists it will be overwritten.
"""
function pix_write_jpeg(
            filename::AbstractString,
            pix::Pix;
            quality::Integer  = Int32(75),
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

    local retval = ccall(
        (:pixWriteJpeg, LEPTONICA),
        Cint,
        (Cstring, Ptr{Cvoid}, Cint, Cint),
        filename,
        pix,
        quality,
        progressive ? Int32(1) : Int32(0)
    )

    return retval == 0
end

# =================================================================================================
"""
    pix_write_jpeg(
        stream::IO,
        pix::Pix;
        quality::Integer = Int32(75),
        progressive::Bool = false
    )::Bool

Write an image to an IO stream in the JPEG image format.  If there is an error `false` is returned.

__Parameters:__

| T | Name        | Default     | Description
|:--| :---------- | :---------- | :----------
| R | stream      |             | The stream to write the image to.
| R | pix         |             | The image to write to the stream.
| O | quality     | `Int32(75)` | The quality to encode the image at.
| O | progressive | `false`     | Should the progressive encoding algorithm be used?

__Restriction:__

  * `quality` - Must be in the range 1 to 100.
"""
function pix_write_jpeg(
            stream::IO,
            pix::Pix;
            quality::Integer  = Int32(75),
            progressive::Bool = false
        )::Bool
    local result = false
    local data, size = pix_write_jpeg_i(pix, quality, progressive)

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
    pix_write_jpeg(
        pix::Pix;
        quality::Integer = Int32(75),
        progressive::Bool = false
    )::Bool

Write an image to a byte array in the JPEG image format.  If there is an error `nothing` is
returned.

__Parameters:__

| T | Name        | Default     | Description
|:--| :---------- | :---------- | :----------
| R | pix         |             | The image to write to a byte array.
| O | quality     | `Int32(75)` | The quality to encode the image at.
| O | progressive | `false`     | Should the progressive encoding algorithm be used?

__Restriction:__

  * `quality` - Must be in the range 1 to 100.
"""
function pix_write_jpeg(
            pix::Pix;
            quality::Integer  = Int32(75),
            progressive::Bool = false
        )::Union{Vector{UInt8}, Nothing}
    local output     = nothing
    local data, size = pix_write_jpeg_i(pix, quality, progressive)

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
