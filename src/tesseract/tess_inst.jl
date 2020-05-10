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
    mutable struct TessInst
        ptr::Ptr{Cvoid}
    end

A wrapper for the Api object in the Tesseract library.

__Values:__

| Name | Description
| :--- | :----------
| ptr  | The pointer to the Api object allocated by the C library.

__Details:__

Most method calls cannot use this object until `tess_init()` called on it for initialization.

When the garbage collector collects this object the associated pointer object will be freed in the
library.  The object can also be manually freed by calling `tess_delete!()` on it.

See also: [`TessInst(languages::AbstractString, dataPath::AbstractString)`](@ref).
"""
mutable struct TessInst
    ptr::Ptr{Cvoid}
end

# =================================================================================================
"""
    TessInst(
        languages::AbstractString = "eng",
        dataPath::AbstractString = TESS_DATA
    )

Construct an initialize a TessInst object.

__Arguments:__

| T | Name      | Default    | Description
|:--| :-------- | :--------- | :----------
| O | languages | `eng`      | The language(s) to load.
| O | dataPath  | `tessdata` | The directory to look for the language files in.

__Details:__

To change the langauges identified by this instance you can call `tess_init()`.  Multiple
langagues can be specified by seperating them with a plus.  So if you want english and spanish you
could specify "eng+spa".  The language codes are (usually) the
[ISO 639-3](https://en.wikipedia.org/wiki/ISO_639-3) code.

__Example:__

```jldoctest
julia> using Tesseract

julia> download_languages("eng+fra")
true

julia> instance = TessInst("eng+fra")
Allocated Tesseract instance.
```

See also: [`tess_init`](@ref).
"""
function TessInst(
            languages::AbstractString = "eng",
            dataPath::AbstractString = TESS_DATA
        )
    local ptr    = ccall((:TessBaseAPICreate, TESSERACT), Ptr{Cvoid}, ())
    local retval = TessInst(ptr)

    finalizer(retval) do obj
        tess_delete!(obj)
    end

    tess_init(retval, languages, dataPath)

    retval
end

# =================================================================================================
"""
    show(
        io::IO,
        inst::TessInst
    )::Nothing

Display summary information about the tesseract instance.

__Arguments:__

| T | Name  | Default | Description
|---| :---- | :------ | :----------
| R | io    |         | The stream to write the information to.
| R | inst  |         | The tesseract instance to display info about.
"""
function Base.show(
            io::IO,
            inst::TessInst
        )::Nothing
    if is_valid(inst)
        print(io, "Allocated Tesseract instance.")
    else
        print(io, "Freed Tesseract instance.")
    end
    nothing
end

# =================================================================================================
"""
    is_valid(
        inst::TessInst
    )::Bool

Check if the isntance has been freed or if it's still valid.

__Arguments:__

| T | Name | Default | Description
|---| :--- | :------ | :----------
| R | inst |         | The instance to check.
"""
function is_valid(
            inst::TessInst
        )::Bool
    return inst.ptr != C_NULL
end

# =================================================================================================
"""
    unsafe_convert(
        ::Type{Ptr{Cvoid}},
        inst::TessInst
    )::Ptr{Cvoid}

"Convert" the instance into a the handle pointer used by the Tesseract library.

__Arguments:__

| T | Name               | Default | Description
|---| :----------------- | :------ | :----------
| R | ::Type{Ptr{Cvoid}} |         | The type to convert into.
| R | inst               |         | The instance to return the Teseract handle for.
"""
Base.unsafe_convert(::Type{Ptr{Cvoid}}, inst::TessInst) = inst.ptr

# =================================================================================================
"""
    tess_delete!(
        inst::TessInst
    )::Nothing

Destroy the Tesseract object and release any associated memory.

__Arguments:__

| T | Name | Default | Description
|---| :--- | :------ | :----------
| R | inst |         | The instance to free.

__Details:__

This method is called automatically by the garbage collector but can be called manually to release
the object early.  This method can be called multiple times without any negative effects.

Once `tess_delete!()` is called on an object passing the object to any other library call will
result in an error.

Note: This method is not thread safe.
"""
function tess_delete!(
            inst::TessInst
        )::Nothing

    if is_valid(inst) == true
        ccall(
            (:TessBaseAPIDelete, TESSERACT),
            Cvoid,
            (Ptr{Cvoid},),
            inst
        )
        inst.ptr = C_NULL
    end
    nothing
end


# =================================================================================================
"""
    tess_recognize(
        inst::TessInst
    )::Bool

Perform the OCR extraction.  This will be called automatically if you call one of the retrieval
functions so you don't need to call it directly.  Returns `false` if there was an error.

__Arguments:__

| T | Name | Default | Description
|---| :--- | :------ | :----------
| R | inst |         | The instance to perform the recognition with.

__Example:__

```jldoctest
julia> using Tesseract

julia> download_languages("eng+fra")
true

julia> instance = TessInst("eng+fra")
Allocated Tesseract instance.

julia> pix = sample_pix()
Image (500, 600) at 32ppi

julia> tess_image(instance, pix)

julia> tess_resolution(instance, 72)

julia> tess_recognize(instance)
true
```

See also: [`tess_text`](@ref), [`tess_hocr`](@ref), [`tess_alto`](@ref), [`tess_tsv`](@ref),
[`tess_parsed_tsv`](@ref).
"""
function tess_recognize(
            inst::TessInst
        )::Bool
    local result = -1

    if is_valid(inst) == true
        result = ccall(
            (:TessBaseAPIRecognize, TESSERACT),
            Cint,
            (Ptr{Cvoid}, Ptr{Cvoid}),
            inst,
            C_NULL
        )
    else
        @error "Instance has been freed."
    end

    return result == 0
end
