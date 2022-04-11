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
    unlv_copy(
        pipe::TessPipeline,
        filename::AbstractString
    )::Bool

Generate a UNLV test file from the pipeline and save it to the specified file.  Returns
`false` if there is a problem adding the UNLV generator to the output.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | pipe     |         | The pipline to collect the UNLV text from.
| R | filename |         | The file to write the UNLV text to.

__Details:__

If the file exists it will be overwritten. The file will be in the Latin-1 encoding which
is what Tesseract generates by default.
"""
function unlv_copy(
            pipe::TessPipeline,
            filename::AbstractString,
        )
    local dir         = dirname(filename)
    local tmpfile, io = mktemp(dir;cleanup=false); close(io)
    local tmpname     = basename(tmpfile)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_unlv(tmpfile)

    rm(tmpfile)

    if ptr == C_NULL
        return false
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local task = pipeline_start_task(
        joinpath(dir, "$(tmpname).unlv"),
        filename
    )

    pipeline_add_renderer(pipe, ptr, task, RENDERER_UNLV)

    return true
end

# =========================================================================================
"""
    unlv_transcode(
        pipe::TessPipeline,
        filename::AbstractString
    )::Bool

Generate a UNLV test file from the pipeline and save it to the specified file.  Returns
`false` if there is a problem adding the UNLV generator to the output.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | pipe     |         | The pipline to collect the UNLV text from.
| R | filename |         | The file to write the UNLV text to.

__Details:__

If the file exists it will be overwritten. This will transcode the file into UTF-8 to match
the rest of Julia.
"""
function unlv_transcode(
            pipe::TessPipeline,
            filename::AbstractString,
        )
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_unlv(
        joinpath(path, "output")
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return false
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local task = pipeline_start_task(path, "output.unlv", filename)

    pipeline_add_renderer(pipe, ptr, task, RENDERER_UNLV)

    return true
end

# =========================================================================================
"""
    tess_pipeline_unlv(
        pipe::TessPipeline,
        filename::AbstractString,
        utf8::Bool = true
    )::Bool

Generate a UNLV test file from the pipeline and save it to the specified file.  Returns
`false` if there is a problem adding the UNLV generator to the output.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | pipe     |         | The pipline to collect the UNLV text from.
| R | filename |         | The file to write the UNLV text to.
| O | utf8     | `true`  | Should the output be transcoded to UTF-8?

__Details:__

If the file exists it will be overwritten.  The Tesseract library outputs a file in Latin-1
encoding (even through all other formats are UTF-8).  We can use Julia to convert the file
into UTF-8 to match the other encodings if desired.

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

tess_pipeline_unlv(pipeline, "My Book.unlv")

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

for line in readlines("My Book.unlv")[1:10]
    println(line)
end

# output

No one would have believed in the last years of the
the nineteenth century that this world was being watched
watched keenly and closely by intelligences greater than
than man's and yet as mortal as his own; that as men busied
busied themselves about their various concerns they were
were scrutinised and studied, perhaps almost as narrowly as
as a man with a microscope might scrutinise the transient
transient creatures that swarm and multiply in a drop of
of water. With infinite complacency men went to and fro over
over this globe about their little affairs, serene in their
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_word_box`](@ref),
          [`tess_pipeline_lstm_box`](@ref), [`tess_pipeline_unlv_latin1`](@ref)
"""
function tess_pipeline_unlv(
            pipe::TessPipeline,
            filename::AbstractString,
            utf8::Bool = true
        )::Bool
    local result = false

    if utf8 == true
        result = unlv_transcode(pipe, filename)
    else
        result = unlv_copy(pipe, filename)
    end

    return result
end

# =========================================================================================
"""
    tess_pipeline_unlv(
        pipe::TessPipeline
    )::Union{TessOutput{String}, Nothing}

Generate an UNLV file from the pipeline and save it to a string.  Returns `nothing` if
there is a problem adding the UNLV generator to the output.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | pipe |         | The pipline to collect the UNLV text from.

__Details:__

The Tesseract generates Latin-1 text however this function will transcode it to UTF-8 to
interact with Julia correctly.

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

book = tess_pipeline_unlv(pipeline)

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

for line in split(book[], "\\n")[1:10]
    println(line)
end

# output

No one would have believed in the last years of the
the nineteenth century that this world was being watched
watched keenly and closely by intelligences greater than
than man's and yet as mortal as his own; that as men busied
busied themselves about their various concerns they were
were scrutinised and studied, perhaps almost as narrowly as
as a man with a microscope might scrutinise the transient
transient creatures that swarm and multiply in a drop of
of water. With infinite complacency men went to and fro over
over this globe about their little affairs, serene in their
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_word_box`](@ref),
          [`tess_pipeline_lstm_box`](@ref), [`tess_pipeline_unlv_latin1`](@ref)
"""
function tess_pipeline_unlv(
            pipe::TessPipeline
        )::Union{TessOutput{String}, Nothing}
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_unlv(
        joinpath(path, "output")
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return nothing
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local out = TessOutput(String)
    local task = pipeline_start_task(path, "output.unlv", out, true)

    pipeline_add_renderer(pipe, ptr, task, RENDERER_UNLV)

    return out
end

# =========================================================================================
"""
    tess_pipeline_unlv_latin1(
        pipe::TessPipeline
    )::Union{TessOutput{Vector{UInt8}}, Nothing}

Generate an UNLV file from the pipeline and save it to a byte array.  Returns `nothing` if
there is a problem adding the UNLV generator to the output.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | pipe |         | The pipline to collect the UNLV text from.

__Details:__

The returned bytes will be in Latin-1 encoding, so a conversion would be required before
using the bytes as a string in Julia.  [`tess_pipeline_unlv`](@ref) will provide you with
the same data but already encoded in UTF-8 for Julia.

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

bytes = tess_pipeline_unlv_latin1(pipeline)

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

println(string("Book generated: ", length(bytes[]), " bytes."))

# output

Book generated: 4410 bytes.
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_word_box`](@ref),
          [`tess_pipeline_lstm_box`](@ref), [`tess_pipeline_unlv`](@ref)
"""
function tess_pipeline_unlv_latin1(
            pipe::TessPipeline
        )::Union{TessOutput{Vector{UInt8}}, Nothing}
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_unlv(
        joinpath(path, "output")
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return nothing
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local out = TessOutput(Vector{UInt8})
    local task = pipeline_start_task(path, "output.unlv", out)

    pipeline_add_renderer(pipe, ptr, task, RENDERER_UNLV)

    return out
end

# =========================================================================================
"""
    tess_pipeline_unlv(
        func::Function,
        pipe::TessPipeline
    )::Bool

Generate an UNLV file from the pipeline and pass it back to the client via a callback.
Returns `false` if there is a problem adding the UNLV generator to the output.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | func |         | The function to call with the lines of text.
| R | pipe |         | The pipline to collect the text from.

__Details:__

The text will be passed to the caller one line at a time. The "\\n" line terminator will be
included with the text.  Tesseract generates UNLV text in Latin-1, this method will
transcode it to UTF-8 to work with Julia.

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
tess_pipeline_unlv(pipeline) do line
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
than man's and yet as mortal as his own; that as men busied
busied themselves about their various concerns they were
were scrutinised and studied, perhaps almost as narrowly as
as a man with a microscope might scrutinise the transient
transient creatures that swarm and multiply in a drop of
of water. With infinite complacency men went to and fro over
over this globe about their little affairs, serene in their
true
```

See also: [`tess_run_pipeline`](@ref), [`tess_pipeline_word_box`](@ref),
          [`tess_pipeline_lstm_box`](@ref), [`tess_pipeline_unlv_latin1`](@ref)
"""
function tess_pipeline_unlv(
            func::Function,
            pipe::TessPipeline
        )::Bool
    local path = mktempdir(;cleanup=false)

    # -------------------------------------------------------------------------------------
    # Create the text renderer.
    local ptr = pipeline_create_unlv(
        joinpath(path, "output")
    )

    if ptr == C_NULL
        rm(path;recursive = true)
        return false
    end

    # -------------------------------------------------------------------------------------
    # Create the task to generate the output string.
    local task = pipeline_start_task(path, "output.unlv", func, "", true)

    pipeline_add_renderer(pipe, ptr, task, RENDERER_UNLV)

    return true
end
