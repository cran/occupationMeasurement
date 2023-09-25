## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

data.table::setDTthreads(1)

## ----eval=FALSE---------------------------------------------------------------
#  # Start the API (and open its documentation)
#  occupationMeasurement::api()

## ----api_flow, eval=FALSE, include=FALSE--------------------------------------
#  # Since Graphviz is rendering the diagram via JS, it actually includes the
#  # whole JS library in the resulting document. It is therefore much more efficient to just
#  # render the document once and then copy-paste the resulting svg as a figure.
#  # This code is still included in-case the diagram needs to be updated.
#  DiagrammeR::grViz('
#  digraph G {
#    suggestions [
#      label = <Get a list of job suggestions to show from <b>/v1/suggestions</b>>;
#      shape = rect;
#    ];
#    check_followup_questions [
#      label = "Is suggestion.has_followup_questions == true?";
#      shape = diamond;
#    ];
#    next_followup_question [
#      label = <Get the next followup question to show from <b>/v1/next_followup_question</b>>;
#      shape = rect;
#    ];
#    check_finished_post_followup [
#      label = "Is answer.is_coding_finished == true?";
#      shape = diamond;
#    ];
#    final_codes [
#      label = <Get the final codes from <b>/v1/final_codes</b>>;
#      shape = rect;
#    ];
#    coding_finished [
#      label = "Coding is finished";
#      shape = oval;
#    ];
#  
#    suggestions -> check_followup_questions [ label = "Respondent chose\na suggestion"];
#    check_followup_questions -> next_followup_question [ label = "Yes"; style="dashed" ];
#    check_followup_questions -> final_codes [ label = "No"; style="dashed" ];
#    next_followup_question -> check_finished_post_followup [ label = "Respondend chose\nan answer"];
#    check_finished_post_followup:w -> next_followup_question:w [ label = "No"; style="dashed" ];
#    check_finished_post_followup -> final_codes [ label = "Yes"; style="dashed" ];
#    final_codes -> coding_finished;
#  }
#  ')

