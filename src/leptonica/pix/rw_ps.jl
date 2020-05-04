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
    pix_write_ps_i(
        pix::Pix,
        box::Union{PixBox, Nothing},
        ppi::Integer,
        scale::AbstractFloat
    )::Tuple{Ptr{UInt8}, Csize_t}

Write an image to memory as a PostScript file. If there is an error `(C_NULL, 0)` is returned.

__Parameters:__

| T | Name     | Default  | Description
|:--| :------- | :------- | :----------
| R | pix      |          | The image to write to memory.
| R | box      |          | Optional location to have the image appear on the page.
| R | ppi      |          | The resolution to use for the image.
| R | scale    |          | Scale the image on the page.

__Restrictions:__

  * `ppi` - Must be greater than 0.
  * `scale` - Must be greater than or equal to `0.0`.

__Details:__

**This method is meant for internal use only.**  It returns the memory pointer and number of bytes
allocated by the Leptonica library to write out the image.  The caller is responsible for freeing
this memory with a call to `lept_free()`.

If you don't want the image scaled set the `scale` to `1.0`.  If you want to position the image on
the page you can use a `box` however set `w` and `h` to `0`, then the image will be positioned
where you want it and not scaled.

If you want the image to be a specific size set the scale to `0.0` and use a box setting `w` and
`h` to the width and height you want in thousandth of an inch.  So a width of `5000` and a height of
`2000` will give you an image that is 5 inches across and 2 inches high.

If you want the image scaled set the `scale` to the factor you desire.  Value of `0.5` will cause
the image to be halfed, while a value of `2.0` will double the size of the image.  If you want to
also position the image on the page use a `box` but set the `w` and `h` values to `0`.
"""
function pix_write_ps_i(
            pix::Pix,
            box::Union{PixBox, Nothing},
            ppi::Integer,
            scale::AbstractFloat
        )::Tuple{Ptr{UInt8}, Csize_t}
    local temp   = Ref(Ptr{UInt8}(C_NULL))
    local size   = Ref(Csize_t(0))
    local boxPtr = C_NULL

    # ---------------------------------------------------------------------------------------------
    # Verify the parameters.
    if is_valid(pix) == false
        @error "Pix has been freed."
        return (C_NULL, 0)
    end

    if ppi <= 0
        @error "PPI must be positive."
        return (C_NULL, 0)
    end

    if scale <= Float32(0.0)
        @error "Scale must be positive."
        return (C_NULL, 0)
    end

    # ---------------------------------------------------------------------------------------------
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
        return (C_NULL, 0)
    end

    # ---------------------------------------------------------------------------------------------
    # Call the write function.
    local strPtr = ccall(
        (:pixWriteStringPS, LEPTONICA),
        Ptr{UInt8},
        (Ptr{Cvoid}, Ptr{Cvoid}, Cint, Cfloat),
        pix,
        boxPtr,
        ppi,
        scale
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

    if strPtr == C_NULL
        return (C_NULL, 0)
    end

    # ---------------------------------------------------------------------------------------------
    # Figure out how long the string is.
    local size = 0
    while unsafe_load(strPtr, size+1) != 0x00
        size += 1
    end

    return (strPtr, size)
end

# =================================================================================================
"""
    pix_write_ps(
        filename::AbstractString,
        pix::Pix;
        box::Union{PixBox, Nothing} = nothing,
        ppi::Integer = Int32(300),
        scale::AbstractFloat = Float32(1.0)
    )::Bool

Write an image to a PostScript file.  If there is an error `false` is returned.

__Parameters:__

| T | Name     | Default        | Description
|:--| :------- | :------------- | :----------
| R | filename |                | The name of the file to write to.
| R | pix      |                | The image to write to the file.
| O | box      | `nothing`      | Location to have the image appear on the page.
| O | ppi      | `Int32(300)`   | The resolution to use for the image.
| O | scale    | `Float32(1.0)` | Scale the image on the page.

__Restrictions:__

  * `ppi` - Must be greater than 0.
  * `scale` - Must be greater than or equal to `0.0`.

__Details:__

If the file exists it will be overwritten.

If you don't want the image scaled set the `scale` to `1.0`.  If you want to position the image on
the page you can use a `box` however set `w` and `h` to `0`, then the image will be positioned
where you want it and not scaled.

If you want the image to be a specific size set the scale to `0.0` and use a box setting `w` and
`h` to the width and height you want in thousandth of an inch.  So a width of `5000` and a height of
`2000` will give you an image that is 5 inches across and 2 inches high.

If you want the image scaled set the `scale` to the factor you desire.  Value of `0.5` will cause
the image to be halfed, while a value of `2.0` will double the size of the image.  If you want to
also position the image on the page use a `box` but set the `w` and `h` values to `0`.
"""
function pix_write_ps(
            filename,
            pix::Pix;
            box::Union{PixBox, Nothing} = nothing,
            ppi::Integer                = Int32(300),
            scale::AbstractFloat        = Float32(1.0)
        )::Bool
    local file   = nothing
    local result = false
    local data, size = pix_write_ps_i(pix, box, ppi, scale)

    if data != C_NULL
        try
            if size > 0
                file = open(filename; write=true, create=true)
                unsafe_write(file, data, size)
                result = true
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
    pix_write_ps(
        stream::IO,
        pix::Pix;
        box::Union{PixBox, Nothing} = nothing,
        ppi::Integer = Int32(300),
        scale::AbstractFloat = Float32(1.0)
    )::Bool

Write an image to a PostScript file.  Returns 'false' if there was an error.

__Parameters:__

| T | Name     | Default        | Description
|:--| :------- | :------------- | :----------
| R | stream   |                | The stream to write the image to.
| R | pix      |                | The image to write to the stream.
| O | box      | `nothing`      | Location to have the image appear on the page.
| O | ppi      | `Int32(300)`   | The resolution to use for the image.
| O | scale    | `Float32(1.0)` | Scale the image on the page.

__Restrictions:__

  * `ppi` - Must be greater than 0.
  * `scale` - Must be greater than or equal to `0.0`.

__Details:__

If you don't want the image scaled set the `scale` to `1.0`.  If you want to position the image on
the page you can use a `box` however set `w` and `h` to `0`, then the image will be positioned
where you want it and not scaled.

If you want the image to be a specific size set the scale to `0.0` and use a box setting `w` and
`h` to the width and height you want in thousandth of an inch.  So a width of `5000` and a height of
`2000` will give you an image that is 5 inches across and 2 inches high.

If you want the image scaled set the `scale` to the factor you desire.  Value of `0.5` will cause
the image to be halfed, while a value of `2.0` will double the size of the image.  If you want to
also position the image on the page use a `box` but set the `w` and `h` values to `0`.
"""
function pix_write_ps(
            stream::IO,
            pix::Pix;
            box::Union{PixBox, Nothing} = nothing,
            ppi::Integer                = Int32(300),
            scale::AbstractFloat        = Float32(1.0)
        )::Bool
    local result = false
    local data, size = pix_write_ps_i(pix, box, ppi, scale)

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
    pix_write_ps(
        pix::Pix;
        box::Union{PixBox, Nothing} = nothing,
        ppi::Integer = Int32(300),
        scale::AbstractFloat = Float32(1.0)
    )::Union{Vector{UInt8}, Nothing}

Write an image to a byte array.  Returns 'nothing' if there was an error.

__Parameters:__

| T | Name     | Default        | Description
|:--| :------- | :------------- | :----------
| R | pix      |                | The image to write to a byte array.
| O | box      | `nothing`      | Location to have the image appear on the page.
| O | ppi      | `Int32(300)`   | The resolution to use for the image.
| O | scale    | `Float32(1.0)` | Scale the image on the page.

__Restrictions:__

  * `ppi` - Must be greater than 0.
  * `scale` - Must be greater than or equal to `0.0`.

__Details:__

If you don't want the image scaled set the `scale` to `1.0`.  If you want to position the image on
the page you can use a `box` however set `w` and `h` to `0`, then the image will be positioned
where you want it and not scaled.

If you want the image to be a specific size set the scale to `0.0` and use a box setting `w` and
`h` to the width and height you want in thousandth of an inch.  So a width of `5000` and a height of
`2000` will give you an image that is 5 inches across and 2 inches high.

If you want the image scaled set the `scale` to the factor you desire.  Value of `0.5` will cause
the image to be halfed, while a value of `2.0` will double the size of the image.  If you want to
also position the image on the page use a `box` but set the `w` and `h` values to `0`.
"""
function pix_write_ps(
            pix::Pix;
            box::Union{PixBox, Nothing} = nothing,
            ppi::Integer                = Int32(300),
            scale::AbstractFloat        = Float32(1.0)
        )::Union{Vector{UInt8}, Nothing}
    local result = nothing
    local data, size = pix_write_ps_i(pix, box, ppi, scale)

    if data != C_NULL
        try
            if size > 0
                result = Vector{UInt8}(undef, size)
                unsafe_copyto!(pointer(result), data, size)
            end
        finally
            lept_free(data)
        end
    end

    return result
end
