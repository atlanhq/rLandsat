# landsat search
#' Search for Landsat8 Products IDs
#' @description Search for landsat8 product IDs for a geography (country name or row/path) and a specific time duration.
#' @param min_date the start date of the products. Format should be \%Y-\%m-\%d
#' @param max_date the end date of the products. Format should be \%Y-\%m-\%d
#' @param country the country for which product ids is required. NULL if search is not on country. List of available countries are available at data(world_rowpath)
#' @param path_master vector of path numbers
#' @param row_master vector of row numbers corresponding to the path number. Check details
#' @param source search source. Default and recommended is sat-api. Available options: "sat-api", "aws". For AWS it will return the Pre-Collection Scene IDs pre March 2017.
#'
#' @return dataframe with the product ids and the meta information (cloud cover, path/row) along with it.
#' If source is sat-api then raw value download links from all the sources (AWS, Google, ESPA) are also outputted
#'
#' @details for path_master and row_master input is in a pair. For example: If we want path/row of :  (147,47) , (147,48) then path_master = c(147, 147), row_master = c(47,48)
#'
#' @export
#' @import "httr" "jsonlite" "dplyr" "readr" "stringr"
#' @examples
#' # define the start and end dates
#' start = "2017-03-11"
#' end = "2017-03-12"
#'
#' # Get for specific row and path
#' result = landsat_search(min_date=start, max_date=end, path_master=147, row_master=48)
#' \donttest{
#' # Get for entire country
#'  result = landsat_search(min_date=start, max_date=end, country = "India")
#' }
#'


landsat_search <- function(min_date = "2017-03-01", max_date = Sys.Date(),
                           country = NULL, path_master = NULL,
                           row_master = NULL,source = "sat-api"){
  if(source == "sat-api"){
    if(!is.null(country)){

      #data("world_rowpath", envir = environment(landsat_search))
      country_rp = world_rowpath
      c_row = which(stringr::str_to_lower(country_rp$ctry_name) %in% stringr::str_to_lower(country))
      # if country not found
      if(length(c_row) == 0){
        # cleaning country
        country_rp$ctry_name = gsub("^Federal\\sRepublic\\sof\\s|^Republic\\sof\\s","", country_rp$ctry_name)
        c_row = which(stringr::str_to_lower(country_rp$ctry_name) %in% stringr::str_to_lower(country))
      }
      # if still no country found
      if(length(c_row) == 0){
        if(country == "All" | country == "all"){
          c_row = 1:nrow(country_rp)
        } else{
          stop("Error: Country not found")
        }
      }
      # final aws subset for the c
      country_rp = country_rp[c_row,]
      country_rp = StandardColnames(country_rp)
      output = list()
      k = 1
      # for each path and row run the api
      for(path in unique(country_rp$path)){
        for(row in unique(country_rp$row[country_rp$path == path])){
          result = satapilsat8(date_from = min_date, date_to = max_date, path = path, row = row)
          result = GEToutput(result)
          if(nrow(result)>0){
            output[[k]] = result
            k = k+1
          }
        }
      }

      df = bind_rows(output)
      colnames(df) = gsub("results\\.","", colnames(df))

    } else if(!is.null(path_master)){
      # if no country, but row and path mentioned ============

      row_path = data.frame(path_master, row_master)
      output = list()
      k = 1
      # for each path and row run the api
      for(path in unique(row_path$path_master)){
        for(row in unique(row_path$row_master[row_path$path_master == path])){
          result = satapilsat8(date_from = min_date, date_to = max_date, path = path, row = row)
          result = GEToutput(result)
          if(nrow(result)>0){
            output[[k]] = result
            k = k+1
          }
        }
      }
      df = bind_rows(output)
      colnames(df) = gsub("results\\.","", colnames(df))
    } else{
      # if nothing mmentioned =======
      all_yn = readline("Run for entire entire world? [y/n]")
      if(all_yn == "y"){
        result = satapilsat8(date_from = min_date, date_to = max_date, path = NULL, row = NULL)
        df = GEToutput(result)
      } else{
        print("Please narrow your search")
      }
    }
    return(df)
  } else{
    if((as.Date(min_date) < as.Date("2017-03-01")) & (as.Date(max_date) < as.Date("2017-03-01"))){
      # If entire data before Collection
      temp = list.files(path = gsub("(.*\\/)(.*)","\\1",tempfile()), pattern = "preaws*", full.names = T)
      if(length(temp) == 1){
        cat("getting pre-downloaded data from aws\n")
        aws_list_old <- readr::read_csv(gzfile(temp))
      } else{
        temp <- tempfile(pattern = "preaws")
        cat("getting meta data from AWS\n")
        download.file("https://landsat-pds.s3.amazonaws.com/scene_list.gz", destfile = temp)
        aws_list_old <- readr::read_csv(gzfile(temp))
      }
      aws_list_old = aws_list_old[!duplicated(aws_list_old[,-which(names(aws_list_old) == "cloudCover")]),]
      aws_list_old$date = as.Date(substr(aws_list_old$acquisitionDate, 1, 10))
      aws_list = aws_list_old[which(aws_list_old$date >= as.Date(min_date) & aws_list_old$date <= as.Date(max_date)),]
      aws_list = StandardColnames(aws_list)
    } else if(as.Date(min_date) >= as.Date("2017-03-01")){
      # If entire data after Collection
      temp = list.files(path = gsub("(.*\\/)(.*)","\\1",tempfile()), pattern = "aws_c1*", full.names = T)
      if(length(temp) == 1){
        cat("getting pre-downloaded data from aws\n")
        aws_list <- readr::read_csv(gzfile(temp))
      } else{
        temp <- tempfile(pattern = "aws_c1")
        cat("getting meta data from AWS\n")
        download.file("https://landsat-pds.s3.amazonaws.com/c1/L8/scene_list.gz", destfile = temp)
        aws_list <- readr::read_csv(gzfile(temp))
      }
      aws_list = aws_list[!duplicated(aws_list[,-which(names(aws_list) == "cloudCover")]),]
      aws_list$date = as.Date(substr(aws_list$acquisitionDate, 1, 10))
      aws_list = aws_list[which(aws_list$date >= as.Date(min_date) & aws_list$date <= as.Date(max_date)),]
      # ====== including tier type ======
      aws_list$tier = substr(aws_list$productId, (nchar(aws_list$productId)-1) , nchar(aws_list$productId))
      aws_list = StandardColnames(aws_list)
    } else {
      # If data both pre and post Collection
      temp = list.files(path = gsub("(.*\\/)(.*)","\\1",tempfile()), pattern = "preaws*", full.names = T)
      if(length(temp) == 1){
        cat("getting pre-downloaded data from aws \n")
        aws_list_old <- readr::read_csv(gzfile(temp))
      } else{
        temp <- tempfile(pattern = "preaws")
        cat("getting meta data from AWS \n")
        download.file("https://landsat-pds.s3.amazonaws.com/scene_list.gz", destfile = temp)
        aws_list_old <- readr::read_csv(gzfile(temp))
      }
      aws_list_old = aws_list_old[!duplicated(aws_list_old[,-which(names(aws_list_old) == "cloudCover")]),]
      aws_list_old$date = as.Date(substr(aws_list_old$acquisitionDate, 1, 10))
      aws_list_old = aws_list_old[which(aws_list_old$date >= as.Date(min_date) & aws_list_old$date <= as.Date(max_date)),]
      aws_list_old = StandardColnames(aws_list_old)
      temp = list.files(path = gsub("(.*\\/)(.*)","\\1",tempfile()), pattern = "aws_c1*", full.names = T)
      if(length(temp) == 1){
        cat("getting pre-downloaded data from aws\n")
        aws_list <- readr::read_csv(gzfile(temp))
      } else{
        temp <- tempfile(pattern = "aws_c1")
        cat("getting meta data from AWS\n")
        download.file("https://landsat-pds.s3.amazonaws.com/c1/L8/scene_list.gz", destfile = temp)
        aws_list <- readr::read_csv(gzfile(temp))
      }
      aws_list = aws_list[!duplicated(aws_list[,-which(names(aws_list) == "cloudCover")]),]
      aws_list$date = as.Date(substr(aws_list$acquisitionDate, 1, 10))
      aws_list = aws_list[which(aws_list$date >= as.Date(min_date) & aws_list$date <= as.Date(max_date)),]
      # ====== including tier type ======
      aws_list$tier = substr(aws_list$productId, (nchar(aws_list$productId)-1) , nchar(aws_list$productId))
      aws_list = StandardColnames(aws_list)
      # ===== merging old and new data =======
      aws_list = bind_rows(aws_list, aws_list_old)
    }
    aws_list$location_id = paste(aws_list$path,aws_list$row, sep = "-")
    # ====== subsetting for country selected, if any ======
    if(!is.null(country)){
      # read file with country and row-path combination
      #data("world_rowpath", envir = environment(landsat_search))
      country_rp = world_rowpath
      c_row = which(stringr::str_to_lower(country_rp$ctry_name) %in% stringr::str_to_lower(country))
      # if country not found
      if(length(c_row) == 0){
        # cleaning country
        country_rp$ctry_name = gsub("^Federal\\sRepublic\\sof\\s|^Republic\\sof\\s","", country_rp$ctry_name)
        c_row = which(stringr::str_to_lower(country_rp$ctry_name) %in% stringr::str_to_lower(country))
      }
      # if still no country found
      if(length(c_row) == 0){
        if(country == "All" | country == "all"){
          c_row = 1:nrow(country_rp)
        } else{
          stop("Error: Country not found")
        }
      }
      # final aws subset for the c
      country_rp = country_rp[c_row,]
      country_rp = StandardColnames(country_rp)
      country_rp$location_id = paste(country_rp$path,country_rp$row, sep = "-")
      aws_row = which(aws_list$location_id %in% country_rp$location_id)
      if(length(aws_row)>0){
        aws_list = aws_list[aws_row,]
      } else {
        stop("Error: No rows found")
      }
    } else if(!is.null(path_master) & length(row_master)>0){
      row_path = paste0(path_master,"-",row_master)
      # if no country selected and row_path combination input
      aws_row = which(aws_list$location_id %in% row_path)
      if(length(aws_row)>0){
        aws_list = aws_list[aws_row,]
      } else {
        stop("Error: No rows found for given row path combination")
      }
    }
    cat(paste("Total rows :",nrow(aws_list), "\n"))
    return(aws_list)
  }


}
