@echo off
setlocal enabledelayedexpansion

rem Set the input GeoTIFF file path (the merged file)
set INPUT_TIF="D:\Documents\cyber\projects\vaayu\code\data\Gujarat\merged_output.tif"

rem Set the desired output ECW file path
set OUTPUT_ECW="D:\Documents\cyber\projects\vaayu\code\data\Gujarat\merged_output.ecw"

rem Run gdal_translate to convert the TIF to ECW
echo Converting TIF to ECW...

gdal_translate -of ECW %INPUT_TIF% %OUTPUT_ECW%

echo Conversion complete.

endlocal
