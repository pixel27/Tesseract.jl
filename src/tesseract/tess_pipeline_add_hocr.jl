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
    tess_pipeline_hocr(
        pipe::TessPipeline,
        filename::AbstractString,
        fontInfo::Bool = false
    )::Bool

Generate a HOCR file from the pipeline and save it to the specified file.  Returns `false`
if there is a problem adding the HOCR generator to the output.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | pipe     |         | The pipline to collect the HORC text from.
| R | filename |         | The file to write the HORC text to.
| O | fontInfo | `false` | Should font information be included in the output?

__Details:__

If the file exists it will be overwritten.

__Examples:__

```jldoctest; filter = r"(\\s+)"
using Tesseract

# Generate some pages to load.
write("page01.tiff", sample_tiff())
write("page02.tiff", sample_tiff())
write("page03.tiff", sample_tiff())

download_languages() # Make sure we have the data files.

instance = TessInst()
pipeline = TessPipeline(instance)

tess_pipeline_hocr(pipeline, "My Book.hocr")

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

for line in readlines("My Book.hocr")[1:10]
    println(line)
end

# output

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
        <title>My First Book</title>
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
        <meta name='ocr-system' content='tesseract 4.1.1' />
        <meta name='ocr-capabilities' content='ocr_page ocr_carea ocr_par ocr_line ocrx_word ocrp_wconf'/>
    </head>
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_alto`](@ref),
          [`tess_pipeline_pdf`](@ref), [`tess_pipeline_text`](@ref)
          [`tess_pipeline_tsv`](@ref)
"""
function tess_pipeline_hocr(
            pipe::TessPipeline,
            filename::AbstractString,
            fontInfo::Bool = false
        )::Bool
    local dir         = dirname(filename)
    local tmpfile, io = mktemp(dir;cleanup=false); close(io)
    local tmpname     = basename(tmpfile)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_hocr(tmpfile, fontInfo)

    if ptr == C_NULL
        rm(tmpfile)
        return false
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local task = pipeline_start_task(
        joinpath(dir, "$(tmpname).hocr"),
        filename
    )

    pipeline_add_renderer(pipe, ptr, task)

    return true
end

# =========================================================================================
"""
    tess_pipeline_hocr(
        pipe::TessPipeline,
        fontInfo::Bool = false
    )::Union{TessOutput{String}, Nothing}

Generate an HOCR file from the pipeline and save it to a string.  Returns `nothing` if
there is a problem adding the HOCR generator to the output.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | pipe     |         | The pipline to collect the HOCR text from.
| O | fontInfo | `false` | Should font information be included in the output?

__Examples:__

```jldoctest; filter = r"(\\s+)"
using Tesseract

# Generate some pages to load.
write("page01.tiff", sample_tiff())
write("page02.tiff", sample_tiff())
write("page03.tiff", sample_tiff())

download_languages() # Make sure we have the data files.

instance = TessInst()
pipeline = TessPipeline(instance)

book = tess_pipeline_hocr(pipeline)

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

for line in split(book[], "\\n")[1:10]
    println(line)
end

# output

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
        <title>My First Book</title>
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
        <meta name='ocr-system' content='tesseract 4.1.1' />
        <meta name='ocr-capabilities' content='ocr_page ocr_carea ocr_par ocr_line ocrx_word ocrp_wconf'/>
    </head>
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_alto`](@ref),
          [`tess_pipeline_pdf`](@ref), [`tess_pipeline_text`](@ref)
          [`tess_pipeline_tsv`](@ref)
"""
function tess_pipeline_hocr(
            pipe::TessPipeline,
            fontInfo::Bool = false
        )::Union{TessOutput{String}, Nothing}
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_hocr(
        joinpath(path, "output"),
        fontInfo
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return nothing
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local out = TessOutput(String)
    local task = pipeline_start_task(path, "output.hocr", out)

    pipeline_add_renderer(pipe, ptr, task)

    return out
end

# =========================================================================================
"""
    tess_pipeline_hocr(
        func::Function,
        pipe::TessPipeline,
        fontInfo::Bool = false
    )::Bool

Generate an HOCR file from the pipeline and pass it back to the client via a callback.
Returns `false` if there is a problem adding the HOCR generator to the output.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | func     |         | The function to call with the lines of text.
| R | pipe     |         | The pipline to collect the text from.
| O | fontInfo | `false` | Should font information be included in the output?

__Details:__

The text will be passed to the caller one line at a time. The "\\n" line terminator will be
included with the text.

__Examples:__

```jldoctest; filter = r"(\\s+)"
using Tesseract

# Generate some pages to load.
write("page01.tiff", sample_tiff())
write("page02.tiff", sample_tiff())
write("page03.tiff", sample_tiff())

download_languages() # Make sure we have the data files.

instance = TessInst()
pipeline = TessPipeline(instance)

count = 0
tess_pipeline_hocr(pipeline) do line
    global count
    if count < 10
        print(line)
    end
    count += 1
end

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

# output

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
        <title>My First Book</title>
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
        <meta name='ocr-system' content='tesseract 4.1.1' />
        <meta name='ocr-capabilities' content='ocr_page ocr_carea ocr_par ocr_line ocrx_word ocrp_wconf'/>
    </head>
true
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_alto`](@ref),
          [`tess_pipeline_pdf`](@ref), [`tess_pipeline_text`](@ref)
          [`tess_pipeline_tsv`](@ref)
"""
function tess_pipeline_hocr(
            func::Function,
            pipe::TessPipeline,
            fontInfo::Bool = false
        )::Bool
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_hocr(
        joinpath(path, "output"),
        fontInfo
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return false
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local task = pipeline_start_task(path, "output.hocr", func, "")

    pipeline_add_renderer(pipe, ptr, task)

    return true
end
