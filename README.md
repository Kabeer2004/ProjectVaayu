# Project Vaayu

The official repository for Project Vaayu - SIH Problem Statement 1705. 

The problem statement (put forward by the Ministry of Panchayati Raj, Government of India) required us to train and optimize an ML model capable of performing feature extraction and identification from drone orthophotos. This was a challenging PS and even though we didn't win at the National Grand Final, Team Vaayu has decided to open-source our code from the competition as well as a [rectified and finished final version of the project that includes a better implementation of the solution](https://github.com/Kabeer2004/ProjectVaayu/tree/main#aaand-finally-the-winner-is). This repo will also serve as a record of the work we performed, the techniques we followed, models we compared and the final results we got.

## Background

1. The Honorable Prime Minister launched the SVAMITVA Scheme on National Panchayati Raj Day, 24th April 2020, with the resolve to enable the economic progress of Rural India by providing "Record of Rights" to every rural household owner. The scheme aims to demarcate inhabited (Abadi) land in rural areas through the latest surveying drone technology, Continuous Operating Reference System (CORS), and Geographic Information System (GIS) technology. The scheme covers multiple aspects such as facilitating the monetization of properties and enabling bank loans, reducing property-related disputes, and supporting comprehensive village-level planning.

2. With the use of the latest drone technology and CORS for the Abadi land survey, the high-resolution and accurate image-based maps (with 50 cm resolution) have facilitated the creation of the most durable record of property holdings in areas without legacy revenue records. These accurate image-based maps provide a clear demarcation of land holdings in a very short time compared to on-ground physical measurement and mapping of land parcels.

## Description of the Problem Statement

i. **Develop an AI model capable of identifying key features in orthophotos with high precision:**  
   Use AI/ML techniques for the extraction of the following features from SVAMITVA Drone Imagery using a cloud-based solution:  
   - Building footprint extraction (built-up area from the drone image and classified rooftop based on observation in the imagery as RCC, Tiled, Tin, and Others). These built-up areas can be used for various services such as solar energy calculation, property tax calculation, etc.  
   - Road feature extraction  
   - Waterbody extraction, etc.

ii. **Achieve a target accuracy of 95% in feature identification.**

iii. **Optimize the model for efficient processing and deployment.**

## Navigating this Repository:
1. [sample_data](https://github.com/Kabeer2004/ProjectVaayu/tree/main/sample_data) contains sample data from the dataset provided to us.
2. [legacy_code](https://github.com/Kabeer2004/ProjectVaayu/tree/main/legacy_code) contains our training notebooks from the competition. This code is undocumented, uncommented and may contain errors.
3. [gdal_scripts](https://github.com/Kabeer2004/ProjectVaayu/tree/main/gdal_scripts) contains batch scripts that can perform various actions using GDAL. These scripts are used at various points of the training data creation and inference pipelines. You may run these batch scripts in the OSGeo4W Shell on Windows which comes packaged with QGIS.
4. [models](https://github.com/Kabeer2004/ProjectVaayu/tree/main/models) contains the weights for the UNet++ models we trained in [this notebook.](https://github.com/Kabeer2004/ProjectVaayu/blob/main/VaayuUnetPPTraining_Notebook.ipynb)

## The Data

### File Formats

The first issue we had to tackle when solving this problem was understanding the data given to us. The Ministry of Panchayati Raj provided us a dataset of geospatial data that included .ecw base-maps and .shp vector files. ECW stands for Enhanced Compression Wavelet and is a proprietary file format used for storing high-resolution geographical images. SHP stands for ShapeFiles which is a vector data format that stores geographic information, such as the location, shape, and attributes of features.

Read more about ECW files [here.](https://en.wikipedia.org/wiki/ECW_(file_format))
Read more about Shapefiles [here.](https://www.precisely.com/glossary/shapefile)

We are attaching sample input and output data from the SVAMITVA dataset [here.](https://github.com/Kabeer2004/ProjectVaayu/tree/main/sample_data)

Here is what an input ECW file looks like when opened in QGIS:

![image](https://github.com/user-attachments/assets/ad9510ff-89d8-4ae7-8607-31fff60412ca)

And here is what the Shapefiles look like when overlayed on top of the ECW layer. (This is for the "Buildings" layer - we also received data for water bodies and roads.)

![image](https://github.com/user-attachments/assets/1f091556-2f8c-494a-9b0d-826f57dee49b)



### Dealing with the Data

Since this was our first time dealing with geospatial data, these file formats were completely foreign for us. It took us a while to learn QGIS and explore the data. After exploring the data given to us for a while, it became apparent that the ECW files were meant to be the expected "input" data for our AI model, whereas the SHP files were manually created annotations that were meant to be the expected output of the ML model.

The first problem with the ECW files was that they were very high-resolution. Also, you cannot directly process ECW files in GDAL unless you have a license (you can only read the files for free). So we would need to convert the data from ECW to something else.

We first converted the images from ECW to TIF file formats, which resulted in us obtaining very large TIF files (multiple gigabytes large). We could not process these files directly with segmentation models. So we decided to go for a sliding-window approach where the image would be split up into tiles and each tile would be processed independently. This process would be followed during training and inference. We went for a resolution of 3000x3000 for the tiles.

![image](https://github.com/user-attachments/assets/2a63b505-c86c-4d72-9211-dbf3655745f2)

#### GDAL command used for ECW to TIF Conversion:
```
gdal_translate -of GTiff -co "COMPRESS=LZW" input.ecw output.tif
```

#### Tiling
For creating tiles, we created and used [this batch script.](https://github.com/Kabeer2004/ProjectVaayu/blob/main/gdal_scripts/any_to_tif_grid.bat)

The same process was followed for the Shapefiles as well. First, the Shapefile was rasterized, after which some processing was applied to make the output data into binary masks that would be suitable for training an ML model. Basically, the masks had black backgrounds and white masks for the foreground elements that we wanted to segment out. Then this large rasterized TIF file was also tiled to get "output" data. The masks also had a resolution of 3000x3000.

![image](https://github.com/user-attachments/assets/95c415c8-c687-449b-a462-217c33083bcb)

#### Shapefile rasterization settings we used in QGIS:
```
{
  "area_units": "m2",
  "distance_units": "meters",
  "ellipsoid": "EPSG:7030",
  "inputs": {
    "BURN": 1.0,
    "DATA_TYPE": 0,
    "EXTENT": "Calculate from Layer and Choose your ECW Raster Layer",
    "EXTRA": "",
    "FIELD": null,
    "HEIGHT": {pixel height of base raster layer},
    "INIT": null,
    "INPUT": "input_shapefile.shp",
    "INVERT": false,
    "NODATA": 0.0,
    "OPTIONS": "COMPRESS=DEFLATE|PREDICTOR=2|ZLEVEL=9|mask=1|ALPHA=YES|TILED=YES",
    "OUTPUT": "output_raster.tif",
    "UNITS": 1,
    "USE_Z": false,
    "WIDTH": {pixel height of base raster layer}
  }
}
```

The above settings are very important - if you don't set these properly, you can end up generating rasterized shapefiles that are hundreds of gigabytes large. (💀) I speak from experience here.

#### GDAL commands for post-processing the rasterized Shapefile

```
gdal_rasterize -l layer_name -burn 1.0 -tr 1.0 1.0 -te [SET EXTENT OF UNDERLYING ECW LAYER. Use "Calculate from Layer" option in QGIS.] -a_nodata 0.0 -ot Byte -of GTiff -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 -co TILED=YES "input.shp" temp_raster.tif

gdal_translate -of GTiff -b 1 -mask 1 -a_nodata 0 -co ALPHA=YES temp_raster.tif raster_with_alpha.tif

gdal_calc -A raster_with_alpha.tif --outfile=final_raster_white.tif --calc="255*(A>0)" --NoDataValue=0 --type=Byte
```
This post-processing creates the binary mask TIF file that we then convert to tiles. Check [raster_mask_pipeline.bat](https://github.com/Kabeer2004/ProjectVaayu/blob/main/gdal_scripts/raster_mask_pipeline.bat) for step 2 and 3.

## The Models

We explored a lot of models during the duration of the hackathon. Here are the results from a few:

### Meta's Segment Anything Model (SAM)
This was the first model we tried, and we tested it out on SAM's official website - using the automatic mask generator.
#### Input:
![WhatsApp Image 2024-12-12 at 16 07 17_8d40fac6](https://github.com/user-attachments/assets/27ed1119-15a9-4265-b145-01954a1511b1)

#### Output:
![WhatsApp Image 2024-12-12 at 16 07 17_600d80d0](https://github.com/user-attachments/assets/c9f781d1-9f24-47e8-9d39-d50550613b8b)

#### LangSAM
We also attempted to use LangSAM which applied a text encoder to SAM and allowed you to use input text prompts for image segmentation. This implementation was fine for input images where the buildings were few and far between. 

For example, 

![image](https://github.com/user-attachments/assets/29033732-e870-4af2-b459-0543dda32305)

But when the buildings were closer together, LangSAM struggled to keep up due to overlapping bounding boxes.

![image](https://github.com/user-attachments/assets/88f83eb5-5329-4dbe-a37a-73108b2d7a9b)

#### Verdict:
SAM was performing well at making precise masks but it was also selecting a lot of random surrounding objects. The base model was also not able to perform well for roads and water bodies.

### Detectron2
We found a few posts online suggesting that Detectron2 was better than SAM for image segmentation. So we decided to proceed with fine-tuning Detectron2. For this, we had to create a COCO dataset from the training data we had.

#### Results for Buildings:

![image](https://github.com/user-attachments/assets/e6937481-53e2-422c-8547-b5c17f597b9b)

![image](https://github.com/user-attachments/assets/1aee04b4-eb65-4e91-83aa-51ffa5933cda)


#### Results for Water Bodies:

![image](https://github.com/user-attachments/assets/927a8715-efcf-4d51-9825-e0a27c9bf9bc)

#### Verdict:
Out of all the models we tried, Detectron had the best performance for water bodies. We had limited training data for water bodies and it was the only model out of the ones we tried that was able to generalize well to this training data. When it came to buildings, as you can see [here](https://github.com/Kabeer2004/ProjectVaayu#results-for-buildings), the model produced very jagged and _blotchy_ masks. I don't know if this was a problem with the way we configured the model for training or if it was an issue with Detectron2 itself. The model was also not able to perform well for roads, since in most tiles, roads stretched across the entire image. This made Detectron draw bounding boxes that covered the entire image - as a result of which, it was unable to identify exactly what it is supposed to mask. The same issue was also occuring with LangSAM.

### FPN - Feature Pyramid Networks

We decided to try fine-tuning an FPN model.

#### FPN for Roads:

![image](https://github.com/user-attachments/assets/94877538-753d-4a37-b44c-6dfec389945d)

#### FPN for Buildings:

![image](https://github.com/user-attachments/assets/2cc0adc0-5f74-4927-a68d-00c49b4464c9)

#### FPN for Water Bodies:

![image](https://github.com/user-attachments/assets/30e05fab-c8a9-4351-a8cd-a0adea8ac879)

#### Verdict:
FPNs only performed well for roads. When it came to water bodies, due to the lack of training data, it was not able to learn enough from the data. For buildings, it seemed to face the same problem that Detectron2 faced - it was generating very blotchy outputs. This was a general problem we faced with all of our segmentation models and architectures that we tried. Even UNet, the architecture that ended up winning the competition, showed the same issues in our early testing.

## Aaand finally, the winner is....
UNet++. It was always UNet! Seeing UNet get the best performance on this task and also seeing it win the entire competition was like a back-to-basics moment for me. Sometimes, the simplest solution is the correct solution. 

UNet++ (U-Net with Nested Skip Pathways) is an advanced architecture for image segmentation tasks, primarily used in medical imaging and computer vision. It builds upon the original U-Net model by enhancing its skip connections through nested pathways. This structure allows the network to capture more fine-grained features at various resolutions, improving segmentation accuracy. The key innovation of UNet++ is the introduction of dense skip pathways and deep supervision, which helps refine the features learned at different levels and improves the overall performance of the model. This makes UNet++ particularly effective for complex segmentation tasks where precise details are critical.

![image](https://github.com/user-attachments/assets/6982d9c7-ae43-425b-8245-b17821512ba8)

Here are the results for UNet++:

#### UNet++ for Buildings:

![image](https://github.com/user-attachments/assets/9e624bbd-1f3b-485d-a3e2-f25f0bd06466)

#### UNet++ for Roads:

![image](https://github.com/user-attachments/assets/4aeb6423-70ac-4f83-9a99-e82906aa3f16)

#### UNet++ for Water Bodies:

![image](https://github.com/user-attachments/assets/038cc9ec-4c6c-4db8-90c3-bc5ca45968d7)

Accuracy for the water body model is much lower due to a lack of training data. Also, the water bodies that were present in the training data were covered with algae - leading to the model confusing it for grass. The Detectron2 model we trained for water body segmentation seemed to perform much better for this task. Check it out [here](https://github.com/Kabeer2004/ProjectVaayu/tree/main#results-for-water-bodies).

## The Solution
At the competition, we prepared a pipeline that used FPNs for roads and buildings and Detectron2 for water bodies. FPN for roads and Detectron2 for water bodies showed great results but the performance for FPN for buildings was not acceptable - before we could try anything else for buildings, our time at the hackathon ran out. However, the updated version of the solution will solve the issue with buildings.

Our final inference pipeline looked like this: 

![IMG-20241216-WA0005 1](https://github.com/user-attachments/assets/4e5c0f7c-617a-49cd-a22e-fce2c2def0a5)

Steps in the pipeline:

1. The user uploads an ECW file.
2. The ECW file is converted to a large TIF file using GDAL Translate.
3. The large TIF file is converted to a grid of smaller tiles - each 3000x3000 pixels. This is done using the any_to_tif_grid.bat script.
4. Each tile is passed through different models. Specifically, each image is passed through one instance of each of the following models - the road segmentation model, the water body segmentation model, the rooftop type segmentation model (one model each for RCC, Tiled, Tin and Other rooftops).
5. Each inference will produce one output tile - which is saved in a corresponding output folder for each feature.
6. All the output tiles are then recombined into one large raster file using GDAL Warp.
7. The raster file is then converted to a ShapeFile using GDAL Polygonize.

One issue here is that when the input tiles pass through the model, the output TIF tiles do not contain their Geographical Information anymore - i.e. they go from GeoTiffs to normal TIF files. Due to this, they do not get polygonized by GDAL Polygonize. To solve this, we can re-apply the geographical information present in the input tiles to the output tiles - since they correspond with each other 1:1 and thus, have the same geographical information. You can use the following gdalwarp command to copy the geo-referencing information from the GeoTIFF tile to the normal TIFF output mask tile: (you will have to run this command for each tile - I suggest creating a batch script)

```
gdalwarp -s_srs EPSG:4326 -t_srs EPSG:4326 -of GTiff -co "TILED=YES" -co "COMPRESS=LZW" input_normal.tif input_georeferenced.tif
```

GDAL Warp is used to merge the generated output TIF grid back to one large TIF file as follows:

```
gdalwarp -of GTiff path\to\grid_tifs\*.tif path\to\output_combined.tif
```

Finally, using GDAL Polygonize, the recombined TIF file would be polygonized to a Shapefile which was the desired output filetype:

```cmd
gdal_polygonize built_up_raster_lalpur.tif -f "ESRI Shapefile" test_builtup_lalpur.shp
```

The solution also expected us to design a deployment pipeline for the AI model that we created using AWS, ReST APIs and a microservices architecture.
