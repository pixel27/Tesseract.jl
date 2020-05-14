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
    tess_set_debug_param(
        inst::TessInst,
        name::AbstractString,
        value::Integer
    )::Bool

Sets an debug integer variable in th Tesseract engine.  Returns `false` if the parameter
was not found.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | inst  |         | The instance to set the variable in
| R | name  |         | The name of the variable to set.
| R | value |         | The value to set.

__Details:__

If the parameter is not a debug setting then the value will not be changed.

__Examples:__

```jldoctest
julia> using Tesseract

julia> download_languages()
true

julia> instance = TessInst()
Allocated Tesseract instance.

julia> tess_set_debug_param(instance, "classify_learning_debug_level", 0)
true
```

See also: [`tess_params`](@ref), [`tess_params_parsed`](@ref), [`tess_get_param`](@ref)
"""
function tess_set_debug_param(
            inst::TessInst,
            name::AbstractString,
            value::Integer
        )::Bool

    if is_valid(inst) == false
        @error "Instance has been freed."
        return false
    end

    local result = ccall(
        (:TessBaseAPISetDebugVariable, TESSERACT),
        Cint,
        (Ptr{Cvoid}, Cstring, Cstring),
        inst,
        name,
        string(value)
    )

    return result == 1
end

# =========================================================================================
"""
    tess_set_debug_param(
        inst::TessInst,
        name::AbstractString,
        value::Bool
    )::Bool

Sets a debug boolean variable in th Tesseract engine.  Returns `false` if the parameter was
not found.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | inst  |         | The instance to set the variable in
| R | name  |         | The name of the variable to set.
| R | value |         | The value to set.

__Details:__

If the parameter is not a debug setting then the value will not be changed.

__Examples:__

```jldoctest
julia> using Tesseract

julia> download_languages()
true

julia> instance = TessInst()
Allocated Tesseract instance.

julia> tess_set_debug_param(instance, "textord_debug_tabfind", false)
true
```

See also: [`tess_params`](@ref), [`tess_params_parsed`](@ref), [`tess_get_param`](@ref)
"""
function tess_set_debug_param(
            inst::TessInst,
            name::AbstractString,
            value::Bool
        )::Bool

    if is_valid(inst) == false
        @error "Instance has been freed."
        return false
    end

    local result = ccall(
        (:TessBaseAPISetDebugVariable, TESSERACT),
        Cint,
        (Ptr{Cvoid}, Cstring, Cstring),
        inst,
        name,
        value ? "true" : "false"
    )

    return result == 1
end

# =========================================================================================
"""
    tess_set_debug_param(
        inst::TessInst,
        name::AbstractString,
        value::Float64
    )::Bool

Sets a debug `Float64` variable in th Tesseract engine.  Returns `false` if the parameter
was not found.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | inst  |         | The instance to set the variable in
| R | name  |         | The name of the variable to set.
| R | value |         | The value to set.

__Details:__

This method is implmented for future enchancements.  Currently there are no tesseract debug
parameters.

See also: [`tess_params`](@ref), [`tess_params_parsed`](@ref), [`tess_get_param`](@ref)
"""
function tess_set_debug_param(
            inst::TessInst,
            name::AbstractString,
            value::Float64
        )::Bool

    if is_valid(inst) == false
        @error "Instance has been freed."
        return false
    end

    local result = ccall(
        (:TessBaseAPISetDebugVariable, TESSERACT),
        Cint,
        (Ptr{Cvoid}, Cstring, Cstring),
        inst,
        name,
        string(value)
    )

    return result == 1
end

# =========================================================================================
"""
    tess_set_debug_param(
        inst::TessInst,
        name::AbstractString,
        value::AbstractString
    )::Bool

Sets a debug string variable in th Tesseract engine.  Returns `false` if the parameter was
not found.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | inst  |         | The instance to set the variable in
| R | name  |         | The name of the variable to set.
| R | value |         | The value to set.

__Details:__

If the parameter is not a debug setting then the value will not be changed.

__Examples:__

```jldoctest
julia> using Tesseract

julia> download_languages()
true

julia> instance = TessInst()
Allocated Tesseract instance.

julia> tess_set_debug_param(instance, "debug_file", "debug.log")
true
```

See also: [`tess_params`](@ref), [`tess_params_parsed`](@ref), [`tess_get_param`](@ref)
"""
function tess_set_debug_param(
            inst::TessInst,
            name::AbstractString,
            value::AbstractString
        )::Bool

    if is_valid(inst) == false
        @error "Instance has been freed."
        return false
    end

    local result = ccall(
        (:TessBaseAPISetDebugVariable, TESSERACT),
        Cint,
        (Ptr{Cvoid}, Cstring, Cstring),
        inst,
        name,
        value
    )

    return result == 1
end
