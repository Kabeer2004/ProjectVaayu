@echo off
rem Input vector and ECW files
set VECTOR="D:\Documents\cyber\projects\vaayu\repo\data\Gujarat\LalPur, Suragpur\Gujarat_Build_Up_Area_Type.shp"
set ECW="D:\Documents\cyber\projects\vaayu\repo\data\Gujarat\Ortho_SURAGPUR(515578)_28_04_2022_3857.ecw"

rem Output directory for all generated files
set OUT_DIR="output"
set TILE_RES=1.0

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

for %%v in (VillageA VillageB VillageC) do (
    echo Processing %%v...

    rem Filter vector layer for the current village
    ogr2ogr -where "village_name='%%v'" "%OUT_DIR%\%%v.shp" %VECTOR%

    rem Get extents of the current village (replace <xmin>, <ymin>, etc. dynamically if known)
    rem For automation, use ogrinfo or similar to fetch extents
    set XMIN=<xmin>
    set YMIN=<ymin>
    set XMAX=<xmax>
    set YMAX=<ymax>

    rem Export the ECW file for the current village
    echo Clipping ECW for %%v...
    gdal_translate -projwin !XMIN! !YMAX! !XMAX! !YMIN! %ECW% "%OUT_DIR%\%%v_ecw.tif"

    rem Rasterize the vector layer for the current village
    echo Rasterizing vector layer for %%v...
    gdal_rasterize -burn 1 -tr %TILE_RES% %TILE_RES% -te !XMIN! !YMIN! !XMAX! !YMAX! -a_nodata 0 -ot Byte -of GTiff -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 -co TILED=YES "%OUT_DIR%\%%v.shp" "%OUT_DIR%\%%v_rasterized.tif"

    rem Add transparency and convert rasterized vector to binary mask
    echo Adding transparency to rasterized vector for %%v...
    gdal_translate -of GTiff -b 1 -mask 1 -a_nodata 0 -co ALPHA=YES "%OUT_DIR%\%%v_rasterized.tif" "%OUT_DIR%\%%v_with_alpha.tif"

    gdal_calc.py -A "%OUT_DIR%\%%v_with_alpha.tif" --outfile="%OUT_DIR%\%%v_final.tif" --calc="255*(A>0)" --NoDataValue=0 --type=Byte

    echo Finished processing %%v.
)

echo All processing complete!
