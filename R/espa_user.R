

#' Validate Espa Credentials
#' @description To check espa credentials and if espa-api is responding. Suggest to use \code{\link{espa_creds}} function to store your credentials before running this function
#' @param host the api call host. Default set to espa v1 web api
#' @param username default NULL, which fetches the username from the global environment. If defined otherwise, will run the api with the provided details
#' @param password default NULL, which fetches the password from the global environment. If defined otherwise, will run the api with the provided details
#'
#' @return logical. TRUE if user is active, FALSE if credentials are wrong or API is unresponsive
#' @export
#' @import "httr" "jsonlite" "dplyr" "readr" "stringr"
#' @examples
#' ## inputting the credentials
#' espa_creds("your_espaname", "secret_password")
#' ## checking if the user is valid
#' espa_user() # returns FALSE
#'
espa_user <- function(host = 'https://espa.cr.usgs.gov/api/v1/', username = NULL, password = NULL){
  # getting the username and password from global environment if not specified
  if(is.null(username) | is.null(password)){
    username = tryCatch(espa_get_creds()[1], error = function(e) stop("Please set your espa-api creds in espa_creds()"))
    password = tryCatch(espa_get_creds()[2], error = function(e) stop("Please set your espa-api creds in espa_creds()"))
  }
  # Running GET for espa-api
  result = tryCatch(GET(paste0(host, "user/"), authenticate(username, password)),error = function(e) {FALSE})
  if(is.logical(result)){
    cat("Cannot Connect to espa-api\n")
    return(result)
  }
  # getting the role of user specified
  tryCatch({
    user_role = fromJSON(rawToChar(result$content))$roles
  }, error = function(err){
    cat("Status Code from ESPA API:",result$status_code,"\n")
    print(result)
    return("Cannot Connect to ESPA APIs. Please check https://espa.cr.usgs.gov/api/v1/user for details\n")
  })

  if(length(user_role)>0){
    result = fromJSON(rawToChar(result$content))$roles == "active"
    cat(paste("The user", username, " is", user_role,"\n"))
    cat("\n")
  } else {
    cat('Oops! Invalid username password\n')
    result = FALSE
  }
  return(result)
}
