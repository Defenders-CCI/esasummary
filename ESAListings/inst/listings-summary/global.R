library(dplyr)
library(DT)
#library(ESAListings)
library(highcharter)
library(leaflet)
library(plotly)
library(treemap)
library(shinyBS)
library(shinydashboard)
library(viridis)

load("data/county_topo.rda")
load("data/esacounties.rda")
#data("TECP_date")
#data("TECP_domestic")
load("data/TECP_domestic.rda")
load("data/county_attrib.rda")

#pull summaries of listings for boxes
num_es <- nrow(filter(TECP_domestic, Federal_Listing_Status == "Endangered"))
num_th <- nrow(filter(TECP_domestic, Federal_Listing_Status == "Threatened"))
num_pr <- nrow(filter(TECP_domestic, startsWith(Federal_Listing_Status, "Proposed")))
num_cn <- nrow(filter(TECP_domestic, Federal_Listing_Status == "Candidate"))



#create 'counties' dataset
counties<-group_by(esacounties, GEOID)%>%
  summarise(count = n())

#counties$Species <- sapply(counties$GEOID, function(x,y) y$Scientific[y$GEOID == x], y = esacounties)

counties <- dplyr::left_join(counties, select(county_attrib, GEOID, INTPTLAT, INTPTLON, NAME, ALAND),by = "GEOID")


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
  filter(Status != "Experimental Population, Non-Essential" & Status != "Similarity of Appearance to a Threatened Taxon")%>%
  summarise(count=n())

regions <- as.data.frame(regions)
regions$Lead_Region[regions$Lead_Region != "NMFS"] <- paste("Region", regions$Lead_Region[regions$Lead_Region != "NMFS"])

#create 'years' dataframe
years <- mutate(TECP_domestic, Year = substr(First_Listed,9,12))%>%
  select(Year, Federal_Listing_Status)%>%
  filter(Federal_Listing_Status == "Endangered"|Federal_Listing_Status == "Threatened")

years$Status <- sapply(years$Federal_Listing_Status, function(x)
  if(x == "Proposed Endangered"|x == "Proposed Threatened"){
    "Proposed"}
  else{x})

years <- group_by(years, Year,Status)%>%
  summarise(count = n())

years$Year <- as.integer(years$Year)

impute <- data.frame(Year = rep(seq(min(years$Year,na.rm=TRUE),
                                    max(years$Year,na.rm=TRUE),1),2),
                     Status = rep(unique(years$Status),
                                  each = max(years$Year, na.rm =TRUE) - 1966))

years <- right_join(years, impute, by = c("Year", "Status"))
years$count[is.na(years$count)] <- 0

totals <- group_by(years, Year)%>%
            arrange(Year)%>%
            summarise(total = sum(count))%>%
            mutate(cumm = cumsum(total))


# create color palettes for
list_pal <- rev(substr(viridis(4),1,7)) #c("yellow","red","black","green","purple","orange")
#define pallete function for chloropleth map
palfx <- colorNumeric(palette = c("midnightblue","yellow"), domain = c(0,75), na.color = "yellow")
#define pallete funciton converting status names to colors
stat_pal <- function(status){switch(status,
                                    Candidate = list_pal[2],
                                    Endangered = list_pal[1],
                                    Proposed = list_pal[3],
                                    Threatened = list_pal[4])}
                                    #Experimental = substr(list_pal[5]),
                                    #Similarity = substr(list_pal[6])}

#create initial treemaps
dat1 <- group_by(regions, Lead_Region, Status)%>%
    summarize(count = sum(count))
dat2 <- group_by(regions,Group, Status)%>%
    summarize(count = sum(count))

tm_tx <- list()
  for(i in unique(dat1$Lead_Region)){
    ls1 <- list(name = i, id = i, value = sum(dat1$count[dat1$Lead_Region == i]), color = NA)
    tm_tx[[length(tm_tx)+1]] <- ls1
  }
  for(i in 1:length(dat1$count)){
    ls2 <- list(parent = dat1$Lead_Region[i], name = dat1$Status[i], value = dat1$count[i], color = stat_pal(strsplit(dat1$Status[i]," ")[[1]][1]))
    tm_tx[[length(tm_tx)+1]] <- ls2
  }

tm_rg <- list()
 for(i in unique(dat2$Group)){
   ls1 <- list(name = i, id = i, value = sum(dat2$count[dat2$Group == i]), color = NA)
   tm_rg[[length(tm_rg)+1]] <- ls1
 }
 for(i in 1:length(dat2$count)){
   ls2 <- list(parent = dat2$Group[i], name = dat2$Status[i], value = dat2$count[i], color = stat_pal(strsplit(dat2$Status[i]," ")[[1]][1]))
   tm_rg[[length(tm_rg)+1]] <- ls2
 }


#create all combos of region x status and group x status - need these for highcharter to do proper grouping
#of stacked bar plots
rg_combos <- data.frame(Lead_Region = rep(unique(regions$Lead_Region),each = 4),Status = rep(c("Endangered","Proposed","Threatened", "Candidate"),9))
tx_combos <- data.frame(Group = rep(unique(regions$Group),each = 4),Status = rep(c("Endangered","Proposed","Threatened", "Candidate"),11))


#tags$li(class = "dropdown", img(height = "50px", src = "01_DOW_LOGO_COLOR_300-01.png")),
#tags$li(class = "dropdown", p(tags$b("Defenders of Wildlife"), br(), tags$b("Endangered Species Program")))
#https://www.fws.gov/Endangered/media/regions/region-map.png
