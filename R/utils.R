# this script contains supporting functions, which are needed to run the other functions in rLandsat

# =================== ESPA ====================
# to return the stored username and password, if not saved then asks for user input if interactive
espa_get_creds <- function(){
  username <- Sys.getenv('espa_username')
  password <- Sys.getenv('espa_password')
  if(!identical(username, "") & !identical(password, "")) return(c(username, password))

  if(!interactive()) {
    stop("Please set your espa-api creds in espa_creds()", call.=FALSE)
  }

  message("Couldn't find espa-api creds")
  message("Please enter espa-api creds")
  username <- readline("username: ")
  password <- readline("password: ")

  if(identical(username, "")) {
    stop("Username entry failed", call.=FALSE)
  }

  message("Updating espa-api creds...")
  espa_creds(username = username, password = password)
  return(c(username, password))
}

# to GET the date of order from order id
order_date = function(order_id){
  return(as.Date(gsub("(.*\\-)([[:digit:]]{8})(.*)", "\\2", order_id),"%m%d%Y"))
}

# to GET the list of orders for a date range
## returns a list of order ids
## if API fails then returns NULL
espa_list_orders <- function(min_date = NULL, max_date = NULL,  host = 'https://espa.cr.usgs.gov/api/v1/', username = NULL, password = NULL){
  # GETting the username and password from global environment if not specified
  if(is.null(username) | is.null(password)){
    username = tryCatch(espa_get_creds()[1], error = function(e) stop("Please set your espa-api creds in espa_creds()"))
    password = tryCatch(espa_get_creds()[2], error = function(e) stop("Please set your espa-api creds in espa_creds()"))
  }
  # check if username and password and if API working
  if(!espa_user(host = host, username = username, password = password)){
    return(NULL)
  }
  list_url = paste0(host, "list-orders")
  result = tryCatch(httr::GET(list_url, httr::authenticate(username, password)), error = function(e) FALSE)
  if(is.logical(result)){
    cat(paste0("API Connection Failed for order\n"))
    return(NULL)
  }
  if(result$status_code == 200){
    result_list = jsonlite::fromJSON(rawToChar(result$content))
  } else {
    cat(paste0("Error:",result$status_code, "\nAPI Connection Failed for order\n"))
    return(NULL)
  }

  # take subset of order list is date specified
  if(!is.null(min_date) | !is.null(max_date)){
    result_list = as.data.frame(result_list)
    # GETting the date of the orders from the order ids
    result_list$ordered_date = as.Date(order_date(result_list$result_list))
    if(!is.null(min_date)){
      result_list = result_list[which(result_list$ordered_date>= as.Date(min_date)),]
    }
    if(!is.null(max_date)){
      result_list = result_list[which(result_list$ordered_date<= as.Date(max_date)),]
    }
    result_list = as.character(result_list$result_list)
  }
  return(result_list)
}

# =================== SAT API ===================

# sat-api-express wrapper for landsat8
satapilsat8 <- function(date_from = "2013-04-01", date_to = Sys.Date(), limit = 10000, path = NULL, row = NULL){
#  suppressWarnings(suppressMessages(library(httr)))
  if(is.null(row) | is.null(path)){
    link = paste0('https://api.developmentseed.org/satellites/?limit=',limit,'$satellite_name=landsat-8&date_from=',date_from,'&date_to=',date_to)
  } else{
    link = paste0('https://api.developmentseed.org/satellites/?limit=',limit,'$satellite_name=landsat-8&date_from=',date_from,'&date_to=',date_to,'&path=',path,'&row=',row)
  }
  result = httr::GET(link)
  if(result$status_code != 200){
    print(paste("Error:",result$status_code))
  }
  return(result)
}

# =================== GENERIC ===================

# to GET a named vector of path and row from landsat8 collection-1 product_id
product_row_path = function(product_id){
  rowpath = gsub("(.*_)([[:digit:]]{6})(_)(.*)", "\\2",product_id)
  path = substr(rowpath, 1,3)
  row = substr(rowpath, 4,6)
  return(c(path = path, row = row))
}

# to GET a named vector of capture_date and process_date from product_id
product_date = function(product_id){
  capture_date = as.Date(gsub("(.*_)([[:digit:]]{6})(_)([[:digit:]]{8})(_)([[:digit:]]{8})(_)().*", "\\4",product_id),"%Y%m%d")
  process_date = as.Date(gsub("(.*_)([[:digit:]]{6})(_)([[:digit:]]{8})(_)([[:digit:]]{8})(_)().*", "\\6",product_id),"%Y%m%d")
  return(c(capture_date = as.character(capture_date), process_date = as.character(process_date)))
}

# function to GET dataframe after GET
GEToutput <- function(result, output_col = "results", isJSON = TRUE){
#  suppressWarnings(suppressMessages(library(jsonlite)))
  if(isJSON){
    result = jsonlite::fromJSON(rawToChar(result$content))
    if(!is.null(output_col)){
      result = jsonlite::flatten(as.data.frame(result[output_col]))
    }
  } else{
    result = rawToChar(result$content)
  }
  return(result)
}

# to standardize colnames
StandardColnames <- function (dataframe){
 # suppressWarnings(suppressMessages(library(stringr)))
  colnames(dataframe) = gsub("([[:upper:]])([[:upper:]][[:lower:]])",
                             "\\\\1\\\\_\\\\2", colnames(dataframe))
  colnames(dataframe) = gsub("([[:lower:]])([[:upper:]])",
                             "\\\\1\\\\_\\\\2", colnames(dataframe))
  colnames(dataframe) = gsub("[[:punct:]]|\\\\s", "_", colnames(dataframe))
  colnames(dataframe) = gsub("\\\\_+", "_", colnames(dataframe))
  colnames(dataframe) = gsub("\\\\_$|^\\\\_", "", colnames(dataframe))
  colnames(dataframe) = stringr::str_to_lower(colnames(dataframe))
  return(dataframe)
}



