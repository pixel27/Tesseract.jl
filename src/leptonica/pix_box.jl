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
    struct PixBox
        x::Int32
        y::Int32
        w::Int32
        h::Int32
    end

The PixBox structure is used to identify a region in an image.

__Values:__

| Name | Description
| :--- | :----------
| x    | The left side of the region identified by this box.
| y    | The top edge of the region identified by this box.
| w    | The width of the box.
| h    | The height of the box.
"""
struct PixBox
    x::Int32
    y::Int32
    w::Int32
    h::Int32
end

# =================================================================================================
"""
    show(
        io::IO,
        box::PixBox
    )::Nothing

Write some summary information about the PixBox to the IO stream.

__Parameters:__
| T | Name | Default | Description
|---| :--- | :------ | :----------
| R | io   |         | The stream to write the information to.
| R | box  |         | The box to display information about.
"""
function Base.show(
            io::IO,
            box::PixBox
        )::Nothing
    println(io, "Box at: ($(box.x), $(box.y)) Dims: ($(box.w), $(box.h))")
    nothing
end
