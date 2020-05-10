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
    pix_get_depth(
        pix::Pix
    )::Int32

Retrieves the color bit depth of the image.

__Arguments:__

| T | Name | Default  | Description
|---| :--- | :------- | :----------
| R | pix  |          | The image to get the bit depth from.

See also: [`pix_get_dimensions`](@ref)
"""
function pix_get_depth(
            pix::Pix
        )::Int32
    if is_valid(pix) == false
        @error "Pix has been freed."
        return 0
    end

    local result = ccall(
        (:pixGetDepth, LEPTONICA),
        Cint,
        (Ptr{Cvoid},),
        pix
    )

    return result
end

# =================================================================================================
"""
    pix_get_dimensions(
        pix::Pix
    )::Union{NamedTuple{(:w, :h, :d), Tuple{Int32, Int32, Int32}}, Nothing}

Retrieve the dimensions of the image.

__Arguments:__

| T | Name | Default  | Description
|---| :--- | :------- | :----------
| R | pix  |          | The image to get the dimensions of.

__Details:__

This method returns a named tuple:

  * w - Image width.
  * h - Image height.
  * d - Color depth.

See also: [`pix_get_depth`](@ref)
"""
function pix_get_dimensions(
            pix::Pix
        )::Union{NamedTuple{(:w, :h, :d), Tuple{Int32, Int32, Int32}}, Nothing}
    if is_valid(pix) == false
        @error "Pix has been freed."
        return nothing
    end

    local w = Ref{Cint}(0)
    local h = Ref{Cint}(0)
    local d = Ref{Cint}(0)

    local result = ccall(
        (:pixGetDimensions, LEPTONICA),
        Cint,
        (Ptr{Cvoid}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
        pix,
        w,
        h,
        d
    )

    if result == 1
        return nothing
    end

    return (w = w[], h = h[], d = d[])
end
