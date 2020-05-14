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
using Test
using JSON

# -------------------------------------------------------------------------------------------------
# Test download_languages()
@testset "download_languages" begin
    local dir = mktempdir(;cleanup = false)
        @test download_languages("eng"; target=dir) == true
        @test isfile(joinpath(dir, "eng.traineddata")) == true
        @test filesize(joinpath(dir, "eng.traineddata")) > 0
        @test isfile(joinpath(dir, ".languages")) == true
        @test filesize(joinpath(dir, ".languages")) > 0
    rm(dir;recursive = true)

    local dir = mktempdir(;cleanup = false)
        @test download_languages("fra+heb+hin"; target=dir) == true
        @test isfile(joinpath(dir, "fra.traineddata")) == true
        @test filesize(joinpath(dir, "fra.traineddata")) > 0
        @test filesize(joinpath(dir, "heb.traineddata")) > 0
        @test isfile(joinpath(dir, "heb.traineddata")) == true
        @test filesize(joinpath(dir, "hin.traineddata")) > 0
        @test isfile(joinpath(dir, "hin.traineddata")) == true
        @test isfile(joinpath(dir, ".languages")) == true
        @test filesize(joinpath(dir, ".languages")) > 0
    rm(dir;recursive = true)

    local dir = mktempdir(;cleanup = false)
        @test download_languages("kat"; target=dir) == true
        local timestamp = mtime(joinpath(dir, "kat.traineddata"))
        @test download_languages("kat"; target=dir) == true
        @test timestamp == mtime(joinpath(dir, "kat.traineddata"))
        @test download_languages("kat"; target=dir, force=true) == true
        @test timestamp != mtime(joinpath(dir, "kat.traineddata"))
    rm(dir;recursive = true)

    local dir = mktempdir(;cleanup = false)
        @test download_languages("eng"; target=dir, baseUrl="https://raw.githubusercontent.com/tesseract-ocr/tessdata/master/") == true
        @test isfile(joinpath(dir, "eng.traineddata")) == true
        @test filesize(joinpath(dir, "eng.traineddata")) > 0
        @test isfile(joinpath(dir, ".languages")) == true
        @test filesize(joinpath(dir, ".languages")) > 0
    rm(dir;recursive = true)
end

# -------------------------------------------------------------------------------------------------
# Test update_languages()
@testset "update_languages" begin
    local dir = mktempdir(;cleanup = false)
        @test update_languages("eng"; target=dir) == true
        @test isfile(joinpath(dir, "eng.traineddata")) == true
        @test filesize(joinpath(dir, "eng.traineddata")) > 0
        @test isfile(joinpath(dir, ".languages")) == true
        @test filesize(joinpath(dir, ".languages")) > 0
        local timestamp = mtime(joinpath(dir, "eng.traineddata"))
        local lastcheck = JSON.parse(read(joinpath(dir, ".languages"), String))["lastcheck"]
        @test update_languages("eng"; target=dir) == true
        @test timestamp == mtime(joinpath(dir, "eng.traineddata"))
        @test lastcheck == JSON.parse(read(joinpath(dir, ".languages"), String))["lastcheck"]
    rm(dir;recursive = true)

    local dir = mktempdir(;cleanup = false)
        @test update_languages("fra+heb+hin"; target=dir) == true
        @test isfile(joinpath(dir, "fra.traineddata")) == true
        @test filesize(joinpath(dir, "fra.traineddata")) > 0
        @test filesize(joinpath(dir, "heb.traineddata")) > 0
        @test isfile(joinpath(dir, "heb.traineddata")) == true
        @test filesize(joinpath(dir, "hin.traineddata")) > 0
        @test isfile(joinpath(dir, "hin.traineddata")) == true
        @test isfile(joinpath(dir, ".languages")) == true
        @test filesize(joinpath(dir, ".languages")) > 0
    rm(dir;recursive = true)

    local dir = mktempdir(;cleanup = false)
        @test update_languages("kat"; target=dir) == true
        local timestamp = mtime(joinpath(dir, "kat.traineddata"))
        @test update_languages("kat"; target=dir) == true
        @test timestamp == mtime(joinpath(dir, "kat.traineddata"))
    rm(dir;recursive = true)
end

# -------------------------------------------------------------------------------------------------
# Test download_pdf_font()
@testset "download_pdf_font" begin
    local dir = mktempdir(;cleanup = false)
        @test download_pdf_font(; target=dir) == true
        @test isfile(joinpath(dir, "pdf.ttf")) == true
        @test filesize(joinpath(dir, "pdf.ttf")) > 0
        @test isfile(joinpath(dir, ".pdffont")) == true
        @test filesize(joinpath(dir, ".pdffont")) > 0
    rm(dir;recursive = true)

    local dir = mktempdir(;cleanup = false)
        @test download_pdf_font(; target=dir) == true
        local timestamp = mtime(joinpath(dir, "pdf.ttf"))
        @test download_pdf_font(; target=dir) == true
        @test timestamp == mtime(joinpath(dir, "pdf.ttf"))
        @test download_pdf_font(; target=dir, force=true) == true
        @test timestamp != mtime(joinpath(dir, "pdf.ttf"))
    rm(dir;recursive = true)

    local dir = mktempdir(;cleanup = false)
        @test download_pdf_font(; target=dir, baseUrl="https://raw.githubusercontent.com/tesseract-ocr/tessconfigs/master/") == true
        @test isfile(joinpath(dir, "pdf.ttf")) == true
        @test filesize(joinpath(dir, "pdf.ttf")) > 0
        @test isfile(joinpath(dir, ".pdffont")) == true
        @test filesize(joinpath(dir, ".pdffont")) > 0
    rm(dir;recursive = true)
end

# -------------------------------------------------------------------------------------------------
# Test update_pdf_font()
@testset "update_pdf_font" begin
    local dir = mktempdir(;cleanup = false)
        @test update_pdf_font(; target=dir) == true
        @test isfile(joinpath(dir, "pdf.ttf")) == true
        @test filesize(joinpath(dir, "pdf.ttf")) > 0
        @test isfile(joinpath(dir, ".pdffont")) == true
        @test filesize(joinpath(dir, ".pdffont")) > 0
        local timestamp = mtime(joinpath(dir, "pdf.ttf"))
        local lastcheck = JSON.parse(read(joinpath(dir, ".pdffont"), String))["lastcheck"]
        @test update_pdf_font(; target=dir) == true
        @test timestamp == mtime(joinpath(dir, "pdf.ttf"))
        @test lastcheck == JSON.parse(read(joinpath(dir, ".pdffont"), String))["lastcheck"]
    rm(dir;recursive = true)

    local dir = mktempdir(;cleanup = false)
        @test update_pdf_font(; target=dir) == true
        local timestamp = mtime(joinpath(dir, "pdf.ttf"))
        @test update_pdf_font(; target=dir) == true
        @test timestamp == mtime(joinpath(dir, "pdf.ttf"))
    rm(dir;recursive = true)
end
