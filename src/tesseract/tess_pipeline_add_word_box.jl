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
    tess_pipeline_word_box(
        pipe::TessPipeline,
        filename::AbstractString
    )::Bool

Generate a BOX file from the pipeline and save it to the specified file.  Returns `false`
if there is a problem adding the BOX generator to the output.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | pipe     |         | The pipline to collect the BOX from.
| R | filename |         | The file to write the BOX to.

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

tess_pipeline_word_box(pipeline, "My Book.box")

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

for line in readlines("My Book.box")[1:10]
    println(line)
end

# output

WordStr 11 577 417 591 0 #No one would have believed in the last years of the
   418 577 422 591 0
WordStr 11 557 457 571 0 #the nineteenth century that this world was being watched
   458 557 462 571 0
WordStr 10 537 457 551 0 #watched keenly and closely by intelligences greater than
   458 537 462 551 0
WordStr 11 517 481 531 0 #than man’s and yet as mortal as his own; that as men busied
   482 517 486 531 0
WordStr 11 497 457 511 0 #busied themselves about their various concerns they were
   458 497 462 511 0
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_unlv`](@ref),
          [`tess_pipeline_lstm_box`](@ref)
"""
function tess_pipeline_word_box(
            pipe::TessPipeline,
            filename::AbstractString
        )::Bool
    local dir         = dirname(filename)
    local tmpfile, io = mktemp(dir;cleanup=false); close(io)
    local tmpname     = basename(tmpfile)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_word_box(tmpfile)

    rm(tmpfile)

    if ptr == C_NULL
        return false
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local task = pipeline_start_task(
        joinpath(dir, "$(tmpname).box"),
        filename
    )

    pipeline_add_renderer(pipe, ptr, task)

    return true
end

# =========================================================================================
"""
    tess_pipeline_word_box(
        pipe::TessPipeline
    )::Union{TessOutput{String}, Nothing}

Generate a BOX file from the pipeline and save it to a string.  Returns `nothing` if
there is a problem adding the BOX generator to the output.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | pipe  |         | The pipline to collect the BOX data from.

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

book = tess_pipeline_word_box(pipeline)

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

for line in split(book[], "\\n")[1:10]
    println(line)
end

# output

WordStr 11 577 417 591 0 #No one would have believed in the last years of the
   418 577 422 591 0
WordStr 11 557 457 571 0 #the nineteenth century that this world was being watched
   458 557 462 571 0
WordStr 10 537 457 551 0 #watched keenly and closely by intelligences greater than
   458 537 462 551 0
WordStr 11 517 481 531 0 #than man’s and yet as mortal as his own; that as men busied
   482 517 486 531 0
WordStr 11 497 457 511 0 #busied themselves about their various concerns they were
   458 497 462 511 0
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_unlv`](@ref),
          [`tess_pipeline_lstm_box`](@ref)
"""
function tess_pipeline_word_box(
            pipe::TessPipeline
        )::Union{TessOutput{String}, Nothing}
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_word_box(
        joinpath(path, "output")
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return nothing
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local out = TessOutput(String)
    local task = pipeline_start_task(path, "output.box", out)

    pipeline_add_renderer(pipe, ptr, task)

    return out
end

# =========================================================================================
"""
    tess_pipeline_word_box(
        func::Function,
        pipe::TessPipeline
    )::Bool

Generate a BOX file from the pipeline and pass it back to the client via a callback.
Returns `false` if there is a problem adding the BOX generator to the output.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | func  |         | The function to call with the lines of text.
| R | pipe  |         | The pipline to collect the BOX data from.

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
tess_pipeline_word_box(pipeline) do line
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

WordStr 11 577 417 591 0 #No one would have believed in the last years of the
   418 577 422 591 0
WordStr 11 557 457 571 0 #the nineteenth century that this world was being watched
   458 557 462 571 0
WordStr 10 537 457 551 0 #watched keenly and closely by intelligences greater than
   458 537 462 551 0
WordStr 11 517 481 531 0 #than man’s and yet as mortal as his own; that as men busied
   482 517 486 531 0
WordStr 11 497 457 511 0 #busied themselves about their various concerns they were
   458 497 462 511 0
true
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_unlv`](@ref),
          [`tess_pipeline_lstm_box`](@ref)
"""
function tess_pipeline_word_box(
            func::Function,
            pipe::TessPipeline
        )::Bool
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_word_box(
        joinpath(path, "output")
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return false
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local task = pipeline_start_task(path, "output.box", func, "")

    pipeline_add_renderer(pipe, ptr, task)

    return true
end
