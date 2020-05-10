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
    mutable struct Pix
        ptr::Ptr{Cvoid}
    end

A wrapper for the PIX structure in the leptonica library.

__Values:__

| Name | Description
| :--- | :----------
| ptr  | The pointer to the Pix object allocated by the C library.

__Details:__

When the garbage collector collects this object the associated PIX object will be freed in the
library.
"""
mutable struct Pix
    ptr::Ptr{Cvoid}
    function Pix(ptr::Ptr{Cvoid})
        local retval = new(ptr)

        finalizer(retval) do obj
            pix_delete!(obj)
        end

        retval
    end
end

# =================================================================================================
"""
    show(
        io::IO,
        pix::Pix
    )::Nothing

Display summary information about the pix image.

__Arguments:__

| T | Name | Default | Description
|---| :--- | :------ | :----------
| R | io   |         | The stream to write the information to.
| R | pix  |         | The image to display information about.
"""
function Base.show(
            io::IO,
            pix::Pix
        )::Nothing
    if pix.ptr != C_NULL
        local dims = pix_get_dimensions(pix)
        print(io, "Image ($(dims.w), $(dims.h)) at $(dims.d)ppi")
    else
        print(io, "Freed image.")
    end
    nothing
end

# =================================================================================================
"""
    is_valid(
        pix::Pix
    )::Bool

Check if the image has been freed or if it's still valid.

__Arguments:__

| T | Name | Default | Description
|---| :--- | :------ | :----------
| R | pix  |         | The image to check.
"""
function is_valid(
            pix::Pix
        )::Bool
    return pix.ptr != C_NULL
end

# =================================================================================================
"""
    unsafe_convert(
        ::Type{Ptr{Cvoid}},
        pix::Pix
    )::Ptr{Cvoid}

"Convert" the image into a the pointer used by the Leptonica library.

__Arguments:__

| T | Name               | Default | Description
|---| :----------------- | :------ | :----------
| R | ::Type{Ptr{Cvoid}} |         | The type to convert into.
| R | pix                |         | The image to return the Leptonica pointer for.
"""
Base.unsafe_convert(::Type{Ptr{Cvoid}}, pix::Pix) = pix.ptr

# =================================================================================================
"""
    pix_delete!(
        pix::Pix
    )::Nothing

Release the Pix object so it can be freed.

__Arguments:__

| T | Name | Default | Description
|---| :--- | :------ | :----------
| R | pix  |         | The image to release.

__Details:__

This method is called automatically by the garbage collector but can be called manually to release
the object early.  This method can be called multiple times without any negative effects.

Calling this method will free the object unless a reference is held by an external library.  Once
that library releases it's reference the Pix object should be fully freed.  However once
`pix_delete!()` is called on an object passing the object to any other library call will result in
an error.

Note: This method is not thread safe.
"""
function pix_delete!(pix::Pix)::Nothing
    if pix.ptr != C_NULL
        ccall((:pixDestroy, LEPTONICA), Cvoid, (Ptr{Ptr{Cvoid}},), Ref(pix.ptr))
        pix.ptr = C_NULL
    end
    nothing
end
