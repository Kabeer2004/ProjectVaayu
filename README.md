# ProjectVaayu

The official repository for Project Vaayu - SIH 1705

## important commands:

- Merging TIF Grid back into one large TIF

```
gdalwarp -of GTiff path\to\grid_tifs\*.tif path\to\output_combined.tif
```

- Converting ECW to TIF

```
gdal_translate -of GTiff -co "COMPRESS=LZW" input.ecw output.tif
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
    "EXTENT": "Calculate from Layer and Choose your ECW Raster Layer",
    "EXTRA": "",
    "FIELD": null,
    "HEIGHT": {pixel height of base raster layer},
    "INIT": null,
    "INPUT": "input_shapefile.shp",
    "INVERT": false,
    "NODATA": 0.0,
    "OPTIONS": "COMPRESS=DEFLATE|PREDICTOR=2|ZLEVEL=9|mask=1|ALPHA=YES|TILED=YES",
    "OUTPUT": "output_raster.tif",
    "UNITS": 1,
    "USE_Z": false,
    "WIDTH": {pixel height of base raster layer}
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

Created raster_mask_pipeline.bat for step 2 and 3

## Pipeline to Create MultiClass Files from Binary

Step 1: Assign Unique Values to Each Binary Mask
Use gdal_calc.py to multiply each binary mask by a unique value corresponding to the class.

Example:

```
gdal_calc -A binary_mask_1.tif --outfile=class_mask_1.tif --calc="A*1" --NoDataValue=0 --type=Byte
gdal_calc -A binary_mask_2.tif --outfile=class_mask_2.tif --calc="A*2" --NoDataValue=0 --type=Byte
gdal_calc -A binary_mask_3.tif --outfile=class_mask_3.tif --calc="A*3" --NoDataValue=0 --type=Byte
```

Here, 1, 2, and 3 are unique values representing each class. Replace them with your desired class IDs or color indices.

Step 2: Combine the Individual Class Masks
Once each mask has a unique value, use gdal_merge.py to combine them into a single raster. Set the -n flag to define the NoData value and ensure proper overwriting behavior for overlapping areas (the last layer in the input list will take precedence).

Example:

```
gdal_merge.py -n 0 -o combined_multiclass_raster.tif -a_nodata 0 class_mask_1.tif class_mask_2.tif class_mask_3.tif

gdaldem color-relief combined_multiclass_raster.tif color_table.txt colored_multiclass_raster.tif
```

## Color Table:

| Features       | Color   | HTML Color Notation (Hex) | Layer Index |
| -------------- | ------- | ------------------------- | ----------- |
| Roads          | Red     | #FF0000                   | 1           |
| Water Bodies   | Blue    | #0000FF                   | 2           |
| RCC Rooftop    | Green   | #008000                   | 3           |
| Tin Rooftop    | Yellow  | #FFFF00                   | 4           |
| Tiled Rooftop  | Magenta | #FF00FF                   | 5           |
| Other Rooftops | Brown   | #A52A2A                   | 6           |

## Polygonizing the output mask (large .tif that we get from recombining tiles) to SHP

```cmd
gdal_polygonize built_up_raster_lalpur.tif -f "ESRI Shapefile" test_builtup_lalpur.shp
```
