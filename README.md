# rLandsat <img src="https://i.imgur.com/btZP6vS.png" align="right" />
Acquire Landsat 8 Data: R Package to make Landsat 8 data accessible and help unlock its mysteries.

![](https://travis-ci.org/socialcopsdev/rLandsat.svg?branch=master)

## Overview

rLandsat makes it easy to search for Landsat8 product IDs, place an order on USGS-ESPA and download the data along with the meta information in the perfect format from R. Internally, it uses a combination of sat-api, espa-api and AWS S3 Landsat 8 metadata.

<img src="https://i.imgur.com/cmjtegG.png" align="centre" />

  - `landsat_search()`: search product IDs (and AWS/Google download links) based on time and geography
  - `espa_product()`: get list of available products for product IDs
  - `espa_order()`: place an order for product IDs on ESPA
  - `espa_status()`: get the status of the order
  - `landsat_download()`: download the Landsat 8 scenes using ESPA URLs
 
To run any of the functions starting with `espa_`, you need valid login credentials from [ESPA-LSRD](https://espa.cr.usgs.gov/) and you need to input them in your environment with `espa_creds(username, password)` for the functions to work properly.

**You should also check the demo script** (which downloads all the Landsat 8 data for India for January 2018) in the demo folder, or run `demo("india_landsat")` in R after loading this library.

## Installation

``` r
# Install the CRAN version
install.packages("rLandsat")

# Install the latest dev version from GitHub:
install.packages("devtools")
devtools::install_github("atlanhq/rLandsat")

# Load the library
library(rLandsat)
```

If you encounter a bug, please file an issue with steps to reproduce it on [Github](https://github.com/atlanhq/rLandsat/issues). Please use the same for any feature requests, enhancements or suggestions.

## Additional Details
### About Landsat 8 ###
Landsat 8 Operational Land Imager (OLI) and Thermal Infrared Sensor (TIRS) images consist of nine spectral bands with a spatial resolution of 30 meters for Bands 1 to 7 and 9. The ultra blue Band 1 is useful for coastal and aerosol studies. Band 9 is useful for cirrus cloud detection. The resolution for Band 8 (panchromatic) is 15 meters. Thermal bands 10 and 11 are useful in providing more accurate surface temperatures and are collected at 100 meters. 

Landsat offers this data through a variety of data products, depending on the data quality and level of processing, including SR (Surface Reflectance), TOA (Top of Atmosphere), BT (Brightness Temperature), and Spectral Indices.

This data is available with EROS Science Processing Architecture (ESPA), AWS S3 and Google Cloud Storage. Using data from ESPA is recommended as they have made Collection 1 data available even for data before January 2017. AWS S3 and Google Cloud Storage, on the other hand, have Pre-Collection data until January 1, 2017, and Collection 1 data after that. This library considers that change.

**Here are some additional resources you might want to read:**
* Read about the Landsat Collection (Pre Collection and Collection 1) [here](https://www.usgs.gov/land-resources/nli/landsat/landsat-collections).
* Watch [this](https://www.youtube.com/watch?v=R5_XHqlNDc4) video to understand the difference between the data on ESPA and that on AWS S3/Google Cloud Storage, and why using ESPA is preferred over AWS' Digital Numbers (DN).  
* Watch how the data is captured [here](https://www.youtube.com/watch?v=xBhorGs8uy8).
* Read about over 120 applications of Landsat 8 data [here](http://grindgis.com/blog/120-landsat-data-applications).

### What can I do on rLandsat?
* **landsat_search**: Get Landsat 8 product IDs for certain time periods and countries (or define your own path and row). This search uses sat-api (developed by DevelopmentSeed, this also gives the download urls for AWS S3) or the AWS Landsat master meta file, based on your input.

* **espa_product**: For the specified Landsat 8 product IDs, get the products available from ESPA. This uses espa-api.

* **espa_order**: Place an order to get the download links for the specified product IDs and the corresponding products. You can also specify the projection (AEA and Lon/Lat), the resampling method and the file format. This is better than downloading the data from AWS as this gives data from advanced products (like Surface Reflectance), which is necessary for creating most of the indices.

* **espa_status**: Get the status of the order placed using espa_order. If the status is complete, the download URLs for each tile will also be available.

* **landsat_download**: A small function to download multiple URLs using the `download.file` function. If each band is being downloaded individually from AWS, this function will create a folder (instead of a zip file) for each tile, grouping the bands.

A few other smaller functions and features/options are also available. Use `?function_name` to learn more about each function.

**Please note:** Most of the functions are dependent on external APIs, so the functionalities may be dependent on the APIs working properly. Any major changes in the APIs may need the functions in rLandsat to be modified accordingly.

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
* sat-api (Development Seed): https://github.com/sat-utils/sat-api
* espa-api (USGS-EROS): https://github.com/USGS-EROS/espa-api/
* Google Server and AWS Landsat Data: http://krstn.eu/landsat-batch-download-from-google/

Cheers to open data :blush:

<img src="http://i65.tinypic.com/9h4ajs.png" align="centre" />
