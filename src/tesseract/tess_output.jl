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
    mutable struct TessOutput{T}
        result::Union{T, Nothing}
    end

Output object returned when adding an output renderer to a pipeline.  This object usually
holds `nothing` until the [`tess_run_pipeline`](@ref) method completes.

See slso: [`tess_pipeline_text`](@ref)
"""
mutable struct TessOutput{T}
    result::Union{T, Nothing}
    TessOutput(String) = new{String}(nothing)
end

# =========================================================================================
"""
    show(
        io::IO,
        inst::TessOutput
    )::Nothing

Display summary information about the TessOutput instance.

__Arguments:__

| T | Name  | Default | Description
|---| :---- | :------ | :----------
| R | io    |         | The stream to write the information to.
| R | inst  |         | The TessOutput instance to display info about.
"""
function Base.show(
            io::IO,
            inst::TessOutput
        )::Nothing
    if inst.result === nothing
        print(io, "No output available.")
    else
        show(io, inst.result)
    end
    nothing
end

# =========================================================================================
"""
    is_available(
        p::TessOutput
    )::Bool

Test if [`TessOutput`](@ref) object contains something yet.  Returns `false` if it contains
`nothing`.
"""
function is_available(
            p::TessOutput
        )::Bool
    return p.result !== nothing
end

# =========================================================================================
"""
    getindex(
        p::TessOutput{T}
    )::Union{T, Nothing} where T

Provides functionality to retrieve the contents of the  [`TessOutput`](@ref) object by
using [].
"""
function Base.getindex(
            p::TessOutput{T}
        )::Union{T, Nothing} where T
    return p.result
end
