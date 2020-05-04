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
    tess_image(
            inst::TessInst,
            pix::Pix
        )::Nothing

Set the image to be OCRed.

__Parameters:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | inst |         | The instance to load the image into.
| R | pix  |         | The image to load into Tesseract to perform OCR.

__Details:__

Only 1 image can be set, calling this multiple times will replace the last image.
"""
function tess_image(
            inst::TessInst,
            pix::Pix
        )::Nothing

    if is_valid(inst) == true && is_valid(pix) == true
        ccall(
            (:TessBaseAPISetImage2, TESSERACT),
            Cvoid,
            (Ptr{Cvoid},Ptr{Cvoid}),
            inst,
            pix.ptr
        )
    elseif is_valid(inst) == false
        @error "Instance has been freed."
    else
        @error "Pix object has been freed."
    end
    nothing
end

# =================================================================================================
"""
    tess_resolution(
        inst::TessInst, # The instance to configure.
        ppi             # The PPI of the source image.
    )::Nothing

Set the resolution of the image in ppi.

__Parameters:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | inst |         | The instance of load the image into.
| R | ppi  |         | The PPI (pixels per inch) of the source image.
"""
function tess_resolution(
            inst::TessInst,
            ppi::Integer
        )::Nothing
    # ---------------------------------------------------------------------------------------------
    # Make sure the object is still valid.
    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Make the C call.
    ccall(
        (:TessBaseAPISetSourceResolution, TESSERACT),
        Cvoid,
        (Ptr{Cvoid}, Cint),
        inst,
        ppi
    )
    nothing
end
