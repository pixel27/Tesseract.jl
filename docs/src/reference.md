# Reference

## Types

```@docs
TessInst
Pix
PixBox
TessParam
Tsv
```

## Enumerations

```@docs
IFF
```

## General
```@docs
lept_version
pix_delete!
sample_pix
sample_tiff
tess_delete!
tess_version
```

## Image loading
```@docs
pix_read
pix_read_bmp
pix_read_gif
pix_read_jp2k
pix_read_jpeg
pix_read_png
pix_read_pnm
pix_read_spix
pix_read_tiff
pix_read_webp
```

## Image saving
```@docs
pix_write
pix_write_implied_format
pix_write_bmp
pix_write_gif
pix_write_jp2k
pix_write_jpeg
pix_write_pdf
pix_write_pam
pix_write_png
pix_write_pnm
pix_write_ps
pix_write_spix
pix_write_tiff
pix_write_webp
```

## Image general
```@docs
pix_get_depth
pix_get_dimensions
```

## Data files
```@docs
download_languages
update_languages
```

## OCR configuration
```@docs
TessInst(languages::AbstractString, dataPath::AbstractString)
tess_available_languages
tess_image
tess_init
tess_initialized_languages
tess_loaded_languages
tess_print_variables
tess_print_variables_parsed
tess_read_config
tess_read_debug_config
tess_resolution
```

## OCR text
```@docs
tess_alto
tess_confidences
tess_hocr
tess_lstm_box
tess_parsed_tsv
tess_recognize
tess_text
tess_text_box
tess_tsv
tess_unlv
tess_word_box
```
