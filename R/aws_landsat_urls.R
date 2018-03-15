#' Getting Landsat8 Raw Files URL from AWS index html Files
#'
#' @param index_html_url index.html url for which download urls are needed
#' @param TIFtxtOnly logical. To download only the TIF and txt files or all files
#' @param band vector for required bands number
#' @param dest_file the destination location
#' @param scrape if the urls should be scraped from index.html or created using the pattern
#'
#' @return dataframe with download urls
#' @export
#'
#' @examples index_url = "https://s3-us-west-2.amazonaws.com/landsat-pds/c1/L8/148/047/LC08_L1TP_148047_20170404_20170414_01_T1/index.html"
#' temp = aws_landsat_urls(index_url, dest_file = getwd())

aws_landsat_urls <- function(index_html_url, TIFtxtOnly = TRUE, band = NULL, dest_file = NULL, scrape = FALSE){
  require(rvest)
  url_all = list()
  if(!is.null(band)){
    band = c(paste0("B",band), "ANG","MTL")
  }
  if(scrape){
    for(i in 1:length(index_html_url)){
      progress((i/length(index_html_url))*100)
      webpage <- read_html(index_html_url[i])
      tbls <- html_nodes(webpage, "a")
      tbls = bind_rows(lapply(xml_attrs(tbls), function(x) data.frame(as.list(x), stringsAsFactors=FALSE)))
      if(TIFtxtOnly){
        tbls = as.data.frame(tbls[grep("\\.TIF$|\\.txt$", tbls$href),])
        colnames(tbls) = "links"
      }
      tbls$links = paste0(gsub("index\\.html","",index_html_url[i]), tbls$links)
      tbls$band = gsub("\\.txt|\\.TIF|_","",substr(tbls$links, (nchar(tbls$links)-6), nchar(tbls$links)))
      tbls$master = index_html_url[i]
      master_link = index_html_url[i]
      master_link = gsub("index\\.html","",master_link)
      entity_id = gsub("(.*\\/)(.*)(\\/)","\\2",master_link)
      tbls$product_id = entity_id
      #subsetting bands
      if(!is.null(band)){
        band_row = which(tbls$band %in% band)
        if(length(band_row) == 0){
          stop("Wrong bands input. Please Check.")
        } else {
          tbls = tbls[band_row, ]
        }
      }
      url_all[[i]] = tbls
    }
  } else{
    band_master = c("_B4.TIF", "_B11.TIF", "_B2.TIF",
                    "_B1.TIF",  "_B6.TIF",  "_B3.TIF" ,
                    "_B5.TIF" , "_B9.TIF" , "_B8.TIF" ,
                    "_B7.TIF" , "_ANG.txt" ,"_MTL.txt" ,
                    "_B10.TIF", "_BQA.TIF")
    # to get links using index.html path
    for(i in 1:length(index_html_url) ){
      progress((i/length(index_html_url))*100)
      tbls = data.frame(matrix(ncol = 4, nrow = 14))
      names(tbls) = c("product_id","links","band", "master")
      master_link = index_html_url[i]
      master_link = gsub("index\\.html","",master_link)
      entity_id = gsub("(.*\\/)(.*)(\\/)","\\2",master_link)
      band_list = paste0(entity_id, band_master)

      tbls$links = paste0(master_link, band_list)
      tbls$band = gsub("\\.txt|\\.TIF|_","",substr(tbls$links, (nchar(tbls$links)-6), nchar(tbls$links)))
      tbls$master = index_html_url[i]
      tbls$product_id = entity_id
      #subsetting bands
      if(!is.null(band)){
        band_row = which(tbls$band %in% band)
        if(length(band_row) == 0){
          stop("Wrong bands input. Please Check.")
        } else {
          tbls = tbls[band_row, ]
        }
      }
      url_all[[i]] = tbls
    }

    url_all = bind_rows(url_all)

  }
  return(url_all)
}
