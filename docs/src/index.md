# Tesseract.jl documentation

```jldoctest
using Tesseract

# Generate some pages to load.
write("page01.tiff", sample_tiff())
write("page02.tiff", sample_tiff())
write("page03.tiff", sample_tiff())

# Download the Tesseract English data files
download_languages("eng")

# Initialize the library to generate a text file.
instance = TessInst("eng")
pipeline = TessPipeline(instance)

tess_pipeline_text(pipeline, "My Book.txt")

# Process all the pages in the book.
tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

# The results will be saved in "My Book.txt".
println("My Book.txt: $(filesize("My Book.txt")) bytes.")

# output

My Book.txt: 4436 bytes.
```

This Julia packages provides support for performing OCR on scanned images.  This is done by using the [Tesseract](https://github.com/tesseract-ocr/tesseract) C library.  Tesseract.jl tries to provide a direct mapping of the Tesseract API to Julia with additional functionality added to fit better into the Julia ecosystem.
