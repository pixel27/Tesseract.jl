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
    pipeline_create_alto(
        output::AbstractString
    )::Ptr{Cvoid}

Create the ALTO renderer in tesseract.

__Arguments:__

| T | Name   | Default | Description
|:--| :----- | :------ | :----------
| R | output |         | The name of the file to create (without an extension).
"""
function pipeline_create_alto(
            output::AbstractString
        )::Ptr{Cvoid}
    return ccall(
        (:TessAltoRendererCreate, TESSERACT),
        Ptr{Cvoid},
        (Cstring,),
        output
    )
end

# =========================================================================================
"""
    pipeline_create_hocr(
        output::AbstractString,
        fontInfo::Bool
    )::Ptr{Cvoid}

Create the HOCR renderer in tesseract.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | output   |         | The name of the file to create (without an extension).
| R | fontinfo |         | Should font information be included in the output?
"""
function pipeline_create_hocr(
            output::AbstractString,
            fontInfo::Bool
        )::Ptr{Cvoid}
    return ccall(
        (:TessHOcrRendererCreate2, TESSERACT),
        Ptr{Cvoid},
        (Cstring, Cint),
        output,
        fontInfo ? 1 : 0
    )
end

# =========================================================================================
"""
pipeline_create_pdf(
        output::AbstractString,
        textOnly::Bool,
        dataDir::AbstractString
)::Ptr{Cvoid}

Create the PDF renderer in tesseract.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | output   |         | The name of the file to create (without an extension).
| R | textOnly |         | Only include the text (no images) in the output?
| R | dataDir  |         | The directory to look for the PDF font file in.
"""
function pipeline_create_pdf(
            output::AbstractString,
            textOnly::Bool,
            dataDir::AbstractString
        )::Ptr{Cvoid}
    return ccall(
        (:TessPDFRendererCreate, TESSERACT),
        Ptr{Cvoid},
        (Cstring, Cstring, Cint),
        output,
        dataDir,
        textOnly ? 1 : 0
    )
end

# =========================================================================================
"""
    pipeline_create_text(
        output::AbstractString
    )::Ptr{Cvoid}

Create the text renderer in tesseract.

__Arguments:__

| T | Name   | Default    | Description
|:--| :----- | :--------- | :----------
| R | output |            | The name of the file to create (without an extension).
"""
function pipeline_create_text(
            output::AbstractString
        )::Ptr{Cvoid}
    return ccall(
        (:TessTextRendererCreate, TESSERACT),
        Ptr{Cvoid},
        (Cstring,),
        output
    )
end

# =========================================================================================
"""
    pipeline_create_tsv(
        output::AbstractString
    )::Ptr{Cvoid}

Create the TSV renderer in tesseract.

__Arguments:__

| T | Name   | Default    | Description
|:--| :----- | :--------- | :----------
| R | output |            | The name of the file to create (without an extension).
"""
function pipeline_create_tsv(
            output::AbstractString
        )::Ptr{Cvoid}
    return ccall(
        (:TessTsvRendererCreate, TESSERACT),
        Ptr{Cvoid},
        (Cstring,),
        output
    )
end

# =========================================================================================
"""
    pipeline_create_unlv(
        output::AbstractString
    )::Ptr{Cvoid}

Create the UNLV renderer in tesseract.

__Arguments:__

| T | Name   | Default    | Description
|:--| :----- | :--------- | :----------
| R | output |            | The name of the file to create (without an extension).
"""
function pipeline_create_unlv(
            output::AbstractString
        )::Ptr{Cvoid}
    return ccall(
        (:TessUnlvRendererCreate, TESSERACT),
        Ptr{Cvoid},
        (Cstring,),
        output
    )
end

# =========================================================================================
"""
    pipeline_create_word_box(
        output::AbstractString
    )::Ptr{Cvoid}

Create the String Word Box renderer in tesseract.

__Arguments:__

| T | Name   | Default    | Description
|:--| :----- | :--------- | :----------
| R | output |            | The name of the file to create (without an extension).
"""
function pipeline_create_word_box(
            output::AbstractString
        )::Ptr{Cvoid}
    return ccall(
        (:TessWordStrBoxRendererCreate, TESSERACT),
        Ptr{Cvoid},
        (Cstring,),
        output
    )
end

# =========================================================================================
"""
pipeline_create_lstm_box(
        output::AbstractString
    )::Ptr{Cvoid}

Create the LSTM Box renderer in tesseract.

__Arguments:__

| T | Name   | Default    | Description
|:--| :----- | :--------- | :----------
| R | output |            | The name of the file to create (without an extension).
"""
function pipeline_create_lstm_box(
            output::AbstractString
        )::Ptr{Cvoid}
    return ccall(
        (:TessLSTMBoxRendererCreate, TESSERACT),
        Ptr{Cvoid},
        (Cstring,),
        output
    )
end
