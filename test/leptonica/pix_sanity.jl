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
# Test writing a BMP image.
#
# A 32bit PNM is written as a PAM file so we can't compare those.
@testset "Sanity Check" begin
    local pix = pix_with()
    local formats = [
        pix_write_bmp(pix),
        pix_write_gif(pix),
        pix_write_jpeg(pix),
        pix_write_jp2k(pix),
        pix_write_pdf(pix),
        pix_write_png(pix),
        pix_write_pnm(pix),
        pix_write_ps(pix),
        pix_write_spix(pix)
    ]

    for i = eachindex(formats)
        for j = eachindex(formats)
            if i != j
                @test formats[i] != formats[j]
            end
        end
    end
end
