
#' Downlaod Landsat Files from URL
#'
#' @param download_url vector of urls to be downloaded
#' @param entity_id product id correspoding to the urls if the downloads need to be in folder wise for AWS links
#' @param folder_wise if the downloads need to be in folder wise for AWS links
#' @param dest_file the destination folder where the files are to be downloaded
#'
#' @return vector of failed urls
#' @details Caution: use entity_id and folder_wise ONLY in case of downloading the individual bands (like from AWS). Get the downlaod urls from espa functions in this library. View the demo
#' @export
#'
#' @examples landsat_download("https://edclpdsftp.cr.usgs.gov/orders/espa-order_id1.tar.gz", dest_file = getwd())

landsat_download <- function(download_url, entity_id = NULL, folder_wise = FALSE, dest_file = NULL){
  if(is.null(dest_file)){
    if(interactive()){
      dest_yn = readline(prompt = "No destination folder selected. Download in the current directory? [y/n]")
    } else {
      dest_yn = "n"
    }
    if(dest_yn == "y"){
      dest_file = getwd()
    } else{
      stop("Stopping. No destination file found.")
    }
  }
  if(!(folder_wise)){
    entity_id = rep("/", length(download_url))
  }
  if(is.null(entity_id)){
    stop("Error: entity_id not found for folder_wise structure")
  } else if(length(download_url) != length(entity_id)){
    stop("Error: Different lengths of urls and entity ids")
  } else{
    # cont_yn = readline(prompt = paste("Scared of BIG data? Download", length(download_url), "files? [y/n]"))
    # if(cont_yn != "y"){
    #  stop("Stopping: Don't be scared of me. I am just BIG data")
    # }
    failed = c()
    for(i in 1: length(download_url)){
      if(!dir.exists(paste0(dest_file,"/",entity_id[i]))){
        dir.create(paste0(dest_file,"/",entity_id[i]))
      }
      failed = suppressWarnings(tryCatch(download.file(download_url[i], paste0(dest_file,"/",entity_id[i],"/",gsub("(.*\\/)(.*)","\\2",download_url[i]))),
                                         error = function(e) {c(failed, i)}))
      progress((i/length(download_url))*100)
    }
  }
  return(failed)
}
