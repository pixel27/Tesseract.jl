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
using Cairo

const FONT_NAME = "Sans"
const FONT_SIZE = 16.0
const LINE_HEIGHT = 20.0
const IMAGE_WIDTH = 300.0
const IMAGE_HEIGHT = 600.0

# ==================================================================================================
"""
    struct Line{T}
        words::Vector{SubString{T}}
        slant::Int32
        weight::Int32
    end

Construct a "line" of text.  Handles italics an bold via the constructor.

    Line(text::T; italic::Bool = false, bold::Bool = false) where T <: AbstractString
"""
struct Line{T}
    words::Vector{SubString{T}}
    slant::Int32
    weight::Int32
    Line(text::T; italic::Bool = false, bold::Bool = false) where T <: AbstractString = new{T}(
        split(text),
        italic ? Cairo.FONT_SLANT_ITALIC : Cairo.FONT_SLANT_NORMAL,
        bold ? Cairo.FONT_WEIGHT_BOLD : Cairo.FONT_WEIGHT_NORMAL
    )
end

const DEFAULT_TEXT = [
    Line("The quick brown fox jumped over the lazy dog."),
    Line("Suzy sells sea shells by the sea shore.", italic=true),
    Line("The sixth sick sheik's sixth sheep's sick.", bold=true)
]

# ==================================================================================================
"""
    wrap_words(
        cr::CairoContext,
        margin::Float64,
        start::Float64,
        words
    )::Float64

Writes the list of words to the image wrapping if they will extend off the right side.  Returns the
next Y offset to start writing at to avoid overwriting the existing text.
"""
function wrap_words(
            cr::CairoContext,
            margin::Float64,
            start::Float64,
            words
        )::Float64
    local y = 0
    local w = 1

    # -----------------------------------------------------------------------------------------
    # Process all the words.
    while w < length(words)
        local good = "$(words[w])"
        local line = ""

        # -----------------------------------------------------------------------------------------
        # Keep increasing the line length until we overflow.
        while w < length(words)
            w       = w + 1
            line    = "$good $(words[w])"
            local e = text_extents(cr, line)

            if e[3] > IMAGE_WIDTH - (2.0 * margin)
                w -= 1
                break
            end

            good = line
        end

        # -----------------------------------------------------------------------------------------
        # Write out the line.
        move_to(cr, margin, start + Float64(y) * LINE_HEIGHT)
        show_text(cr, good)
        y += 1
    end

    if start + Float64(y) * LINE_HEIGHT > IMAGE_HEIGHT
        @error "Ran off the bottom of the image."
    end

    return start + Float64(y) * LINE_HEIGHT
end

# ==================================================================================================
"""
    draw_image(text = DEFAULT_TEXT)::Vector{UInt8}

Creates an image with the specified text as a PNG.  The text should be a list of Line objects to
write to the image.
"""
function draw_image(text = DEFAULT_TEXT)::Vector{UInt8}
    local c = CairoImageSurface(
        IMAGE_WIDTH,
        IMAGE_HEIGHT,
        Cairo.FORMAT_RGB24
        )
    local cr = CairoContext(c)

    # Create a white image.
    save(cr)
        set_source_rgb(cr, 1.0, 1.0, 1.0)
        rectangle(cr, 0.0, 0.0, IMAGE_WIDTH, IMAGE_HEIGHT)
        fill(cr)
    restore(cr)

    save(cr)
        set_source_rgb(cr, 0.0, 0.0, 0.0);
        set_font_size(cr, FONT_SIZE)

        local y = 0.0
        for line in text
            y += LINE_HEIGHT
            select_font_face(cr, "Sans", line.slant, line.weight)
            y = wrap_words(cr, 10.0, y, line.words)
        end
    restore(cr)

    local buffer = IOBuffer()
    write_to_png(c, buffer)
    return take!(buffer)
end

# =================================================================================================
"""
    pix_with(text = DEFAULT_TEXT)::Pix

Load a Pix image into memory.
"""
function pix_with(text = DEFAULT_TEXT)::Pix
    local buffer = draw_image(text)
    return pix_read_png(buffer)
end

# =================================================================================================
"""
    safe_tmp_file()::String

Create a temporary file we can write to.
"""
function safe_tmp_file()::String
    local path, io = mktemp()
    close(io)
    return path
end

# =================================================================================================
"""
    save_image(data)::String

Save an image to a temporary file.  Returns the path of the temporary file.
"""
function save_image(data)::String
    local path, io = mktemp()
    write(io, data)
    close(io)
    return path
end

# =================================================================================================
"""
    bmp_with(text = DEFAULT_TEXT)::Vector{UInt8}

Create a BMP image with the specified text in memory.  Returns the image data. The text should be a
list of Line objects.
"""
function bmp_with(text = DEFAULT_TEXT)::Vector{UInt8}
    local pix = pix_with(text)
    return pix_write_bmp(pix)
end

# =================================================================================================
"""
    gif_with(text = DEFAULT_TEXT)::Vector{UInt8}

Create a GIF image with the specified text in memory.  Returns the image data. The text should be a
list of Line objects.
"""
function gif_with(text = DEFAULT_TEXT)::Vector{UInt8}
    local pix = pix_with(text)
    return pix_write_gif(pix)
end

# =================================================================================================
"""
    jp2k_with(text = DEFAULT_TEXT)::Vector{UInt8}

Create a J2K image with the specified text in memory.  Returns the image data. The text should be a
list of Line objects.
"""
function jp2k_with(text = DEFAULT_TEXT)::Vector{UInt8}
    local pix = pix_with(text)
    return pix_write_jp2k(pix)
end

# =================================================================================================
"""
    jpeg_with(text = DEFAULT_TEXT)::Vector{UInt8}

Create a JPG image with the specified text in memory.  Returns the image data. The text should be a
list of Line objects.
"""
function jpeg_with(text = DEFAULT_TEXT)::Vector{UInt8}
    local pix = pix_with(text)
    return pix_write_jpeg(pix)
end

# =================================================================================================
"""
    png_with(text = DEFAULT_TEXT)::Vector{UInt8}

Create a PNG image with the specified text in memory.  Returns the image data. The text should be a
list of Line objects.
"""
function png_with(text = DEFAULT_TEXT)::Vector{UInt8}
    return draw_image(text)
end

# =================================================================================================
"""
    pnm_with(text = DEFAULT_TEXT)::Vector{UInt8}

Create a PNM image with the specified text in memory.  Returns the image data. The text should be a
list of Line objects.
"""
function pnm_with(text = DEFAULT_TEXT)::Vector{UInt8}
    local pix = pix_with(text)
    return pix_write_pnm(pix)
end

# =================================================================================================
"""
    spix_with(text = DEFAULT_TEXT)::Vector{UInt8}

Create a SPIX image with the specified text in memory.  Returns the image data. The text should be
a list of Line objects.
"""
function spix_with(text = DEFAULT_TEXT)::Vector{UInt8}
    local pix = pix_with(text)
    return pix_write_spix(pix)
end

# =================================================================================================
"""
    tiff_with(text = DEFAULT_TEXT)::Vector{UInt8}

Create a TIFF image with the specified text in memory.  Returns the image data. The text should be
a list of Line objects.
"""
function tiff_with(text = DEFAULT_TEXT)::Vector{UInt8}
    local pix = pix_with(text)
    return pix_write_tiff(pix)
end

# =================================================================================================
"""
    webp_with(text = DEFAULT_TEXT)::Vector{UInt8}

Create a WEBP image with the specified text in memory.  Returns the image data. The text should be
a list of Line objects.
"""
function webp_with(text = DEFAULT_TEXT)::Vector{UInt8}
    local pix = pix_with(text)
    return pix_write_webp(pix)
end

# =================================================================================================
"""
    bmp_file_with(text = DEFAULT_TEXT)::String

Create a BMP file with the specified text.  Returns the path to the file that was created.  The
text should be a list of Line objects.
"""
function bmp_file_with(text = DEFAULT_TEXT)::String
    local data = bmp_with(text)
    return save_image(data)
end

# =================================================================================================
"""
    gif_file_with(text = DEFAULT_TEXT)::String

Create a GIF file with the specified text.  Returns the path to the file that was created.  The
text should be a list of Line objects.
"""
function gif_file_with(text = DEFAULT_TEXT)::String
    local data = gif_with(text)
    return save_image(data)
end

# =================================================================================================
"""
    jp2k_file_with(text = DEFAULT_TEXT)::String

Create a J2K file with the specified text.  Returns the path to the file that was created.  The
text should be a list of Line objects.
"""
function jp2k_file_with(text = DEFAULT_TEXT)::String
    local data = jp2k_with(text)
    return save_image(data)
end

# =================================================================================================
"""
    jpeg_file_with(text = DEFAULT_TEXT)::String

Create a JPG file with the specified text.  Returns the path to the file that was created.  The
text should be a list of Line objects.
"""
function jpeg_file_with(text = DEFAULT_TEXT)::String
    local data = jpeg_with(text)
    return save_image(data)
end

# =================================================================================================
"""
    png_file_with(text = DEFAULT_TEXT)::String

Create a PNG file with the specified text.  Returns the path to the file that was created.  The
text should be a list of Line objects.
"""
function png_file_with(text = DEFAULT_TEXT)::String
    local data = png_with(text)
    return save_image(data)
end

# =================================================================================================
"""
    pnm_file_with(text = DEFAULT_TEXT)::String

Create a PNM file with the specified text.  Returns the path to the file that was created.  The
text should be a list of Line objects.
"""
function pnm_file_with(text = DEFAULT_TEXT)::String
    local data = pnm_with(text)
    return save_image(data)
end

# =================================================================================================
"""
    spix_file_with(text = DEFAULT_TEXT)::String

Create a SPIX file with the specified text.  Returns the path to the file that was created.  The
text should be a list of Line objects.
"""
function spix_file_with(text = DEFAULT_TEXT)::String
    local data = spix_with(text)
    return save_image(data)
end

# =================================================================================================
"""
    tiff_file_with(text = DEFAULT_TEXT)::String

Create a TIFF file with the specified text.  Returns the path to the file that was created.  The
text should be a list of Line objects.
"""
function tiff_file_with(text = DEFAULT_TEXT)::String
    local data = tiff_with(text)
    return save_image(data)
end

# =================================================================================================
"""
    webp_file_with(text = DEFAULT_TEXT)::String

Create a WEBP file with the specified text.  Returns the path to the file that was created.  The
text should be a list of Line objects.
"""
function webp_file_with(text = DEFAULT_TEXT)::String
    local data = webp_with(text)
    return save_image(data)
end
