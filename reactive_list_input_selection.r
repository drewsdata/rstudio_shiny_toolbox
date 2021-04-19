# Reading a list of saved objects and selecting them for display
# In this case, a list of pre-built plotly plots and a list of reactable tables
# Shiny renders the objects quickly as they merely need to be rendered, not built
# Critical concepts:
# - storing the lists to be read as named list
# - using selectInput to choose the reactive list object
# - using reactiveFileReader to read the periodically updated objects
# - Base the output, reactive object on a list input selection

# ui
fluidRow(
  column(br(), br(), br(),
         selectInput("plot", "Select Plot:", choices=gdata_choices),
         fluidRow(plotlyOutput(outputId = "gp_trend"))
         ,offset = 1,
         width=10),
  column(br(), br(), br(),
         selectInput("table", "Select Table:", choices=gtable_choices),
         fluidRow(reactableOutput(outputId = "gp_table"))
         ,offset = 1,
         width = 10)
)

# server 
google_trend <- reactiveFileReader(
  intervalMillis = 3600000,
  session = session,
  filePath = "c:/scripts/license_plots.rds",
  readFunc = readRDS)

output$gp_trend <- renderPlotly({
  i <- as.integer(input$plot)
  google_trend()[[i]]
})

google_tables <- reactiveFileReader(
  intervalMillis = 3600000,
  session = session,
  filePath = "c:/scripts/gsuite_license_tables.rds",
  readFunc = readRDS)

output$gp_table <- renderReactable({
  i <- as.integer(input$table)
  google_tables()[[i]]
})