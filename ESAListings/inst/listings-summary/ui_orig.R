#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
header <-  dashboardHeader(disable = TRUE)

sidebar <-  dashboardSidebar(disable = TRUE)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom_styles.css")),

  navbarPage(div(column(4,tags$a(href = "http://www.defenders.org", tags$img(src = "01_DOW_LOGO_COLOR_300-01.png", height = "80px"))), column(8, h4("Defenders of Widlife", br(), "Center for Conservation Innovation"))),
   tabPanel(h4("Overview"),id = "summary", icon=icon("binoculars"), fluidPage(
    fluidRow(
     column(12, h2("ESA Overview"),
      h4("Since 1973, the Endangered Species Act (ESA) has listed over 2,000 species as
        'Threatened' or 'Endangered'. The Fish and Wildlife Service (FWS) provides a",
        a(href = "http://www.fws.gov/endangered/what-we-do/listing-overview.html", " detailed
        description of the listing process."),  "Below, you can explore the number of domestic listed
        species by year as of", textOutput("yesterday", inline=TRUE))
     )
     ),
    fluidRow(
     column(3, valueBox(num_es, "Endangered Species", color = "red", width = 12)),
     column(3, valueBox(num_th, "Threatened Species", color = "orange", width = 12)),
     column(3, valueBox(num_cn, "Candidate Species", color = "yellow", width = 12)),
     column(3, valueBox(num_pr, "Proposed for Listing", color = "green", width = 12))
    ),

    fluidRow(
     column(9, plotlyOutput("time"), height = 450),
     column(3,
      h2("Timeline of Listings"),
      h4("This chart tracks the number of species listings over time.", br(),
         "Click on a timepoint to see the species listed in a particular category that year.",br(), br()),
      DT::dataTableOutput("timeTbl"))
    )
   )),
   tabPanel(h4("Listing Summaries"), id = "listings", icon = icon("bar-chart"), fluidPage(
    fluidRow(
     tabsetPanel(id = "panel1",
      tabPanel("Taxa",
       fluidRow(
          h3("Listings by Taxonomic Group", align = "center")
        ),
       fluidRow(column(6,
        h4("The bar chart breaks down the number of listed species by taxa,
              and listing status."), radioButtons("plants", label = "Plants and Lichens", choices = c("Show" = "", "Hide" = "Plants and Lichens"), inline = TRUE)),
        column(6, id= "bx1", h4("The treemap organizes this information hierarchically,
              and can be used to visualize the breakdown of taxa within specific FWS Regional Offices.
              Box sizes correspond to the number of listed species.", br(), em("Click here for instructions."))),
        bsPopover(id = "bx1", title = "Treemap Instructions",
                  content = "Mouse over the boxes to see the number of listed species. Click on a taxon to zoom in.", trigger = "click")
          ),
       fluidRow(column(12, selectInput("rg_select", NULL,
                                      choices = setNames(as.list(c("",unique(regions$Lead_Region))),c("All FWS Regions",unique(regions$Lead_Region)[1:8], "NMFS (Lead)")),
                                      selected = "", selectize = FALSE), align = "center"),
        bsTooltip(id = "rg_select", title = "Choose a FWS Region")
       ),
       fluidRow(
        column(6,highchartOutput("specbars")),
        column(6,highchartOutput("spectree"))
       )
      ),
      tabPanel("Regions",
       fluidRow(
         h3("Listings by Region", align = "center")
       ),
       fluidRow(
         column(6,
         h4("The bar chart breaks down the number of listed species by FWS Regional Offices,
            and listing status."), actionButton("mapBut", "FWS Regions Map", inline = TRUE)),
         column(6, id = "bx2",
            h4("The treemap organizes this information hierarchically,
            and can be used to visualize how listings for specific taxa are distributed among FWS Regional Offices.
            Box sizes correspond to the number of listed species.", br(), em("Click here for instructions."))),

         bsPopover(id = "bx2", title = "Treemap instructions",
                   content = "Mouse over the boxes to see the number of listed species. Click on a region to zoom in.", trigger = "click"),
         bsModal("mapwin", title = "Fish & Wildlife Service Regions", trigger = "mapBut", size = "large", tags$img(src = "https://www.fws.gov/endangered/media/regions/region-map.png"))),
       fluidRow(column(12,selectInput("tx_select", NULL,
                                      choices = setNames(as.list(c("",unique(regions$Group))),c("All Taxa", unique(regions$Group))),
                                      selected = "", selectize = FALSE), align = "center"),
       bsPopover(id = "tx_select", title = "Choose a Taxon")
       ),
       fluidRow(
       column(6, highchartOutput("regbars")),
       column(6, highchartOutput("regtree"))
       )
       )
      )
     )
    )),

  tabPanel(h4("ESA Geography"), id = "area",icon = icon("globe"), fluidPage(
    fluidRow(
      tabsetPanel(id = "panel2",
        tabPanel("U.S. Map",
          fluidRow(
            column(9, leafletOutput("map", height = 800), height = 800),
            column(3,
          h2("Geography of Listings"),
          h4("This map shows the number of listed species in each
             U.S. county based on data from the U.S. Fish and Wildlife Service.
             It can be used to identify 'hot spots' -
             areas with a high concentration of listed species - such as
             southern California."),
          DT::dataTableOutput("specTble")
            )
          )
        ),

      tabPanel("Range Sizes",
        fluidRow(
         column(8, plotlyOutput("sp_cumm", height =400), br(),
               plotlyOutput("cn_cumm", height = 400)
         ),
         column(4, h2("Distributions of Listed Species"),
                   h4("The majority of listed species occupy limited ranges.
                  The top graph illustrates the distribution of listed
                  species' range sizes, in terms of the number of
                  U.S. counties in which they occur.", br(), br(),
                  "Similarly, most counties have few listed species, although
                  this distribution is less skewed than the sizes
                  of species' ranges.  In 75% of U.S. counties, there are
                  8 or fewer listed species."),
                DT::dataTableOutput("rngTble"))
        )
      )
     )
    )
   )), fluid=TRUE
  ),
  br(),
 fluidRow(column(2),
  column(4, div(HTML('<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">
    <img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a>
  <br />
  This <span xmlns:dct="http://purl.org/dc/terms/" href="http://purl.org/dc/dcmitype/InteractiveResource" rel="dct:type">work</span>
  by <a xmlns:cc="http://creativecommons.org/ns" href="http://defenders.org" property="cc:attributionName" rel="cc:attributionURL">Defenders of Wildlife</a>
  is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
  <br />'),
  style = "text-align: center")),
  column(1),
  column(2, div(HTML('<br /> Email questions or comments to <a href = "mailto:esa@defender.org"> esa@defenders.org </a>'), style = "text-align: center"))
 )
)

dashboardPage(header, sidebar, body, skin = "blue")

