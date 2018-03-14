# this script contains supporting functions, which are needed to run the other functions in rLandsat

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

# to get the date of order from order id
order_date = function(order_id){
  return(as.Date(gsub("(.*\\-)([[:digit:]]{8})(.*)", "\\2", order_id),"%m%d%Y"))
}

# to get a named vector of path and row from landsat8 collection-1 product_id
product_row_path = function(product_id){
  rowpath = gsub("(.*_)([[:digit:]]{6})(_)(.*)", "\\2",product_id)
  path = substr(rowpath, 1,3)
  row = substr(rowpath, 4,6)
  return(c(path = path, row = row))
}

# to get a named vector of capture_date and process_date from product_id
product_date = function(product_id){
  capture_date = as.Date(gsub("(.*_)([[:digit:]]{6})(_)([[:digit:]]{8})(_)([[:digit:]]{8})(_)().*", "\\4",product_id),"%Y%m%d")
  process_date = as.Date(gsub("(.*_)([[:digit:]]{6})(_)([[:digit:]]{8})(_)([[:digit:]]{8})(_)().*", "\\6",product_id),"%Y%m%d")
  return(c(capture_date = as.character(capture_date), process_date = as.character(process_date)))
}

