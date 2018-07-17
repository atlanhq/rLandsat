# rLandsat <img src="https://i.imgur.com/btZP6vS.png" align="right" />
Acquire Landsat8 Data: R Package to make Landsat8 data accessible and to unlock the mystery.

## Overview

rLandsat makes it easy to search for Landsat8 product IDs, place an order on USGS-ESPA and download the data along with the meta information in the perfect format from R. Internally uses a combination of sat-api, espa-api and AWS S3 Landsat8 data.

<img src="https://i.imgur.com/cmjtegG.png" align="centre" />

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
# Load the library
library(rLandsat)
```

If you encounter a bug, please file an issue with steps to reproduce it on [github](https://github.com/socialcopsdev/rLandsat/issues). Use the same for any feature requests, enhancements and suggestions.

## Additional Details
### About Landsat8 ###
Landsat 8 Operational Land Imager (OLI) and Thermal Infrared Sensor (TIRS) imagery consist of nine spectral bands with a spatial resolution of 30 meters for Bands 1 to 7, and 9. New band 1 (ultra-blue) is useful for coastal and aerosol studies. Band 9 is useful for cirrus cloud detection. The resolution for Band 8 (panchromatic) is 15 meters. Thermal bands 10 and 11 are useful in providing more accurate surface temperatures and are collected at 100 meters.

Landsat offers this data through variety of data products depending upon data quality and level of processing, like SR (Surface Reflectance), TOA (Top of Atmosphere), BT (Brightness Temperature), Spectral Indices).

This data is available with EROS Science Processing Architecture (ESPA), AWS S3, and Google Cloud Storage. Using data from ESPA is recommended as they have made available Collection-1 data for even Landsat 1. AWS S3 and Google Cloud Storage, on the other hand, have Pre-Collection data till January 1, 2017, and Collection-1 data post that. This library considers this change.

**You might want to read :**
* Read about the Landsat Collection (Pre-Collection and Collection-1) [here](https://landsat.usgs.gov/landsat-collections).
* Watch [this](https://www.youtube.com/watch?v=R5_XHqlNDc4) video to understand the difference between the data on ESPA and that on AWS S3/Google Cloud Storage, and why using ESPA is preferred over the digital numbers (DN) provided by the former.  
* Watch how the data is captured [here](https://www.youtube.com/watch?v=xBhorGs8uy8)</br>
* Read about the 120+ applications of Landsat8 data [here](http://grindgis.com/blog/120-landsat-data-applications)

### What can I do?
* **landsat_search** Get landsat8 product IDs for certain time period and country (or define your own path and row). This search is being done using sat-api (developed by DevelopmentSeed, this also gives the download urls for AWS S4) or the AWS Landsat master meta file based on your input.

* **espa_product** For the specified landsat8 product IDs, get the products available from ESPA. This uses espa-api

* **espa_order** Place an order to get the download links for the specified product IDs and the corresponding product. You can also specify the projection (aea and lonlat), the resampling method and the file format. This is better than downloading the data from AWS as this gives advanced products (like sr:surface reflectance) data, which is needed to create most of the indices.

* **espa_status** Get the status of the order placed using espa_order. If the status is complete, download urls for each tile will also be available.

* **landsat_download** A small function to download multiple urls using download.file function. If each band is being downloaded individually, instead of a zip file (in case of data from AWS) then this function will create a folder for each tile, grouping the bands.

Few other smaller functions and features/options are also available. Use `?function_name` to know more about each function. 

**Please Note:** Most of the functions are dependent on external APIs, so the functionalities may be dependent on the APIs working properly. Any major changes in the APIs may need the functions in rLandsat to be modified accordingly.

### Example

```
# get all the product IDs for India, alternatively can define path and row
result = landsat_search(min_date = "2018-01-01", max_date = "2018-01-16", country = "India")

# inputting espa creds
espa_creds("yourusername", "yourpassword")

# getting available products
prods = espa_products(result$product_id)
prods = prods$master

# placing an espa order
result_order = espa_order(result$product_id, product = c("sr","sr_ndvi"),
                          projection = "lonlat",
                          order_note = "All India Jan 2018")
order_id = result_order$order_details$orderid

# getting order status
durl = espa_status(order_id = order_id, getSize = TRUE)
downurl = durl$order_details

# download; after the order is complete
landsat_download(download_url = downurl$product_dload_url, dest_file = getwd())
```

## References
* sat-api (Development Seed) https://github.com/sat-utils/sat-api
* espa-api (USGS - EROS) https://github.com/USGS-EROS/espa-api/
* Google Server and AWS Landsat Data http://krstn.eu/landsat-batch-download-from-google/

Cheers to open data :blush:
