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
using .Pipeline

# =========================================================================================
"""
    tess_pipeline_pdf(
        pipe::TessPipeline,
        filename::AbstractString;
        textOnly::Bool = false,
        dataDir::AbstractString = TESS_DATA
    )::Bool

Generate a PDF file from the pipeline and save it to the specified file.  Returns `false`
if there is a problem adding the PDF generator to the output.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | pipe     |         | The pipline to collect the tsv from.
| R | filename |         | The file to write the tsv to.
| K | textOnly |         | Should the PDF just include text or also contain the images?
| K | dataDir  |         | The directory to look for the PDF font file in.

__Details:__

If the file exists it will be overwritten.  A text only PDF will appear empty since
Tesseract uses a glyphless font, however you will be able to search for the text and see
and "empty" page where it's found.  Normally textOnly is false and will include the image
scanned by Tesseract which gives you a searchable PDF with the images.

__Examples:__

```jldoctest
using Tesseract

# Generate some pages to load.
write("page01.tiff", sample_tiff())
write("page02.tiff", sample_tiff())
write("page03.tiff", sample_tiff())

download_languages() # Make sure we have the data files.
download_pdf_font() # Make sure we have the PDF font file.

instance = TessInst()
pipeline = TessPipeline(instance)

tess_pipeline_pdf(pipeline, "My Book.pdf")

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

println(string("PDF created: ", filesize("My Book.pdf"), " bytes."))

# output

PDF created: 316722 bytes.
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_alto`](@ref),
          [`tess_pipeline_hocr`](@ref), [`tess_pipeline_text`](@ref)
          [`tess_pipeline_tsv`](@ref)
"""
function tess_pipeline_pdf(
            pipe::TessPipeline,
            filename::AbstractString;
            textOnly::Bool = false,
            dataDir::AbstractString = TESS_DATA
        )::Bool
    local dir         = dirname(filename)
    local tmpfile, io = mktemp(dir;cleanup=false); close(io)
    local tmpname     = basename(tmpfile)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_pdf(tmpfile, textOnly, dataDir)

    rm(tmpfile)

    if ptr == C_NULL
        return false
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local task = pipeline_start_task(
        joinpath(dir, "$(tmpname).pdf"),
        filename
    )

    pipeline_add_renderer(pipe, ptr, task)

    return true
end

# =========================================================================================
"""
    tess_pipeline_pdf(
        pipe::TessPipeline;
        textOnly::Bool = false,
        dataDir::AbstractString = TESS_DATA
    )::Union{TessOutput, Nothing}

Generate a PDF file from the pipeline and save it to a byte array.  Returns `nothing` if
there is a problem adding the PDF generator to the output.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | pipe     |         | The pipline to collect the TSV data from.
| K | textOnly |         | Should the PDF just include text or also contain the images?
| K | dataDir  |         | The directory to look for the PDF font file in.

__Examples:__

```jldoctest
using Tesseract

# Generate some pages to load.
write("page01.tiff", sample_tiff())
write("page02.tiff", sample_tiff())
write("page03.tiff", sample_tiff())

download_languages() # Make sure we have the data files.
download_pdf_font() # Make sure we have the PDF font file.

instance = TessInst()
pipeline = TessPipeline(instance)

book = tess_pipeline_pdf(pipeline)

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

println(string("PDF created: ", length(book[]), " bytes."))

# output

PDF created: 316722 bytes.
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_alto`](@ref),
          [`tess_pipeline_hocr`](@ref), [`tess_pipeline_text`](@ref)
          [`tess_pipeline_tsv`](@ref)
"""
function tess_pipeline_pdf(
            pipe::TessPipeline;
            textOnly::Bool = false,
            dataDir::AbstractString = TESS_DATA
        )::Union{TessOutput, Nothing}
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_pdf(
        joinpath(path, "output"),
        textOnly,
        dataDir
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return nothing
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local out = TessOutput(Vector{UInt8})
    local task = pipeline_start_task(path, "output.pdf", out)

    pipeline_add_renderer(pipe, ptr, task)

    return out
end
