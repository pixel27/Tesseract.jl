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
using StringEncodings

# =================================================================================================
"""
    tess_text(
        inst::TessInst
    )::Union{String, Nothing}

Extract the text from the image.    If there is an error `nothing` will be returned.

__Parameters:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | inst |         | The instance to grab the text from.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.
"""
function tess_text(
            inst::TessInst
        )::Union{String, Nothing}
    local retval = nothing

    if is_valid(inst) == true
        local text = ccall(
            (:TessBaseAPIGetUTF8Text, TESSERACT),
            Cstring,
            (Ptr{Cvoid},),
            inst
        )

        if text != C_NULL
            retval = unsafe_string(text)
            delete_text(text)
        end
    else
        @error "Instance has been freed."
    end

    return retval
end

# =================================================================================================
"""
    tess_hocr(
        inst::TessInst,
        page::Integer = Int32(1)
    )::Union{String, Nothing}

Extract the text in hOCR format from the image.  Returns `nothing` if there is an error.

__Parameters:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | inst |            | The instance to grab the text from.
| O | page | `Int32(1)` | The page to extract the hOCR text for.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.  The current
hOCR spec can be accessed at [http://kba.cloud/hocr-spec/1.2/](http://kba.cloud/hocr-spec/1.2/).
"""
function tess_hocr(
            inst::TessInst,
            page::Integer = Int32(1)
        )::Union{String, Nothing}
    local retval = nothing

    if is_valid(inst) == true
        local text = ccall(
            (:TessBaseAPIGetHOCRText, TESSERACT),
            Cstring,
            (Ptr{Cvoid},Cint),
            inst,
            page-1

        )
        if text != C_NULL
            retval = unsafe_string(text)
            delete_text(text)
        end
    else
        @error "Instance has been freed."
    end

    return retval
end

# =================================================================================================
"""
    tess_alto(
        inst::TessInst,
        page::Integer = Int32(1)
    )::Union{String, Nothing}

Extract the text in ALTO format from the image.  Returns `nothing` if there is an error.

__Parameters:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | inst |            | The instance to grab the text from.
| O | page | `Int32(1)` | The page to extract the ALTO text for.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.  The current
ALTO spec can be accessed at
[https://github.com/altoxml/documentation/wiki/Versions](https://github.com/altoxml/documentation/wiki/Versions).
"""
function tess_alto(
            inst::TessInst,
            page::Integer = Int32(1)
        )::Union{String, Nothing}
    local retval = nothing

    if is_valid(inst) == true
        local text = ccall(
            (:TessBaseAPIGetAltoText, TESSERACT),
            Cstring,
            (Ptr{Cvoid},Cint),
            inst,
            page - 1
        )
        if text != C_NULL
            retval = unsafe_string(text)
            delete_text(text)
        end
    else
        @error "Instance has been freed."
    end

    return retval
end

# =================================================================================================
"""
    tess_tsv(
        inst::TessInst,
        page::Integer = Int32(1)
    )::Union{String, Nothing}

Retrieve the TSV results from an recognition as a string with tabbed separated values.

__Parameters:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | inst |            | The Tesseract instance to call.
| O | page | `Int32(1)` | The page to get the data for.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.

If you want to read the data take a look at `tess_parsed_tsv()` which parses it into a form that
is easier to use.  If you just want to display the data to the user or write it to a file then
this method will probably be fine.

This call basically returns the results of the recognition process.  Each line in the string
identifies an "object" found by Tesseract.  The 12 values per line are as follows:

  * level - Identifies what the line describes.
  * page - This is the page number passed into the `tess_tsv()` method.
  * block - Identifies the block on the page.
  * paragraph - The paragraph number in the block.
  * line - The line in the paragraph.
  * word - The word in the line.
  * left - Left edge of the item in pixels.
  * top - Top edge of the item in pixels.
  * width - Width of the item in pixels.
  * height - Height of the item in pixels.
  * conf - How confident the OCR engine is of the word (`0` - `100`). `-1` if level is not 5.
  * text - The word that was decoded from the image.

Level identifies what information the line is providing:

* `1` - Page information, added at the start of the page.
* `2` - Block information, added at the start of a block.
* `3` - Paragraph information, added at the start of a paragraph.
* `4` - Line information, added at the start of a line.
* `5` - Word information, identifies a word that was read from the page.

The left, top, width, and height values define a box in pixels that encompases the item.  So if the
level is 1, the box describes the whole image.  If the level is `1`, then the box encloses the block
that was extracted, and so on down to the word that was extracted.
"""
function tess_tsv(
            inst::TessInst,
            page::Integer = Int32(1)
        )::Union{String, Nothing}
    local retval = nothing

    if is_valid(inst) == true
        local text = ccall(
            (:TessBaseAPIGetTsvText, TESSERACT),
            Cstring,
            (Ptr{Cvoid},Cint),
            inst,
            page - 1
        )
        if text != C_NULL
            retval = unsafe_string(text)
            delete_text(text)
        end
    else
        @error "Instance has been freed."
    end

    return retval
end

# =================================================================================================
"""
    tess_text_box(
        inst::TessInst,
        page::Integer = Int32(1)
    )::Union{String, Nothing}

Retrieve the boxes for the identified characters on the page.  If there is an error 'nothing' is
returned.

__Parameters:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | inst |            | The Tesseract instance to call.
| O | page | `Int32(1)` | The page to get the data for.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.  The results
are primarly useful for training purposes.

Each line in the result is a character identified with 6 values:

  * The character that was recognized.
  * The left edge of the character measured in pixels from the left edge.
  * The bottom edge of the character measured in pixels from the bottom of the image.
  * The right edge of the character measured in pixels from the left edge.
  * The top edge of the character measured in pixels from the bottom of the image.
  * The page used in the recogniztion 0 based.
"""
function tess_text_box(
            inst::TessInst,
            page::Integer = Int32(1)
        )::Union{String, Nothing}
    local retval = nothing

    if is_valid(inst) == true
        local text = ccall(
            (:TessBaseAPIGetBoxText, TESSERACT),
            Cstring,
            (Ptr{Cvoid}, Cint),
            inst,
            page - 1
        )
        if text != C_NULL
            retval = unsafe_string(text)
            delete_text(text)
        end
    else
        @error "Instance has been freed."
    end

    return retval
end

# =================================================================================================
"""
    tess_word_box(
        inst::TessInst,
        page::Integer = Int32(1)
    )::Union{String, Nothing}

Create a UTF8 box file with WordStr strings,  If there is an error 'nothing' is returned.

__Parameters:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | inst |            | The Tesseract instance to call.
| O | page | `Int32(1)` | The page to get the data for.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.  The results
are probably used for training.
"""
function tess_word_box(
            inst::TessInst,
            page::Integer = Int32(1)
        )::Union{String, Nothing}
    local retval = nothing

    if is_valid(inst) == true
        local text = ccall(
            (:TessBaseAPIGetWordStrBoxText, TESSERACT),
            Cstring,
            (Ptr{Cvoid}, Cint),
            inst,
            page - 1
        )
        if text != C_NULL
            retval = unsafe_string(text)
            delete_text(text)
        end
    else
        @error "Instance has been freed."
    end

    return retval
end

# =================================================================================================
"""
    tess_lstm_box(
        inst::TessInst,
        page::Integer = Int32(1)
    )::Union{String, Nothing}

Return the UTF-8 box file for LSTM training.  If there is an error 'nothing' is returned.

__Parameters:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | inst |            | The Tesseract instance to call.
| O | page | `Int32(1)` | The page to get the data for.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.
"""
function tess_lstm_box(
            inst::TessInst,
            page::Integer = Int32(1)
        )::Union{String, Nothing}
    local retval = nothing

    if is_valid(inst) == true
        local text = ccall(
            (:TessBaseAPIGetLSTMBoxText, TESSERACT),
            Cstring,
            (Ptr{Cvoid}, Cint),
            inst,
            page - 1
        )
        if text != C_NULL
            retval = unsafe_string(text)
            delete_text(text)
        end
    else
        @error "Instance has been freed."
    end

    return retval
end

# =================================================================================================
"""
    tess_unlv(
        inst::TessInst
    )::Union{String, Nothing}

Extract the text in UNLV format Latin-1 with reject and suspect codes.  If there is an error
`nothing` is returned.

__Parameters:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | inst |         | The Tesseract instance to call.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.

This method is more used to test the OCR results than anything else.
"""
function tess_unlv(
            inst::TessInst
        )::Union{String, Nothing}
    local retval = nothing

    if is_valid(inst) == true
        local bytes = ccall(
            (:TessBaseAPIGetUNLVText, TESSERACT),
            Ptr{UInt8},
            (Ptr{Cvoid},),
            inst
        )

        if bytes == C_NULL
            return nothing
        end

        local size = 0
        while unsafe_load(bytes, size+1) != 0x00
            size += 1
        end
        local buffer = Vector{UInt8}(undef, size)
        unsafe_copyto!(pointer(buffer), bytes, size)
        delete_text(bytes)

        retval = decode(buffer, enc"LATIN1")
    else
        @error "Instance has been freed."
    end

    return retval
end

# =================================================================================================
"""
    tess_confidences(
        inst::TessInst
    )::Union{Vector{Int}, Nothing}

Extract the confidences in the words that where extracted from the image.

__Parameters:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | inst |         | The Tesseract instance to call.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.
"""
function tess_confidences(
            inst::TessInst
        )::Union{Vector{Int}, Nothing}

    # ---------------------------------------------------------------------------------------------
    # Make sure the object is still valid.
    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Make the C call.
    local list = ccall(
        (:TessBaseAPIAllWordConfidences, TESSERACT),
        Ptr{Cint},
        (Ptr{Cvoid},),
        inst
    )

    if list == C_NULL
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Walk the pointer until we find a -1.
    local retval = Vector{Cint}()
    local offset = 1
    while unsafe_load(list, offset) != -1
        push!(retval, unsafe_load(list, offset))
        offset += 1
    end

    # ---------------------------------------------------------------------------------------------
    # Free the memory.
    delete_array(list)

    return retval
end
