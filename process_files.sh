#!/bin/bash

# Collect all input files
INPUT_FILES=("$@")
OUTPUT_DIR="./tiles"
ZOOM_LEVELS="0-10" # For 500m data, consider 0-9 or 0-10

if [ "$#" -lt 1 ]; then
    echo "Usage: ./process_file.sh <input_file1> [input_file2 ...]"
    exit 1
fi

# Detect OS for CPU count
if [[ "$OSTYPE" == "darwin"* ]]; then
    THREADS=$(sysctl -n hw.ncpu)
else
    THREADS=$(nproc 2>/dev/null || echo 2)
fi

rm -rf "$OUTPUT_DIR" temp_mercator.tif merged_source.vrt

# Step 0: Merge multiple inputs if necessary
if [ "${#INPUT_FILES[@]}" -gt 1 ]; then
    echo "--- Step 0: Merging multiple source files ---"
    gdalbuildvrt merged_source.vrt "${INPUT_FILES[@]}"
    ACTUAL_INPUT="merged_source.vrt"
else
    ACTUAL_INPUT="${INPUT_FILES[0]}"
fi

echo "--- Step 1: Reprojecting (with Pole Clipping) ---"
# Using a slightly smaller bounding box to avoid edge cases at the poles
# -20037508.34 is the limit; we'll use 20037508 to be safe.
gdalwarp -t_srs EPSG:3857 \
         -te -20037508 -20037508 20037508 20037508 \
         -r bilinear \
         -of GTiff \
         -co COMPRESS=LZW \
         -overwrite \
         "$ACTUAL_INPUT" temp_mercator.tif

echo "--- Step 2: Generating XYZ Tiles ---"
gdal2tiles --xyz --zoom=$ZOOM_LEVELS \
    --processes=$THREADS --webviewer=none \
    temp_mercator.tif "$OUTPUT_DIR"

rm temp_mercator.tif
[ -f merged_source.vrt ] && rm merged_source.vrt

echo "--- Step 3: Converting PNGs to WebP ---"
# Convert PNGs to WebP (Quality 75, Effort 6)
find "$OUTPUT_DIR" -name "*.png" -print0 | xargs -0 -I {} -P $THREADS \
    sh -c 'cwebp -q 75 -m 6 "{}" -o "${1%.png}.webp" && rm "{}"' -- {}

echo "--- Done! ---"