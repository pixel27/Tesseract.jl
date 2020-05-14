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
    tess_pipeline_tsv(
        pipe::TessPipeline,
        filename::AbstractString
    )::Bool

Generate a tsv file from the pipeline and save it to the specified file.  Returns `false`
if there is a problem adding the tsv generator to the output.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | pipe     |         | The pipline to collect the tsv from.
| R | filename |         | The file to write the tsv to.

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

tess_pipeline_tsv(pipeline, "My Book.tsv")

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

for line in readlines("My Book.tsv")[1:10]
    println(line)
end

# output

level page_num    block_num   par_num line_num    word_num    left    top width   height  conf    text
1 1   0   0   0   0   0   0   500 600 -1
2 1   1   0   0   0   10  9   479 514 -1
3 1   1   1   0   0   11  9   406 14  -1
4 1   1   1   1   0   11  9   406 14  -1
5 1   1   1   1   1   11  9   14  11  95  No
5 1   1   1   1   2   35  12  22  8   95  one
5 1   1   1   1   3   66  9   39  11  93  would
5 1   1   1   1   4   115 9   30  11  93  have
5 1   1   1   1   5   155 9   62  11  96  believed
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_alto`](@ref),
          [`tess_pipeline_hocr`](@ref), [`tess_pipeline_pdf`](@ref)
          [`tess_pipeline_text`](@ref)
"""
function tess_pipeline_tsv(
            pipe::TessPipeline,
            filename::AbstractString
        )::Bool
    local dir         = dirname(filename)
    local tmpfile, io = mktemp(dir;cleanup=false); close(io)
    local tmpname     = basename(tmpfile)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_tsv(tmpfile)

    rm(tmpfile)

    if ptr == C_NULL
        return false
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local task = pipeline_start_task(
        joinpath(dir, "$(tmpname).tsv"),
        filename
    )

    pipeline_add_renderer(pipe, ptr, task)

    return true
end

# =========================================================================================
"""
    tess_pipeline_tsv(
        pipe::TessPipeline
    )::Union{TessOutput{String}, Nothing}

Generate a TSV file from the pipeline and save it to a string.  Returns `nothing` if
there is a problem adding the TSV generator to the output.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | pipe  |         | The pipline to collect the TSV data from.

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

book = tess_pipeline_tsv(pipeline)

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
    true
end

for line in split(book[], "\\n")[1:10]
    println(line)
end

# output

level page_num    block_num   par_num line_num    word_num    left    top width   height  conf    text
1 1   0   0   0   0   0   0   500 600 -1
2 1   1   0   0   0   10  9   479 514 -1
3 1   1   1   0   0   11  9   406 14  -1
4 1   1   1   1   0   11  9   406 14  -1
5 1   1   1   1   1   11  9   14  11  95  No
5 1   1   1   1   2   35  12  22  8   95  one
5 1   1   1   1   3   66  9   39  11  93  would
5 1   1   1   1   4   115 9   30  11  93  have
5 1   1   1   1   5   155 9   62  11  96  believed
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_alto`](@ref),
          [`tess_pipeline_hocr`](@ref), [`tess_pipeline_pdf`](@ref)
          [`tess_pipeline_text`](@ref)
"""
function tess_pipeline_tsv(
            pipe::TessPipeline
        )::Union{TessOutput{String}, Nothing}
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_tsv(
        joinpath(path, "output")
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return nothing
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local out = TessOutput(String)
    local task = pipeline_start_task(path, "output.tsv", out)

    pipeline_add_renderer(pipe, ptr, task)

    return out
end

# =========================================================================================
"""
    tess_pipeline_tsv(
        func::Function,
        pipe::TessPipeline
    )::Bool

Generate a TSV file from the pipeline and pass it back to the client via a callback.
Returns `false` if there is a problem adding the TSV generator to the output.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | func  |         | The function to call with the lines of text.
| R | pipe  |         | The pipline to collect the TSV data from.

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
tess_pipeline_tsv(pipeline) do line
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
    true
end

# output

level page_num    block_num   par_num line_num    word_num    left    top width   height  conf    text
1 1   0   0   0   0   0   0   500 600 -1
2 1   1   0   0   0   10  9   479 514 -1
3 1   1   1   0   0   11  9   406 14  -1
4 1   1   1   1   0   11  9   406 14  -1
5 1   1   1   1   1   11  9   14  11  95  No
5 1   1   1   1   2   35  12  22  8   95  one
5 1   1   1   1   3   66  9   39  11  93  would
5 1   1   1   1   4   115 9   30  11  93  have
5 1   1   1   1   5   155 9   62  11  96  believed
true
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_alto`](@ref),
          [`tess_pipeline_hocr`](@ref), [`tess_pipeline_pdf`](@ref)
          [`tess_pipeline_text`](@ref)
"""
function tess_pipeline_tsv(
            func::Function,
            pipe::TessPipeline
        )::Bool
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_tsv(
        joinpath(path, "output")
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return false
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local task = pipeline_start_task(path, "output.tsv", func, "")

    pipeline_add_renderer(pipe, ptr, task)

    return true
end
