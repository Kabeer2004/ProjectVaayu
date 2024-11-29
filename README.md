# ProjectVaayu

The official repository for Project Vaayu - SIH 1705

## important commands:

- Merging TIF Grid back into one large TIF

```
gdalwarp -of GTiff path\to\grid_tifs\*.tif path\to\output_combined.tif
```

## Shapefile Rasterization Settings I used in QGIS

```
{
  "area_units": "m2",
  "distance_units": "meters",
  "ellipsoid": "EPSG:7030",
  "inputs": {
    "BURN": 1.0,
    "DATA_TYPE": 0,
    "EXTENT": "8098996.378200000,8099677.155200000,2636558.407300000,2637264.506000000 [EPSG:3857]",
    "EXTRA": "",
    "FIELD": null,
    "HEIGHT": 0.03,
    "INIT": null,
    "INPUT": "D:/Documents/cyber/projects/vaayu/repo/data/Gujarat/LalPur, Suragpur/Gujarat_Build_Up_Area_Type.shp",
    "INVERT": false,
    "NODATA": 0.0,
    "OPTIONS": "COMPRESS=DEFLATE|PREDICTOR=2|ZLEVEL=9|mask=1|ALPHA=YES|TILED=YES",
    "OUTPUT": "D:/Documents/cyber/projects/vaayu/repo/data/Gujarat/built_up_modified.tif",
    "UNITS": 1,
    "USE_Z": false,
    "WIDTH": 0.03
  }
}
```

## Shapefile to Alpha Mask TIF Pipeline

- Lalpur Example

```
gdal_rasterize -l Gujarat_Build_Up_Area_Type -burn 1.0 -tr 1.0 1.0 -te 7937898.8094 2473668.505 8099451.5942 2637166.9567 -a_nodata 0.0 -ot Byte -of GTiff -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 -co TILED=YES "D:/Documents/cyber/projects/vaayu/repo/data/Gujarat/LalPur, Suragpur/Gujarat_Build_Up_Area_Type.shp" temp_raster.tif

gdal_translate -of GTiff -b 1 -mask 1 -a_nodata 0 -co ALPHA=YES temp_raster.tif raster_with_alpha.tif

gdal_calc -A raster_with_alpha.tif --outfile=final_raster_white.tif --calc="255*(A>0)" --NoDataValue=0 --type=Byte
```
