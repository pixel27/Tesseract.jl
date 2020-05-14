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

# =========================================================================================
"""
    mutable struct Latin1{T<:IO} <: IO
        handle::T
        buffer::Vector{UInt8}
        Latin1(handle::T) where T = new{T}(handle, Vector{UInt8}())
    end

Implements a subset of the IO functionality and converts from the Latin-1 encoding to UTF-8.

__Constructors:__

    Latin1(handle::T)

Wrap the IO stream handle for reading and converting from Latin-1 to UTF-8.
"""
mutable struct Latin1{T<:IO} <: IO
    handle::T
    buffer::Vector{UInt8}
    Latin1(handle::T) where T = new{T}(handle, Vector{UInt8}())
end

# =========================================================================================
"""
    isopen(io::Latin1)

Check if the stream is still open.

__Arguments:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | io   |            | The IO stream being wrapped.
"""
Base.isopen(io::Latin1) = isopen(io.handle)

# =========================================================================================
"""
    close(io::Latin1)

Close the IO stream.

__Arguments:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | io   |            | The IO stream to close.
"""
Base.close(io::Latin1) = close(io.handle)

# =========================================================================================
"""
    readbytes!(
        io::Latin1,
        buf::AbstractVector{UInt8},
        nb=length(buf)
    )::Int

Read at most `nb` bytes from the stream.  Returns the number of bytes actually read.

__Arguments:__

| T | Name | Default     | Description
|:--| :--- | :---------- | :----------
| R | io   |             | The IO stream to read from.
| R | buf  |             | The buffer to write the data to.
| R | nb   | length(buf) | The number of bytes to read.

__Details:__

This method reads nb/2 bytes then converts them from Latin1 encoding to UTF-8.  Worst case
that each byte read will be converted into 2 bytes so we only read half the bytes requested.
In that way we don't have to handle a partially filled internal buffer.
"""
function Base.readbytes!(
            io::Latin1,
            buf::AbstractVector{UInt8},
            nb=length(buf)
        )::Int
    local bytes = readbytes!(io.handle, io.buffer, nb÷2)
    local offset = 0

    for i in 1:bytes
        @inbounds local by = io.buffer[i]

        if by < 128
            buf[offset+1] = by
            offset += 1
        else
            buf[offset+1] = 0xc0 | (by >> 6)
            buf[offset+2] = 0x80 | (by & 0x3f)
            offset += 2
        end
    end

    return offset
end
