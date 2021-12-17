library(ecosscraper)
library(dplyr)
BASEDIR <- file.path("~/Repos/defend-esc-dev/open/listings-summary/data")
TECP_table <- get_TECP_table()
TECP_domestic <- filter_domestic(TECP_table)
if(exists(TECP_domestic)){
 save(TECP_domestic, file = file.path(BASEDIR, "TECP_domestic.rda"))
}
