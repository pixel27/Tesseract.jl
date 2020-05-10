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
    struct TessParam{T}
        name::String  # The name/key of the parameter.
        default::T    # The default value which will be either a Float64, Int32, or String.
        desc::String  # The description of the parameter.
    end

Holds details about the default value of a parameter.

__Values:__

| Name    | Description
| :------ | :----------
| name    | The name/ID of the parameter.
| default | The default value of the parameter.
| desc    | The description of the variable.

__Details:__

This structure currently comes in 3 flavors, T may be Float64, Int32, or a String based on the
default value.
"""
struct TessParam{T}
    name::String
    default::T
    desc::String
end

# =================================================================================================
"""
    TessParam(
        name::AbstractString,
        value::AbstractString,
        help::AbstractString
    )::TessParam{T} where T

Construct a new instance of the TessParam structure from the provided values.

__Arguments:__

| T | Name  | Default | Description
|:--| :---- | :------ | :----------
| R | name  |         | The name/ID of the parameter.
| R | value |         | The default value of the parameter as a string.
| R | help  |         | Help text about the parameter.

__Details:__

This method looks at the contents of `value` and determines the correct TessParam type to create.
"""
function TessParam(
            name::AbstractString,
            value::AbstractString,
            help::AbstractString
        )::TessParam
    if match(r"^-?[0-9]+\.[0-9]+$", value) != nothing
        return TessParam{Float64}(name, parse(Float64, value), help)
    elseif match(r"^-?[0-9]+$", value) != nothing
        return TessParam{Int32}(name, parse(Int32, value), help)
    else
        return TessParam{String}(name, value, help)
    end
end

# =================================================================================================
"""
    tess_print_variables_parsed(
            inst::TessInst, # The instance to retrieve the default parameters from.
        )::Vector{TessParam}

Retrieved all the Tesseract parameters with their valuse as an array of TessParam objects.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | inst |         | The Tesseract instance to get get the parameters from.

__Details:__

Parses the result of `print_variables()` into something more easily digested by a computer.
Each line of text is split into 3 values:

* The name of the parameter.
* The default value of the parameter (may be an empty string).
* Text describing the parameter.

Each value is separated by a tab and the description is terminated by a new line.

See also: [`tess_print_variables`](@ref)
"""
function tess_print_variables_parsed(
            inst::TessInst
        )::Vector{TessParam}
    local params = Vector{TessParam}()
    local data   = tess_print_variables(inst)

    if data != nothing
        for m in eachmatch(r"([a-z0-9_]+)\t([^\t]*)\t([^\n]+)"sm, data)
            local name, value, help = m.captures
            push!(params, TessParam(name, value, help))
        end
    end

    return params
end
