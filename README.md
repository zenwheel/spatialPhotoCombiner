# spatialPhotoCombiner

I was looking for a way to convert the `.MPO` files from the [Fujifilm FinePix Real 3D W3](https://www.dpreview.com/products/fujifilm/compacts/fujifilm_w3) to spatial images compatible with Apple Photos and Vision Pro. Nothing did exactly what I wanted, so I made some tweaks to the code in `picCombiner` in [vision-utils](https://github.com/studiolanes/vision-utils) to allow a field of view to be specified.

## Usage

```
USAGE: spatialPhotoCombiner --left <left> --right <right> --output <output> [--hfov <hfov>]

OPTIONS:
  -l, --left <left>       The path to the left image.
  -r, --right <right>     The path to the right image.
  -o, --output <output>   The output path for the combined HEIC image.
  --hfov <hfov>           Horizontal field-of-view (in degrees). (default: 55.0)
  -h, --help              Show help information.
```

I am using it in a script which uses [mpoSplit](https://github.com/AlbrechtL/mposplit) to extract the left and right images from the `.MPO` file, then using the field of view for the Fuji Camera of 48°, generate the spatial image and lastly, copies the metadata to the final image.

```
mpoSplit $BASENAME.MPO
spatialPhotoCombiner --hfov 48 -l $BASENAME-L.JPG -r $BASENAME-R.JPG -o $BASENAME.heic
exiftool -overwrite_original -tagsfromfile $BASENAME-L.jpg -all:all $BASENAME.heic
```

## References

* https://www.finnvoorhees.com/words/reading-and-writing-spatial-photos-with-image-io
* https://github.com/studiolanes/vision-utils
* https://leimao.github.io/blog/Camera-Intrinsics-Extrinsics/
* https://blog.mikeswanson.com/spatial