#' Input and Save esap-api Credentials
#' @description Save the ESPA login credentials as global environment to be used in other functions in rLandsat. This is a pre-requisite for running any of the other functions requiring espa-api
#' @param username espa account's username
#' @param password espa account's password corresponding to the username
#' @details If you do not have an account with espa, please create one here: https://ers.cr.usgs.gov/register
#' @return NULL. Just saves the username and password in .Reviron
#' @export
#'
#' @examples
#' # set the espa credentials to be used by other functions
#' espa_creds(username = "your_espaname", password = "secret_password")
espa_creds <- function(username, password){
  Sys.setenv("espa_username" = username)
  Sys.setenv("espa_password" = password)
}
