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
    tess_text(
        inst::TessInst
    )::Union{String, Nothing}

Extract the text from the image. If there is an error `nothing` will be returned.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | inst |         | The instance to grab the text from.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.

__Example:__

```jldoctest
using Tesseract

download_languages()

instance = TessInst()
pix = sample_pix()

tess_image(instance, pix)
tess_resolution(instance, 72)

text = tess_text(instance)

for line in split(text, '\\n'; keepempty = false)[1:5]
    println(line)
end

# output

No one would have believed in the last years of the
the nineteenth century that this world was being watched
watched keenly and closely by intelligences greater than
than man’s and yet as mortal as his own; that as men busied
busied themselves about their various concerns they were
```

See also: [`tess_hocr`](@ref), [`tess_alto`](@ref), [`tess_tsv`](@ref),
          [`tess_parsed_tsv`](@ref), [`tess_confidences`](@ref)
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

__Arguments:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | inst |            | The instance to grab the text from.
| O | page | `Int32(1)` | The page to extract the hOCR text for.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.  The current
hOCR spec can be accessed at http://kba.cloud/hocr-spec/1.2/.

__Example:__

```jldoctest
using Tesseract

download_languages()

instance = TessInst()
pix = sample_pix()

tess_image(instance, pix)
tess_resolution(instance, 72)

hocr = tess_hocr(instance)

for line in split(hocr, '\\n'; keepempty = false)[1:5]
    println(strip(line))
end

# output

<div class='ocr_page' id='page_1' title='image "unknown"; bbox 0 0 500 600; ppageno 0; scan_res 72 72'>
<div class='ocr_carea' id='block_1_1' title="bbox 10 9 489 523">
<p class='ocr_par' id='par_1_1' lang='eng' title="bbox 11 9 417 23">
<span class='ocr_line' id='line_1_1' title="bbox 11 9 417 23; baseline 0 -3; x_size 22.717392; x_descenders 5.5; x_ascenders 5.7391305">
<span class='ocrx_word' id='word_1_1' title='bbox 11 9 25 20; x_wconf 95'>No</span>
```

See also: [`tess_text`](@ref), [`tess_alto`](@ref), [`tess_tsv`](@ref),
          [`tess_parsed_tsv`](@ref), [`tess_confidences`](@ref)
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

__Arguments:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | inst |            | The instance to grab the text from.
| O | page | `Int32(1)` | The page to extract the ALTO text for.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.  The current
ALTO spec can be accessed at https://github.com/altoxml/documentation/wiki/Versions.

__Example:__

```jldoctest
using Tesseract

download_languages()

instance = TessInst()
pix = sample_pix()

tess_image(instance, pix)
tess_resolution(instance, 72)

alto = tess_alto(instance)

for line in split(alto, '\\n'; keepempty = false)[1:5]
    println(strip(line))
end

# output

<Page WIDTH="500" HEIGHT="600" PHYSICAL_IMG_NR="0" ID="page_0">
<PrintSpace HPOS="0" VPOS="0" WIDTH="500" HEIGHT="600">
<ComposedBlock ID="cblock_0" HPOS="10" VPOS="9" WIDTH="479" HEIGHT="514">
<TextBlock ID="block_0" HPOS="11" VPOS="9" WIDTH="406" HEIGHT="14">
<TextLine ID="line_0" HPOS="11" VPOS="9" WIDTH="406" HEIGHT="14">
```

See also: [`tess_text`](@ref), [`tess_hocr`](@ref), [`tess_tsv`](@ref), [`tess_parsed_tsv`](@ref),
[`tess_confidences`](@ref)
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

__Arguments:__

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

__Example:__

```jldoctest; filter = r"(\\s+)"
using Tesseract

download_languages()

instance = TessInst()
pix = sample_pix()

tess_image(instance, pix)
tess_resolution(instance, 72)

tsv = tess_tsv(instance)

for line in split(tsv, '\\n'; keepempty = false)[2:6]
    println(strip(line))
end

# output

2	1	1	0	0	0	10	9	479	514	-1
3	1	1	1	0	0	11	9	406	14	-1
4	1	1	1	1	0	11	9	406	14	-1
5	1	1	1	1	1	11	9	14	11	95.791931	No
5	1	1	1	1	2	35	12	22	8	95.791931	one
```

See also: [`tess_tsv`](@ref), [`tess_hocr`](@ref), [`tess_alto`](@ref), [`tess_parsed_tsv`](@ref),
[`tess_confidences`](@ref)
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

__Arguments:__

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

__Example:__

```jldoctest"
using Tesseract

download_languages()

instance = TessInst()
pix = sample_pix()

tess_image(instance, pix)
tess_resolution(instance, 72)

box = tess_text_box(instance)

for line in split(box, '\\n'; keepempty = false)[1:5]
  println(line)
end

# output

N 11 580 17 591 0
o 19 580 25 588 0
o 35 580 41 588 0
n 43 580 49 588 0
e 51 580 57 588 0
```

See also: [`tess_unlv`](@ref), [`tess_lstm_box`](@ref), [`tess_word_box`](@ref)
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

__Arguments:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | inst |            | The Tesseract instance to call.
| O | page | `Int32(1)` | The page to get the data for.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.  The results
are probably used for training.

__Example:__

```jldoctest; filter = r"(\\s+)"
using Tesseract

download_languages()

instance = TessInst()
pix = sample_pix()

tess_image(instance, pix)
tess_resolution(instance, 72)

box = tess_word_box(instance)

for line in split(box, '\\n'; keepempty = false)[1:5]
    println(line)
end

# output

WordStr 11 577 417 591 0 #No one would have believed in the last years of the
    418 577 422 591 0
WordStr 11 557 457 571 0 #the nineteenth century that this world was being watched
    458 557 462 571 0
WordStr 10 537 457 551 0 #watched keenly and closely by intelligences greater than
```

See also: [`tess_unlv`](@ref), [`tess_lstm_box`](@ref), [`tess_text_box`](@ref)
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

__Arguments:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | inst |            | The Tesseract instance to call.
| O | page | `Int32(1)` | The page to get the data for.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.

__Example:__

```jldoctest; filter = r"(\\s+)"
using Tesseract

download_languages()

instance = TessInst()
pix = sample_pix()

tess_image(instance, pix)
tess_resolution(instance, 72)

box = tess_lstm_box(instance)

for line in split(box, '\\n'; keepempty = false)[1:5]
    println(line)
end

# output

N 11 577 422 591 0
o 11 577 422 591 0
  11 577 422 591 0
o 11 577 422 591 0
n 11 577 422 591 0
```

See also: [`tess_unlv`](@ref), [`tess_word_box`](@ref), [`tess_text_box`](@ref)
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

# =========================================================================================
"""
    tess_unlv(
        inst::TessInst
    )::Union{String, Nothing}

Extract the text in UNLV format UTF-8 with reject and suspect codes.  If there is an error
`nothing` is returned.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | inst |         | The Tesseract instance to call.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.

This method is more used to test the OCR results than anything else.  If you want the
original Latin1 encoding use [`tess_unlv_latin1`](@ref) method.

__Example:__

```jldoctest
using Tesseract

download_languages()

instance = TessInst()
pix = sample_pix()

tess_image(instance, pix)
tess_resolution(instance, 72)

unlv = tess_unlv(instance)

for line in split(unlv, '\\n'; keepempty = false)[1:5]
    println(line)
end

# output

No one would have believed in the last years of the
the nineteenth century that this world was being watched
watched keenly and closely by intelligences greater than
than man's and yet as mortal as his own; that as men busied
busied themselves about their various concerns they were
```

See also: [`tess_lstm_box`](@ref), [`tess_word_box`](@ref), [`tess_text_box`](@ref),
          [`tess_unlv_latin1`](@ref)
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

        local buffer = Vector{UInt8}()

        local offset = 1
        while unsafe_load(bytes, offset) != 0x00
            local by = unsafe_load(bytes, offset)
            if by < 128
                push!(buffer, by)
            else
                push!(buffer, 0xc0 | (by >> 6))
                push!(buffer, 0x80 | (by & 0x3f))
            end
            offset += 1
        end
        delete_text(bytes)

        retval = String(buffer)
    else
        @error "Instance has been freed."
    end

    return retval
end

# =========================================================================================
"""
    tess_unlv_latin1(
        inst::TessInst
    )::Union{String, Nothing}

Extract the text in UNLV format Latin-1 with reject and suspect codes.  If there is an error
`nothing` is returned.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | inst |         | The Tesseract instance to call.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.

This method is more used to test the OCR results than anything else.  This method returns
the OCR data in Latin1 encoding.  If you want to use it as a string in Julia use the
[`tess_unlv`](@ref) method which will convert it to UTF-8 for you.

__Example:__

```jldoctest
using Tesseract

download_languages()

instance = TessInst()
pix = sample_pix()

tess_image(instance, pix)
tess_resolution(instance, 72)

unlv = tess_unlv_latin1(instance)

# output

1470-element Vector{UInt8}:
 0x4e
 0x6f
 0x20
 0x6f
 0x6e
 0x65
 0x20
 0x77
 0x6f
 0x75
    ⋮
 0x6f
 0x6e
 0x6d
 0x65
 0x6e
 0x74
 0x2e
 0x0a
 0x0a
```

See also: [`tess_lstm_box`](@ref), [`tess_word_box`](@ref), [`tess_text_box`](@ref),
          [`tess_unlv`](@ref)
"""
function tess_unlv_latin1(
            inst::TessInst
        )::Union{Vector{UInt8}, Nothing}
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
        while unsafe_load(bytes, size + 1) != 0x00
            size += 1
        end

        retval = Vector{UInt8}(undef, size)

        unsafe_copyto!(pointer(retval), bytes, size)

        delete_text(bytes)
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

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | inst |         | The Tesseract instance to call.

__Details:__

This method will call `tess_recognize()` if it has not been called yet for the image.

__Example:__

```jldoctest
using Tesseract

download_languages()

instance = TessInst()
pix = sample_pix()

tess_image(instance, pix)
tess_resolution(instance, 72)

confidence = tess_confidences(instance)

# output

256-element Vector{Int64}:
 95
 95
 92
 92
 96
 96
 96
 96
 96
 96
  ⋮
 96
 96
 96
 96
 96
 96
 96
 86
 86
```

See also: [`tess_tsv`](@ref), [`tess_parsed_tsv`](@ref)
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
