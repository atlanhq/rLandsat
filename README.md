# rLandsat (Acquire Landsat8 Data)
R Package to make Landsat8 data accessible and to unlock the mystery.
Easily search and download landsat8 data from R (internally using sat-api, espa-api and AWS Landsat8 data)

### About Landsat8 ###
Landsat 8 - Operational Land Imager (OLI) and Thermal Infrared Sensor (TIRS) imagery consist of nine spectral bands with a spatial resolution of 30 meters for Bands 1 to 7 and 9. New band 1 (ultra-blue) is useful for coastal and aerosol studies. Band 9 is useful for cirrus cloud detection. The resolution for Band 8 (panchromatic) is 15 meters. Thermal bands 10 and 11 are useful in providing more accurate surface temperatures and are collected at 100 meters.

**You might want to read :**
* About the Landsat Collection (Pre-Collection and Collection-1) [here](https://landsat.usgs.gov/landsat-collections). This impacts the data on AWS/Google servers, as they have pre-collection data per 5/1/2017 and collection-1 post that. Hence using data from ESPA is suggested as they have only Collection-1 data for the entire time period. This library considers this change.
* About the different products available in ESPA (eg, SR (Surface Reflectance), TOA (Top of Atmosphere), BT (Brightness Temperature), Spectral Indices) and why using these are better than the digital numbers (DN) prodived by AWS/GoogleServers.

### What can I do?
* **landsat_search** Get landsat8 product IDs for certain time period and country (or define your own path and row). This search is being done using sat-api (developed by DevelopmentSeed, this also gives the download urls for AWS) or the AWS Landsat master meta file based on your input.

* **espa_product** For the specified landsat8 product IDs, get the products available from ESPA. This uses espa-api

* **espa_order** Place an order to get the download links for the specified product IDs and the corresponding product. You can also specify the projection (aea and lonlat), the resampling method and the file format. This is better than downloading the data from AWS as this gives advanced products (like sr:surface reflectance) data, which is needed to create most of the indices.

* **espa_status** Get the status of the order placed using espa_order. If the status is complete, download urls for each tile will also be available.

* **landsat_download** A small function to download multiple urls using download.file function. If each band is being downloaded individually, instead of a zip file (in case of data from AWS) then this function will create a folder for each tile, grouping the bands.

* Few other smaller functions and features/options are also available. Also check the demo script which downloads all the landsat8 data for India for Jan 2018. Use `?function_name` to know more about each function

Please Note: To run any of the functions starting with *espa_* you need valid login credentials from [ESPA - LSRD](https://espa.cr.usgs.gov) and need to input it in your environment with `espa_creds(username, password)` for the functions to work properly

### References ###
* sat-api (Development Seed) https://github.com/sat-utils/sat-api
* espa-api (USGS - EROS) https://github.com/USGS-EROS/espa-api/
* Google Server and AWS Landsat Data http://krstn.eu/landsat-batch-download-from-google/

Cheers to open data :blush:
