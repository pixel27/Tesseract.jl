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
    delete_text(
        text::Cstring
    )::Nothing

Free a string allocated by the Tesseract library.

__Parameters:__

| T | Name | Default | Description
|---| :--- | :------ | :----------
| R | text |         | The string to call Tesseract to free.

__Details:__

This method is meant for internal use.  This library only exports normal Julia objects that can be
garbage collected like normal.
"""
function delete_text(
            text::Cstring
        )::Nothing
    ccall((:TessDeleteText, TESSERACT), Cstring, (Cstring,), text)
    nothing
end

# =================================================================================================
"""
    delete_text(
        text::Ptr{CUInt8}
    )::Nothing

Free a byte array allocated by the Tesseract library.

__Parameters:__

| T | Name | Default | Description
|---| :--- | :------ | :----------
| R | text |         | The string to call Tesseract to free.

__Details:__

This method is meant for internal use.  This library only exports normal Julia objects that can be
garbage collected like normal.
"""
function delete_text(
            text::Ptr{UInt8}
        )::Nothing
    ccall((:TessDeleteText, TESSERACT), Cstring, (Ptr{UInt8},), text)
    nothing
end

# =================================================================================================
"""
    delete_array(
        array::Ptr{Ptr{UInt8}}
    )::Nothing

Free an array of strings allocated by the Tesseract library.

__Parameters:__

| T | Name  | Default | Description
|---| :---- | :------ | :----------
| R | array |         | The array of strings to free.

__Details:__

This method is meant for internal use.  This library only exports normal Julia objects that can be
garbage collected like normal.
"""
function delete_array(
            array::Ptr{Ptr{UInt8}}
        )::Nothing
    ccall((:TessDeleteTextArray, TESSERACT), Cvoid, (Ptr{Ptr{UInt8}},), array)
    nothing
end

# =================================================================================================
"""
    delete_array(
        array::Ptr{Cint}
    )::Nothing

Free an array of integers allocated by the Tesseract library.

__Parameters:__

| T | Name  | Default | Description
|---| :---- | :------ | :----------
| R | array |         | The array to ask Tesseract to free.

__Details:__

This method is meant for internal use.  This library only exports normal Julia objects that can be
garbage collected like normal.
"""
function delete_array(
            array::Ptr{Cint}
        )::Nothing
    ccall((:TessDeleteIntArray, TESSERACT), Cvoid, (Ptr{Cint},), array)
    nothing
end
