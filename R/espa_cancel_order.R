# to cancel orders
## returns a vector of order ids which could NOT be cancelled
#' Cancel Landst espa Orders
#' @description This will cancel the order placed earlier through \code{\link{espa_order}}
#' @param order_id vector of order ids to be cancelled
#' @param host the api call host. Default set to espa v1 web api
#' @param username default NULL, which fetches the username from the global environment. If defined otherwise, will run the api with the provided details
#' @param password default NULL, which fetches the password from the global environment. If defined otherwise, will run the api with the provided details
#'
#' @return vector of order ids which could NOT be cancelled
#' @export
#'
#' @examples
#' \dontrun{
#' # input the credentials, if not defined earlier
#' espa_creds("your_espaname", "secret_password")
#' # Cancel orders
#' ## return NULL as credentials not valid
#' espa_cancel_order(order_id = c("your_order_id1", "your_order_id2"))}

espa_cancel_order <- function(order_id, host = 'https://espa.cr.usgs.gov/api/v1/', username = NULL, password = NULL){
  # getting the username and password from global environment if not specified
  if(is.null(username) & is.null(password)){
    username = tryCatch(espa_get_creds()[1], error = function(e) stop("Please set your espa-api creds in espa_creds()"))
    password = tryCatch(espa_get_creds()[2], error = function(e) stop("Please set your espa-api creds in espa_creds()"))
  }
  # check if username and password and if API working
  if(!espa_user(host = host, username = username, password = password)){
    return(NULL)
  }
  # can cancel only one order at a time
  failed_order = c()
  for(i in 1:length(order_id)){
    json_cancel = paste0('{
                         "orderid": "',order_id[i],'",
                         "status": "cancelled"
  }')
    cancel_url = paste0(host,"order")
    pp = tryCatch(PUT(cancel_url,
                      authenticate(username, password),
                      body = json_cancel),error = function(e) {FALSE})
    if(is.logical(pp)){
      cat(paste("Cancellation failed for order id:",order_id[i],"\n"))
      failed_order = c(failed_order, order_id[i])
    }
    if(pp$status_code == 202){
      cat(paste("Cancellation successful for order id:",order_id[i],"\n"))
    }
}
  return(failed_order = failed_order)
  }
