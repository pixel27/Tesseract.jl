# Process multiple images

This process is normally used to process all the pages in a book.

```jldoctest
using Tesseract

# Generate some pages to load.
write("page01.tiff", sample_tiff())
write("page02.tiff", sample_tiff())
write("page03.tiff", sample_tiff())

download_languages() # Make sure we have the data files.

instance = TessInst()
pipeline = TessPipeline(instance)

text = tess_pipeline_text(pipeline)
hocr = tess_pipeline_hocr(pipeline)
tsv  = tess_pipeline_tsv(pipeline)

tess_run_pipeline(pipeline, "My First Book") do add
    add(pix_read("page01.tiff"), 72)
    add(pix_read("page02.tiff"), 72)
    add(pix_read("page03.tiff"), 72)
end

println("Text size: $(length(text[]))")
println("HOCR size: $(length(hocr[]))")
println("TSV  size: $(length(tsv[]))")

# output

Text size: 4431
HOCR size: 91051
TSV  size: 29558
```

To process multiple pages and combine them all into a single document you use the [TessPipeline](ref/tess_pipeline.md) object.  First a [TessInst](ref/tess_inst.md) object is created to handle the OCR then the it's passed to the [TessPipeline](ref/tess_pipeline.md) durring initialization.  

You can generate multiple document types simultaneously.  In the above example we use [tess\_pipeline\_text](ref/tess_pipeline_text.md) to generate a TXT file, [tess\_pipeline\_hocr](ref/tess_pipeline_hocr.md) to generate a HORC XML file, and [tess\_pipeline\_tsv](ref/tess_pipeline_tsv.md) to get details about the OCR in the Tabbed Separated Format.

Finally [tess\_run\_pipeline](ref/tess_run_pipeline.md) is called to generate the documents.  An optional title is added.  Some output formats ignore the title, others will add it to the output.  A callback is used with [tess\_run\_pipeline](ref/tess_run_pipeline.md) which passes back a function  that is used to specify the images to decode along with their resolution.  To indicate an error your callback can return `false` which will in turn cause [tess\_run\_pipeline](ref/tess_run_pipeline.md) to return `false` as well.

In the above example the documents are created in memory and can be accessed by using the `[]` operation on the returned objects. In general there are 3 output formats for each pipeline output function (i.e. [tess\_pipeline\_text](ref/tess_pipeline_text.md)).  The first is to output to a file by specifying a file name.  The second we used above to output the results to memory.  The third is to pass in a callback function that will be called with each line of text, allowing you to process the data as it is being generated.
