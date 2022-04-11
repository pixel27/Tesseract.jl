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
    tess_set_input_name(
        inst::TessInst,
        input_name::AbstractString
    )::Nothing

Set the name of input file.

__Arguments:__

| T | Name       | Default | Description
|:--| :--------- | :------ | :----------
| R | inst       |         | The Tesseract instance to set the input name.
| R | input_name |         | The name of the input file.

"""
function tess_set_input_name(
            inst::TessInst,
            input_name::AbstractString
        )::Nothing

    # ---------------------------------------------------------------------------------------------
    # Make sure the Tess object is not freed.
    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Call the C library.
    ccall(
        (:TessBaseAPISetInputName, TESSERACT),
        Cvoid,
        (Ptr{Cvoid}, Cstring),
        inst,
        input_name
    )
    nothing
end

# =================================================================================================
"""
    tess_get_input_name(
        inst::TessInst
    )::Union{String, Nothing}

Get the name of input file.

__Arguments:__

| T | Name       | Default | Description
|:--| :--------- | :------ | :----------
| R | inst       |         | The Tesseract instance to load the input name.

"""
function tess_get_input_name(
            inst::TessInst
        )::Union{String, Nothing}

    # ---------------------------------------------------------------------------------------------
    # Make sure the Tess object is not freed.
    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Call the C library.
    local text = ccall(
        (:TessBaseAPIGetInputName, TESSERACT),
        Cstring,
        (Ptr{Cvoid},),
        inst
    )

    text == C_NULL ? nothing : unsafe_string(text)
end

