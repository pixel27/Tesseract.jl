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
    @enum PageSegMode begin
        PSM_OSD_ONLY               = 0
        PSM_AUTO_OSD               = 1
        PSM_AUTO_ONLY              = 2
        PSM_AUTO                   = 3
        PSM_SINGLE_COLUMN          = 4
        PSM_SINGLE_BLOCK_VERT_TEXT = 5
        PSM_SINGLE_BLOCK           = 6
        PSM_SINGLE_LINE            = 7
        PSM_SINGLE_WORD            = 8
        PSM_CIRCLE_WORD            = 9
        PSM_SINGLE_CHAR            = 10
        PSM_SPARSE_TEXT            = 11
        PSM_SPARSE_TEXT_OSD        = 12
        PSM_RAW_LINE               = 13
    end

Various constants used by tesseract to determine how the page will be processed.

__Details:__

| Value                      | Description
| :------------------------- | :----------
| PSM_OSD_ONLY               | Orientation and script detection only.
| PSM_AUTO_OSD               | Automatic page segmentation with orientation and script detection.
| PSM_AUTO_ONLY              | Automatic page segmentation, but no OSD, or OCR.
| PSM_AUTO                   | Fully automatic page segmentation, but no OSD.
| PSM_SINGLE_COLUMN          | Assume a single column of text of variable sizes.
| PSM_SINGLE_BLOCK_VERT_TEXT | Assume a single uniform block of vertically aligned text.
| PSM_SINGLE_BLOCK           | Assume a single uniform block of text. (Default)
| PSM_SINGLE_LINE            | Treat the image as a single text line.
| PSM_SINGLE_WORD            | Treat the image as a single word.
| PSM_CIRCLE_WORD            | Treat the image as a single word in a circle.
| PSM_SINGLE_CHAR            | Treat the image as a single character.
| PSM_SPARSE_TEXT            | Find as much text as possible in no particular order.
| PSM_SPARSE_TEXT_OSD        | Sparse text with orientation and script detection.
| PSM_RAW_LINE               | Treat the image as a single text line, bypassing hacks that are Tesseract-specific.
"""
@enum PageSegMode begin
    PSM_OSD_ONLY               = 0
    PSM_AUTO_OSD               = 1
    PSM_AUTO_ONLY              = 2
    PSM_AUTO                   = 3
    PSM_SINGLE_COLUMN          = 4
    PSM_SINGLE_BLOCK_VERT_TEXT = 5
    PSM_SINGLE_BLOCK           = 6
    PSM_SINGLE_LINE            = 7
    PSM_SINGLE_WORD            = 8
    PSM_CIRCLE_WORD            = 9
    PSM_SINGLE_CHAR            = 10
    PSM_SPARSE_TEXT            = 11
    PSM_SPARSE_TEXT_OSD        = 12
    PSM_RAW_LINE               = 13
end
