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
using Printf

# =================================================================================================
"""
    struct Tsv
        level::Int
        page::Int
        block::Int
        paragraph::Int
        line::Int
        word::Int
        left::Int
        top::Int
        width::Int
        height::Int
        conf::Float32
        text::String
    end

This structure holds the details of a line in the TSV formatted text provided by the tesseract
library.

__Values:__

| Name       | Description
| :--------- | :----------
| level      | Identifies what the line describes.
| page       | This is the page number passed into the `tess_tsv()` method.
| block      | Identifies the block on the page.
| paragraph  | The paragraph number in the block.
| line       | The line in the paragraph.
| word       | The word in the line.
| left       | Left edge of the item in pixels.
| top        | Top edge of the item in pixels.
| width      | Width of the item in pixels.
| height     | Height of the item in pixels.
| conf       | How confident the OCR engine is of the word (`0` - `100`). `-1` if level is not 5.
| text       | The word that was decoded from the image.

__Details:__

Level identifies what information the line is providing:

  * `1` - Page information, added at the start of the page.
  * `2` - Block information, added at the start of a block.
  * `3` - Paragraph information, added at the start of a paragraph.
  * `4` - Line information, added at the start of a line.
  * `5` - Word information, identifies a word that was read from the page.

The left, top, width, and height values define a box in pixels that encompases the item.  So if the
level is 1, the box describes the whole image.  If the level is `1`, then the box encloses the block
that was extracted, and so on down to the word that was extracted.

See also: [`tess_parsed_tsv`](@ref)
"""
struct Tsv
    level::Int
    page::Int
    block::Int
    paragraph::Int
    line::Int
    word::Int
    left::Int
    top::Int
    width::Int
    height::Int
    conf::Float32
    text::String
end

# =================================================================================================
"""
    show(
        io::IO,
        data::Tsv
    )::Nothing

Display summary information about the object.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | io   |         | The stream to write the data to.
| R | data |         | The object to display the information for.
"""
function Base.show(
            io::IO,
            data::Tsv
        )::Nothing
    if data.level == 1
        print(io, "Page:  [$(data.page)] ($(data.width), $(data.height))")
    elseif data.level == 2
        print(io, "Block: [$(data.page)/$(data.block)] ($(data.left), $(data.top)) - ($(data.width), $(data.height))")
    elseif data.level == 3
        print(io, "Para:  [$(data.page)/$(data.block)/$(data.paragraph)] ($(data.left), $(data.top)) - ($(data.width), $(data.height))")
    elseif data.level == 4
        print(io, "Line:  [$(data.page)/$(data.block)/$(data.paragraph)/$(data.line)] ($(data.left), $(data.top)) - ($(data.width), $(data.height))")
    elseif data.level == 5
        print(io, "Word:  [$(data.page)/$(data.block)/$(data.paragraph)/$(data.line)/$(data.word)] $(data.text) ($(data.conf)%)")
    else
        print(io, "Unhandled level: $(data.level)")
    end
    nothing
end

# =================================================================================================
"""
    tsv_from(
        line::AbstractString
    )::Tsv

Create a Tsv object from a line of text.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | line |         | The line to extract the information from for the Tsv.

__Details:__

The line must have 12 values separated by tabs.
"""
function tsv_from(
            line::AbstractString
        )::Tsv
    local a = split(line, '\t')

    if length(a) != 12
        throw("Line doesn't contain 12 values $(length(a)): $line")
    end

    Tsv(
        parse(Int, a[1]),
        parse(Int, a[2]),
        parse(Int, a[3]),
        parse(Int, a[4]),
        parse(Int, a[5]),
        parse(Int, a[6]),
        parse(Int, a[7]),
        parse(Int, a[8]),
        parse(Int, a[9]),
        parse(Int, a[10]),
        parse(Float32, a[11]),
        a[12]
        )
end

# =================================================================================================
"""
    tess_parsed_tsv(
        inst::TessInst,
        page::Integer = Int32(1)
    )::Union{Vector{Tsv}, Nothing}

Retrieve the TSV results from an recognition and parse it into a list of Tsv objects.  Returns
nothing if there is an error.

__Arguments:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | inst |            | The Tesseract instance to call.
| O | page | `Int32(1)` | The page to get the data for.

__Example:__

```jldoctest
using Tesseract

download_languages()

instance = TessInst()
pix = sample_pix()

tess_image(instance, pix)
tess_resolution(instance, 72)

tsv = tess_parsed_tsv(instance);

# output

292-element Vector{Tsv}:
 Page:  [1] (500, 600)
 Block: [1/1] (10, 9) - (479, 514)
 Para:  [1/1/1] (11, 9) - (406, 14)
 Line:  [1/1/1/1] (11, 9) - (406, 14)
 Word:  [1/1/1/1/1] No (95.79193%)
 Word:  [1/1/1/1/2] one (95.79193%)
 Word:  [1/1/1/1/3] would (92.95379%)
 Word:  [1/1/1/1/4] have (92.95379%)
 Word:  [1/1/1/1/5] believed (96.81915%)
 Word:  [1/1/1/1/6] in (96.770004%)
 ⋮
 Word:  [1/1/7/3/5] twentieth (96.62509%)
 Word:  [1/1/7/3/6] century (96.81123%)
 Word:  [1/1/7/3/7] came (96.81123%)
 Word:  [1/1/7/3/8] the (96.72949%)
 Word:  [1/1/7/3/9] great (96.72949%)
 Para:  [1/1/8] (11, 509) - (172, 14)
 Line:  [1/1/8/1] (11, 509) - (172, 14)
 Word:  [1/1/8/1/1] great (86.34806%)
 Word:  [1/1/8/1/2] disillusionment. (86.34806%)
```

See also: [`tess_tsv`](@ref), [`tess_confidences`](@ref)
"""
function tess_parsed_tsv(
            inst::TessInst,
            page::Integer = Int32(1)
        )::Union{Vector{Tsv}, Nothing}
    local text = tess_tsv(inst, page)

    if text == nothing
        return nothing
    end

    local retval = Vector{Tsv}()
    for line in split(text, '\n')
        if isempty(line) == false
            push!(retval, tsv_from(line))
        end
    end

    return retval
end
