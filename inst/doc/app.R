## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  eval = FALSE,
  comment = "#>"
)

data.table::setDTthreads(1)

## ----eval=FALSE---------------------------------------------------------------
#  library(occupationMeasurement)
#  
#  # Start the interactive application with default settings
#  app()

## ----app_flow, eval=FALSE, include=FALSE--------------------------------------
#  # Since Graphviz is rendering the diagram via JS, it actually includes the
#  # whole JS library in the resulting document. It is therefore much more efficient to just
#  # render the document once and then copy-paste the resulting svg as a figure.
#  # This code is still included in-case the diagram needs to be updated.
#  DiagrammeR::grViz('
#  digraph G {
#    free_text_1 [
#      label = "Get free text response describing occupation";
#      shape = rect;
#    ];
#    free_text_1 -> generate_suggestions;
#    generate_suggestions [
#      label = "Generate a list of suggestions\nbased on the free text response";
#      shape = rect;
#    ];
#  
#    free_text_2 [
#      label = "Ask again for a more detailed free text response";
#      shape = rect;
#    ];
#    generate_suggestions -> check_generate_suggestions;
#    check_generate_suggestions [
#      label = "Was it possible\nto generate suggestions?";
#      shape = diamond;
#    ];
#    check_suggestions [
#      label = "Are we trying to generate\nsuggestions for the first time?";
#      shape = diamond;
#    ];
#    check_suggestions -> free_text_2 [ label = "1st time"; style="dashed" ];
#    free_text_2 -> generate_suggestions;
#  
#    check_generate_suggestions -> pick_suggestion [ label = "Yes"; style="dashed" ];
#    check_generate_suggestions -> check_suggestions [ label = "No"; style="dashed" ];
#    pick_suggestion [
#      label = "The participant picks a suggestion from the list\n(or indicates that none of them match).";
#      shape = rect;
#    ];
#    pick_suggestion -> check_pick_suggestions;
#    check_pick_suggestions [
#      label = "Did the participant pick\none of the suggestions?";
#      shape = diamond;
#    ];
#  
#    check_pick_suggestions -> free_text_manual [ label = "No (none match)"; style="dashed" ];
#    check_suggestions -> free_text_manual [ label = "2nd time"; style="dashed" ];
#    free_text_manual [
#      label = "Ask for final free text response\nfor later manual coding of occupation";
#      shape = oval;
#    ];
#  
#    check_pick_suggestions -> check_followup_questions [ label = "Yes"; style="dashed" ];
#    check_followup_questions [
#      label = "Does this suggestion have followup questions?\n(Only applies when using the Auxiliary Classification)";
#      shape = diamond;
#    ];
#    check_followup_questions -> coding_finished [ label = "No"; style="dashed" ];
#    check_followup_questions -> next_followup_question [ label = "Yes"; style="dashed" ];
#  
#    next_followup_question [
#      label = "Ask up to 2 followup questions to the participant\nto clarify the classification";
#      shape = rect;
#    ];
#    next_followup_question -> coding_finished;
#    coding_finished [
#      label = "✅ Coding is finished";
#      shape = oval;
#    ];
#  }
#  ')

## ----eval=FALSE---------------------------------------------------------------
#  library(occupationMeasurement)
#  
#  app(
#    # Use the questionnaire for interviewer-administered interviews
#    questionnaire = questionnaire_interviewer_administered(),
#    app_settings = create_app_settings(
#      # ... specify your custom settings here:
#  
#      # Collect an interview_id, so that you can merge data from your questionnaire
#      # and from the app after data collection
#      require_respondent_id = TRUE,
#  
#      # Skip follow-up questions related to ISCO skill level
#      # or ISCO supervisory/managment occupations
#      # (in case similar questions are already included in your questionnaire)
#      skip_followup_types = c("anforderungsniveau", "aufsicht")
#  
#      # ...
#    )
#  )

