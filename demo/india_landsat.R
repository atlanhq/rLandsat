# ======== DEMO Script to download Landsat 8 data for India for 1st half Jan 2018 ===========

# get all the product IDs for India for 1 time period
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
paste0("Total Size of Order: ", round(sum(downurl$size)/(1000^3), 2), "GB")

# download; after the order is complete
landsat_download(download_url = downurl$product_dload_url, dest_file = getwd())
