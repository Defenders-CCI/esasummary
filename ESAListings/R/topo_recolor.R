#' change color scales by 'count' value in topoJson
#'
#' @param topo topoJSON character vector with \code{count} attribute
#' @param max maximum value of \code{count} attribute
#' @param function defining color mapping such as \code{leaflet::colorNumeric}
#' @return topoJSON character vector
#' @examples
#'topo_recolor(topo_prac, 300, palfx)
topo_recolor <- function(topo, max, FUN){
 for(i in 1:max){
  str_replace_all(topo,
                  sprintf("\"count\":\\[%s\\],\"style\":\\{\"fillColor\":\\[\"#[:alnum:]*",i),
                  sprintf("\"count\":\\[%s\\],\"style\":\\{\"fillColor\":\\[\"%s",i,FUN(i)))
 }
}


#' update listed species counts per county in topoJSON
#'
#' @param topo topoJSON character vector with \code{GEOID} and \code{count] attributes
#' @param counts dataframe containing \code{GEOID} and \code{count} attributes
#' @return topoJSON character vector
#' @examples
#'topo_update(topo_prac, counties)
topo_update <- function(topo, counts){
  for(i in counts$GEOID){
    count <- sprintf("\"GEOID\":\\[\"%s\"\\],.+,\"count\":\\[[:digit:]{1,4}\\]", i)
    txt <- str_extract(topo, count)
    new_count <- sprintf("\"count\":\\[%s\\]", counts$count[counts$GEOID==i])
    new_txt <- str_replace_all(txt, "\"count\":\\[[:digit:]{1,4}\\]", count)
    str_replace_all(topo, txt, new_txt)
  }
}

for(i in test_df$GEOID){
  count <- sprintf("'GEOID':\\[\"%s\"\\],.+,'count':\\[[:digit:]{1,4}\\]", i)
  txt <- str_extract(test_topo, count)
  new_count <- sprintf("'count':\\[%s\\]", test_df$count[test_df$GEOID==i])
  new_txt <- str_replace_all(txt, "'count':\\[[:digit:]{1,4}\\]", count)
  str_replace_all(test_topo, txt, new_txt)
}