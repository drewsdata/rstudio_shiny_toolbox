# This will display a datatable then call a parameterized 
# SQL script when a datatable row is clicked. The resulting
# recursive SQL query retrieves all
# subordinates of a manager if the DT row 
# clicked was a manager's record having at least
# one subordinate. If records are returned then a second
# data table below the first is displayed with those
# subordinate records.


hierarchy_data <- reactive({select(ad_data_itops_shiny(), 1:5)})

output$hierarchy <- DT::renderDataTable(hierarchy_data(),
                                               filter = 'top',
                                               selection = 'single',
                                               options = list(
                                                 extend = 'collection',
                                                 scrollX = TRUE,
                                                 pageLength = 5,
                                                 lengthMenu = list(c(5, 10, 50, -1), list('5', '10', '50', 'All')),
                                                 rownames = FALSE
                                               ))

selected_mgr <- eventReactive(input$hierarchy_rows_selected, {
  dt_row_empid <- hierarchy_data()$employeeid[input$hierarchy_rows_selected]
  conpgdb <- dbConnect(odbc::odbc(), "pg_db_dsn")
  mgr_query <- read_lines("c:/hier_emp.sql") %>%
    glue_collapse(sep = "\n") %>%
    glue_sql(.con = conpgdb)
  
  hier_data <-  dbGetQuery(conpgdb, mgr_query)
})

output$hier_data_table <- DT::renderDataTable({
  if(is.null(selected_mgr()))
    return()
  # return all results if they exist by default initially before any bar click
  if (!is.null(selected_mgr())) return(
    DT::datatable(selected_mgr(), filter = 'top', extensions = 'Buttons',
                  options = list(
                    dom = 'Blftip',
                    buttons = 
                      list('colvis', list(
                        extend = 'collection',
                        buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
                        text = 'Download'
                      )),
                    scrollX = TRUE,
                    pageLength = 5,
                    lengthMenu = list(c(5, 10, 50, -1), list('5', '10', '50', 'All')),
                    rownames = FALSE
                  )
    ))
})
