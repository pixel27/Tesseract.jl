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
    struct TessParam{T}
        name::String
        default::T
        desc::String
        debug::Bool
    end

Holds details about the default value of a parameter.

__Values:__

| Name    | Description
| :------ | :----------
| name    | The name/ID of the parameter.
| default | The default value of the parameter.
| desc    | The description of the variable.
| debug   | True if the value is a debug parameter.

__Details:__

This structure currently comes in 3 flavors, T may be Float64, Int32, or a String based on
the default value.

See also: [`tess_params_parsed`](@ref), [`tess_get_param`](@ref), [`tess_set_param`](@ref)
"""
struct TessParam{T}
    name::String
    default::T
    desc::String
    debug::Bool
end

# =========================================================================================
"""
    TessParam(
        name::AbstractString,
        value::AbstractString,
        help::AbstractString
    )::TessParam{T} where T

Construct a new instance of the [`TessParam`](@ref) structure from the provided values.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | name  |         | The name/ID of the parameter.
| R | value |         | The default value of the parameter as a string.
| R | help  |         | Help text about the parameter.

__Details:__

This method looks at the contents of `value` and determines the correct [`TessParam`](@ref)
type to create.

See also: [`tess_params_parsed`](@ref)
"""
function TessParam(
            name::AbstractString,
            value::AbstractString,
            help::AbstractString
        )::TessParam
    local debug = findfirst("debug", name) !== nothing ||
                  findfirst("display", name) !== nothing

    if match(r"^-?[0-9]+\.[0-9]+$", value) !== nothing
        return TessParam{Float64}(name, parse(Float64, value), help, debug)
    elseif match(r"^-?[0-9]+$", value) !== nothing
        return TessParam{Int32}(name, parse(Int32, value), help, debug)
    else
        return TessParam{String}(name, value, help, debug)
    end
end

# =========================================================================================
"""
    tess_params_parsed(
            inst::TessInst
        )::Vector{TessParam}

Retrieved all the Tesseract parameters with their valuse as an array of [`TessParam`](@ref)
objects.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | inst |         | The Tesseract instance to get the parameters from.

__Details:__

Parses the result of `[`tess_params`](@ref) into something more easily digested by a
computer.  Each line of text is split into 3 values:

* The name of the parameter.
* The default value of the parameter (may be an empty string).
* Text describing the parameter.

Each value is separated by a tab and the description is terminated by a new line.

See also: [`TessParam`](@ref), [`tess_params`](@ref), [`tess_get_param`](@ref),
          [`tess_set_param`](@ref)
"""
function tess_params_parsed(
            inst::TessInst
        )::Vector{TessParam}
    local params = Vector{TessParam}()
    local data   = tess_params(inst)

    if data !== nothing
        for m in eachmatch(r"([a-z0-9_]+)\t([^\t]*)\t([^\n]+)"sm, data)
            local name, value, help = m.captures
            push!(params, TessParam(name, value, help))
        end
    end

    return params
end
