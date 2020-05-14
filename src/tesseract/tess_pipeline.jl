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
    mutable struct TessPipeline
        inst::TessInst
        ptr::Ptr{Cvoid}
        tasks::Vector{PipelineTask}
    end

Allows the client to process multiple images in sequence.

__Values:__

| Name   | Description
| :----- | :----------
| inst   | The TessInst that will be processing the images.
| ptr    | The Tesseract pipeline that will be outputing the data.
| task   | The list of background tasks associated with pipeline.

See also: [`tess_run_pipeline`](@ref)
"""
mutable struct TessPipeline
    inst::TessInst
    ptr::Ptr{Cvoid}
    tasks::Vector{PipelineTask}
end

# =========================================================================================
"""
    TessPipeline(
        inst::TessInst
    )

Construct a new instance of the object.  Registers a finalizer to clean up allocated
resources.

| Name   | Description
| :----- | :----------
| inst   | The TessInst that will be processing the images.

See also: [`tess_run_pipeline`](@ref)
"""
function TessPipeline(
            inst::TessInst
        )
    local retval = TessPipeline(inst, C_NULL, Vector{PipelineTask}())

    finalizer(retval) do obj
        tess_delete!(obj, false)
    end

    return retval
end

# =========================================================================================
"""
    show(
        io::IO,
        inst::TessPipeline
    )::Nothing

Display summary information about the `TessPipeline` instance.

__Arguments:__

| T | Name  | Default | Description
|---| :---- | :------ | :----------
| R | io    |         | The stream to write the information to.
| R | inst  |         | The `TessPipeline` instance to display info about.
"""
function Base.show(
            io::IO,
            inst::TessPipeline
        )::Nothing
    if inst.ptr == C_NULL
        print(io, "Pipeline is empty.")
    else
        print(io, "Pipeline is populated.")
    end
    nothing
end

# =========================================================================================
"""
    unsafe_convert(
        ::Type{Ptr{Cvoid}},
        p::TessPipeline
    )

Retreieve a pointer to the Tesseract pipeline we are using.

__Arguments:__

| T | Name               | Default  | Description
|:--| :----------------- | :------- | :----------
| R | ::Type{Ptr{Cvoid}} |          | The type we "convert" the object to.
| R | p                  |          | The pipeline we are converting.
"""
Base.unsafe_convert(::Type{Ptr{Cvoid}}, p::TessPipeline) = p.ptr

# =========================================================================================
"""
    tess_delete!(
        pipe::TessPipeline,
        wait::Bool = true
    )

Release all resources associated with the pipeline.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | pipe |         | The pipeline to release.
| O | wait | `true`  | Wait for the tasks to complete?

See also: [`TessPipeline`](@ref)
"""
function tess_delete!(
            pipe::TessPipeline,
            wait::Bool = true
        )
    if pipe.ptr != C_NULL
        ccall(
            (:TessDeleteResultRenderer, TESSERACT),
            Cvoid,
            (Ptr{Cvoid},),
            pipe
        )
        pipe.ptr = C_NULL

        for task in pipe.tasks
            pipeline_stop_task(task, wait)
        end
        resize!(pipe.tasks, 0)
    end
end

# =========================================================================================
"""
    pipeline_add_renderer(
        pipe::TessPipeline,
        ptr::Ptr{Cvoid},
        task::PipelineTask
    )

Add a renderer to the pipeline.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | pipe |         | The pipeline to add the renderer to.
| R | ptr  |         | The Tesseract renderer to add.
| R | task |         | The task that processes the results from the renderer.

__Details:__

This method actually inserts the renderer at the front of the pipeline.  The pipeline is
really a series of independant extractors so the order doesn't matter.
"""
function pipeline_add_renderer(
            pipe::TessPipeline,
            ptr::Ptr{Cvoid},
            task::PipelineTask
        )::Nothing

    # ---------------------------------------------------------------------------------------------
    # If we have a current renderer, add it AFTER this new renderer.
    if pipe.ptr != C_NULL
        ccall(
            (:TessResultRendererInsert, TESSERACT),
            Cvoid,
            (Ptr{Cvoid}, Ptr{Cvoid}),
            ptr,
            pipe.ptr
        )
    end

    # ---------------------------------------------------------------------------------------------
    # Save the pointer in our structure.
    pipe.ptr = ptr

    # ---------------------------------------------------------------------------------------------
    # Add the task to the end of our list.
    push!(pipe.tasks, task)

    nothing
end

# =========================================================================================
"""
    pipeline_add_image(
        pipe::TessPipeline,
        inst::TessInst
    )

Push the currently recognized image out to the renderers in the pipeline.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | pipe |         | The pipeline to push the recognized image to.
| R | inst |         | The tesseract image to pull the text from.

__Details:__

`tess_recognize` must be called before this method is called so the renderers can pick up
the recognized text.
"""
function pipeline_add_image(
            pipe::TessPipeline
        )::Bool

    if pipe.ptr == C_NULL
        @error "Pipline has been freed."
        return false
    end

    if is_valid(pipe.inst) == false
        @error "Instance has been freed."
        return false
    end

    local retval = ccall(
        (:TessResultRendererAddImage, TESSERACT),
        Cint,
        (Ptr{Cvoid}, Ptr{Cvoid}),
        pipe,
        pipe.inst
    )

    return retval == 1
end

# =========================================================================================
"""
    pipeline_start(
        pipe::TessPipeline,
        title::AbstractString
    )::Bool

Notifies the pipeline that we are starting, allowing the renderers to write out header
information before the content.  Returns `false` if Tesseract reports an error.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | pipe  |         | The pipeline to start.
| R | title |         | An optional title for the document.
"""
function pipeline_start(
            pipe::TessPipeline,
            title::AbstractString
        )::Bool

    if pipe.ptr == C_NULL
        @warn "Pipeline has no renderers."
        return false
    end

    local result = @threadcall(
        (:TessResultRendererBeginDocument, TESSERACT),
        Cint,
        (Ptr{Cvoid}, Cstring),
        pipe,
        title
    );

    return result == 1
end

# =========================================================================================
"""
    pipeline_finish(
        pipe::TessPipeline
    )::Bool

Tell the renders to write out any footer information they want at the end of the document.
Returns `false` if Tesseract reports an error.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | pipe  |         | The pipeline to complete.
"""
function pipeline_finish(
            pipe::TessPipeline
        )::Bool
    local retval = false

    if pipe.ptr == C_NULL
        @warn "Pipeline has no renderers."
        return false
    end

    local result = @threadcall(
        (:TessResultRendererEndDocument, TESSERACT),
        Cint,
        (Ptr{Cvoid},),
        pipe
    )

    return result == 1
end

# =========================================================================================
"""
    tess_run_pipeline(
        func::Function,
        pipe::TessPipeline,
        title::AbstractString = ""
    )::Bool

Run the pipeline against a series of images.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | func  |         | The callback to call for the images.
| R | pipe  |         | The pipline we're going to execute.
| O | title | `""`    | Optional title for the document.

__Details:__

This is the primary function of the `TessPipeline` object.  This method is used to combine
output from multiple images into a single document (or multiple documents of different
types).

The argument passed back to the function is a method with the form:

    function add(Pix, Integer)::Bool

The client calls this method with the image and pixels per inch of the image.  The image
will be processed immediately and added to the pipeline's output.

If you the callback returns false then the `tess_run_pipeline()` will return `false`.  If it
doesn't return a boolean or returns `true` then `tess_run_pipeline()` returns `true`
assuming there are no other errors.

This method can only be used "once".  After it's called new output needs to be added to the
pipeline if you want to reuse the [`TessPipeline`](@ref) object.

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

for line in split(book[], "\\n")[1:10]
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

See also: [`TessPipeline`](@ref), [`tess_pipeline_text`](@ref)
"""
function tess_run_pipeline(
            func::Function,
            pipe::TessPipeline,
            title::AbstractString = ""
        )::Bool
    local result = true

    # -------------------------------------------------------------------------------------
    # Make sure there is somethign to do.
    if pipe.ptr == C_NULL
        @error "No renderers attached to the pipeline."
        return false
    end

    # ---------------------------------------------------------------------------------
    # Allow the renderers to write out a header.
    if pipeline_start(pipe, title) == false
        tess_delete!(pipe)
        return false
    end

    try
        # ---------------------------------------------------------------------------------
        # This function si called by the client to process an image.
        function process(
                    pix::Pix,
                    res::Integer
                )::Bool
            # -----------------------------------------------------------------------------
            # Set the image.
            tess_image(pipe.inst, pix)
            tess_resolution(pipe.inst, res)

            # -----------------------------------------------------------------------------
            # Look for text.
            if tess_recognize(pipe.inst) == false
                result = false
                return false
            end

            # -----------------------------------------------------------------------------
            # Allow the renderers to process the new text.
            if pipeline_add_image(pipe) == false
                result = false
                return false
            end

            # -----------------------------------------------------------------------------
            # Notify the tasks that there is probably new data to read.
            for task in pipe.tasks
                notify(task.event)
            end

            return true
        end

        # ---------------------------------------------------------------------------------
        # Call the client to provide all the images for processing.
        local retval = func(process)

        if isa(retval, Bool) && retval == false
            result = false
        end

    finally

        # ---------------------------------------------------------------------------------
        # Allow the renderers to finish the documents.
        if pipeline_finish(pipe) == false
            result = false
        end

        # ---------------------------------------------------------------------------------
        # Delete the renderers so they finish writing out their data.
        tess_delete!(pipe)
    end

    return result
end

# =========================================================================================
"""
    tess_run_pipeline(
        pipe::TessPipeline,
        filename::AbstractString;
        retryConfig::AbstractString = "",
        timeout::Integer = Int32(0)
    )::Bool

Run the pipline against a file that contains the list of images to process or a TIFF
file with multiple images.  Returns `false` if the process fails.

__Arguments:__

| T | Name        | Default | Description
|:--| :---------- | :--------- | :----------
| R | pipe        |            | The pipline we're going to execute.
| R | filename    |            | The name of the file to read.
| K | retryConfig | `""`       | A configuration file to load if an image cannot be processed.
| K | timeout     | `Int32(0)` | The maximum time in milliseconds to spend per page.

__Details:__

This method provides a simplified version of the `tess_run_pipeline` function.  This
uses method exposed by the Tesseract library to process a list of files or a single
TIFF file without additional input.

This method can only be used "once".  After it's called new output needs to be added to the
pipeline if you want to reuse the [`TessPipeline`](@ref) object.

__Examples:__

Providing a file with a list of images to process:

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

# Create a text file with the files to process.
open("pages.lst", create = true, write = true) do io
    println(io, "page01.tiff")
    println(io, "page02.tiff")
    println(io, "page03.tiff")
end

tess_run_pipeline(pipeline, "pages.lst")

for line in split(book[], "\\n")[1:10]
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

Using a multipage TIFF:

```jldoctest
using Tesseract

# Generate some pages to load.
pix_write_tiff("book.tiff", sample_pix())
pix_write_tiff("book.tiff", sample_pix(); append = true)
pix_write_tiff("book.tiff", sample_pix(); append = true)

download_languages() # Make sure we have the data files.

instance = TessInst()
pipeline = TessPipeline(instance)

book = tess_pipeline_text(pipeline)

tess_run_pipeline(pipeline, "book.tiff")

for line in split(book[], "\\n")[1:10]
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

See also: [`TessPipeline`](@ref), [`tess_pipeline_text`](@ref)
"""
function tess_run_pipeline(
            pipe::TessPipeline,
            filename::AbstractString;
            retryConfig::AbstractString = "",
            timeout::Integer = Int32(0)
        )::Bool
    local result = true

    # -------------------------------------------------------------------------------------
    # Make sure there is something to do.
    if pipe.ptr == C_NULL
        @error "No renderers attached to the pipeline."
        return false
    end

    # -------------------------------------------------------------------------------------
    # Make sure the instanc is still valid.
    if is_valid(pipe.inst) == false
        @error "Instance has been freed."
        return false
    end

    # -------------------------------------------------------------------------------------
    # Make sure the file name is provided.
    if filename == ""
        @error "No filename provided."
        return false
    end

    # -------------------------------------------------------------------------------------
    # Make the call.
    local retval = ccall(
        (:TessBaseAPIProcessPages, TESSERACT),
        Cint,
        (Ptr{Cvoid}, Cstring, Cstring, Cint, Ptr{Cvoid}),
        pipe.inst,
        filename,
        isempty(retryConfig) ? C_NULL : retryConfig,
        timeout,
        pipe
    )

    # ---------------------------------------------------------------------------------
    # Delete the renderers so they finish writing out their data.
    tess_delete!(pipe)

    return result
end
