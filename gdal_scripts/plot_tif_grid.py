import os
import rasterio
import matplotlib.pyplot as plt
import numpy as np

# Set the directory where the TIFF files are stored
tif_dir = "./data/Gujarat/tiles_output"

# List of TIFF filenames in the directory (assuming the TIFFs are numbered sequentially)
tif_files = [f for f in os.listdir(tif_dir) if f.endswith('.tif')]

# Number of rows and columns for the grid
rows = 21  # Change to the number of rows in your grid
cols = 21  # Change to the number of columns in your grid

# Create a plot with subplots arranged in rows and columns
fig, axes = plt.subplots(rows, cols, figsize=(15, 15))

# Loop through each subplot and load the corresponding TIFF file
for i, ax in enumerate(axes.flat):  # Flatten the 2D axes array for easy iteration
    if i < len(tif_files):  # Check if there's a corresponding TIFF file
        tif_file = os.path.join(tif_dir, tif_files[i])
        
        # Open the TIFF file using Rasterio
        with rasterio.open(tif_file) as src:
            # Read the data (assuming single band or read the first band)
            data = src.read(1)  # Read the first band
            
            # Plot the data using Matplotlib
            ax.imshow(data, cmap='gray', interpolation='none')
            ax.set_title(f"Tile {i + 1}")
            ax.axis('off')  # Turn off the axis labels

# Adjust layout
plt.tight_layout()
plt.show()
