# ---------------------------------------------
# Coursera Data Product Course
# Module: HDB Reseller price predictive model - Shiny Server
#         Predict HDB flat price based on input criteria
# Data: 2nd July 2016
# Author: Jean-Michel Coeur
# ---------------------------------------------

library(shiny)
library(googleVis) # Google graphics
require(leaflet) # Maps

# We load the library of R functions used to build the predictive model on HDB Flat Resale Price
source("./Library/HDBPredictiveModel.R") 

# Get HDB towns coordinates to display as markers on the Singapore map
hdb_coord <- town_coord()

# Loading & cleaning HDB Resale flat prices
hdb_flat <- getCleanHDBData()

# Build the inventory for each type of flat
buildInventory(hdb_flat) # Not used in this version

# Build the predictive Linear model
fit_model <- buildModel(hdb_flat)

# Build the dataframe that contains all predictions
price_predict_df <- data.frame(town = NULL, flat_type = NULL, flat_model = NULL, storey_range = NULL, 
                               lease_start_date = NULL, Price = NULL, Lower = NULL, Upper = NULL)
price_table <<- price_predict_df
content <<- NULL

# Initialise the Singapore map using the Leaflet object
smap <- addTiles(leaflet())
themap <<- smap

# Define server logic required to:
#    - First tabpanel: display a dynamic table with price predictions, 
#    - Mark each HDB town on the Singapore map, which corresponds to the location of a given prediction,
#    - Display a graphical view of a recent HDB programme.

shinyServer(function(input, output, session) {
  
  # If the user select any input parameter, we focus on the first tab: "Price prediction"
  # This is because we need an updated table of prediction before displaying the info on the map
  observeEvent(input$towns, {
    updateTabsetPanel(session, "navPanel", selected = "Predicted price")
  })
  observeEvent(input$types, {
    updateTabsetPanel(session, "navPanel", selected = "Predicted price")
  })
  observeEvent(input$models, {
    updateTabsetPanel(session, "navPanel", selected = "Predicted price")
  })
  observeEvent(input$storeys, {
    updateTabsetPanel(session, "navPanel", selected = "Predicted price")
  })
  observeEvent(input$start_year_lease, {
    updateTabsetPanel(session, "navPanel", selected = "Predicted price")
  })
  
  # Predict the price using a reactive variable 
  prediction <- eventReactive(input$compute, {
    # Gather the input data
    ndata <- c(input$towns, input$types, input$models, input$storeys, input$start_year_lease)
    
    # Predict the price using the Linear model
    new_pred <- predict_price(fit_model, ndata)
    
    # We fix the numeric numbers that have 2 decimals by default
    # We round the prices in Singapore dollars to the S$1,000
    new_pred$lease_start_date <- as.character(new_pred$lease_start_date)
    new_pred$Price <- as.character(round(new_pred$Price / 1000, 0) * 1000)
    new_pred$Lower <- as.character(round(new_pred$Lower / 1000, 0) * 1000)
    new_pred$Upper <- as.character(round(new_pred$Upper / 1000, 0) * 1000)

        # We add the new prediction to the previous one WITHOUT resetting the dataframe: use f "<<-"
    price_table <<- rbind(price_table, new_pred)
  })

  # Display the updated table with all predictions
  output$oselection <- renderTable ({prediction()})

  # Add marker of the selected HDB town to the Singapore map
  computeMap <- eventReactive(input$compute, {
    
    # Retrieve previous records from the same town
    allrecords <- price_table[price_table$town == input$towns,]
    
    # Collapse the columns and store all records in one vector
    display <- paste(apply( allrecords[ , 2:5] , 1 , paste , collapse = " - " ), " - S$", 
                     allrecords[ , 6], sep = "")
    
    # Put each vector element in one HTML row for display as marker popup
    content <<- paste(sep = "<br/>",
                      input$towns, # Selected town
                      paste(display[1:length(display)], collapse = "<br/>")
    )
    
    # Add Marker on the selected HDB town with a popup that contains all predictions for that specific town
    ind <- which(hdb_coord$hdb_town == input$towns)
    themap <<- addMarkers(themap, lat = hdb_coord[ind, 2], lng = hdb_coord[ind, 3], 
                          popup = content)
    themap
  })
  
  # Display the Singapore map with the selected HDB towns: we use a Leaflet
  output$map <- renderLeaflet({computeMap()})
})

#  ---------------- End of the file server.R ---------------- 
