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
    pix_write_pdf_i(
        pix::Pix,
        ppi::Integer,
        title::AbstractString
    )::Tuple{Ptr{UInt8}, Csize_t}

Write an image to memory in the PDF image format. If there is an error `(C_NULL, 0)` is returned.

__Parameters:__

| T | Name     | Default  | Description
|:--| :------- | :------- | :----------
| R | pix      |          | The image to write to memory.
| R | ppi      |          | The resolution of the image to use in pixels per inch.
| R | title    |          | The title to use in the PDF.

__Restrictions:__

  * `ppi` - Must be greater than 0.
  * `title` - An empty string will result in no title being used in the PDF.

__Details:__

**This method is meant for internal use only.**  It returns the memory pointer and number of bytes
allocated by the Leptonica library to write out the image.  The caller is responsible for freeing
this memory with a call to `lept_free()`.
"""
function pix_write_pdf_i(
            pix::Pix,
            ppi::Integer,
            title::AbstractString
        )::Tuple{Ptr{UInt8}, Csize_t}
    local temp = Ref(Ptr{UInt8}(C_NULL))
    local size = Ref(Csize_t(0))

    if is_valid(pix) == false
        @error "Pix has been freed."
        return (C_NULL, 0)
    end

    if ppi <= 0
        @error "PPI needs to be greater than 0."
        return (C_NULL, 0)
    end

    local retval = ccall(
        (:pixWriteMemPdf, LEPTONICA),
        Cint,
        (Ptr{Ptr{UInt8}}, Ptr{Csize_t}, Ptr{Cvoid}, Cint, Cstring),
        temp,
        size,
        pix,
        ppi,
        isempty(title) ? C_NULL : title
    )

    if retval == 1
        return (C_NULL, 0)
    end

    return (temp[], size[])
end

# =================================================================================================
"""
    pix_write_pdf(
        filename::AbstractString,
        pix::Pix;
        ppi::Integer = Int32(300),
        title::AbstractString = ""
    )::Bool

Write an image to a file as a PDF.  If there is an error `false` is returned.

__Parameters:__

| T | Name     | Default      | Description
|:--| :------- | :----------- | :----------
| R | filename |              | The name of the file to write to.
| R | pix      |              | The image to write to the file.
| O | ppi      | `Int32(300)` | The resolution of the image to use in pixels per inch.
| O | title    |              | The title to use in the PDF.

__Restrictions:__

  * `ppi` - Must be greater than 0.
  * `title` - An empty string will result in no title being used in the PDF.

__Details:__

If the file exists it will be overwritten.  By default no title is added.
"""
function pix_write_pdf(
            filename::AbstractString,
            pix::Pix;
            ppi::Integer          = Int32(300),
            title::AbstractString = ""
        )::Bool
    local result = false
    local file = nothing
    local data, size = pix_write_pdf_i(pix, ppi, title)

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
    pix_write_pdf(
        stream::IO,
        pix::Pix;
        ppi::Integer = Int32(300),
        title::AbstractString = ""
    )::Bool

Write an image to an IO stream as a PDF.  If there is an error `false` is returned.

__Parameters:__

| T | Name   | Default      | Description
|:--| :----- | :----------- | :----------
| R | stream |              | The stream to write the PDF to.
| R | pix    |              | The image to write to the PDF.
| O | ppi    | `Int32(300)` | The resolution of the image to use in pixels per inch.
| O | title  |              | The title to use in the PDF.

__Restrictions:__

  * `ppi` - Must be greater than 0.
  * `title` - An empty string will result in no title being used in the PDF.

__Details:__

If the file exists it will be overwritten.  By default no title is added.
"""
function pix_write_pdf(
            stream::IO,
            pix::Pix;
            ppi::Integer          = Int32(300),
            title::AbstractString = ""
        )::Bool
    local result = false
    local data, size = pix_write_pdf_i(pix, ppi, title)

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
    pix_write_pdf(
        pix::Pix;
        ppi::Integer = Int32(300),
        title::AbstractString = ""
    )::Union{Vector{UInt8}, Nothing}

Write an image to a byte array as a PDF.  If there is an error `nothing` is returned.

__Parameters:__

| T | Name  | Default      | Description
|:--| :---- | :----------- | :----------
| R | pix   |              | The image to write to the PDF.
| O | ppi   | `Int32(300)` | The resolution of the image to use in pixels per inch.
| O | title |              | The title to use in the PDF.

__Restrictions:__

  * `ppi` - Must be greater than 0.
  * `title` - An empty string will result in no title being used in the PDF.

__Details:__

By default no title is added.
"""
function pix_write_pdf(
            pix::Pix;
            ppi::Integer          = Int32(300),
            title::AbstractString = ""
        )::Union{Vector{UInt8}, Nothing}
    local output     = nothing
    local data, size = pix_write_pdf_i(pix, ppi, title)

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
