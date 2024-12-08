# ProjectVaayu

The official repository for Project Vaayu - SIH 1705

## important commands:

- Merging TIF Grid back into one large TIF

```
gdalwarp -of GTiff path\to\grid_tifs\*.tif path\to\output_combined.tif
```

- Converting ECW to TIF

```
gdal_translate -of GTiff -co "COMPRESS=LZW" input.ecw output.tif
```

## Shapefile Rasterization Settings I used in QGIS

```
{
  "area_units": "m2",
  "distance_units": "meters",
  "ellipsoid": "EPSG:7030",
  "inputs": {
    "BURN": 1.0,
    "DATA_TYPE": 0,
    "EXTENT": "8098996.378200000,8099677.155200000,2636558.407300000,2637264.506000000 [EPSG:3857]",
    "EXTRA": "",
    "FIELD": null,
    "HEIGHT": 0.03,
    "INIT": null,
    "INPUT": "D:/Documents/cyber/projects/vaayu/repo/data/Gujarat/LalPur, Suragpur/Gujarat_Build_Up_Area_Type.shp",
    "INVERT": false,
    "NODATA": 0.0,
    "OPTIONS": "COMPRESS=DEFLATE|PREDICTOR=2|ZLEVEL=9|mask=1|ALPHA=YES|TILED=YES",
    "OUTPUT": "D:/Documents/cyber/projects/vaayu/repo/data/Gujarat/built_up_modified.tif",
    "UNITS": 1,
    "USE_Z": false,
    "WIDTH": 0.03
  }
}
```

## Shapefile to Alpha Mask TIF Pipeline

- Lalpur Example

```
gdal_rasterize -l Gujarat_Build_Up_Area_Type -burn 1.0 -tr 1.0 1.0 -te 7937898.8094 2473668.505 8099451.5942 2637166.9567 -a_nodata 0.0 -ot Byte -of GTiff -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 -co TILED=YES "D:/Documents/cyber/projects/vaayu/repo/data/Gujarat/LalPur, Suragpur/Gujarat_Build_Up_Area_Type.shp" temp_raster.tif

gdal_translate -of GTiff -b 1 -mask 1 -a_nodata 0 -co ALPHA=YES temp_raster.tif raster_with_alpha.tif

gdal_calc -A raster_with_alpha.tif --outfile=final_raster_white.tif --calc="255*(A>0)" --NoDataValue=0 --type=Byte
```

Created raster_mask_pipeline.bat for step 2 and 3

## Multi-Village ECW to Raster and Mask Layer

To handle ECW files with multiple villages and generate rasterized layers for each village separately, you need to:

1. **Isolate the features (buildings, roads, etc.) for each village**:

   - Use an attribute in the vector layer that identifies the village (e.g., `village_name` or `village_id`).
   - Filter the vector data to extract features for each village.

2. **Export the rasterized vector layers for each village**:

   - Use the extent of each village to clip the ECW and vector data.
   - Rasterize the filtered vector data within the specific village bounds.

3. **Export the ECW for each village**:
   - Clip the ECW using the extent of the village.

Here’s a detailed **workflow**:

---

### **Step 1: Isolate Village Features**

Filter the vector layer by village using `ogr2ogr`:

```cmd
ogr2ogr -where "village_name='VillageA'" villageA.shp Gujarat_Build_Up_Area_Type.shp
ogr2ogr -where "village_name='VillageB'" villageB.shp Gujarat_Build_Up_Area_Type.shp
```

This creates separate shapefiles (`villageA.shp`, `villageB.shp`) for each village.

If you’re unsure of the attribute name for villages:

- Open the attribute table in QGIS or use `ogrinfo`:
  ```cmd
  ogrinfo -al -so Gujarat_Build_Up_Area_Type.shp
  ```

---

### **Step 2: Determine Village Extents**

Use `ogrinfo` to get the bounding box for each village shapefile:

```cmd
ogrinfo -al -so villageA.shp
```

Look for the `Extent:` field in the output, which provides the coordinates (`xmin, ymin, xmax, ymax`).

---

### **Step 3: Clip the ECW for Each Village**

Use `gdal_translate` to clip the ECW based on the village extents:

```cmd
gdal_translate -projwin xmin ymax xmax ymin ortho.ecw villageA_raster.tif
```

Repeat this for each village, replacing `xmin`, `ymin`, `xmax`, and `ymax` with the extents of the village.

---

### **Step 4: Rasterize Vector Layers for Each Village**

Use `gdal_rasterize` to rasterize the filtered vector data for each village:

```cmd
gdal_rasterize -burn 1 -tr 1.0 1.0 -te xmin ymin xmax ymax -a_nodata 0 -ot Byte -of GTiff -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 -co TILED=YES villageA.shp villageA_rasterized.tif
```

- Replace `xmin`, `ymin`, `xmax`, and `ymax` with the extents of the village.

---

### **Step 5: Export Rasterized Vector with Transparency**

Add transparency and ensure the features are represented as white (255):

```cmd
gdal_translate -of GTiff -b 1 -mask 1 -a_nodata 0 -co ALPHA=YES villageA_rasterized.tif villageA_with_alpha.tif

gdal_calc.py -A villageA_with_alpha.tif --outfile=villageA_final.tif --calc="255*(A>0)" --NoDataValue=0 --type=Byte
```

## Polygonizing the output mask (large .tif that we get from recombining tiles) to SHP

```cmd
gdal_polygonize built_up_raster_lalpur.tif -f "ESRI Shapefile" test_builtup_lalpur.shp
```

# Team Vaayu-backend

## Getting started

To make it easy for you to get started with GitLab, here's a list of recommended next steps.

Already a pro? Just edit this README.md and make it your own. Want to make it easy? [Use the template at the bottom](#editing-this-readme)!

## Add your files

- [ ] [Create](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#create-a-file) or [upload](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#upload-a-file) files
- [ ] [Add files using the command line](https://docs.gitlab.com/ee/gitlab-basics/add-file.html#add-a-file-using-the-command-line) or push an existing Git repository with the following command:

```
cd existing_repo
git remote add origin https://repo.mic.gov.in/sih2024/sri-krishna-college-of-engineering-and-technology/team-vaayu-backend.git
git branch -M main
git push -uf origin main
```

## Integrate with your tools

- [ ] [Set up project integrations](https://repo.mic.gov.in/sih2024/sri-krishna-college-of-engineering-and-technology/team-vaayu-backend/-/settings/integrations)

## Collaborate with your team

- [ ] [Invite team members and collaborators](https://docs.gitlab.com/ee/user/project/members/)
- [ ] [Create a new merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html)
- [ ] [Automatically close issues from merge requests](https://docs.gitlab.com/ee/user/project/issues/managing_issues.html#closing-issues-automatically)
- [ ] [Enable merge request approvals](https://docs.gitlab.com/ee/user/project/merge_requests/approvals/)
- [ ] [Set auto-merge](https://docs.gitlab.com/ee/user/project/merge_requests/merge_when_pipeline_succeeds.html)

## Test and Deploy

Use the built-in continuous integration in GitLab.

- [ ] [Get started with GitLab CI/CD](https://docs.gitlab.com/ee/ci/quick_start/index.html)
- [ ] [Analyze your code for known vulnerabilities with Static Application Security Testing (SAST)](https://docs.gitlab.com/ee/user/application_security/sast/)
- [ ] [Deploy to Kubernetes, Amazon EC2, or Amazon ECS using Auto Deploy](https://docs.gitlab.com/ee/topics/autodevops/requirements.html)
- [ ] [Use pull-based deployments for improved Kubernetes management](https://docs.gitlab.com/ee/user/clusters/agent/)
- [ ] [Set up protected environments](https://docs.gitlab.com/ee/ci/environments/protected_environments.html)

---

# Editing this README

When you're ready to make this README your own, just edit this file and use the handy template below (or feel free to structure it however you want - this is just a starting point!). Thanks to [makeareadme.com](https://www.makeareadme.com/) for this template.

## Suggestions for a good README

Every project is different, so consider which of these sections apply to yours. The sections used in the template are suggestions for most open source projects. Also keep in mind that while a README can be too long and detailed, too long is better than too short. If you think your README is too long, consider utilizing another form of documentation rather than cutting out information.

## Name

Choose a self-explaining name for your project.

## Description

Let people know what your project can do specifically. Provide context and add a link to any reference visitors might be unfamiliar with. A list of Features or a Background subsection can also be added here. If there are alternatives to your project, this is a good place to list differentiating factors.

## Badges

On some READMEs, you may see small images that convey metadata, such as whether or not all the tests are passing for the project. You can use Shields to add some to your README. Many services also have instructions for adding a badge.

## Visuals

Depending on what you are making, it can be a good idea to include screenshots or even a video (you'll frequently see GIFs rather than actual videos). Tools like ttygif can help, but check out Asciinema for a more sophisticated method.

## Installation

Within a particular ecosystem, there may be a common way of installing things, such as using Yarn, NuGet, or Homebrew. However, consider the possibility that whoever is reading your README is a novice and would like more guidance. Listing specific steps helps remove ambiguity and gets people to using your project as quickly as possible. If it only runs in a specific context like a particular programming language version or operating system or has dependencies that have to be installed manually, also add a Requirements subsection.

## Usage

Use examples liberally, and show the expected output if you can. It's helpful to have inline the smallest example of usage that you can demonstrate, while providing links to more sophisticated examples if they are too long to reasonably include in the README.

## Support

Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap

If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing

State if you are open to contributions and what your requirements are for accepting them.

For people who want to make changes to your project, it's helpful to have some documentation on how to get started. Perhaps there is a script that they should run or some environment variables that they need to set. Make these steps explicit. These instructions could also be useful to your future self.

You can also document commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something. Having instructions for running tests is especially helpful if it requires external setup, such as starting a Selenium server for testing in a browser.

## Authors and acknowledgment

Show your appreciation to those who have contributed to the project.

## License

For open source projects, say how it is licensed.

## Project status

If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.
