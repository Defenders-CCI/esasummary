library(dplyr)
library(DT)
library(ESAListings)
library(highcharter)
library(leaflet)
library(plotly)
library(treemap)
library(shinydashboard)
library(shinyjs)
library(viridis)

data("county_topo")
data("esacounties")
data("TECP_date")
data("TECP_domestic")
data("county_attrib")

#pull summaries of listings for boxes
num_es <- nrow(filter(TECP_domestic, Federal_Listing_Status == "Endangered"))
num_th <- nrow(filter(TECP_domestic, Federal_Listing_Status == "Threatened"))
num_pr <- nrow(filter(TECP_domestic, startsWith(Federal_Listing_Status, "Proposed")))
num_cn <- nrow(filter(TECP_domestic, Federal_Listing_Status == "Candidate"))



#create 'counties' dataset
counties<-group_by(esacounties, GEOID)%>%
  summarise(count = n())

#counties$Species <- sapply(counties$GEOID, function(x,y) y$Scientific[y$GEOID == x], y = esacounties)

counties <- dplyr::left_join(counties, select(county_attrib, GEOID, INTPTLAT, INTPTLON, NAME),by = "GEOID")


#create species dataset
species <- dplyr::group_by(esacounties, Scientific)%>%
  summarise(count = n())%>%
  arrange(count)

#create regions dataset
regions <- group_by(TECP_domestic, Lead_Region, Species_Group, Federal_Listing_Status)

regions$Group <- sapply(regions$Species_Group, function(x)
  if(x == "Ferns and Allies"|x == "Flowering Plants"|x == "Conifers and Cycads"|x == "Lichens"){
    "Plants and Lichens"}
  else if(x == "Snails"|x=="Clams"){
    "Molluscs"}else{x})

regions$Status <- sapply(regions$Federal_Listing_Status, function(x)
  if(x == "Proposed Endangered"|x == "Proposed Threatened"){
    "Proposed"}
  else{x})

regions <- group_by(regions, Lead_Region, Group, Status)%>%
  summarise(count=n())

regions <- as.data.frame(regions)
regions$Lead_Region[regions$Lead_Region != "NMFS"] <- paste("Region", regions$Lead_Region[regions$Lead_Region != "NMFS"])

#create 'years' dataframe
years <- mutate(TECP_date,Year = substr(First_Listed,9,12))%>%
  select(Year, Federal_Listing_Status)

years$Status <- sapply(years$Federal_Listing_Status, function(x)
  if(x == "Proposed Endangered"|x == "Proposed Threatened"){
    "Proposed"}
  else{x})

years <- group_by(years, Year,Status)%>%
  summarise(count = n())

years$Year <- as.integer(years$Year)

impute <- data.frame(Year = rep(seq(min(years$Year,na.rm=TRUE),
                                    max(years$Year,na.rm=TRUE),1),6),
                     Status = rep(unique(years$Status),
                                  each = max(years$Year, na.rm =TRUE) - 1966))

years <- right_join(years, impute, by = c("Year", "Status"))
years$count[is.na(years$count)] <- 0

totals <- summarise(group_by(years, Year), total = sum(count))

# create color palettes for
list_pal <- c("yellow","red","black","green","purple","orange")
name_pal <- c("yellow","red","black","green","purple","orange")
names(name_pal) <- c("Candidate", "Endangered", "Experimental Population, Non-Essential", "Proposed", "Similarity of Appearance to a Threatened Taxon", "Threatened")
#define pallete function for chloropleth map
palfx <- colorNumeric(palette = c("midnightblue","yellow"), domain = c(0,75), na.color = "yellow")

#create initial treemaps
dat1 <- group_by(regions, Lead_Region, Status)%>%
    summarize(count = sum(count))
dat2 <- group_by(regions,Group, Status)%>%
    summarize(count = sum(count))

  tm_tx <- treemap(dat1,
                   index = c("Lead_Region", "Status"),
                   vSize = "count", type = "categorical", vColor = "Status",
                   fontsize.labels = c(16, 0),
                   align.labels = list(c("left","top"), c("center","center")),
                   bg.labels = 0, palette = list_pal[names(name_pal)%in%dat1$Status])
  tm_tx$tm$color[tm_tx$tm$level == 1] <- NA

  tm_rg <- treemap(dat2,
                   index = c("Group", "Status"),
                   vSize = "count", type = "categorical", vColor = "Status",
                   fontsize.labels = c(16, 0),
                   align.labels = list(c("left","top"), c("center","center")),
                   bg.labels = 0, palette = list_pal[names(name_pal)%in%dat2$Status])
  tm_rg$tm$color[tm_rg$tm$level == 1] <- NA