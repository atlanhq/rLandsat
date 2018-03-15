# rLandsat (Acquire Landsat8 Data)
R Package to make Landsat8 data accessible. 
Easily search and download landsat8 data from R (internally using sat-api, espa-api and AWS Landsat8 data)

### What can I do?
* **landsat_search** Get landsat8 product IDs for certain time period and country (or define your own path and row). This search is being done using sat-api (developed by DevelopmentSeed, this also gives the download urls for AWS) or the AWS Landsat master meta file based on your input.

* **espa_product** For the specified landsat8 product IDs, get the products available from ESPA. This uses espa-api

* **espa_order** Place an order to get the download links for the specified product IDs and the corresponding product. You can also specify the projection (aea and lonlat), the resampling method and the file format. This is better than downloading the data from AWS as this gives advanced products (like sr:surface reflectance) data, which is needed to create most of the indices.

* **espa_status** Get the status of the order placed using espa_order. If the status is complete, download urls for each tile will also be available.

* **landsat_download** A small function to download multiple urls using download.file function. If each band is being downloaded individually, instead of a zip file (in case of data from AWS) then this function will create a folder for each tile, grouping the bands.

* Few other smaller functions and features/options are also available. Also check the demo script which downloads all the landsat8 data for India for Jan 2018. Use *?function* to know more about each function

Please Note: To run any of the functions starting with *espa_* you need valid login credentials from [ESPA - LSRD](https://espa.cr.usgs.gov) and need to input it in your environment with **espa_creds(username, password)** for the functions to work properly

### References ###
* sat-api (Development Seed) https://github.com/sat-utils/sat-api
* espa-api (USGS - EROS) https://github.com/USGS-EROS/espa-api/
* Google and Amazon http://krstn.eu/landsat-batch-download-from-google/

Cheers to open data :blush:
