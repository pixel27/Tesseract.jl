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
    tess_pipeline_text(
        pipe::TessPipeline,
        filename::AbstractString
    )::Bool

Generate a text file from the pipeline and save it to the specified file.  Returns `false`
if there is a problem adding the text generator to the output.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | pipe     |         | The pipline to collect the text from.
| R | filename |         | The file to write the text to.

__Details:__

If the file exists it will be overwritten.

__Examples:__

```jldoctest
using Tesseract

# Generate some pages to load.
write("page01.tiff", sample_tiff())
write("page02.tiff", sample_tiff())
write("page03.tiff", sample_tiff())

download_languages() # Make sure we have the data files.

instance = TessInst()
pipeline = TessPipeline(instance)

tess_pipeline_text(pipeline, "My Book.txt")

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

for line in readlines("My Book.txt")[1:10]
    println(line)
end

# output

No one would have believed in the last years of the

the nineteenth century that this world was being watched
watched keenly and closely by intelligences greater than
than man’s and yet as mortal as his own; that as men busied
busied themselves about their various concerns they were
were scrutinised and studied, perhaps almost as narrowly as
as a man with a microscope might scrutinise the transient
transient creatures that swarm and multiply in a drop of
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_alto`](@ref),
          [`tess_pipeline_hocr`](@ref), [`tess_pipeline_pdf`](@ref)
          [`tess_pipeline_tsv`](@ref)
"""
function tess_pipeline_text(
            pipe::TessPipeline,
            filename::AbstractString
        )::Bool
    local dir         = dirname(filename)
    local tmpfile, io = mktemp(dir;cleanup=false); close(io)
    local tmpname     = basename(tmpfile)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_text(tmpfile)

    rm(tmpfile)

    if ptr == C_NULL
        return false
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local task = pipeline_start_task(
        joinpath(dir, "$(tmpname).txt"),
        filename
    )

    pipeline_add_renderer(pipe, ptr, task, RENDERER_TEXT)

    return true
end

# =========================================================================================
"""
    tess_pipeline_text(
        pipe::TessPipeline
    )::Union{TessOutput{String}, Nothing}

Generate a text file from the pipeline and save it to a string.  Returns `nothing` if there
is a problem adding the text generator to the output.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | pipe |         | The pipline to collect the text from.

__Examples:__

```jldoctest
using Tesseract

# Generate some pages to load.
write("page01.tiff", sample_tiff())
write("page02.tiff", sample_tiff())
write("page03.tiff", sample_tiff())

download_languages() # Make sure we have the data files.

instance = TessInst()
pipeline = TessPipeline(instance)

book = tess_pipeline_text(pipeline)

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

count = 0
for line in split(book[], "\\n")[1:10]
    global count
    if count < 10
        println(line)
    end
    count += 1
end

# output

No one would have believed in the last years of the

the nineteenth century that this world was being watched
watched keenly and closely by intelligences greater than
than man’s and yet as mortal as his own; that as men busied
busied themselves about their various concerns they were
were scrutinised and studied, perhaps almost as narrowly as
as a man with a microscope might scrutinise the transient
transient creatures that swarm and multiply in a drop of
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_alto`](@ref),
          [`tess_pipeline_hocr`](@ref), [`tess_pipeline_pdf`](@ref)
          [`tess_pipeline_tsv`](@ref)
"""
function tess_pipeline_text(
            pipe::TessPipeline
        )::Union{TessOutput{String}, Nothing}
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_text(
        joinpath(path, "output")
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return nothing
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local out = TessOutput(String)
    local task = pipeline_start_task(path, "output.txt", out)

    pipeline_add_renderer(pipe, ptr, task, RENDERER_TEXT)

    return out
end

# =========================================================================================
"""
    tess_pipeline_text(
        func::Function,
        pipe::TessPipeline
    )::Union{TessOutput, Nothing}

Generate a text file from the pipeline and pass it back to the client via a callback.
Returns `false` if there is a problem adding the text generator to the output.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | func |         | The function to call with the lines of text.
| R | pipe |         | The pipline to collect the text from.

__Details:__

The text will be passed to the caller one line at a time. The "\\n" line terminator will be
included with the text.

Tesseract inserts a "page separator" between pages, by default this value is "\\f", however
it can be changed with [`tess_set_param`](@ref).  If you want to use different text
to separate the pages you must set the value before calling this function.

__Examples:__

```jldoctest
using Tesseract

# Generate some pages to load.
write("page01.tiff", sample_tiff())
write("page02.tiff", sample_tiff())
write("page03.tiff", sample_tiff())

download_languages() # Make sure we have the data files.

instance = TessInst()
pipeline = TessPipeline(instance)

count = 0
tess_pipeline_text(pipeline) do line
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

No one would have believed in the last years of the

the nineteenth century that this world was being watched
watched keenly and closely by intelligences greater than
than man’s and yet as mortal as his own; that as men busied
busied themselves about their various concerns they were
were scrutinised and studied, perhaps almost as narrowly as
as a man with a microscope might scrutinise the transient
transient creatures that swarm and multiply in a drop of

true
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_alto`](@ref),
          [`tess_pipeline_hocr`](@ref), [`tess_pipeline_pdf`](@ref)
          [`tess_pipeline_tsv`](@ref)
"""
function tess_pipeline_text(
            func::Function,
            pipe::TessPipeline
        )::Bool
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_text(
        joinpath(path, "output")
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return false
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local separator = tess_get_param(pipe.inst, "page_separator", String)
    local task      = pipeline_start_task(path, "output.txt", func, separator)

    pipeline_add_renderer(pipe, ptr, task, RENDERER_TEXT)

    return true
end
