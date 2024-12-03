@echo off
setlocal enabledelayedexpansion

rem Set the input ECW file path (ensure the quotes are correctly handled)
set INPUT="D:\Documents\cyber\projects\vaayu\repo\data\Chhattisgarh\Chhattisgarh_2\my_files\amora_tin_builtup_final.tif"

rem Set the desired output directory (make sure to change this path if needed)
set OUT_DIR="D:\Documents\cyber\projects\vaayu\repo\data\Chhattisgarh\Chhattisgarh_2\my_files\amora_tin_builtup_tiles"

rem Set the tile dimensions (in pixels)
set TILE_WIDTH=3000
set TILE_HEIGHT=3000

rem Set the number of rows and columns (you can adjust this based on your image size)
set ROWS=4
set COLS=5

rem Check if the output directory exists, and create it if it doesn't
if not exist "%OUT_DIR%" (
    echo The directory "%OUT_DIR%" does not exist. Creating it now...
    mkdir "%OUT_DIR%"
)

rem Loop through rows and columns to generate the tiles
for /L %%r in (0,1,%ROWS%) do (
    for /L %%c in (0,1,%COLS%) do (
        rem Calculate the x and y offsets for each tile
        set /A X_OFFSET=%%c*%TILE_WIDTH%
        set /A Y_OFFSET=%%r*%TILE_HEIGHT%
        
        rem Define the output file name and path for each tile
        set OUTPUT_FILE="%OUT_DIR%\amora_output_tile_%%r_%%c.tif"
        
        rem Run gdal_translate with the calculated offsets
        echo Generating tile %%r_%%c...
        rem Use delayed expansion to correctly pass the output file path
        gdal_translate -of GTiff -srcwin !X_OFFSET! !Y_OFFSET! %TILE_WIDTH% %TILE_HEIGHT% %INPUT% !OUTPUT_FILE!
    )
)

endlocal
