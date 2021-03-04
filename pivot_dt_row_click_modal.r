# This will create a modal dialog box from reactive data frame in a DT table
# and when a datable row is clicked the dialog box will display all columns
# as individual rows for that record in the dialog box

my_data_frame <- reactiveFileReader(
  intervalMillis = 3600000,
  session = session,
  filePath = "c:/my_data_frame.rds",
  readFunc = readRDS)

output$ad_data_table <- DT::renderDataTable(my_data_frame(),
                                            filter = 'top',
                                            selection = 'single',
                                            rownames = FALSE,
                                            options = list(columnDefs = list(list(
                                              targets = 6:18, visible = FALSE,
                                              pageLength = 25,
                                              lengthMenu = list(c(5, 25, 50, 100), list('5', '20', '50','100')))),
                                              buttons = c('colvis'), dom = 'Bfrtip'),
                                            extensions = 'Buttons')

observeEvent(input$ad_data_table_rows_selected,
             {
               showModal(modalDialog(
                 renderDataTable({
                   pivot_longer(my_data_frame()[input$ad_data_table_rows_selected,], cols = everything())
                 })
               ))
             }
)