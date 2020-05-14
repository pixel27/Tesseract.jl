# Index

## D

| Type                         | Description
| :--------------------------- | :----------
| [`download_pdf_font`](@ref)  | Download the PDF font file needed to create PDF images.
| [`download_languages`](@ref) | Download the language data files needed to OCR an image.

## G
| Type                     | Description
| :----------------------- | :----------
| [`GitHubProject`](@ref)  | Describes a GitHub repository to download data files from.

## I

| Type                 | Description
| :------------------- | :----------
| [`IFF`](@ref)        | Image enumeration to identify image types.

## L

| Type                 | Description
| :--------------------- | :----------
| [`lept_version`](@ref) | Retrieve the version of the Leptonica library.

## P

| Type                               | Description
| :--------------------------------- | :----------
| [`Pix`](@ref)                      | Picture object to perform OCR on.
| [`PixBox`](@ref)                   | Picture box to reference an area inside a [`Pix`](@ref) object.
| [`pix_delete!`](@ref)              | Manually free a image.
| [`pix_get_depth`](@ref)            | Retrieve the color bit depth of the image in BPP.
| [`pix_get_dimensions`](@ref)       | Retrieve the image width, height, and color bit depth.
| [`pix_read`](@ref)                 | Read an image from disk, memory, or a stream.
| [`pix_read_bmp`](@ref)             | Read a BMP image from disk, memory, or a stream.
| [`pix_read_gif`](@ref)             | Read a GIF image from disk, memory, or a stream.
| [`pix_read_jp2k`](@ref)            | Read a JP2K image from disk, memory, or a stream.
| [`pix_read_jpeg`](@ref)            | Read a JPEG image from disk, memory, or a stream.
| [`pix_read_png`](@ref)             | Read a PNG image from disk, memory, or a stream.
| [`pix_read_pnm`](@ref)             | Read a PNM image from disk, memory, or a stream.
| [`pix_read_spix`](@ref)            | Read a SPIX image from disk, memory, or a stream.
| [`pix_read_tiff`](@ref)            | Read a TIFF image from disk, memory, or a stream.
| [`pix_read_webp`](@ref)            | Read a WEBP image from disk, memory, or a stream.
| [`pix_write`](@ref)                | Write an image to disk, memory or a stream.
| [`pix_write_implied_format`](@ref) | Write an image to disk.
| [`pix_write_bmp`](@ref)            | Write image to disk, memory or a stream as a BMP file.
| [`pix_write_gif`](@ref)            | Write image to disk, memory or a stream as a GIF file.
| [`pix_write_jp2k`](@ref)           | Write image to disk, memory or a stream as a JP2K file.
| [`pix_write_jpeg`](@ref)           | Write image to disk, memory or a stream as a JPEG file.
| [`pix_write_pam`](@ref)            | Write image to disk, memory or a stream as a PAM file.
| [`pix_write_pdf`](@ref)            | Write image to disk, memory or a stream as a PDF file.
| [`pix_write_png`](@ref)            | Write image to disk, memory or a stream as a PNG file.
| [`pix_write_pnm`](@ref)            | Write image to disk, memory or a stream as a PNM file.
| [`pix_write_ps`](@ref)             | Write image to disk, memory or a stream as a PostScript file.
| [`pix_write_spix`](@ref)             | Write image to disk, memory or a stream as a SPIX file.
| [`pix_write_tiff`](@ref)             | Write image to disk, memory or a stream as a TIFF file.
| [`pix_write_webp`](@ref)             | Write image to disk, memory or a stream as a WEBP file.

## S

| Type                  | Description
| :-------------------- | :----------
| [`sample_pix`](@ref)  | Create a sample image with text for testing.
| [`sample_tiff`](@ref) | Create a sample TIFF file with text for testing.

## T

| Type                                  | Description
| :------------------------------------ | :----------
| [`TessInst`](@ref)                    | Tesseract object to perform OCR functions.
| [`TessOutput`](@ref)                  | Holds the result of an operation that will be returned later.
| [`TessParam`](@ref)                   | Object that describes a parameter than can be set in TessInst.
| [`TessPipeline`](@ref)                | Object used to process a sequence of pages.
| [`tess_alto`](@ref)                   | Extract the text on the image as an ALTO xml format.
| [`tess_confidences`](@ref)            | Retrieve the condidences of the OCR results.
| [`tess_delete!`](@ref)                | Manually free a [`TessInst`](@ref) or [`TessPipeline`](@ref) object.
| [`tess_available_languages`](@ref)    | Retrieve the list of languages that can be loaded.
| [`tess_get_param`](@ref)              | Retrieve the value of a parameter from the Tesseract engine.
| [`tess_hocr`](@ref)                   | Extract the text on the image as a HOCR xml format.
| [`tess_image`](@ref)                  | Set the image to OCR.
| [`tess_init`](@ref)                   | Change the languages to OCR.
| [`tess_initialized_languages`](@ref)  | Retrieve the list of languages loaded by [`tess_init`](@ref).
| [`tess_loaded_languages`](@ref)       | Retrieve the list of languages actually loaded.
| [`tess_lstm_box`](@ref)               | Extract the text on the image as a LSTM box text format.
| [`tess_params`](@ref)                 | Retrieve the list of parameters as a string.
| [`tess_params_parsed`](@ref)          | Retrieve the list of parameters as an array of [`TessParam`](@ref) objects.
| [`tess_parsed_tsv`](@ref)             | Extract the text on the image as a parsed TSV format.
| [`tess_pipeline_alto`](@ref)          | Add an ALTO XML output renderer to a Pipeline.
| [`tess_pipeline_hocr`](@ref)          | Add a HOCR XML output renderer to a Pipeline.
| [`tess_pipeline_lstm_box`](@ref)      | Add a LSTM BOX output renderer to a Pipeline.
| [`tess_pipeline_pdf`](@ref)           | Add a PDF output renderer to a Pipeline.
| [`tess_pipeline_text`](@ref)          | Add a text output renderer to a Pipeline.
| [`tess_pipeline_tsv`](@ref)           | Add a Tabbed Separated Value output renderer to a Pipeline.
| [`tess_pipeline_unlv`](@ref)          | Add a UNLV/UTF-8 renderer to a Pipeline.
| [`tess_pipeline_unlv_latin1`](@ref)   | Add a UNLV/Latin1 renderer to a Pipeline.
| [`tess_pipeline_word_box`](@ref)      | Add a Word BOX output renderer to a Pipeline.
| [`tess_read_config`](@ref)            | Read and set variables from the specified configuration file.
| [`tess_read_debug_config`](@ref)      | Read and set the debug variables from the specified configuration file.
| [`tess_recognize`](@ref)              | Perform the OCR extraction on the image.
| [`tess_resolution`](@ref)             | Set the resolution of the image to OCR.
| [`tess_run_pipeline`](@ref)           | Execute the pipeline, processing multiple pictures.
| [`tess_set_param`](@ref)              | Set the value of a parameter from the Tesseract engine.
| [`tess_text`](@ref)                   | Extract the text on the image as text.
| [`tess_text_box`](@ref)               | Extract the text on the image in text box format.
| [`tess_tsv`](@ref)                    | Extract the text on the image in the TSV text format.
| [`Tsv`](@ref)                         | Object containing the details of a Tabbed Separated Value (TSV) line.
| [`tess_unlv`](@ref)                   | Extract the text on the image in the UNLV UTF-8 text format.
| [`tess_unlv_latin1`](@ref)            | Extract the text on the image in the UNLV Latin1 format.
| [`tess_word_box`](@ref)               | Extract the text on the image in word box text format.

## U

| Type                       | Description
| :------------------------- | :----------
| [`update_pdf_font`](@ref)  | Update the PDF font file needed to create PDF images.
| [`update_languages`](@ref) | Update the language data files needed to OCR an image.
