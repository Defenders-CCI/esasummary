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

  navbarPage(div(
    column(4,
      tags$a(href = "www.defenders.org",
             tags$img(src = "01_DOW_LOGO_COLOR_300-01.png", height = "80px")
      )
    ),
    column(8,
      h4("Defenders of Widlife", br(), "Center for Conservation Innovation")
    )
  ),
  tabPanel(h4("Overview"),
           id = "summary",
           icon=icon("binoculars"),
    fluidPage(
      fluidRow(
        column(12,
          h2("ESA Overview"),
          span(style="font-size:large",
            p("Since 1973, over 2,000 species have been listed as 'Threatened' or
             'Endangered' under the Endangered Species Act (ESA). The Fish and
             Wildlife Service (FWS) provides a",
             a(href = "http://www.fws.gov/endangered/what-we-do/listing-overview.html",
               target = "_blank",
               " detailed description"),
             " of the listing process. Below, you can explore the number of domestic
             listed species by year as of", textOutput("yesterday", inline=TRUE)
          ))
        )
      ),
      fluidRow(
        column(3,
          valueBox(num_es, "Endangered Species", color = "red", width = 12)),
        column(3,
          valueBox(num_th, "Threatened Species", color = "orange", width = 12)),
        column(3,
          valueBox(num_cn, "Candidate Species", color = "yellow", width = 12)),
        column(3,
          valueBox(num_pr, "Proposed for Listing", color = "green", width = 12))
      ),
      fluidRow(
        column(9,
          plotlyOutput("time"), height = 450),
        column(3,
          h2("Timeline of Listings"),
        span(style="font-size:large",
          p("This chart tracks the number of species listings over time."),
          br(),
          p("Click on a timepoint to see the species listed in a particular
            category that year.", br(), br())),
        DT::dataTableOutput("timeTbl"))
      )
    )
  ),
  tabPanel(h4("Listing Summaries"),
           id = "listings",
           icon = icon("bar-chart"),
    fluidPage(
      fluidRow(
        tabsetPanel(id = "panel1",
          tabPanel("Taxa",
            fluidRow(
              h3("Listings by Taxonomic Group", align = "center")
            ),
            fluidRow(
              column(6,
                span(style="font-size:large",
                  p("The bar chart breaks down the number of listed species by
                    taxon and listing status."
                  )
                ),
                radioButtons(
                  "plants",
                  label = "Plants and Lichens",
                  choices = c("Show" = "", "Hide" = "Plants and Lichens"),
                  inline = TRUE
                )
              ),
              column(6,
                id= "bx1",
                span(style="font-size:large",
                  p("The treemap organizes this information hierarchically, and
                    can be used to visualize the breakdown of taxa within specific
                    FWS Regional Offices. Box sizes correspond to the number of
                    listed species."
                  ),
                  br(),
                  popify(
                    el = p(style = "font-weight:bold",
                           "Click here for instructions."),
                    title = "Treemap Instructions",
                    content = "Mouse over the boxes to see the number of listed species. Click on a taxon to zoom in.",
                    placement = "left",
                    trigger = "click"
                  )
                )
              )
            ),
            fluidRow(
              column(12,
                selectInput(
                  "rg_select",
                  NULL,
                  choices = setNames(
                    as.list(c("", unique(regions$Lead_Region))),
                            c("All FWS Regions", unique(regions$Lead_Region)[1:8],
                            "NMFS (Lead)"
                    )
                  ),
                  selected = "",
                  selectize = FALSE
                ),
                align = "center"
              )
            ),
            fluidRow(
              column(6,highchartOutput("specbars")),
              column(6,highchartOutput("spectree"))
            )
          ),
          tabPanel("Regions",
            fluidRow( h3("Listings by Region", align = "center") ),
            fluidRow(
              column(6,
                span(style="font-size:large",
                  p("The bar chart breaks down the number of listed species by
                    FWS Regional Offices and listing status."
                  )
                ),
                actionButton("mapBut", "FWS Regions Map", inline = TRUE)
              ),
              column(6,
                id = "bx2",
                span(style="font-size:large",
                  p("The treemap organizes this information hierarchically to
                    visualize how listings for specific taxa are distributed
                    among FWS Regional Offices. Box sizes correspond to the
                    number of listed species."),
                  br(),
                  popify(
                    el = p(style="font-weight:bold",
                           "Click here for instructions."),
                    title = "Treemap instructions",
                    content = "Mouse over the boxes to see the number of listed species. Click on a region to zoom in.",
                    trigger = "click",
                    placement = "left"
                  )
                )
              ),
              bsModal("mapwin",
                      title = "Fish & Wildlife Service Regions",
                      trigger = "mapBut",
                      size = "large",
                      tags$img(src = "https://www.fws.gov/endangered/media/regions/region-map.png")
              )
            ),
            fluidRow(
              column(12,
                selectInput(
                  "tx_select",
                  NULL,
                  choices = setNames(
                    as.list(c("", unique(regions$Group))),
                            c("All Taxa", unique(regions$Group))),
                  selected = "",
                  selectize = FALSE),
                align = "center"
              )
            ),
            fluidRow(
              column(6, highchartOutput("regbars")),
              column(6, highchartOutput("regtree"))
            )
          )
        )
      )
    )
  ),
  tabPanel(
    h4("ESA Geography"),
    id = "area",
    icon = icon("globe"),
    fluidPage(
      fluidRow(
        tabsetPanel(id = "panel2",
          tabPanel("U.S. Map",
            fluidRow(
              column(9,
                leafletOutput("map", height = 800), height = 800
              ),
              column(3,
                h2("Geography of Listings"),
                span(style="font-size:large",
                  p("This map shows the number of listed species in each U.S.
                    county based on data from the U.S. Fish and Widlife Service.
                    It can be used to identify 'hot spots' - areas with a high
                    concentration of listed species - such as southern California."
                  )
                ),
                DT::dataTableOutput("specTble")
              )
            )
          ),
          tabPanel("Range Sizes",
            fluidRow(
              column(8,
                plotlyOutput("sp_cumm", height =400), br(),
                plotlyOutput("cn_cumm", height = 400)
              ),
              column(4,
                h2("Distributions of Listed Species"),
                span(style="font-size:large",
                  p("The majority of listed species occupy limited ranges.
                    The top graph illustrates the distribution of listed species'
                    range sizes, in terms of the number of U.S. counties in which
                    they occur."),
                  br(),
                  p("Similarly, most counties have few listed species, although
                    this distribution is less skewed than the sizes of species'
                    ranges.  In 75% of U.S. counties, there are 8 or fewer
                    listed species."
                  )
                ),
                DT::dataTableOutput("rngTble")
              )
            )
          )
        )
      )
    )), fluid=TRUE
  )
)

dashboardPage(header, sidebar, body, skin = "blue")

