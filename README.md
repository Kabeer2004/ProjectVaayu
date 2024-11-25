# ProjectVaayu

The official repository for Project Vaayu - SIH 1705

## important commands:

- Merging TIF Grid back into one large TIF
  gdalwarp -of GTiff path\to\grid_tifs\*.tif path\to\output_combined.tif

## Shapefile to Alpha Mask TIF Pipeline

- Lalpur Example

gdal_rasterize -l Gujarat_Build_Up_Area_Type -burn 1.0 -tr 1.0 1.0 -te 7937898.8094 2473668.505 8099451.5942 2637166.9567 -a_nodata 0.0 -ot Byte -of GTiff -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 -co TILED=YES "D:/Documents/cyber/projects/vaayu/repo/data/Gujarat/LalPur, Suragpur/Gujarat_Build_Up_Area_Type.shp" temp_raster.tif

gdal_translate -of GTiff -b 1 -mask 1 -a_nodata 0 -co ALPHA=YES temp_raster.tif raster_with_alpha.tif

gdal_calc -A raster_with_alpha.tif --outfile=final_raster_white.tif --calc="255\*(A>0)" --NoDataValue=0 --type=Byte
