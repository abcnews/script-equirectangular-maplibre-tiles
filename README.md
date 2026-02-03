# Equirectangular to Slippy Map Tiles

A automated utility to convert high-resolution equirectangular images (Plate Carrée) into Web Mercator slippy map tiles (XYZ format). This is ideal for creating custom map layers for MapLibre GL JS, Leaflet, or OpenLayers.

## Dependencies

- **Docker**: Used to run the GDAL environment without requiring local installation of GIS tools.

## Quick Start

1. **Download the source imagery** (optional/example):
   ```bash
   ./getBlueMarbleTiles
   ```
   This will download the high-resolution 500m Blue Marble tiles into a `./src` folder.

2. **set up the Docker container**:
  ```bash
  docker build -t $IMAGE_NAME .
  ```
3. **Run the processing script**:

   ```bash
   # For a single file
   ./go.sh your_source_image.tif

   # For the high-res Blue Marble tiles 
   ./go.sh src/*.tif
   ```

The script will:
1. Build the Docker image (first run only).
2. **Merge multiple inputs** into a single virtual dataset (VRT) if more than one file is provided.
3. Reproject the image to EPSG:3857 (Web Mercator).
4. Generate XYZ tiles at zoom levels 0-6 (can be adjusted in `process_file.sh`).
5. Convert all PNG tiles to optimized WebP images.
6. Clean up temporary files.

The resulting tiles will be available in the `./tiles` directory.

### Handling High-Resolution Data (e.g. 500m Blue Marble)
When processing the full 500m resolution Blue Marble dataset (which comes in 8 tiles), the script automatically uses `gdalbuildvrt` to treat them as a single continuous map. 

**Note:** For 500m resolution, you should likely increase the `ZOOM_LEVELS` in `process_file.sh` to `0-9` or `0-10` to capture the full detail.

## Example Data Source

A great source for high-resolution planetary imagery is NASA's **Blue Marble: Next Generation**:
- [NASA Blue Marble - Base Topography and Bathymetry](https://science.nasa.gov/earth/earth-observatory/blue-marble-next-generation/base-topography-bathymetry/)

