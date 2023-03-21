## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=FALSE---------------------------------------------------------------
#  library(occupationMeasurement)
#  library(shiny)
#  
#  my_simple_questionnaire <- list(
#    new_page(
#      page_id = "test",
#      render = function(...) {
#        return(
#          p("Hello!"),
#          button_previous(),
#          button_next()
#        )
#      }
#    ),
#  
#    # Create a custom page to choose your favorite meal
#    page_choose_one_option(
#      page_id = "favourite_meal",
#      question_text = "Please pick your favorite kind of meal.",
#      list_of_choices = list(
#        "Breakfast" = 1,
#        "Lunch" = 2,
#        "Dinner" = 3
#      )
#    )
#  )
#  
#  # Test the questionnaire in the app
#  # app(questionnaire = my_simple_questionnaire)

## ----eval=FALSE---------------------------------------------------------------
#  list(
#    # ... some of your pages before ...
#    page_first_freetext(),
#    page_second_freetext(),
#    page_select_suggestion(),
#    page_none_selected_freetext(),
#    page_followup(1),
#    page_followup(2)
#    # ... some of your pages after ...
#  )

## -----------------------------------------------------------------------------
library(occupationMeasurement)
library(shiny)

questionnaire <- questionnaire_web_survey()

# Remove the first page (welcome)
questionnaire[[1]] <- NULL

# Use c() to add a new alternative page at the start
questionnaire <- c(
  list(
    new_page(
      "my_welcome",
      render = function() {
        return(h1("Hello!"))
      }
    )
  ),
  questionnaire
)

# Test the questionnaire in the app
# app(questionnaire = questionnaire)

## -----------------------------------------------------------------------------
library(occupationMeasurement)
library(shiny)

questionnaire <- questionnaire_web_survey()

# Add some text to page_select_suggestion
print(questionnaire[[4]]$page_id)

original_select_suggestion_render <- questionnaire[[4]]$render
questionnaire[[4]]$render <- function(...) {
  return(c(
    list(
      p("~ My custom text before ~")
    ),
    original_select_suggestion_render(...)
  ))
}

# Test the questionnaire in the app
# app(questionnaire = questionnaire)

