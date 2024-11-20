@echo off
setlocal enabledelayedexpansion

rem Set the input directory where the tiles are located
set TILE_DIR="D:\Documents\cyber\projects\vaayu\code\data\Gujarat\tiles_output"

rem Set the output path for the merged image (you can change this to any format, e.g., GeoTIFF, JPEG, etc.)
set OUTPUT_FILE="D:\Documents\cyber\projects\vaayu\code\data\Gujarat\merged_output.tif"

rem Set the current directory for the tile list
set SCRIPT_DIR=%~dp0

rem Create a temporary file to store the list of tile files
set TILE_LIST=%SCRIPT_DIR%tile_list.txt
del %TILE_LIST%

rem Loop through the tile directory and create a list of all .tif files
for %%f in (%TILE_DIR%\*.tif) do (
    echo %%f >> %TILE_LIST%
)

rem Run gdal_merge with the input file list to merge the tiles
echo Merging tiles into a single output file...

rem Read the tile list file and pass each tile to gdal_merge
set GDAL_CMD=gdal_merge -o %OUTPUT_FILE% -of GTiff
for /f "tokens=*" %%a in (%TILE_LIST%) do (
    set GDAL_CMD=!GDAL_CMD! %%a
)

rem Execute the final gdal_merge command
!GDAL_CMD!

rem Clean up the temporary list file
del %TILE_LIST%

endlocal
