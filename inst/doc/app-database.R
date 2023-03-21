## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  library(occupationMeasurement)
#  
#  # Connect to the database
#  db_connection <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
#  
#  # Launch the interactive app
#  app(
#    start = TRUE,
#    app_settings = create_app_settings(
#      handle_data = function(table_name, data, ...) {
#        # Write data into the database and automatically create the table if
#        # it doesn't exist already
#        DBI::dbWriteTable(
#          conn = db_connection,
#          name = table_name,
#          value = data,
#  
#          # Important, to actually add data and not remove any existing data.
#          append = TRUE
#        )
#      },
#  
#      # Let's not save data in files, when we're already using a database
#      save_to_file = FALSE
#    )
#  )

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  library(occupationMeasurement)
#  
#  # Connect to the database
#  db_connection <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
#  
#  # Launch the interactive app
#  app(
#    start = TRUE,
#    app_settings = create_app_settings(
#      handle_data = function(table_name, data, ...) {
#        # By checking for table_name we can identify which type of data is being handled
#        if (table_name == "results_overview") {
#          # Write data into the "results" table (creating it if necessary)
#          DBI::dbWriteTable(
#            conn = db_connection,
#            name = "results",
#            value = data,
#  
#            # Important, to actually add data and not remove any existing data.
#            append = TRUE
#          )
#        }
#  
#        if (table_name == "answers") {
#          # Don't save answers data, just output it into the R console
#          print("'answers' data (not saved):")
#          print(data)
#        }
#  
#        # Ignoring any other type of data e.g. occupations_suggested
#      },
#  
#      # Let's not save data in files, when we're already using a database
#      save_to_file = FALSE
#    )
#  )

