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
    mutable struct ResultRenderer
        ptr::Ptr{Cvoid}
        owner::Bool
    end

A wrapper for the ResultRenderer structure in the tesseract library.  When the garbage collector
collects this object the associated ResultRenderer object will be freed in the library if we own
the object.  The object can also be freed early by calling delete!() on it.
"""
mutable struct ResultRenderer
    ptr::Ptr{Cvoid}
    owner::Bool
    function ResultRenderer(ptr::Ptr{Cvoid}, owner::Bool=true)
        local retval = new(ptr, owner)

        if owner == true
            finalizer(retval) do obj
                delete!(obj)
            end
        end

        retval
    end
end

# =================================================================================================
"""
    delete!(renderer::ResultRenderer)::Nothing

Destroy the result renderer.  This method will normally be called automatically when the object
goes out of scope.  However it can be called explicitly.
"""
function delete!(renderer::ResultRenderer)::Nothing
    if renderer.owner == true && renderer.ptr != C_NULL
        ccall((:TessDeleteResultRenderer, TESSERACT), Cvoid, (Ptr{Cvoid},), renderer.ptr)
        renderer.ptr   = C_NULL
        renderer.owner = false
    end
    nothing
end

# =================================================================================================
"""
    text_renderer(outBase::String)::ResultRenderer

Create a text file renderer with the specified base name.
"""
function text_renderer(outBase::String)::ResultRenderer
    local ptr = ccall((:TessTextRendererCreate, TESSERACT), Ptr{Cvoid}, (Cstring,), outBase)
    return ResultRenderer(ptr)
end

# =================================================================================================
"""
    hocr_renderer(outBase::String, font::Bool=false)::ResultRenderer

Create a HOCR file renderer with the specified base name. For more information on the format visit
https://en.wikipedia.org/wiki/HOCR.
"""
function hocr_renderer(outBase::String, font::Bool=false)::ResultRenderer
    local ptr = C_NULL

    if font == false
        ptr = ccall((:TessHOcrRendererCreate, TESSERACT), Ptr{Cvoid}, (Cstring,), outBase)
    else
        ptr = ccall((:TessHOcrRendererCreate2, TESSERACT), Ptr{Cvoid}, (Cstring, Cint), outBase, 1)
    end

    return ResultRenderer(ptr)
end

# =================================================================================================
"""
    alto_renderer(outBase::String)::ResultRenderer

Create a ALTO file renderer with the specified base name.  For more information on the format visit
https://en.wikipedia.org/wiki/ALTO_(XML).
"""
function alto_renderer(outBase::String)::ResultRenderer
    local ptr = ccall((:TessAltoRendererCreate, TESSERACT), Ptr{Cvoid}, (Cstring,), outBase)
    return ResultRenderer(ptr)
end

# =================================================================================================
"""
    tsv_renderer(outBase::String)::ResultRenderer

Create a tabbed separated file renderer with the specified base name.
"""
function tsv_renderer(outBase::String)::ResultRenderer
    local ptr = ccall((:TessTsvRendererCreate, TESSERACT), Ptr{Cvoid}, (Cstring,), outBase)
    return ResultRenderer(ptr)
end

# =================================================================================================
"""
    pdf_renderer(outBase::String, dataDir::String, textOnly::Bool)::ResultRenderer

Create a pdf file renderer with the base file name into the specified directory.
"""
function pdf_renderer(outBase::String, dataDir::String, textOnly::Bool)::ResultRenderer
    local flag = textOnly ? 1 : 0
    local ptr = ccall((:TessPDFRendererCreate, TESSERACT), Ptr{Cvoid}, (Cstring,Cstring,Cint), outBase, dataDir, flag)
    return ResultRenderer(ptr)
end

# =================================================================================================
"""
    unlv_renderer(outBase::String)::ResultRenderer

Create a UNLV file renderer with the specified base name.
"""
function unlv_renderer(outBase::String)::ResultRenderer
    local ptr = ccall((:TessUnlvRendererCreate, TESSERACT), Ptr{Cvoid}, (Cstring,), outBase)
    return ResultRenderer(ptr)
end

# =================================================================================================
"""
    word_box_renderer(outBase::String)::ResultRenderer

Create a word box file renderer with the specified base name.
"""
function box_renderer(outBase::String)::ResultRenderer
    local ptr = ccall((:TessWordStrBoxRendererCreate, TESSERACT), Ptr{Cvoid}, (Cstring,), outBase)
    return ResultRenderer(ptr)
end

# =================================================================================================
"""
    box_renderer(outBase::String)::ResultRenderer

Create a lstm box file renderer with the specified base name.
"""
function lstm_renderer(outBase::String)::ResultRenderer
    local ptr = ccall((:TessLSTMBoxRendererCreate, TESSERACT), Ptr{Cvoid}, (Cstring,), outBase)
    return ResultRenderer(ptr)
end

# =================================================================================================
"""
    insert!(renderer::ResultRenderer, next::ResultRenderer)::Nothing

Adds another renderer to also process the result of the OCR.
"""
function insert(renderer::ResultRenderer, next::ResultRenderer)::Nothing
    if renderer.ptr != C_NULL && next.ptr != C_NULL && next.owner == true
        ccall((:TessResultRendererInsert, TESSERACT), Cvoid, (Ptr{Cvoid},Ptr{Cvoid}), renderer.ptr, next.ptr)
        next.owner = false
    elseif renderer.ptr == C_NULL
        @error "The renderer has been freed."
    elseif next.ptr != C_NULL
        @error "The next renderer has been freed."
    else
        @error "We are no longer the owner of next."
    end
    nothing
end

# =================================================================================================
"""
    next(renderer::ResultRenderer)::Union{ResultRenderer, Nothing}

Get the next renderer in the chain.  If there are no more renderers nothing is returned.
"""
function next(renderer::ResultRenderer)::Union{ResultRenderer, Nothing}
    local retval = nothing

    if renderer.ptr != C_NULL
        local ptr = ccall((:TessResultRendererNext, TESSERACT), Ptr{Cvoid}, (Ptr{Cvoid},), renderer.ptr)

        if ptr != C_NULL
            retval = ResultRenderer(ptr, false)
        end
    else
        @error "The renderer has been freed."
    end

    return retval
end

# =================================================================================================
"""
    begin_document(renderer::ResultRenderer, title::String)::Bool

Start a new document with the specified title.
"""
function begin_document(renderer::ResultRenderer, title::String)::Bool
    local retval = false

    if renderer.ptr != C_NULL
        if ccall((:TessResultRendererBeginDocument, TESSERACT), Cint, (Ptr{Cvoid},Cstring), renderer.ptr, title) == 1
            retval = true
        end
    else
        @error "The renderer has been freed."
    end

    return retval
end

# =================================================================================================
"""
    end_document(renderer::ResultRenderer)::Bool

Finalize the document.
"""
function end_document(renderer::ResultRenderer)::Bool
    local retval = false

    if renderer.ptr != C_NULL
        if ccall((:TessResultRendererEndDocument, TESSERACT), Cint, (Ptr{Cvoid},), renderer.ptr) == 1
            retval = true
        end
    else
        @error "The renderer has been freed."
    end

    return retval
end
