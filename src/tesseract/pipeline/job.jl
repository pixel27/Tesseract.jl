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
    struct Job{T<:IO}
        event::Condition
        done::Ref{Bool}
        file::T
        buffer::Vector{UInt8}
    end

Encapsulates all the data needed to execute a task that reads the output from Tesseract and
provides it to the Julia application.

__Values:__

| Name   | Description
| :----- | :----------
| event  | The event that gets set when there is more data or the done flag is set.
| done   | The flag that indicates when the tesseract process has finished.
| file   | The file that is being populated by tesseract.
| buffer | The buffer to reuse when reading the data from the file.

__Constructors:__

    Job(event, done, file)

Create a new instance of the object.  The buffer is initialized to the size used by the
reader.
"""
struct Job{T<:IO}
    event::Condition
    done::Ref{Bool}
    file::T
    buffer::Vector{UInt8}
    Job(event::Condition, done::Ref{Bool}, file::T) where T = new{T}(event, done, file, Vector{UInt8}(undef, 4096))
end

# =========================================================================================
"""
    start_job(
        processor::Function,
        event::Condition,
        done::Ref{Bool},
        path::AbstractString,
        filename::AbstractString,
        transcode::Bool = false
    )::Task

Create a job and start a task to execute it.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | processor |         | The function to call on the task to process the job.
| R | event     |         | The event that will be signalled when there is data.
| R | done      |         | The flag that indicates the job is done.
| R | path      |         | The directory created for the job.
| R | filename  |         | The name of the file Tesseract will be writing to.
| O | transcode | `false` | Should the input stream be converted into UTF8 from Latin-1?
"""
function start_job(
            processor::Function,
            event::Condition,
            done::Ref{Bool},
            path::AbstractString,
            filename::AbstractString,
            transcode::Bool = false
        )::Task
    local file = open(joinpath(path, filename); read = true)
    local job

    if transcode == true
        job = Job(event, done, Latin1(file))
    else
        job = Job(event, done, file)
    end

    return @async begin
        try
            # -----------------------------------------------------------------------------
            # Run the task.
            processor(job)
        finally
            # -----------------------------------------------------------------------------
            # Make sure everything is cleaned up.
            isopen(file) && close(file)
            ispath(path) && rm(path; recursive = true)
        end
    end
end

# =========================================================================================
"""
    job_read(
        j::Job
    )::Bool

Read data from the file, waiting if there is no data to read.  If there is no more data
and the job is done returns `false`.

__Arguments:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | j    |            | The job to read the data for.
"""
function job_read(
            j::Job
        )::Bool
    # -------------------------------------------------------------------------------------
    # Make sure the buffer is correctly sized.
    resize!(j.buffer, 4096)

    # -------------------------------------------------------------------------------------
    # Repeat while we've read nothing.
    local read = 0

    while read == 0

        # ---------------------------------------------------------------------------------
        # Read any available bytes.
        read = readbytes!(j.file, j.buffer)

        # ---------------------------------------------------------------------------------
        # If no bytes where read and the task is done, return false.
        if read == 0 && j.done[] == true
            return false
        end

        # ---------------------------------------------------------------------------------
        # If we're read nothing, wait for the event to trigger before we try again.
        if read == 0
            wait(j.event)
        end

    end

    # ---------------------------------------------------------------------------------
    # Resize the buffer down to the bytes read.
    resize!(j.buffer, read)
    return true
end

# =========================================================================================
"""
    job_create_byte_array(
        j::Job,
        out::TessOutput{Vector{UInt8}}
    )::Nothing

Read the file specified by the job and convert the whole file into a byte array.

__Arguments:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | j    |            | The job this function is being called for.
| R | out  |            | The object to pass the byte array to.
"""
function job_create_byte_array(
            j::Job,
            out::TessOutput{Vector{UInt8}}
        )::Nothing
    local data = Vector{UInt8}()

    while job_read(j) == true
        append!(data, j.buffer)
    end

    out.result = data

    nothing
end

# =========================================================================================
"""
    job_create_string(
        j::Job,
        out::TessOutput{String}
    )::Nothing

Read the file specified by the job and convert the whole file into a string.

__Arguments:__

| T | Name | Default    | Description
|:--| :--- | :--------- | :----------
| R | j    |            | The job this function is being called for.
| R | out  |            | The object to pass the string to.
"""
function job_create_string(
            j::Job,
            out::TessOutput{String}
        )::Nothing
    local data = Vector{UInt8}()

    while job_read(j) == true
        append!(data, j.buffer)
    end

    out.result = String(data)

    nothing
end

# =========================================================================================
"""
    job_dispatch(
        j::Job,
        dispatch::Function,
        separator::String
    )::Nothing

Read the file specified by the job, break the file into lines and call the dispatch
function so they can be processed.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | j         |         | The job this function is being called for.
| R | dispatch  |         | The function to pass the lines to.
| R | separator |         | The string that Tesseract will be using to separate pages.
"""
function job_dispatch(
            j::Job,
            dispatch::Function,
            separator::String
        )::Nothing
    local sepbytes = Vector{UInt8}(separator)
    local seplen   = length(separator) + 1
    local line = Vector{UInt8}()

    function page_separator(arr)::Bool

        if length(sepbytes) == 0 || length(arr) < length(sepbytes)
            return false
        end
        for i in 1:length(sepbytes)
            @inbounds if sepbytes[i] != arr[i]
                return false
            end
        end
        return true
    end

    function notify(arr)
        if page_separator(arr)
            dispatch(separator)
            if length(arr) >= seplen
                dispatch(String(arr[seplen:length(arr)]))
            end
        else
            dispatch(String(arr))
        end
    end

    # -------------------------------------------------------------------------------------
    # Read the text and process it.
    while job_read(j) == true
        local s = 1

        # ---------------------------------------------------------------------------------
        # Walk the buffer and extract all the lines to pass to the notify function.
        for (i, v) in enumerate(j.buffer)
            if v == 0x0a && length(line) > 0
                append!(line, view(j.buffer, s:i))
                notify(line)
                s = i + 1
            elseif v == 0x0a
                notify(j.buffer[s:i])
                s = i + 1
            end
        end

        # ---------------------------------------------------------------------------------
        # Copy the remainder of the buffer to the line.
        if s <= length(j.buffer)
            append!(line, view(j.buffer, s:length(j.buffer)))
        end
    end

    # -------------------------------------------------------------------------------------
    # Tell the client about the last line.
    if length(line) > 0
        notify(line)
    end

    nothing
end

# =========================================================================================
"""
    job_copy(
        j::Job,
        output::IO
    )::Nothing

Read the contents of the file specified by the job and write it the output file.

__Arguments:__

| T | Name   | Default | Description
|:--| :----- | :------ | :----------
| R | j      |         | The job this function is being called for.
| R | output |         | The function to pass the lines to.

__Details:__

This method is currently used for transcoding the output from from one encoding to another.
"""
function job_copy(
            j::Job,
            output::IO
        )::Nothing
    # -------------------------------------------------------------------------------------
    # Read the text and process it.
    while job_read(j) == true
        write(output, j.buffer)
    end

    nothing
end
