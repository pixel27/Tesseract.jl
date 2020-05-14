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
    tess_get_param(
        inst::TessInst,
        name::AbstractString,
        ::Type{T}
    )::Union{T, Nothing} where T<:Integer

Retrieve an integer parameter from the Tesseract engine.  Returns `nothing` if the value
could not be retrieved.

__Arguments:__

| T | Name      | Default | Description
|:--| :-------- | :------ | :----------
| R | inst      |         | The instance to read the parameter from.
| R | name      |         | The name of the parameter to read.
| R | ::Type{T} |         | The type to return.

__Examples:__

```jldoctest
julia> using Tesseract

julia> download_languages()
true

julia> instance = TessInst()
Allocated Tesseract instance.

julia> tess_get_param(instance, "edges_min_nonhole", Int)
12
```

See also: [`tess_params`](@ref), [`tess_params_parsed`](@ref), [`tess_set_param`](@ref)
"""
function tess_get_param(
            inst::TessInst,
            name::AbstractString,
            ::Type{T}
        )::Union{T, Nothing} where T<:Integer

    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    local value = Ref{Cint}(0)
    local result = ccall(
        (:TessBaseAPIGetIntVariable, TESSERACT),
        Cint,
        (Ptr{Cvoid}, Cstring, Ptr{Cint}),
        inst,
        name,
        value
    )

    if result == 0
        return nothing
    end

    return value[]
end

# =========================================================================================
"""
tess_get_param(
        inst::TessInst,
        name::AbstractString,
        ::Type{Bool}
    )::Union{Bool, Nothing}

Retrieve a boolean parameter from the Tesseract engine.  Returns `nothing` if the value
could not be retrieved.

__Arguments:__

| T | Name         | Default | Description
|:--| :----------- | :------ | :----------
| R | inst         |         | The instance to read the variable from.
| R | name         |         | The name of the variable to read.
| R | ::Type{Bool} |         | Identifies that you want a boolean value.

__Examples:__

```jldoctest
julia> using Tesseract

julia> download_languages()
true

julia> instance = TessInst()
Allocated Tesseract instance.

julia> tess_get_param(instance, "edges_debug", Bool)
false
```

See also: [`tess_params`](@ref), [`tess_params_parsed`](@ref), [`tess_set_param`](@ref)
"""
function tess_get_param(
            inst::TessInst,
            name::AbstractString,
            ::Type{Bool}
        )::Union{Bool, Nothing}

    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    local value = Ref{Cint}(0)
    local result = ccall(
        (:TessBaseAPIGetBoolVariable, TESSERACT),
        Cint,
        (Ptr{Cvoid}, Cstring, Ptr{Cint}),
        inst,
        name,
        value
    )

    if result == 0
        return nothing
    end

    return value[] == 1
end

# =========================================================================================
"""
    tess_get_param(
        inst::TessInst,
        name::AbstractString,
        ::Type{Float64}
    )::Union{Float64, Nothing}

Retrieve a Float parameter from the Tesseract engine.  Returns `nothing` if the value
could not be retrieved.


__Arguments:__

| T | Name            | Default | Description
|:--| :-------------- | :------ | :----------
| R | inst            |         | The instance to read the variable from.
| R | name            |         | The name of the parameter to read.
| R | ::Type{Float64} |         | Identifies that you want a Float64 value.

__Examples:__

```jldoctest
julia> using Tesseract

julia> download_languages()
true

julia> instance = TessInst()
Allocated Tesseract instance.

julia> tess_get_param(instance, "classify_min_slope", Float64)
0.414213562
```

See also: [`tess_params`](@ref), [`tess_params_parsed`](@ref), [`tess_set_param`](@ref)
"""
function tess_get_param(
            inst::TessInst,
            name::AbstractString,
            ::Type{Float64}
        )::Union{Float64, Nothing}

    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    local value = Ref{Cdouble}(0.0)
    local result = ccall(
        (:TessBaseAPIGetDoubleVariable, TESSERACT),
        Cint,
        (Ptr{Cvoid}, Cstring, Ptr{Cdouble}),
        inst,
        name,
        value
    )

    if result == 0
        return nothing
    end

    return value[]
end

# =========================================================================================
"""
tess_get_param(
        inst::TessInst,
        name::AbstractString,
        ::Type{String}
    )::Union{String, Nothing}

Retrieve a String parameter from the Tesseract engine.  Returns `nothing` if the value
could not be retrieved.

__Arguments:__

| T | Name            | Default | Description
|:--| :-------------- | :------ | :----------
| R | inst            |         | The instance to read the variable from.
| R | name            |         | The name of the parameter to read.
| R | ::Type{Float64} |         | Identifies that you want a Float64 value.

__Examples:__

```jldoctest
julia> using Tesseract

julia> download_languages()
true

julia> instance = TessInst()
Allocated Tesseract instance.

julia> tess_get_param(instance, "page_separator", String)
"\\f"
```

See also: [`tess_params`](@ref), [`tess_params_parsed`](@ref), [`tess_set_param`](@ref)
"""
function tess_get_param(
            inst::TessInst,
            name::AbstractString,
            ::Type{String}
        )::Union{String, Nothing}

    if is_valid(inst) == false
        @error "Instance has been freed."
        return nothing
    end

    local result = ccall(
        (:TessBaseAPIGetStringVariable, TESSERACT),
        Cstring,
        (Ptr{Cvoid}, Cstring),
        inst,
        name
    )

    if result == C_NULL
        return nothing
    end

    return unsafe_string(result)
end
