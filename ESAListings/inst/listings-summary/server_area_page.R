#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

server_area_page <- function(input, output, session) {

  #county map showing # of species per county
  output$map <- renderLeaflet({
      leaflet()%>%
      addTopoJSON(county_topo, weight = 0.5, color = "black", fillOpacity = 0.5)%>%
      addProviderTiles("Stamen.TonerLite")%>%
      setView(lng=-95, lat=38, zoom = 4) %>%
      mapOptions(zoomToLimits = "never")%>%
      addLegend(title = "Number of<br>Listed Species",
                position = "bottomleft",
                #pal = palfx,
                #values = seq(0, 80, 10),
                colors = palfx(seq(0, 80, 10)),
                labels = c("- 0","- 10","- 20","- 30","- 40","- 50","- 60","- 70","> 80"))%>%
      addLegend(title = "Click on the center of a county<br>to see the species listed there.", position = "topright", colors = NULL, labels = NULL)%>%
      addCircles(data = counties,
                      lng = ~INTPTLON,
                      lat = ~INTPTLAT,
                      radius = ~sqrt(ALAND)/5,
                      color = "red",
                      fillOpacity = 0,
                      stroke = FALSE,
                      popup = ~paste0(NAME," County<br>", count, " species<br>")
                      )
  })

  observe({
    if(!is.null(input$specTble_cell_clicked$value)) {
      #print(input$specTble_cell_clicked$value)
    spec_select <- filter(esacounties,
                          Scientific == input$specTble_cell_clicked$value)%>%
                   select(GEOID)
    # print(spec_select$GEOID)
    leafletProxy("map")%>%
    clearMarkers()%>%
    addCircleMarkers(data = filter(counties,GEOID %in% spec_select$GEOID),
                   lng = ~INTPTLON,
                   lat = ~INTPTLAT,
                   radius = 2,
                   color = "black",
                   fillOpacity = 1,
                   stroke = FALSE
    )
    }
  })

  observeEvent(input$map_shape_click,{
    click_lat <- input$map_shape_click[[3]]
    click_lon <- input$map_shape_click[[4]]
    gid <- counties$GEOID[counties$INTPTLAT == click_lat & counties$INTPTLON == click_lon]
    output$specTble <- DT::renderDataTable({
      filter(esacounties, GEOID == gid)%>%
      select(Scientific, Common)%>%
      datatable(rownames = FALSE, selection = "single", colnames = c("Species", "Common Name"), caption = "Click a species name to see it's range displayed")
      })
  })

  output$sp_cumm <- renderPlotly({
    #cummulative number of counties per species
    py<-plot_ly(arrange(species, count), x = ~count, source = "sp_dist")%>%
      add_lines(y = ~round(row_number(count)/nrow(species), 3), name = "Cumulative",
            type = "scatter", mode = "lines",
            text = ~paste(round(row_number(count)/nrow(species),3)*100,"% of species occur in", count, "or fewer counties"), hoverinfo = "text")%>%
      add_histogram(histnorm = "probability", name = "Histogram", xbins = list(start = 0.5, end = 3102.5, size = 1),
                    text = ~paste("% of counties contain", "listed species"),
                    hoverinfo = "none")%>%
      layout(title = "Listed Species Range Sizes<br>(click to see species)",
             xaxis = list(title = "Number of Counties in Species' Range", type = "log", tickvals = c(0, 1, 5, 10, 50, 100, 500, 1000, 3000)),
             yaxis = list(title = "Percentile of Species"),
             legend = list(x = 0.05, y = 0.95))
  })

  output$cn_cumm <- renderPlotly({
  #cummulative number of counties per species
    plot_ly(arrange(counties, count), x = ~count)%>%
      add_lines(y = ~round(row_number(count)/nrow(counties), 3), name = "Cumulative",
            type = "scatter", mode = "lines",
            text = ~paste(round(row_number(count)/nrow(counties),3)*100,"% of counties contain", count, "or fewer species"),
            hoverinfo = "text")%>%
      add_histogram(histnorm = "probability", name = "Histogram",
                  #text = ~paste("% of counties contain", "listed species"),
                    hoverinfo = "none")%>%
      layout(title = "Listed Species per U.S. County",
             xaxis = list(title = "Number of Listed Species per County", type = "log", tickvals = c(0, 1, 5, 10, 50, 100, 1000)),
             yaxis = list(title = "Percentile of Counties"),
             legend = list(x = 0.05, y = 0.95))

  })

 observeEvent(event_data("plotly_click", source = "sp_dist"),{
  print(event_data("plotly_click", source = "sp_dist"))
  sp_count <- event_data("plotly_click", source = "sp_dist")$x[[1]]
  temp <- group_by(TECP_domestic, Scientific_Name, Common_Name)%>%
    summarize(Scientific = first(Scientific_Name))
  output$rngTble <- DT::renderDataTable({
   filter(species, count == sp_count)%>%
   inner_join(temp, by = c("Scientific"))%>%
   select(Scientific, Common_Name, count)%>%
   datatable(rownames = FALSE, selection = "none", colnames = c("Species", "Common Name", "Counties"))
})})
}

