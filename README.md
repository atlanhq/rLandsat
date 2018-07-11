# rLandsat (Acquire Landsat8 Data) <img src="man/logo.png" align="right" />
R Package to make Landsat8 data accessible and to unlock the mystery.

## Overview

rLandsat makes it easy to search for Landsat8 product IDs, place an order on USGS-ESPA and download the data along with the meta information in the perfect format from R. Internally uses a combination of sat-api, espa-api and AWS Landsat8 data.

  - `landsat_search()` search product IDs (and AWS/Google download links) based on time and geography
  - `espa_product()` get list of available products for product ids
  - `espa_order()` place an order for product ids on espa
  - `espa_status()` get the status of the order
  - `landsat_download()` download the landsat8 scenes using espa urls
 
To run any of the functions starting with *espa_* you need valid login credentials from [ESPA - LSRD](https://espa.cr.usgs.gov) and need to input it in your environment with `espa_creds(username, password)` for the functions to work properly.

**Also check the demo script** which downloads all the landsat8 data for India for Jan 2018 in the demo folder, or run `demo("india_landsat")` in R post loading this library

## Installation

``` r
# Install the latest version from GitHub:
install.packages("devtools")
devtools::install_github("socialcopsdev/rLandsat")
library(rLandsat)
```

If you encounter a clear bug, please file a minimal reproducible example on [github](https://github.com/socialcopsdev/rLandsat/issues). Use the same for any feature requests, enhancements and suggestions using appropriate tags.

## Additional Details
### About Landsat8 ###
Landsat 8 - Operational Land Imager (OLI) and Thermal Infrared Sensor (TIRS) imagery consist of nine spectral bands with a spatial resolution of 30 meters for Bands 1 to 7 and 9. New band 1 (ultra-blue) is useful for coastal and aerosol studies. Band 9 is useful for cirrus cloud detection. The resolution for Band 8 (panchromatic) is 15 meters. Thermal bands 10 and 11 are useful in providing more accurate surface temperatures and are collected at 100 meters.

Watch how the data is captured [here](https://www.youtube.com/watch?v=xBhorGs8uy8)</br>
Read about the 120+ applications of Landsat8 data [here](http://grindgis.com/blog/120-landsat-data-applications)

**You might want to read :**
* About the Landsat Collection (Pre-Collection and Collection-1) [here](https://landsat.usgs.gov/landsat-collections). This impacts the data on AWS/Google servers, as they have pre-collection data pre 5/1/2017 and collection-1 post that. Hence using data from ESPA is suggested as they have only Collection-1 data for the entire time period. This library considers this change.
* About the different products available in ESPA (eg, SR (Surface Reflectance), TOA (Top of Atmosphere), BT (Brightness Temperature), Spectral Indices) and why using these are better than the digital numbers (DN) prodived by AWS/GoogleServers. Watch [this](https://www.youtube.com/watch?v=R5_XHqlNDc4) video to understand the difference.

### What can I do?
* **landsat_search** Get landsat8 product IDs for certain time period and country (or define your own path and row). This search is being done using sat-api (developed by DevelopmentSeed, this also gives the download urls for AWS) or the AWS Landsat master meta file based on your input.

* **espa_product** For the specified landsat8 product IDs, get the products available from ESPA. This uses espa-api

* **espa_order** Place an order to get the download links for the specified product IDs and the corresponding product. You can also specify the projection (aea and lonlat), the resampling method and the file format. This is better than downloading the data from AWS as this gives advanced products (like sr:surface reflectance) data, which is needed to create most of the indices.

* **espa_status** Get the status of the order placed using espa_order. If the status is complete, download urls for each tile will also be available.

* **landsat_download** A small function to download multiple urls using download.file function. If each band is being downloaded individually, instead of a zip file (in case of data from AWS) then this function will create a folder for each tile, grouping the bands.

Few other smaller functions and features/options are also available. Use `?function_name` to know more about each function. 

**Please Note:** Most of the functions are dependent on external APIs, so the functionalities may be dependent on the APIs working properly. Any major changes in the APIs may need the functions in rLandsat to be modified accordingly.

## References
* sat-api (Development Seed) https://github.com/sat-utils/sat-api
* espa-api (USGS - EROS) https://github.com/USGS-EROS/espa-api/
* Google Server and AWS Landsat Data http://krstn.eu/landsat-batch-download-from-google/

Cheers to open data :blush:
