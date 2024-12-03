@echo off
rem Batch script for creating a raster with alpha transparency and a white + alpha mask

rem Set input raster file
set INPUT_RASTER=D:\Documents\cyber\projects\vaayu\repo\data\Gujarat\my_files\suragpur_tiled_builtup.tif

rem Extract directory, filename, and extension from the input file
for %%F in ("%INPUT_RASTER%") do (
    set INPUT_DIR=%%~dpF
    set INPUT_NAME=%%~nF
    set INPUT_EXT=%%~xF
)

rem Output files
set RASTER_WITH_ALPHA=%INPUT_DIR%%INPUT_NAME%_alpha%INPUT_EXT%
set FINAL_MASK=%INPUT_DIR%%INPUT_NAME%_final%INPUT_EXT%

rem GDAL commands (ensure gdal_translate and gdal_calc are in PATH)
set GDAL_TRANSLATE=gdal_translate
set GDAL_CALC=gdal_calc

rem Step 1: Create a raster with alpha transparency
echo Generating alpha mask...
%GDAL_TRANSLATE% -of GTiff -b 1 -mask 1 -a_nodata 0 -co ALPHA=YES "%INPUT_RASTER%" "%RASTER_WITH_ALPHA%"
if errorlevel 1 (
    echo Error: Failed to generate alpha mask.
    pause
    exit /b 1
)

rem Step 2: Create a white + alpha mask
echo Generating white + alpha mask...
%GDAL_CALC% -A "%RASTER_WITH_ALPHA%" --outfile="%FINAL_MASK%" --calc="255*(A>0)" --NoDataValue=0 --type=Byte
if errorlevel 1 (
    echo Error: Failed to generate white + alpha mask.
    pause
    exit /b 1
)

echo Process complete.
echo Alpha mask saved to: %RASTER_WITH_ALPHA%
echo Final mask saved to: %FINAL_MASK%
pause
