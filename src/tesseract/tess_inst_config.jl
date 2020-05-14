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

# =================================================================================================
"""
    tess_init(
        inst::TessInst,
        languages::AbstractString = "eng",
        dataPath::AbstractString = "tessdata"
    )::Bool

Initialize the instance for the specified language(s).  Returns `false` if there was an error.

__Arguments:__

| T | Name      | Default    | Description
|:--| :-------- | :--------- | :----------
| R | inst      |            | The instance to initialize.
| O | languages | `eng`      | The language(s) to load.
| O | dataPath  | `tessdata` | The directory to look for the language files in.

__Details:__

This method can be called multiple times to reinitialize the langauges to OCR with.  Multiple
langagues can be specified by seperating them with a plus.  So if you want english and spanish you
could specify "eng+spa".  The language codes are (usually) the
[ISO 639-3](https://en.wikipedia.org/wiki/ISO_639-3) code.

Note: The language files are NOT automatically downloaded.  If you do not have them installed via
alternate means you can download them from https://github.com/tesseract-ocr/tessdata_best.

__Example:__

```jldoctest
julia> using Tesseract

julia> download_languages("eng+spa")
true

julia> instance = TessInst()
Allocated Tesseract instance.

julia> tess_init(instance, "spa")
true
```

See also: [`TessInst()`](@ref)
"""
function tess_init(
            inst::TessInst,
            languages::AbstractString = "eng",
            dataPath::AbstractString = TESS_DATA
        )::Bool
    local result = -1

    if is_valid(inst) == false
        @error "Instance has been freed."
        return false
    end

    if isempty(dataPath) && isempty(languages)
        result = ccall(
            (:TessBaseAPIInit3, TESSERACT),
            Cint,
            (Ptr{Cvoid}, Cstring, Cstring),
            inst,
            C_NULL,
            C_NULL
        )
    elseif isempty(languages)
        result = ccall(
            (:TessBaseAPIInit3, TESSERACT),
            Cint,
            (Ptr{Cvoid},Cstring,Cstring),
            inst,
            dataPath,
            C_NULL
        )
    elseif isempty(dataPath)
        result = ccall(
            (:TessBaseAPIInit3, TESSERACT),
            Cint,
            (Ptr{Cvoid},Cstring,Cstring),
            inst,
            C_NULL,
            languages
        )
    else
        result = ccall(
            (:TessBaseAPIInit3, TESSERACT),
            Cint,
            (Ptr{Cvoid},Cstring,Cstring),
            inst,
            dataPath,
            languages
        )
    end

    return result == 0
end

# =================================================================================================
"""
    tess_initialized_languages(
        inst::TessInst
    )::Union{String, Nothing}

Retrieve the last initialized language(s).  Returns `nothing` if there was an error.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | inst     |         | The instance to get the languages from.

__Details:__

This method returns the language string provided in the last `tess_init()` call.

__Example:__

```jldoctest
julia> using Tesseract

julia> download_languages("eng+fra")
true

julia> instance = TessInst("eng+fra")
Allocated Tesseract instance.

julia> tess_initialized_languages(instance)
"eng+fra"
```

See also: [`tess_init`](@ref)
"""
function tess_initialized_languages(
            inst::TessInst
        )::Union{String, Nothing}

    # ---------------------------------------------------------------------------------------------
    # Make sure the Tess object is not freed.
    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Call the C library.
    local retval = ccall(
        (:TessBaseAPIGetInitLanguagesAsString, TESSERACT),
        Cstring,
        (Ptr{Cvoid}, ),
        inst
    )

    # ---------------------------------------------------------------------------------------------
    # Nothing was returned.
    if retval == C_NULL
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Copy the string into Julia, DON'T free it.
    return unsafe_string(retval)
end

# =================================================================================================
"""
    tess_loaded_languages(
        inst::TessInst
    )::Union{Vector{String}, Nothing}

Get the the list of languages loaded into the OCR engine.  Returns `nothing` if there was an error.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | inst     |         | The instance to get the languages from.

__Details:__

This method returns the language loaded into the Tesseract engine.  Some language files will load
additional languages.  Unlike `tess_initialized_languages()` this method will return all the loaded
languages not just the ones it was told to load by the client.

__Example:__

```jldoctest
julia> using Tesseract

julia> download_languages("eng+spa")
true

julia> instance = TessInst("eng+spa")
Allocated Tesseract instance.

julia> tess_loaded_languages(instance)
2-element Array{String,1}:
 "eng"
 "spa"
```

See also: [`tess_init`](@ref)
"""
function tess_loaded_languages(
            inst::TessInst
        )::Union{Vector{String}, Nothing}

    # ---------------------------------------------------------------------------------------------
    # Make sure the Tess object is not freed.
    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Call the C library.
    local languages = ccall(
        (:TessBaseAPIGetLoadedLanguagesAsVector, TESSERACT),
        Ptr{Ptr{UInt8}},
        (Ptr{Cvoid}, ),
        inst
    )

    if languages == C_NULL
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Create the vector.
    local retval = Vector{String}()

    local pos = 1
    while unsafe_load(languages, pos) != C_NULL
        local language = unsafe_load(languages, pos)
        push!(retval, unsafe_string(language))
        pos += 1
    end

    # ---------------------------------------------------------------------------------------------
    # Free the array of strings na dreturn the vector.
    delete_array(languages)

    return retval
end

# =================================================================================================
"""
    tess_available_languages(
        inst::TessInst
    )::Union{Vector{String}, Nothing}

Get the list of available languages that can be loaded.  Returns `nothing` if there was an error.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | inst     |         | The instance to query for the available languages.

__Details:__

Get the list of languages that can be used in the tess_init() function.  This method only returns
something AFTER `tess_init()`` has been called.

__Example:__

```jldoctest
julia> using Tesseract

julia> download_languages("eng+fra+spa")
true

julia> instance = TessInst("eng")
Allocated Tesseract instance.

julia> tess_available_languages(instance)
3-element Array{String,1}:
 "eng"
 "fra"
 "spa"
```

See also: [`tess_init`](@ref), [`update_languages`](@ref), [`download_languages`](@ref)
"""
function tess_available_languages(
            inst::TessInst
        )::Union{Vector{String}, Nothing}

    # ---------------------------------------------------------------------------------------------
    # Make sure the Tess object is not freed.
    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Call the C library.
    local languages = ccall(
        (:TessBaseAPIGetAvailableLanguagesAsVector, TESSERACT),
        Ptr{Ptr{UInt8}},
        (Ptr{Cvoid}, ),
        inst
    )

    if languages == C_NULL
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Create the vector.
    local retval = Vector{String}()
    local pos    = 1

    while unsafe_load(languages, pos) != C_NULL
        local language = unsafe_load(languages, pos)
        push!(retval, unsafe_string(language))
        pos += 1
    end

    # ---------------------------------------------------------------------------------------------
    # Free the array of strings na dreturn the vector.
    delete_array(languages)

    return retval
end

# =========================================================================================
"""
    tess_params(
        inst::TessInst,
        filename::AbstractString
    )::Bool

Print out all the parameters with their values and help text to the specified file.
Returns false if there was an error.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | inst     |         | The Tesseract instance to get get the parameters from.
| R | filename |         | The filename to write to.

__Details:__

For each parameter this method prints out it's name, it's value, and some descriptive text
about the variable.  Each variable is on it's own line with a tab character seperating each
value.

See also: [`tess_params_parsed`](@ref), [`tess_get_param`](@ref), [`tess_set_param`](@ref)
"""
function tess_params(
            inst::TessInst,
            filename::AbstractString
        )::Bool

    # ---------------------------------------------------------------------------------------------
    # Make sure the Tess object is not freed.
    if is_valid(inst) == false
        @error "Instance has been freed."
        return false
    end

    # ---------------------------------------------------------------------------------------------
    # Make the call.
    local retval = ccall(
        (:TessBaseAPIPrintVariablesToFile, TESSERACT),
        Cint,
        (Ptr{Cvoid}, Cstring),
        inst,
        filename
    )

    return retval == 1
end

# =========================================================================================
"""
    tess_params(
        inst::TessInst,
        stream::IO
    )::Bool

Print out all the parameters with their values and help text to the specified stream.
Returns false if there was an error.

__Arguments:__

| T | Name   | Default | Description
|:--| :----- | :------ | :----------
| R | inst   |         | The Tesseract instance to get get the parameters from.
| R | stream |         | The stream to write the files to.

__Details:__

For each parameter this method prints out it's name, it's value, and some descriptive text
about the variable.  Each variable is on it's own line with a tab character seperating each
value.

See also: [`tess_params_parsed`](@ref), [`tess_get_param`](@ref), [`tess_set_param`](@ref)
"""
function tess_params(
            inst::TessInst,
            stream::IO
        )::Bool
    local result = false

    # ---------------------------------------------------------------------------------------------
    # Make sure the Tess object is not freed.
    if is_valid(inst) == false
        @error "Instance has been freed."
        return false
    end

    # ---------------------------------------------------------------------------------------------
    # Create a temporary file to write to.
    local filename, io = mktemp(;cleanup = false)

    try
        close(io)

        if tess_params(inst, filename)
            local data = read(filename)
            write(stream, data)
            result = true
        end
    finally
        rm(filename)
    end

    return result
end

# =========================================================================================
"""
    tess_params(
        inst::TessInst
    )::Union{String, Nothing}

Print out all the parameters with their values and help text to a string.  Returns
`nothing` if there was an error.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | inst |         | The Tesseract instance to get the parameters from.

__Details:__

The return string will contain multiple lines, each line contains the name of a variable,
it's value, and some descriptive text about the variable.  The fields are separated by
tabs.

See also: [`tess_params_parsed`](@ref), [`tess_get_param`](@ref), [`tess_set_param`](@ref)
"""
function tess_params(
            inst::TessInst
        )::Union{String, Nothing}
    local result = nothing

    # ---------------------------------------------------------------------------------------------
    # Make sure the Tess object is not freed.
    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Create a temporary file to write to.
    local filename, io = mktemp(;cleanup = false)

    try
        close(io)

        if tess_params(inst, filename)
            result = read(filename, String)
        end
    finally
        rm(filename)
    end

    return result
end

# =================================================================================================
"""
    tess_read_config(
        inst::TessInst,
        filename::AbstractString
    )::Nothing

Load configuration settings from a file into the Tesseract instance.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | inst     |         | The Tesseract instance to load the settings into.
| R | filename |         | The name of the file to load the settings from.

See also: [`tess_read_debug_config`](@ref)
"""
function tess_read_config(
            inst::TessInst,
            filename::AbstractString
        )::Nothing

    # ---------------------------------------------------------------------------------------------
    # Make sure the Tess object is not freed.
    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Call the C library.
    ccall(
        (:TessBaseAPIReadConfigFile, TESSERACT),
        Cvoid,
        (Ptr{Cvoid}, Cstring),
        inst,
        filename
    )
    nothing
end

# =================================================================================================
"""
    tess_read_debug_config(
        inst::TessInst,
        filename::AbstractString
    )::Nothing

Load debug configuration settings from a file into the Tesseract instance.

__Arguments:__

| T | Name     | Default | Description
|:--| :------- | :------ | :----------
| R | inst     |         | The Tesseract instance to load the settings into.
| R | filename |         | The name of the file to load the settings from.

__Details:__

Only the debug settings will be loaded, all other settings will be ignored.

See also: [`tess_read_config`](@ref)
"""
function tess_read_debug_config(
            inst::TessInst,
            filename::AbstractString
        )::Nothing

    # ---------------------------------------------------------------------------------------------
    # Make sure the Tess object is not freed.
    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    # ---------------------------------------------------------------------------------------------
    # Call the C library.
    ccall(
        (:TessBaseAPIReadDebugConfigFile, TESSERACT),
        Cvoid,
        (Ptr{Cvoid}, Cstring),
        inst,
        filename
    )
    nothing
end
