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
    pix_read_jp2k(
        filename::AbstractString;
        reduction::Integer = Int32(1),
        box::Union{PixBox, Nothing} = nothing
    )::Union{Pix, Nothing}

Read a JP2K image from the specified file.  Returns `nothing` on error.

__Arguments:__

| T | Name      | Default    | Description
|---| :-------- | :--------- | :----------
| R | filename  |            | The name of the JP2K file to load.
| O | reduction | `Int32(1)` | Load a reduced version of the image from the file.
| O | box       | `nothing`  | Specifies a region to extract from the image.

__Restrictions:__

  * `reduction` - Must be a factor of 2.
"""
function pix_read_jp2k(
            filename::AbstractString;
            reduction::Integer          = Int32(1),
            box::Union{PixBox, Nothing} = nothing
        )::Union{Pix, Nothing}
    local retval = nothing
    local boxPtr = C_NULL

    # ---------------------------------------------------------------------------------------------
    # Make sure reduction is valid.
    if reduction < 1 || count_ones(reduction) != 1
        @error "Reduction must be a factor of 2."
        return nothing
    end

    # If a box was provided allocate a box.
    if box != nothing
        boxPtr = ccall(
            (:boxCreate, LEPTONICA),
            Ptr{Cvoid},
            (Cint, Cint, Cint, Cint),
            box.x, box.y, box.w, box.h
        )
    end

    if box != nothing && boxPtr == C_NULL
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Call the library.
    local result = @threadcall(
        (:pixReadJp2k, LEPTONICA),
        Ptr{Cvoid},
        (Cstring, Cint, Ptr{Cvoid}, Cint, Cint),
        filename,
        reduction,
        boxPtr,
        0,
        0
    )

    # ---------------------------------------------------------------------------------------------
    # Release the box if used.
    if boxPtr != C_NULL
        ccall(
            (:boxDestroy, LEPTONICA),
            Cvoid,
            (Ptr{Cvoid},),
            Ref(boxPtr)
        )
    end

    if result != C_NULL
        retval = Pix(result)
    end

    return retval
end

# =================================================================================================
"""
    pix_read_jp2k(
        stream::IO;
        reduction::Integer = Int32(1),
        box::Union{PixBox, Nothing} = nothing
    )::Union{Pix, Nothing}

Read a JP2K image from the specified stream.  Returns `nothing` on error.

__Arguments:__

| T | Name      | Default    | Description
|:--| :-------- | :--------- | :----------
| R | stream    |            | The IO stream to read the JP2K file from.
| O | reduction | `Int32(1)` | Load a reduced version of the image from the file.
| O | box       | `nothing`  | Specifies a region to extract from the image.

__Restrictions:__

  * `reduction` - Must be a factor of 2.

__Details:__

This implementation mirrors the API provided by Leptonica when you pass in a FILE pointer. This
assumes that the remainder of the stream contains a JP2K image.
"""
function pix_read_jp2k(
            stream::IO;
            reduction::Integer          = Int32(1),
            box::Union{PixBox, Nothing} = nothing
        )::Union{Pix, Nothing}
    local data = read(stream)
    return pix_read_jp2k(data; reduction = reduction, box = box)
end

# =================================================================================================
"""
    pix_read_jp2k(
        data::AbstractArray{UInt8};
        reduction::Integer = Int32(1),
        box::Union{PixBox, Nothing} = nothing
    )::Union{Pix, Nothing}

Read a JP2K image from the byte array.  Returns `nothing` on error.

__Arguments:__

| T | Name       | Default   | Description
|:--| :-------- | :--------- | :----------
| R | data      |            | The byte array to read the JP2K image from.
| O | reduction | `Int32(1)` | Load a reduced version of the image from the file.
| O | box       | `nothing`  | Specifies a region to extract from the image.

__Restrictions:__

  * `reduction` - Must be a factor of 2.
"""
function pix_read_jp2k(
            data::AbstractArray{UInt8};
            reduction::Integer          = Int32(1),
            box::Union{PixBox, Nothing} = nothing
        )::Union{Pix, Nothing}
    local retval = nothing
    local hint   = 0
    local boxPtr = C_NULL

    # ---------------------------------------------------------------------------------------------
    # Make sure reduction is valid.
    if reduction < 1 || count_ones(reduction) != 1
        @error "Reduction must be a factor of 2."
        return nothing
    end

    # If a box was provided allocate a box.
    if box != nothing
        boxPtr = ccall(
            (:boxCreate, LEPTONICA),
            Ptr{Cvoid},
            (Cint, Cint, Cint, Cint),
            box.x, box.y, box.w, box.h
        )
    end

    if box != nothing && boxPtr == C_NULL
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Call the library.
    local result = ccall(
        (:pixReadMemJp2k, LEPTONICA),
        Ptr{Cvoid},
        (Ptr{UInt8}, Csize_t, Cint, Ptr{Cint}, Cint, Cint),
        data,
        length(data),
        reduction,
        boxPtr,
        0,
        0
    )

    # ---------------------------------------------------------------------------------------------
    # Release the box if used.
    if boxPtr != C_NULL
        ccall(
            (:boxDestroy, LEPTONICA),
            Cvoid,
            (Ptr{Cvoid},),
            Ref(boxPtr)
        )
    end

    if result != C_NULL
        retval = Pix(result)
    end

    return retval
end

# =================================================================================================
"""
    pix_write_jp2k_i(
        pix::Pix,
        quality::Integer,
        levels::Integer
    )::Tuple{Ptr{UInt8}, Csize_t}

Write an image to memory in the JP2K image format.  If there is an error `(C_NULL, 0)` is returned.

__Arguments:__

| T | Name     | Default  | Description
|:--| :------- | :------- | :----------
| R | pix      |          | The image to write to memory.
| R | quality  |          | The quality to encode the image at.
| R | levels   |          | The number of reduced resolution images to encode in the file.

__Restriction:__

  * `quality` - Must be in the range `1` to `100`.
  * `levels` - Can be a value from `1` to `10`.

__Details:__

**This method is meant for internal use only.**  It returns the memory pointer and number of bytes
allocated by the Leptonica library to write out the image.  The caller is responsible for freeing
this memory with a call to `lept_free()`.

For the `quality` parameter, `34` is usually considered a good default value.  A setting of `100`
would generate a lossless image.

If levels is `1` then only a full resolution image is encoded in the file.  A value of `2` would
cause a full resolution image and half resolution image to be encoded.  Often this value is set to
`5` so that images with a reduction factor of 1, 2, 4, 8, and 16 are encoded in the file.

Leptonica restricts he number of levels to less than or equal to 10.  However imperical tests show
that any value over 8 fails in the OpenJpeg library.
"""
function pix_write_jp2k_i(
            pix::Pix,
            quality::Integer,
            levels::Integer
        )::Tuple{Ptr{UInt8}, Csize_t}
    local temp = Ref(Ptr{UInt8}(C_NULL))
    local size = Ref(Csize_t(0))

    if is_valid(pix) == false
        @error "Pix has been freed."
        return (C_NULL, 0)
    end

    if quality < 1 || quality > 100
        @error "Quality must be between 1 and 100 inclusive."
        return (C_NULL, 0)
    end

    if levels < 1 || levels > 10
        @error "Levels must be between 1 and 10 inclusive."
        return (C_NULL, 0)
    end

    local retval = ccall(
        (:pixWriteMemJp2k, LEPTONICA),
        Cint,
        (Ptr{Ptr{UInt8}}, Ptr{Csize_t}, Ptr{Cvoid}, Cint, Cint, Cint, Cint),
        temp,
        size,
        pix,
        quality,
        levels,
        0,
        0
    )

    if retval == 1
        return (C_NULL, 0)
    end

    return (temp[], size[])
end

# =================================================================================================
"""
    pix_write_jp2k(
        filename::AbstractString,
        pix::Pix;
        quality::Integer = Int32(34),
        levels::Integer= Int32(5)
    )::Bool

Write an image to a file in the JP2K image format.  If there is an error `false` is returned.

__Arguments:__

| T | Name     | Default     | Description
|:--| :------- | :---------- | :----------
| R | filename |             | The name of the file to write to.
| R | pix      |             | The image to write to the file.
| O | quality  | `Int32(34)` | The quality to encode the image at.
| O | levels   | `Int32(5)`  | The number of reduced resolution images to encode in the file.

__Restriction:__

  * `quality` - Must be in the range `1` to `100`.
  * `levels` - Can be a value from `1` to `10`.

__Details:__

If the file exists it will be overwritten.

Setting `quality` to `100` would generate a lossless image.

If levels is `1` then only a full resolution image is encoded in the file.  A value of `2` would
cause a full resolution image and half resolution image to be encoded.  The default value of `5`
will cause images with a reduction factor of 1, 2, 4, 8, and 16 to be encoded in the file.

Leptonica restricts he number of levels to less than or equal to 10.  However imperical tests show
that any value over 8 fails in the OpenJpeg library.
"""
function pix_write_jp2k(
            filename::AbstractString,
            pix::Pix;
            quality::Integer = Int32(34),
            levels::Integer  = Int32(5)
        )::Bool

    if is_valid(pix) == false
        @error "Pix has been freed."
        return false
    end

    if quality < 1 || quality > 100
        @error "Quality must be between 1 and 100 inclusive."
        return false
    end

    if levels < 1 || levels > 10
        @error "Levels must be between 1 and 10 inclusive."
        return false
    end

    local retval = @threadcall(
        (:pixWriteJp2k, LEPTONICA),
        Cint,
        (Cstring, Ptr{Cvoid}, Cint, Cint, Cint, Cint),
        filename,
        pix,
        quality,
        levels,
        0,
        0
    )

    return retval == 0
end

# =================================================================================================
"""
    pix_write_jp2k(
        stream::IO,
        pix::Pix;
        quality::Integer = Int32(34),
        levels::Integer= Int32(5)
    )::Bool

Write an image to an IO stream in the JP2K image format.  If there is an error `false` is returned.

__Arguments:__

| T | Name    | Default     | Description
|:--| :------ | :---------- | :----------
| R | stream  |             | The stream to write the image to.
| R | pix     |             | The image to write to the stream.
| O | quality | `Int32(34)` | The quality to encode the image at.
| O | levels  | `Int32(5)`  | The number of reduced resolution images to encode in the file.

__Restriction:__

  * `quality` - Must be in the range `1` to `100`.
  * `levels` - Can be a value from `1` to `10`.

__Details:__

Setting `quality` to `100` would generate a lossless image.

If levels is `1` then only a full resolution image is encoded in the file.  A value of `2` would
cause a full resolution image and half resolution image to be encoded.  The default value of `5`
will cause images with a reduction factor of 1, 2, 4, 8, and 16 to be encoded in the file.

Leptonica restricts he number of levels to less than or equal to 10.  However imperical tests show
that any value over 8 fails in the OpenJpeg library.
"""
function pix_write_jp2k(
            stream::IO,
            pix::Pix;
            quality::Integer = Int32(34),
            levels::Integer  = Int32(5)
        )::Bool
    local result = false
    local data, size = pix_write_jp2k_i(pix, quality, levels)

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
    pix_write_jp2k(
        pix::Pix;
        quality::Integer = Int32(34),
        levels::Integer= Int32(5)
    )::Union{Vector{UInt8}, Nothing}

Write an image to a byte array in the JP2K image format.  If there is an error `nothing` is
returned.

__Arguments:__

| T | Name    | Default     | Description
|:--| :------ | :---------- | :----------
| R | pix     |             | The image to write to the byte array.
| O | quality | `Int32(34)` | The quality to encode the image at.
| O | levels  | `Int32(5)`  | The number of reduced resolution images to encode in the file.

__Restriction:__

  * `quality` - Must be in the range `1` to `100`.
  * `levels` - Can be a value from `1` to `10`.

__Details:__

Setting `quality` to `100` would generate a lossless image.

If levels is `1` then only a full resolution image is encoded in the file.  A value of `2` would
cause a full resolution image and half resolution image to be encoded.  The default value of `5`
will cause images with a reduction factor of 1, 2, 4, 8, and 16 to be encoded in the file.

Leptonica restricts he number of levels to less than or equal to 10.  However imperical tests show
that any value over 8 fails in the OpenJpeg library.
"""
function pix_write_jp2k(
            pix::Pix;
            quality::Integer = Int32(34),
            levels::Integer  = Int32(5)
        )::Union{Vector{UInt8}, Nothing}
    local output     = nothing
    local data, size = pix_write_jp2k_i(pix, quality, levels)

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
