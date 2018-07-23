#' Check Available Products for given Product-IDs
#'
#' @description For a set of product IDs, check which products (like, sr, toa, spectral indices) are available to download
#' @param input_ids vector of product ids for which available products are needed
#' @param host the api call host. Default set to espa v1 web api
#' @param username default NULL, which fetches the username from the global environment. If defined otherwise, will run the api with the provided details
#' @param password default NULL, which fetches the password from the global environment. If defined otherwise, will run the api with the provided details
#' @return a list :
#' \item{master}{dataframe with product ids as one of the columns and a column for each product with 0 (not available) and 1 (available) values.}
#' \item{no_product}{a vector of product_ids which are incorrect}
#' \item{sample_message}{sample response from the espa-api}
#' Returns NULL if the espa credentials are not  incorrect or the api is unresponsive
#' @export
#'
#' @examples
#' \dontrun{
#' # input the credentials, if not defined earlier
#' espa_creds("your_espaname", "secret_password")
#'
#' # saving the product ids as a vector
#' product_ids = c("LC08_L1TP_148047_20180202_20180220_01_T1",
#'               "LC08_L1TP_134040_20180115_20180120_01_T1",
#'                "invalid_id")
#'
#' # running function to get the available products
#' ## does not return anything as credentials wrong
#' result = espa_products(input_ids = product_ids)}

espa_products <- function(input_ids, host = 'https://espa.cr.usgs.gov/api/v1/', username = NULL, password = NULL){
  # getting the username and password from global environment if not specified
  if(is.null(username) | is.null(password)){
    username = tryCatch(espa_get_creds()[1], error = function(e) stop("Please set your espa-api creds in espa_creds()"))
    password = tryCatch(espa_get_creds()[2], error = function(e) stop("Please set your espa-api creds in espa_creds()"))
  }
  if(!espa_user(host = host, username = username, password = password)){
    return(NULL)
  }
  master = list()
  no_product = c()
  for(i in 1:length(input_ids)){
    get_url = paste0(host,'available-products/', input_ids[i])
    result =GET(get_url, authenticate(username, password))
    result_vec = unname(unlist(fromJSON(rawToChar(result$content))[[1]][2]))
    result_vec = setdiff(result_vec, NA)
    result_df = data.frame(matrix(ncol = (length(result_vec) + 1), nrow = 1))
    colnames(result_df) = c("product_id", result_vec)
    result_df$product_id = input_ids[i]
    if(ncol(result_df) == 1){
      no_product = c(no_product, input_ids[i])
    } else {
      result_df[1,2:ncol(result_df)] = 1
    }
    master[[i]] = result_df
  }
  # merging rows
  master = bind_rows(master)
  master[is.na(master)] = 0
  return(list(master = master, no_product = no_product, sample_message = fromJSON(rawToChar(result$content))))
}
