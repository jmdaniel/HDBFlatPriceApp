# ---------------------------------------------
# Coursera Data Product Course
# Module: HDB Reseller price predictive model - ShinyUI
#         Predict HDB flat price based on input criteria
# Data: 2nd July 2016
# Author: Jean-Michel Coeur
# ---------------------------------------------

library(shiny)
require(leaflet) # Maps

source("./Library/HDBPredictiveModel.R")

# Loading cleaned HDB Resale flat prices
hdb_flat <- getCleanHDBData()

# Get the available flat choives from the data
towns <- levels(hdb_flat$town)
types <- levels(hdb_flat$flat_type)
storeys <- levels(hdb_flat$storey_range)
models <- levels(hdb_flat$flat_model)

# Define UI for application that plots random distributions 
shinyUI(fluidPage(theme = "bootstrap.css",

  HTML('<center><h4>Pricing tool for choosing a public housing flat in Singapore.</h4></center>'),

  h4("Introduction:"),
  tags$body("Singapore has had an extensive public housing program since its inception in 1960, managed by the Housing Development Board (HDB). This constitutes a large reseller market for all HDB flats older than 5 years."),
  tags$body("This application has been built within the context of the final project of the Coursera 'Data Product' course. It predicts the price of a flat based on the location (HDB town), the type, model, the storeys range and the year when the lease started. To this extend, it uses the 2014 - 2016 public housing resale price data from the"),
  tags$a(href = "http://www.data.gov.sg", "Singapore's Open Data portal"),
  tags$body(", which includes about 40,000 flats transations on the reseller market."),
  
  tags$body("Each HDB development has a 99 years lease (Year start lease): the more recent the lease is, the higher is the price."), p(" "),
  
  # Input data: 
  # Combo box: town, flat_type, storey_range, flat_model
  # Slider: lease_start_date
  # Example: "WOODLANDS","4 ROOM","07 TO 09","Model A", 1980
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(width = 3, height = 8,
               
    # Combox box
    selectInput("towns", "HDB Town:", towns),
    selectInput("types", "Flat Types:", types),
    selectInput("models", "Flat model:", models),
    selectInput("storeys", "Storey range:", storeys),
    
    # Slider
    sliderInput("start_year_lease",
                  "Year start lease:",
                  min = 1966,
                  max = 2013,
                  value = 1980),
    
    # Add Action Button and author
    actionButton("compute", "Compute resale price"),
    p(". "), p("Author: Jean-Michel Coeur - July 2016")
  ),
  
  # Display the main panel with 3 tabs
  mainPanel(
    # Inititial intructions for selecting the characteritics of a flat
    h4("Quick user's guide:"),
    tags$body("1. Select the characteristics of the flat you are looking for and click on 'Compute resale price'. 2. Select the tab 'Flats on Singapore's map' to view the location of the choosen flat."),
    tags$body("3. If you select a different flat from the same town, the marker on the map will include all information of the previously selected flats."),

    tabsetPanel(position = "right", id = "navPanel",
                # First panel displays the table that includes each price prediction 
                tabPanel("Predicted price",br(),
                         p("Estimated resale price are in Singapore dollars (S$) with the lower and upper bounds, rounded to the S$1000."), 
                         tableOutput("oselection")),
                
                # Second panel displays the Singapore map with the markers on each HDB town selected by the user
                tabPanel("Flats on Singapore's map", br(),
                         #p("The map is automatically displayed 5 seconds after a new prediction is performed."),
                         p("The map below plots the location of your selected HDB town(s). Click on the marker(s) to view the flat information."), 
                         leafletOutput("map")),
                
                # Graphical illustration of a recent HDB programme
                tabPanel("Public Housing in Singapore - Overview", br(), 
                         p("Since 1960, more than 1M flats have been built under the HDB scheme across 23 HDB towns and 3 estates. Here is a recent HDB development: the 'Pinnacle @ Duxton', in Tanjong Pagar."), 
                         div(id = "document", class = "picture"),
                         br()) 
    )
  )
))

#  ---------------- End of the file ui.R ---------------- 

