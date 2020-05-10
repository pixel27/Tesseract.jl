# JuliaTesseract

Julia bindings for the Tesseract Library and to a lesser extent the Leptonica library.

This project is still in it's early stages.  Next steps are:

  * Add examples in the documentation.
  * Add calls to more of Tesseract's API.
  * Review the API of Leptonica and see if it makes sense to expose more of it's API.

However what I have currently should be usable.

## Tesseract data

This library currently doesn't ship with the Tesseract data files.  The data files can be
downloaded from:

  * https://github.com/tesseract-ocr/tessdata
  * https://github.com/tesseract-ocr/tessdata_best

The files run several megabytes each, however you only need to download the languages you are interested in decoding.  Each file is prefixed with the [ISO 639-3](https://en.wikipedia.org/wiki/ISO_639-3) code for the language it provides.

## Usage

```julia
using Tesseract

# Generate a sample image if you don't have one handy.
write("sample.tiff", sample_tiff())

# Download the Tesseract training data for for the english language.
download_languages()

# Create an instance of the Tesseract API
inst = TessInst()

# Load the data file, and set the image resolution.
tess_image(inst, pix_read("sample.gif"))
tess_resolution(inst, 72)

# Write out the OCRed text in various formats.
write("output.txt", tess_text(inst))
write("output_hocr.xml", tess_hocr(inst))
write("output_alto.xml", tess_alto(inst))
write("output.tsv", tess_tsv(inst))

# Retrieve details about each word extracted from the image.
details = tess_parsed_tsv(inst)
```
