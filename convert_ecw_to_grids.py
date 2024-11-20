import os
from qgis.core import (
    QgsApplication,
    QgsRasterLayer,
    QgsRasterFileWriter,
    QgsRectangle,
    QgsCoordinateReferenceSystem,
)

# Initialize QGIS Application
QgsApplication.setPrefixPath("D:\Software\QGIS", True)  # Adjust to your QGIS path
qgs = QgsApplication([], False)
qgs.initQgis()

def convert_ecw_to_grids(ecw_path, output_dir, grid_size):
    """
    Converts an ECW file to multiple TIF grid tiles.
    
    :param ecw_path: Path to the input ECW file.
    :param output_dir: Directory to save the grid tiles.
    :param grid_size: Size of each grid in pixels.
    """
    # Load ECW as Raster Layer
    raster_layer = QgsRasterLayer(ecw_path, "ECW Layer")
    if not raster_layer.isValid():
        print("Failed to load ECW file.")
        return
    
    provider = raster_layer.dataProvider()
    extent = raster_layer.extent()
    cols = int((extent.width()) / grid_size)
    rows = int((extent.height()) / grid_size)

    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)

    for i in range(cols):
        for j in range(rows):
            # Define the extent for the current grid
            grid_extent = QgsRectangle(
                extent.xMinimum() + i * grid_size,
                extent.yMinimum() + j * grid_size,
                extent.xMinimum() + (i + 1) * grid_size,
                extent.yMinimum() + (j + 1) * grid_size,
            )

            # Configure output TIF file
            grid_output = os.path.join(output_dir, f"grid_{i}_{j}.tif")
            writer = QgsRasterFileWriter(grid_output)
            writer.setCrs(QgsCoordinateReferenceSystem(raster_layer.crs()))

            # Write the grid
            writer.writeRaster(
                provider,
                grid_size,  # Width of the grid
                grid_size,  # Height of the grid
                grid_extent,  # Extent of the grid
                raster_layer.crs(),  # CRS of the raster
            )

            print(f"Grid {i},{j} saved to {grid_output}")

# Example usage
ecw_path = "D:\\Documents\\cyber\\projects\\vaayu\\code\\data\\Gujarat_5\\Gujarat 2\\ortho_lalpur(511638)_3857.ecw"  # Path to your ECW file
output_dir = "D:\\Documents\\cyber\\projects\\vaayu\\code\\generated_grids\\"  # Path to save the grids
grid_size = 500  # Adjust based on your resolution or processing needs

convert_ecw_to_grids(ecw_path, output_dir, grid_size)

# Cleanup QGIS Application
qgs.exitQgis()
