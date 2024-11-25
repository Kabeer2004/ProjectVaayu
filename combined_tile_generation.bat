@echo off
rem Batch script to split shapefile into grids and rasterize each grid cell (Attempt)

setlocal enabledelayedexpansion

rem Input shapefile
set VECTOR="D:\Documents\cyber\projects\vaayu\repo\data\Gujarat\LalPur, Suragpur\Gujarat_Build_Up_Area_Type.shp"

rem Output directory for rasterized tiles
set OUT_DIR="D:\Documents\cyber\projects\vaayu\repo\data\Gujarat\vector_tiles_output"

rem Tile size (in map units, matching the CRS of the shapefile)
set TILE_WIDTH=4000
set TILE_HEIGHT=4000

rem Overall extent of the shapefile (replace these with actual extent values from QGIS or `ogrinfo`)
set X_MIN=7937898.8094
set Y_MIN=2473668.505
set X_MAX=8099451.5942
set Y_MAX=2637166.9567

rem Ensure the output directory exists
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

rem Loop through rows and columns to define grid tiles
for /L %%x in (%X_MIN%, %TILE_WIDTH%, %X_MAX%) do (
    for /L %%y in (%Y_MIN%, %TILE_HEIGHT%, %Y_MAX%) do (
        rem Define the bounding box for the current tile
        set /A TILE_X_MIN=%%x
        set /A TILE_Y_MIN=%%y
        set /A TILE_X_MAX=%%x + %TILE_WIDTH%
        set /A TILE_Y_MAX=%%y + %TILE_HEIGHT%

        rem Define the output filenames
        set CLIPPED_VECTOR_TILE="%OUT_DIR%\vector_tile_%%x_%%y.shp"
        set RASTERIZED_TILE="%OUT_DIR%\raster_tile_%%x_%%y.tif"

        rem Clip the shapefile to the current tile's extent
        echo Clipping vector tile at %%x, %%y...
        ogr2ogr -spat !TILE_X_MIN! !TILE_Y_MIN! !TILE_X_MAX! !TILE_Y_MAX! -f "ESRI Shapefile" !CLIPPED_VECTOR_TILE! %VECTOR%

        rem Rasterize the clipped vector tile directly
        echo Rasterizing tile at %%x, %%y...
        gdal_rasterize -burn 1 -tr 1.0 1.0 -te !TILE_X_MIN! !TILE_Y_MIN! !TILE_X_MAX! !TILE_Y_MAX! -co COMPRESS=LZW !CLIPPED_VECTOR_TILE! !RASTERIZED_TILE!

        rem Optional: Remove the intermediate clipped vector shapefile
        del /Q /F !CLIPPED_VECTOR_TILE!
    )
)

endlocal
