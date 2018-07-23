#' Get Landsat Order Status and Download URL
#' @description For a successful order placed, get the status of each of the product ID requested in that order id. Once the order is complete, also get the corresponding URLs for the product IDs.
#' @param order_id vector of order ids for which status and download url is needed
#' @param min_date if order_id is NULL, define the starting date from which order ids need to be fetched
#' @param max_date if order_id is NULL, define the ending date till which order ids need to be fetched
#' @param getSize logical. if the status is completed for the entire order, then should the file size be calculated. (Output size in Bytes)
#' @param host the api call host. Default set to espa v1 web api
#' @param username default NULL, which fetches the username from the global environment. If defined otherwise, will run the api with the provided details
#' @param password default NULL, which fetches the password from the global environment. If defined otherwise, will run the api with the provided details
#' @details if order_id, min_date, max_date are NULL, then will run on all the order ids available till date
#' @return a list
#' \item{order_details}{a dataframe with order status and download links}
#' \item{wrong_order_id}{vector of order_ids for which the API failed}
#' @export
#'
#' @examples
#' \dontrun{
#' # input the credentials, if not defined earlier
#'  espa_creds("your_espaname", "secret_password")
#'
#' # getting all the orders' status
#'  result = espa_status()
#'  # getting the dataframe from the list
#'  result = result$order_details}

espa_status <- function(order_id = NULL, min_date = NULL, max_date = NULL, getSize = FALSE,
                        host = 'https://espa.cr.usgs.gov/api/v1/', username = NULL, password = NULL){
  # getting the username and password from global environment if not specified
  if(is.null(username) | is.null(password)){
    username = tryCatch(espa_get_creds()[1], error = function(e) stop("Please set your espa-api creds in espa_creds()"))
    password = tryCatch(espa_get_creds()[2], error = function(e) stop("Please set your espa-api creds in espa_creds()"))
  }
  # check if username and password and if API working
  if(!espa_user(host = host, username = username, password = password)){
    return(NULL)
  }
  # if order id is not specified, specify it using date or take all the orders
  if(is.null(order_id)){
    order_id = espa_list_orders(min_date = min_date, max_date = max_date, host = host, username = username, password = password)
    # if no orders found
    if(length(order_id) == 0){
      order_id = NULL
    }
  }

  # if order id is specified or found using above function
  if(!is.null(order_id)){
    wrong_order_id = c()
    order_details = list()
    k = 1
    for(i in 1:length(order_id)){
      status_url = paste0(host, "item-status/", order_id[i])
      result = tryCatch(GET(status_url, authenticate(username, password)), error = function(e) FALSE)
      if(is.logical(result)){
        cat(paste0("API Connection Failed for order,",order_id[i]))
        wrong_order_id = c(wrong_order_id, order_id[i])
        next
      }
      result_detail = fromJSON(rawToChar(result$content))
      #if order_id is wrong
      if(length(result_detail) == 0){
        wrong_order_id = c(wrong_order_id, order_id[i])
      } else {
        # else storing the meta information and the other product details in a dataframe
        result_detail = as.data.frame(result_detail[[1]])
        result_detail$order_id = order_id[i]
        result_detail$ordered_date = order_date(order_id[i])
        result_detail$path = sapply(result_detail$name, function(x) product_row_path(x)[1])
        result_detail$row = sapply(result_detail$name, function(x) product_row_path(x)[2])
        result_detail$capture_date = sapply(result_detail$name, function(x) product_date(x)[1])
        result_detail$process_date = sapply(result_detail$name, function(x) product_date(x)[2])
        order_details[[k]] = result_detail
        k = k+1
      }
    }
    order_details = bind_rows(order_details)
    if(length(unique(order_details$status)) ==1){
      cat(paste("Status of your order is", unique(order_details$status),"\n"))
      if(unique(order_details$status) == "complete" & getSize){
        cat("Getting file sizes, might take time. Hold on!")
        order_details$size = NA
        url = order_details$product_dload_url
        for(i in 1:length(url)){
          print(i)
          xx = RCurl::getURL(url[i], nobody=1L, header=1L)
          order_details$size[i] = strsplit(xx, "\r\n")[[1]][5]
        }
        order_details$size = as.numeric(gsub("(.*\\s)(.*)", "\\2", order_details$size))
      }
    }
    return(list(order_details = order_details, wrong_order_id = wrong_order_id))
  } else {
    cat("No orders found\n")
    return(NULL)
  }
}
