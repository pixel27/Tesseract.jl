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
    pix_read_tiff(
        filename::AbstractString;
        page::Integer = Int32(1)
    )::Union{Pix, Nothing}

Read a TIFF image from the specified file.  Returns `nothing` on error.

__Parameters:__

| T | Name     | Default    | Description
|:--| :------- | :--------- | :----------
| R | filename |            | The name of the TIFF file to load.
| O | page     | `Int32(1)` | The image to load from the file.

__Restrictions:__

  * `page` - Must be greater than 0.

__Details:__

TIFF files can contain multiple images.  The `page` parameter allows you to specify which image
you want to load.
"""
function pix_read_tiff(
            filename::AbstractString;
            page::Integer = Int32(1)
        )::Union{Pix, Nothing}
    local retval = nothing

    local result = @threadcall(
        (:pixReadTiff, LEPTONICA),
        Ptr{Cvoid},
        (Cstring, Cint),
        filename,
        page - 1
    )

    if result != C_NULL
        retval = Pix(result)
    end

    return retval
end

# =================================================================================================
"""
    pix_read_tiff(
        stream::IO;
        page::Integer = Int32(1)
    )::Union{Pix, Nothing}

Read a TIFF image from the specified stream.  Returns `nothing` on error.

__Parameters:__

| T | Name     | Default    | Description
|:--| :------- | :--------- | :----------
| R | stream   |            | The IO stream to read the TIFF file from.
| O | page     | `Int32(1)` | The image to load from the file.

__Restrictions:__

  * `page` - Must be greater than 0.

__Details:__

This implementation mirrors the API provided by Leptonica when you pass in a FILE pointer. This
assumes that the remainder of the stream contains a TIFF image.

TIFF files can contain multiple images.  The `page` parameter allows you to specify which image
you want to load.
"""
function pix_read_tiff(
            stream::IO;
            page::Integer = Int32(1)
        )::Union{Pix, Nothing}
    local data = read(stream)
    return pix_read_tiff(data; page = page)
end

# =================================================================================================
"""
    pix_read_tiff(
        data::AbstractArray{UInt8};
        page::Integer = Int32(1)
    )::Union{Pix, Nothing}

Read a TIFF image from the byte array.  Returns `nothing` on error.

__Parameters:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | data |            | The byte array to read the TIFF image from.
| O | page | `Int32(1)` | The image to load from the file.

__Restrictions:__

  * `page` - Must be greater than 0.

__Details:__

TIFF files can contain multiple images.  The `page` parameter allows you to specify which image
you want to load.
"""
function pix_read_tiff(
            data::AbstractArray{UInt8};
            page::Integer = Int32(1)
        )::Union{Pix, Nothing}
    local retval = nothing

    local result = ccall(
        (:pixReadMemTiff, LEPTONICA),
        Ptr{Cvoid},
        (Ptr{UInt8}, Csize_t, Cint),
        data,
        length(data),
        page - 1
    )

    if result != C_NULL
        retval = Pix(result)
    end

    return retval
end

# =================================================================================================
"""
    valid_tiff_compression(
        pix::Pix,
        compression::IFF
    )::Bool

Verify that the compression can handle the bit depth of the image.

__Parameters:__

| T | Name        | Default    | Description
|:--| :---------- | :--------- | :----------
| R | pix         |            | The image to check on.
| R | compression |            | The compression being requested by th client.

__Details:__

This method assumes the compression is a valid TIFF compression format.  Some of the TIFF formats
only handle 1bpp images.  If the image is 1bpp then it will return true.  Otherwise it will return
true if the compression supports non 1bpp images.
"""

function valid_tiff_compression(
            pix::Pix,
            compression::IFF
        )::Bool
    if compression == IFF_TIFF
        true
    elseif compression == IFF_TIFF_LZW
        true
    elseif compression == IFF_TIFF_ZIP
        true
    elseif compression == IFF_TIFF_JPEG
        true
    elseif  pix_get_depth(pix) == 1
        true
    else
        false
    end
end

# =================================================================================================
"""
    pix_write_tiff_i(
        pix::Pix,
        compression::IFF
    )::Tuple{Ptr{UInt8}, Csize_t}

Write an image to memory in the PNG image format. If there is an error `(C_NULL, 0)` is returned.

__Parameters:__

| T | Name        | Default  | Description
|:--| :---------- | :------- | :----------
| R | pix         |          | The image to write to memory.
| R | compression |          | The compression to use on the image.

__Restrictions:__

  * `compression` - Must be a one of the following compression formats:

      * `IFF_TIFF` - Supports all images.
      * `IFF_TIFF_RLE` - Requires a b&w 1bpp image.
      * `IFF_TIFF_PACKBITS` - Requires a b&w 1bpp image.
      * `IFF_TIFF_G3` - Requires a b&w 1bpp image.
      * `IFF_TIFF_G4` - Requires a b&w 1bpp image.
      * `IFF_TIFF_LZW` - Supports all images.
      * `IFF_TIFF_ZIP` - Supports all images.
      * `IFF_TIFF_JPEG` - Supports all images.

__Details:__

**This method is meant for internal use only.**  It returns the memory pointer and number of bytes
allocated by the Leptonica library to write out the image.  The caller is responsible for freeing
this memory with a call to `lept_free()`.
"""
function pix_write_tiff_i(
            pix::Pix,
            compression::IFF
        )::Tuple{Ptr{UInt8}, Csize_t}
    local temp = Ref(Ptr{UInt8}(C_NULL))
    local size = Ref(Csize_t(0))

    # ---------------------------------------------------------------------------------------------
    # Verify the input values.
    if is_valid(pix) == false
        @error "Pix has been freed."
        return (C_NULL, 0)
    end

    if compression ∉ TIFF_FORMATS
        @error "Invalid compression format."
        return (C_NULL, 0)
    end

    if valid_tiff_compression(pix, compression) == false
        @error "Invalid compression, bit depth must be 1 for compression $compression."
        return (C_NULL, 0)
    end

    # ---------------------------------------------------------------------------------------------
    # Perform the write.
    local retval = ccall(
        (:pixWriteMemTiff, LEPTONICA),
        Cint,
        (Ptr{Ptr{UInt8}}, Ptr{Csize_t}, Ptr{Cvoid}, Cint),
        temp,
        size,
        pix,
        compression
    )

    if retval == 1
        return (C_NULL, 0)
    end

    return (temp[], size[])
end

# =================================================================================================
"""
    pix_write_tiff(
        filename::AbstractString,
        pix::Pix;
        compression::IFF = IFF_TIFF,
        append::Bool = false
    )::Bool

Write an image to a file in the TIFF image format. Returns `false` if there was an error.

__Parameters:__

| T | Name        | Default    | Description
|:--| :---------- | :--------- | :----------
| R | filename    |            | The name of the file to write to or create.
| R | pix         |            | The image to write to disk.
| O | compression | `IFF_TIFF` | The compression to use on the image.
| O | append      | `false`    | Should we overwrite the image or append it to the file.

__Restrictions:__

  * `compression` - Must be a one of the following compression formats:

      * `IFF_TIFF` - Supports all images.
      * `IFF_TIFF_RLE` - Requires a b&w 1bpp image.
      * `IFF_TIFF_PACKBITS` - Requires a b&w 1bpp image.
      * `IFF_TIFF_G3` - Requires a b&w 1bpp image.
      * `IFF_TIFF_G4` - Requires a b&w 1bpp image.
      * `IFF_TIFF_LZW` - Supports all images.
      * `IFF_TIFF_ZIP` - Supports all images.
      * `IFF_TIFF_JPEG` - Supports all images.

__Details:__

The default compression is no compression.

TIFF files can contain multiple image.  If a file does not exist it will be created.  If the file
exists and append is `false` then the file will be overwritten.  If append is `true` then the image
will be added to the file.
"""
function pix_write_tiff(
            filename::AbstractString,
            pix::Pix;
            compression::IFF = IFF_TIFF,
            append::Bool = false
        )::Bool

    if is_valid(pix) == false
        @error "Pix has been freed."
        return false
    end

    if compression ∉ TIFF_FORMATS
        @error "Invalid compression format."
        return false
    end

    if valid_tiff_compression(pix, compression) == false
        @error "Invalid compression, bit depth must be 1 for compression $compression."
        return false
    end

    local retval = ccall(
        (:pixWriteTiff, LEPTONICA),
        Cint,
        (Cstring, Ptr{Cvoid}, Cint, Cstring),
        filename,
        pix,
        compression,
        append ? "a" : "w"
    )

    return retval == 0
end

# =================================================================================================
"""
    pix_write_tiff(
        stream::IO,
        pix::Pix;
        compression::IFF = IFF_TIFF
    )::Bool

Write an image to an IO stream in the TIFF image format. Returns `false` if there was an error.

__Parameters:__

| T | Name        | Default    | Description
|:--| :---------- | :--------- | :----------
| R | stream      |            | The stream to write the image to.
| R | pix         |            | The image to write to disk.
| O | compression | `IFF_TIFF` | The compression to use on the image.

__Restrictions:__

  * `compression` - Must be a one of the following compression formats:

      * `IFF_TIFF` - Supports all images.
      * `IFF_TIFF_RLE` - Requires a b&w 1bpp image.
      * `IFF_TIFF_PACKBITS` - Requires a b&w 1bpp image.
      * `IFF_TIFF_G3` - Requires a b&w 1bpp image.
      * `IFF_TIFF_G4` - Requires a b&w 1bpp image.
      * `IFF_TIFF_LZW` - Supports all images.
      * `IFF_TIFF_ZIP` - Supports all images.
      * `IFF_TIFF_JPEG` - Supports all images.

__Details:__

The default compression is no compression.
"""
function pix_write_tiff(
            stream::IO,
            pix::Pix;
            compression::IFF = IFF_TIFF
        )::Bool
    local result = false
    local data, size = pix_write_tiff_i(pix, compression)

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
    pix_write_tiff(
        pix::Pix;
        compression::IFF = IFF_TIFF
    )::Union{Vector{UInt8}, Nothing}

Write an image to an byte array in the TIFF image format. Returns `nothing` if there was an error.

__Parameters:__

| T | Name        | Default    | Description
|:--| :---------- | :--------- | :----------
| R | pix         |            | The image to write to a byte array.
| O | compression | `IFF_TIFF` | The compression to use on the image.

__Restrictions:__

  * `compression` - Must be a one of the following compression formats:

      * `IFF_TIFF` - Supports all images.
      * `IFF_TIFF_RLE` - Requires a b&w 1bpp image.
      * `IFF_TIFF_PACKBITS` - Requires a b&w 1bpp image.
      * `IFF_TIFF_G3` - Requires a b&w 1bpp image.
      * `IFF_TIFF_G4` - Requires a b&w 1bpp image.
      * `IFF_TIFF_LZW` - Supports all images.
      * `IFF_TIFF_ZIP` - Supports all images.
      * `IFF_TIFF_JPEG` - Supports all images.

__Details:__

The default compression is no compression.
"""
function pix_write_tiff(
            pix::Pix;
            compression::IFF = IFF_TIFF
        )::Union{Vector{UInt8}, Nothing}
    local output     = nothing
    local data, size = pix_write_tiff_i(pix, compression)

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
