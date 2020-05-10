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
    lept_version()::String

Return the version number of the leptonica library.
"""
function lept_version()::String
    local retval = ccall(
        (:getLeptonicaVersion, LEPTONICA),
        Ptr{UInt8},
        ()
    )
    local result = ""

    if retval != C_NULL
        result = unsafe_string(retval)
        lept_free(retval)
    end

    return result
end

# =================================================================================================
"""
    lept_free(
        ptr::Ptr
    )::Nothing

Call the leptonica library to free some memory it allocated.

__Arguments:__
| T | Name | Default | Description
|---| :--- | :------ | :----------
| R | ptr  |         | The pointer to the memory allocated by leptonica.

__Details:__

This method is meant for internal usage.  At no point is memory allocated by leptonica passed to
clients of this library.
"""
function lept_free(
            ptr::Ptr
        )::Nothing
    ccall(
        (:lept_free, LEPTONICA),
        Cvoid,
        (Ptr{Cvoid},),
        ptr
    )
    nothing
end
