# Load languages

```jldoctest
julia> using Tesseract

julia> download_languages("eng+spa+fra")
true

julia> instance = TessInst("eng+spa")
Allocated Tesseract instance.

julia> tess_init(instance, "fra")
true
```

All OCR call are executed with the [TessInst](ref/tess_inst.md) object.  When the TessInst object is created you specify which languages you want to be able to OCR.  You can switch between languages on the fly by calling [tess_init](ref/tess_init.md) with a different set of languages.

For all calls, if you don't specify a language English is assumed.  So for scanning English text you would just need to do:

```jldoctest
julia> using Tesseract

julia> download_languages()
true

julia> instance = TessInst()
Allocated Tesseract instance.

julia> tess_init(instance)
true
```
