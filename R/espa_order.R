#' Places an Order for the Product IDs
#' @description Places an order in espa for the specified product ids and their products. All the products must be available for the product IDs mentioned for a successful order
#'
#' @param input_ids vector of product ids for which order needs to be places
#' @param product vector of products required for the product ids mentioned. eg. c("sr", "toa", "sr_ndvi")
#' @param file_format the required output format of the order. Default "gtiff". Generally available are: "hdf-eos2": "HDF-EOS2", "envi": "ENVI", "gtiff": "GeoTiff", "netcdf": "NetCDF"
#' @param resampling_method the required resampling method for the order. Default "cc". Generally available are: "cc": "Cubic Convolution", "bil": "Bilinear Interpolation", "nn": "Nearest Neighbor"
#' @param order_note the note (meta information) for the order
#' @param projection the projection of the landsat data for which order is placed. Deafult "lonlat". Avaialble are: "aea" and "lonlat"
#' @param standard_parallel_1 define numeric value if projection is "aea"
#' @param central_meridian define numeric value if projection is "aea"
#' @param datum define numeric value if projection is "aea"
#' @param latitude_of_origin define numeric value if projection is "aea"
#' @param standard_parallel_2 define numeric value if projection is "aea"
#' @param false_northing define numeric value if projection is "aea"
#' @param false_easting define numeric value if projection is "aea"
#' @param host the api call host. Default set to espa v1 web api
#' @param username default NULL, which fetches the username from the global environment. If defined otherwise, will run the api with the provided details
#' @param password default NULL, which fetches the password from the global environment. If defined otherwise, will run the api with the provided details
#'
#' @return a list
#' \item{order_details}{a list of order id and order status if the order was successful, else blank list}
#' \item{response}{the API response message}
#' \item{product_available}{dataframe with product ids and availability}
#' \item{query}{the json body sent in POST api}
#' @export
#' @import "httr" "jsonlite" "dplyr" "readr" "stringr"
#' @examples
#' \dontrun{
#' # input the credentials, if not defined earlier
#' espa_creds("your_espaname", "secret_password")
#'
#' # saving the product ids as a vector
#' product_ids = c("LC08_L1TP_148047_20180202_20180220_01_T1",
#'                 "LC08_L1TP_134040_20180115_20180120_01_T1")
#'
#' # saving the required products as a vector
#' prod = c("sr", "sr_ndvi")
#'
#' # placing the order
#' ## returns NULL as wrong credentials provided
#' result = espa_order(input_ids = product_ids, product = prod, projection = "lonlat")
#' orderid = result$order_details$orderid # storing the order id for future reference}


espa_order <- function(input_ids, product, file_format = "gtiff", resampling_method = "cc", order_note = "Order from R",
                       projection = "lonlat",
                       standard_parallel_1 = 29.5,central_meridian = -96.0,datum = "nad83", latitude_of_origin = 23.0,
                       standard_parallel_2 = 45.5 , false_northing = 0, false_easting = 0,
                       host = 'https://espa.cr.usgs.gov/api/v1/', username = NULL, password = NULL){

  # getting the username and password from global environment if not specified
  if(is.null(username) | is.null(password)){
    username = tryCatch(espa_get_creds()[1], error = function(e) stop("Please set your espa-api creds in espa_creds()"))
    password = tryCatch(espa_get_creds()[2], error = function(e) stop("Please set your espa-api creds in espa_creds()"))
  }
  # checking if username password valid and all the requested products exists
  valid = espa_products(input_ids = input_ids, host = host, username = username, password = password)
  if(!is.null(valid)){
    valid = valid$master
    # if the product doesnt exists for even one
    if(sum(product %in% colnames(valid)) != length(product)){
      cat("Invalid product selection. Please check the 'product_available' dataframe\n")
      return(list(order_details = list(), response = NA, product_available = valid))
    }

    # if a single 0 in the product column requested, error returned
    for(prod in 1:length(product)){
      if(sum(valid[,product[prod]]) != nrow(valid)){
        cat("Invalid product selection. Please check the 'product_available' dataframe\n")
        return(list(order_details = list(), response = NA, product_available = valid))
      }
    }

  } else{
    return(list(order_details = list(), response = NA, product_available = valid))
  }

  # ====== Building JSON to pass to API =========
  # inputting landsat8 product id and products to order
  product = as.character(toJSON(list(
    olitirs8_collection = list(
      inputs = input_ids,
      products = product
    ))))
  product = substr(product, 2, nchar(product))

  #projection
  if(projection == "aea"){
    projection = paste0(
      '{"projection": {
      "aea": {
      "standard_parallel_1":', standard_parallel_1,',
      "central_meridian":', central_meridian,',
      "datum":"', datum,'",
      "latitude_of_origin":', latitude_of_origin,',
      "standard_parallel_2":', standard_parallel_2,',
      "false_northing":', false_northing,',
      "false_easting":', false_easting,'
      }
  }'
  )
    } else if(projection == "lonlat"){
      projection = paste0(
        '{"projection": {
        "lonlat" : null
        }')
  }

  # format, resampling, note
  format = paste0('"format":"', file_format,'"')
  resampling_method = paste0('"resampling_method": "',resampling_method,'"')
  note = paste0('"note":"', order_note,'"')

  #pasting all the parameters
  order_query = paste(projection, format, resampling_method,note, product, sep = ",")
  #url to post to
  post_url = paste0(host, "order")
  # POST order
  pp = tryCatch(POST(post_url,
                     authenticate(username, password),
                     body = order_query),error = function(e) {FALSE})
  if(is.logical(pp)){
    cat("Order Failed!\n")
    return(list(order_details = list(), response = pp, product_available = valid, query = order_query))
  }
  status = pp$status_code
  if(substr(as.character(status),1,1) == 2){
    cat("Order Successful!\n")
    order = fromJSON(rawToChar(pp$content))
    return(list(order_details = order, response = pp, product_available = valid, query = order_query))
  } else{
    cat("Order Failed!\n")
    return(list(order_details = list(), response = pp, product_available = valid, query = order_query))
  }

  }
