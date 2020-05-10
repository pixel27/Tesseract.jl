# Tesseract.jl Documentation

The purpose of Tesseract.jl is to provide Julia bindings into the [Tesseract](https://github.com/tesseract-ocr/tesseract) OCR library.  Tesseract.jl tries to keep close to the Tesseract API but does deviate some to make the API more Julia like and simplier.

The Tesseract library makes use of the [Leptonica ](https://github.com/DanBloomberg/leptonica) to perform image loading.  So in order to provide an easier API Tesseract.jl exports methods that call into the Leptonica library as well.  Mostly around image loading and saving, but additional function calls may be exposed in the future.

Many of the Tesseract function calls return flat text which is not really usable to an application.  Tesseract.jl usually provides calls that will parse this text into something more useful for processing.  This processing is all implemented in Julia to parse the responses from Tesseract.

One note here, Tesseract has two engines the old engine and new engine.  Currently I only plan to provide the API for the new engine.  However the new engine (currently) doesn't support identifying italics, bold, and such, the old engine did support that.  Hopefully this feature will be implemented in the new engine in the near future.

## Sample functions

Tesseract.jl provides two demo methods to help people explore/test the API easier.  [`sample_tiff()`](@ref) provides a TIFF formatted image with text as a `Vector{UInt8}`.  The data can be saved to disk and loaded like a normal TIFF image or passed directly to [`pix_read_tiff()`](@ref) to load it into Leptonica as a [`Pix`](@ref) object.  [`sample_pix()`](@ref) provides the same image but already converted to a Leptonica [`Pix`](@ref) object.  The examples found in this documentation and for the methods in the library make heavy use of these functions.

## Processing an image

```jldoctest
julia> using Tesseract

julia> write("sample.tiff", sample_tiff())
31074

julia> pix = pix_read("sample.tiff")
Image (500, 600) at 32ppi

julia> download_languages()
true

julia> instance = TessInst()
Allocated Tesseract instance.

julia> tess_image(instance, pix)

julia> tess_resolution(instance, 72)

julia> text = tess_text(instance);
```

The first command `write()` is just saving the tiff image to disk.  Normally you would have your own image you want to OCR.  We can load multiple image formats including BMP, GIF, JP2K, JPEG, PNG, PNM, SPIX, TIFF, and WEBP.

The second line `pix = pix_read("sample.tiff")` is simply loading the file into memory. [`pix_read()`](@ref) is the generic reader that can read all the image formats.  There are also specific functions for each image type so [`pix_read_png()`](@ref) would read PNG images, [`pix_read_gif()`](@ref) would read GIF images, and so forth.

[`download_languages()`](@ref) is an important function.  Tesseract.jl does **NOT** ship with the Tesseract data files.  The data files have to be downloaded separately. These files run around 15MB apiece and there is one for every language supported.  You probably only want to download the languages you are interested in.  By default Tesseract.jl assumes you are using the english language.  [`download_languages()`](@ref) will download the languages you requested from [https://github.com/tesseract-ocr/tessdata_best](https://github.com/tesseract-ocr/tessdata_best).

Next a Tesseract instance is created with [`TessInst()`](@ref).  You can use a single instance to process multiple images, so this is a create once and reuse situation.  The Tesseract library is mostly thread safe, however setting the image sets the image for the instance not the thread.  So if you want to use multiple threads to process images simultaneously each thread should use it's own instance of [`TessInst`](@ref).

Now Tesseract is provided with the image to process with the [`tess_image`](@ref) call.  [`tess_resolution`](@ref) provides the resolution of the image in pixels per inch (PPI).

Finally [`tess_text`](@ref) can be called to perform the OCR and return the text. [`tess_confidences`](@ref) can also be called to get the engine's confidence in each word it decoded.

## Using another language

Please note the sample image is in English so I need to include the English language data files for Tesseract to actually decode the test image.

```jldoctest
julia> using Tesseract

julia> write("sample.tiff", sample_tiff())
31074

julia> pix = pix_read("sample.tiff")
Image (500, 600) at 32ppi

julia> download_languages("eng+spa+fra")
true

julia> instance = TessInst("eng+spa+fra")
Allocated Tesseract instance.

julia> tess_image(instance, pix)

julia> tess_resolution(instance, 72)

julia> text = tess_text(instance);
```

This example is exactly like the previous example except it will detect Spanish and French text not english.  To accomplish this [`download_languages()`](@ref) is called with `spa+fra` which are the [ISO 639-3](https://en.wikipedia.org/wiki/ISO_639-3) codes for Spanish and French.  This will cause those data files to be downloaded from GitHub.  

Next `spa+fra` is passed to [`TessInst()`](@ref) to initialize the OCR engine to decode Spanish and French.  

## Switching languages

[`tess_init()`](@ref) can be called to change the recognized languages on the fly.  So if you wanted to decode an image in Spanish then switch to French for another image you could do the following:

```jldoctest
julia> using Tesseract

julia> write("sample_es.tiff", sample_tiff())
31074

julia> write("sample_fr.tiff", sample_tiff())
31074

julia> pix_en = pix_read("sample_es.tiff")
Image (500, 600) at 32ppi

julia> pix_fr = pix_read("sample_fr.tiff")
Image (500, 600) at 32ppi

julia> download_languages("eng+spa+fra")
true

julia> instance = TessInst("eng+spa")
Allocated Tesseract instance.

julia> tess_image(instance, pix_en)

julia> tess_resolution(instance, 72)

julia> spanish = tess_text(instance);

julia> tess_init(instance, "eng+fra")
true

julia> tess_image(instance, pix_fr)

julia> french = tess_text(instance);
```
