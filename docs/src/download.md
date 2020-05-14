# Download required files

```jldoctest
julia> using Tesseract

julia> download_languages("eng+spa")
true

julia> download_pdf_font()
true
```

Tesseract.jl does not contain the language files needed by [Tesseract](https://github.com/tesseract-ocr/tesseract) to perform OCR on images.  These files must be downloaded separately, and are multiple megabytes in size, so only the languages you are interested in can be downloaded.  Languages are specified using [ISO 639-3](https://en.wikipedia.org/wiki/ISO_639-3) language codes with a plus sign(+) between them.

By default the files are downloaded from [https://github.com/tesseract-ocr/tessdata_best](https://github.com/tesseract-ocr/tessdata_best).  Unless told to overwrite the existing file [download\_languages](ref/download_languages.md) only downloads the file is it doesn't already exist.  [download\_pdf\_font](ref/download_pdf_font.md) is only needed if you want to generate searchable PDF files.  Again is only downloads the file if it has not already been downloaded.  The PDF font file is normally downloaded from [https://github.com/tesseract-ocr/tessconfigs](https://github.com/tesseract-ocr/tessconfigs).
