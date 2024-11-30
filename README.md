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

## Multi-Village ECW to Raster and Mask Layer

To handle ECW files with multiple villages and generate rasterized layers for each village separately, you need to:

1. **Isolate the features (buildings, roads, etc.) for each village**:

   - Use an attribute in the vector layer that identifies the village (e.g., `village_name` or `village_id`).
   - Filter the vector data to extract features for each village.

2. **Export the rasterized vector layers for each village**:

   - Use the extent of each village to clip the ECW and vector data.
   - Rasterize the filtered vector data within the specific village bounds.

3. **Export the ECW for each village**:
   - Clip the ECW using the extent of the village.

Here’s a detailed **workflow**:

---

### **Step 1: Isolate Village Features**

Filter the vector layer by village using `ogr2ogr`:

```cmd
ogr2ogr -where "village_name='VillageA'" villageA.shp Gujarat_Build_Up_Area_Type.shp
ogr2ogr -where "village_name='VillageB'" villageB.shp Gujarat_Build_Up_Area_Type.shp
```

This creates separate shapefiles (`villageA.shp`, `villageB.shp`) for each village.

If you’re unsure of the attribute name for villages:

- Open the attribute table in QGIS or use `ogrinfo`:
  ```cmd
  ogrinfo -al -so Gujarat_Build_Up_Area_Type.shp
  ```

---

### **Step 2: Determine Village Extents**

Use `ogrinfo` to get the bounding box for each village shapefile:

```cmd
ogrinfo -al -so villageA.shp
```

Look for the `Extent:` field in the output, which provides the coordinates (`xmin, ymin, xmax, ymax`).

---

### **Step 3: Clip the ECW for Each Village**

Use `gdal_translate` to clip the ECW based on the village extents:

```cmd
gdal_translate -projwin xmin ymax xmax ymin ortho.ecw villageA_raster.tif
```

Repeat this for each village, replacing `xmin`, `ymin`, `xmax`, and `ymax` with the extents of the village.

---

### **Step 4: Rasterize Vector Layers for Each Village**

Use `gdal_rasterize` to rasterize the filtered vector data for each village:

```cmd
gdal_rasterize -burn 1 -tr 1.0 1.0 -te xmin ymin xmax ymax -a_nodata 0 -ot Byte -of GTiff -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 -co TILED=YES villageA.shp villageA_rasterized.tif
```

- Replace `xmin`, `ymin`, `xmax`, and `ymax` with the extents of the village.

---

### **Step 5: Export Rasterized Vector with Transparency**

Add transparency and ensure the features are represented as white (255):

```cmd
gdal_translate -of GTiff -b 1 -mask 1 -a_nodata 0 -co ALPHA=YES villageA_rasterized.tif villageA_with_alpha.tif

gdal_calc.py -A villageA_with_alpha.tif --outfile=villageA_final.tif --calc="255*(A>0)" --NoDataValue=0 --type=Byte
```

## Polygonizing the output mask (large .tif that we get from recombining tiles) to SHP

```cmd
gdal_polygonize built_up_raster_lalpur.tif -f "ESRI Shapefile" test_builtup_lalpur.shp
```
