#!/bin/bash

# Ensure we have at least one input file
if [ "$#" -lt 1 ]; then
    echo "Usage: ./go.sh <input_tif_1> [input_tif_2 ...]"
    exit 1
fi

# Run the processing script inside the container
# Mounting the current directory to /data in the container
echo "--- Running GDAL Processing in Docker ---"
docker run --rm -v "$(pwd):/data" gdal-processor:local ./process_file.sh "$@"
