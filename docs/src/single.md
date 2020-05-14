# Process a single image

This method is normally used if you just want to extract the text from an image.  If you want something more like advanced like an ALTO XML, HOCR XML, or PDF file, then you would want to read the next section on scanning multiple files.

```jldoctest
using Tesseract

download_languages()

instance = TessInst()
pix = sample_pix()

tess_image(instance, pix)
tess_resolution(instance, 72)

text = tess_text(instance)

print(text)

# output

No one would have believed in the last years of the

the nineteenth century that this world was being watched
watched keenly and closely by intelligences greater than
than man’s and yet as mortal as his own; that as men busied
busied themselves about their various concerns they were
were scrutinised and studied, perhaps almost as narrowly as
as a man with a microscope might scrutinise the transient
transient creatures that swarm and multiply in a drop of

of water. With infinite complacency men went to and fro over
over this globe about their little affairs, serene in their
their assurance of their empire over matter. It is possible
possible that the infusoria under the microscope do the

the same. No one gave a thought to the older worlds of space
space as sources of human danger, or thought of them only to
to dismiss the idea of life upon them as impossible or

or improbable. It is curious to recall some of the mental
mental habits of those departed days. At most terrestrial
terrestrial men fancied there might be other men upon Mars,
Mars, perhaps inferior to themselves and ready to welcome a
a missionary enterprise. Vet across the gulf of space, minds
minds that are to our minds as ours are to those of the

the beasts that perish, intellects vast and cool and

and unsympathetic, regarded this earth with envious eyes
eyes, and slowly and surely drew their plans against us. And
And early in the twentieth century came the great

great disillusionment.
```

This example uses [sample\_pix](ref/sample_pix.md) to get an image with text to test with.  Normally you would use [pix\_read](ref/pix_read.md) to load an image from disk.  Next [tess\_image](ref/tess_image.md) is called to pass the image to Tesseract for OCRing.  You need to call [tess\_resolution](ref/tess_resolution.md) to let Tesseract know the PPI of the image.  For a scanned image this will probably be 300, 600, or higher.

Finally to get the text Tesseract found you make a call to [tess\_text](ref/tess_text.md) to retrieve the text.  This method will call [tess\_recognize](ref/tess_recognize.md) if it has not been called already.  You might also be interested in calling [tess\_confidences](ref/tess_confidences.md) to get Tesseract's confidence in the OCR process for each word.  Calling [tess\_parsed\_tsv](ref/tess_parsed_tsv.md) is also helpful to get the details for each word found on the page.
