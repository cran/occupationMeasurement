#' Create a new questionnaire page.
#'
#' Each page corresponds to a page within the app/questionnaire.
#'
#' Pages are rendered by calling the different life-cycle functions one
#' after another. The order in which they are called is as follows:
#'
#'   1. `condition` (`session`)
#'        Only if this evaluated to `TRUE`, continue.
#'   2. `run_before` (`session`)
#'   3. `render_before` (`session`, `run_before_output`, `input`, `output`)
#'   4. `render` (`session`, `run_before_output`, `input`, `output`)
#'   5. `render_after` (`session`, `run_before_output`, `input`, `output`)
#'       The outputs from `render_before`, `render` & `render_after` are
#'       stitched together to produce the final HTML output of the page.
#'   6. `run_after` (`session`, `input`, `output`)
#'       Run when the user leaves the page (=clicks the next button). Any
#'       user input has to be handled here. For each question asked, one will
#'       typically call [set_item_data()] to save the collected data
#'       internally.
#'
#' Each of the life-cycle functions above is annotated with the
#' paramaters it has access to. `session`, `input` and `output` are
#' passed directly from shiny and correspond to the objects made available by
#' [shiny::shinyServer()], `run_before_output` is available for convenience and
#' corresponds to whatever is returned by `run_before`.
#'
#' Some side-effects occur:
#' - `occupationMeasurement:::init_page_data` is called before 1. `run_before`.
#'   It sets up an internal representation of the page data to be saved.
#' - `occupationMeasurement:::finalize_data` is called before 6. `run_before`.
#' - `occupationMeasurement:::save_page_data` is called after 6. `run_before`.
#'   It saves the responses on a hard drive, i.e. it appends the responses
#'   from this page to `table_name == "answers"`. See the vignette
#'   and [create_app_settings()] for details.
#'
#' Use of `render_before`, `render_after` is discouraged if not necessary,
#' as these two life-cycle functions have only been added to allow for easier
#' modification and extension of existing pages.
#' @param page_id A unique string identifiying this page. (Required)
#'   This will be used to store data.
#' @param render Function to render the page. (Required)
#'   It is expected, that the function returns a list of shiny tags.
#'   Its output will be combined with `render_before` and `render_after.`
#'   This function has access to the shiny `session` and the `run_before_output.`
#' @param condition Function to check whether the page should be shown.
#'   When this function returns `TRUE`, the page will be shown upon navigating
#'   there, if it returns `FALSE` it will be skipped.
#'   Defaults to show the page.
#'   This function has access to the shiny `session`.
#' @param run_before Function that prepares data to render the page.
#'   Called immediately after condition (if `condition` returned `TRUE`).
#'   Whatever run_before returns is available in render, render_before and
#'   render_after as `run_before_output`.
#'   This function has access to the shiny `session`.
#' @param render_before Called exactly like `render`. Output will be added
#'   just *before* the output from render. Mainly used to add additional
#'   outputs to existing pages.
#' @param render_after Called exactly like `render`. Output will be added
#'   just *after* the output from render. Mainly used to add additional
#'   outputs to existing pages.
#' @param run_after Function that handles the user input when they leave the
#'   page. This function has access to the shiny session and shiny input.
#' @return A new `page` object.
#' @export
#' @examples
#' \dontshow{data.table::setDTthreads(1)}
#'
#' \dontrun{
#' very_simple_page <- new_page(
#'   page_id = "example",
#'   render = function(session, run_before_output, input, output, ...) {
#'     list(
#'       shiny::tags$h1("My test page"),
#'       button_previous(),
#'       button_next()
#'     )
#'   }
#' )
#'
#' # Example where we also save some data
#' page_that_saves_two_items <- new_page(
#'   page_id = "questions_1_and_2",
#'   render = function(session, run_before_output, page, input, output, ...) {
#'     list(
#'       shiny::tags$h1("Questions"),
#'       shiny::textAreaInput(
#'         inputId = "day_freetext",
#'         label = "How was your day? Please give a detailed answer.",
#'         value = get_item_data(
#'           session = session, page_id = page$page_id,
#'           item_id = "day_freetext",
#'           key = "response_text"
#'         )
#'       ),
#'       shiny::tags$p("How would you rate your day? On a scale of 1 - 4"),
#'       radioButtons(
#'         inputId = "day_radio",
#'         label = NULL,
#'         width = "100%",
#'         choices = list(One = 1, Two = 2, Three = 3, Four = 4),
#'         selected = get_item_data(
#'           session = session,
#'           page_id = page$page_id,
#'           item_id = "day_radio",
#'           key = "response_id",
#'           default = character(0)
#'         )
#'       ),
#'       button_previous(),
#'       button_next()
#'     )
#'   },
#'   run_after = function(session, page, input, ...) {
#'     set_item_data(
#'       session = session,
#'       page_id = page$page_id,
#'       item_id = "day_freetext",
#'       response_text = input$day_freetext
#'     )
#'     set_item_data(
#'       session = session,
#'       page_id = page$page_id,
#'       item_id = "day_radio",
#'       response_id = input$day_radio
#'     )
#'   }
#' )
#'
#' questionnaire_that_saves_two_items <- list(
#'   page_that_saves_two_items,
#'   # So we have a next page to go to
#'   very_simple_page
#' )
#'
#' if (interactive()) {
#'   app(questionnaire = questionnaire_that_saves_two_items)
#' }
#' }
new_page <- function(page_id, render, condition = NULL, run_before = NULL, render_before = NULL, render_after = NULL, run_after = NULL) {
  page <- list(
    # A unique string identifiying this page. Used to store data.
    page_id = page_id,
    # Function to check whether the page should be shown.
    condition = condition,
    # Function that prepares data to render the page.
    run_before = run_before,
    # Called exactly like `render`. Output will be added just *before* the output from render.
    render_before = render_before,
    # Function to render the page. (Required)
    render = render,
    # Called exactly like `render`. Output will be added just *after* the output from render.
    render_after = render_after,
    # Function that handles the user input when they leave the page.
    run_after = run_after
  )

  class(page) <- "page"

  page
}

#' Called internally by the shiny server.
#' @param session The shiny session
#' @param ... All additional arguments are passed along
#' @keywords internal
check_condition <- function(page, session, ...) {
  if (session$userData$app_settings$verbose) {
    message(paste("Check Condition:", page$page_id))
  }

  if (!is.null(page$condition)) {
    condition_result <- page$condition(session = session, page = page, ...) |>
      as.logical()
    return(
      # Treat empty vector (i.e. of length 0) as FALSE
      length(condition_result) > 0 &&
        # Use the result itself
        condition_result
    )
  } else {
    return(TRUE)
  }
}

#' Called internally by the shiny server.
#' @param session The shiny session
#' @param ... All additional arguments are passed along
#' @keywords internal
execute_run_before <- function(page, session, input, output, ...) {
  if (session$userData$app_settings$verbose) {
    message(paste("Show Page:", page$page_id))
  }

  # Initialize trial data e.g. set first timestamp, set ids etc.
  init_page_data(session = session, page_id = page$page_id)
  if (!is.null(page$run_before)) {
    return(page$run_before(session = session, page = page, input = input, output = output, ...))
  }
}

#' Called internally by the shiny server.
#' @param session The shiny session
#' @param run_before_output The output from `run_before`
#' @param ... All additional arguments are passed along
#' @keywords internal
execute_render <- function(page, session, run_before_output, ...) {
  return(
    list(
      # If specified, add the page_id
      if (session$userData$app_settings$display_page_ids) shiny::tags$div(class = "page-id", page$page_id),

      # Combine output from page rendering functions
      if (!is.null(page$render_before)) page$render_before(session = session, page = page, run_before_output = run_before_output, ...),
      page$render(session = session, page = page, run_before_output = run_before_output, ...),
      if (!is.null(page$render_after)) page$render_after(session = session, page = page, run_before_output = run_before_output, ...)
    )
  )
}

#' Called internally by the shiny server when navigating to the next page.
#' @param session The shiny session
#' @param input The shiny input
#' @param ... All additional arguments are passed along
#' @keywords internal
execute_run_after <- function(page, session, input, output, ...) {
  # Finalize the trial data e.g. set the final timestamp
  finalize_data(session = session, page_id = page$page_id, forward = TRUE)

  if (!is.null(page$run_after)) {
    page$run_after(session = session, page = page, input = input, output = output, ...)
  }

  ## Save the page's data
  save_page_data(session = session, page_id = page$page_id)

  # Show a detailed message of the page's data if enabled
  if (session$userData$app_settings$verbose) {
    message(paste(
      "Page data for", page$page_id, ":",
      get_page_data(session = session, page_id = page$page_id) |>
        utils::str() |>
        utils::capture.output() |>
        paste(collapse = "\n"),
      "\n"
    ))
  }
}

#' Called internally by the shiny server when navigating to the previous page.
#' @param session The shiny session
#' @param input The shiny input
#' @param ... All additional arguments are passed along
#' @keywords internal
leaving_page_backwards <- function(page, session, input, output, ...) {
  # Finalize the trial data, but don't mark data as new
  finalize_data(session = session, page_id = page$page_id, forward = FALSE)
}

#' Set some values in the page/questionnaire data in the current session.
#'
#' Data is automatically linked to a page's page_id.
#' Note that page data is *not* automatically saved and you probably want
#' to use set_item_data instead.
#' @param session The shiny session
#' @param values A named list of values to add / overwrite in the page data.
#'   Values are added / overwritten based on the names provided in the list.
#' @seealso [set_item_data()]
#' @keywords internal
#' @return nothing
set_page_data <- function(session, page_id, values) {
  # Add / Overwrite all provided values in the questionnaire data
  session$userData$questionnaire_data[[page_id]] <- utils::modifyList(
    session$userData$questionnaire_data[[page_id]],
    values
  )
}

#' Get questionnaire / page data.
#'
#' Note that page data is *not* automatically saved and you probably want
#' to use page$get_item_data instead.
#' @param session The shiny session
#' @param key The key for which to retrieve a value. (Optional)
#'   If no key is provided, the page's whole data will be returned.
#' @param default A default value to return if the key or page is not
#'   present in the questionnaire data.
#' @param page_id The page for which to retrieve data.
#'   Defaults to the page where data the function is being called from.
#' @return The page data value at the provided key or the whole page's data
#'   if no key is provided.
#' @seealso [get_item_data()]
#' @keywords internal
get_page_data <- function(session, page_id, key = NULL, default = NULL) {
  stopifnot(!is.null(session) && !is.null(page_id))

  data_entry <- session$userData$questionnaire_data[[page_id]]
  if (!is.null(data_entry)) {
    if (!is.null(key)) {
      if (!is.null(data_entry[[key]])) {
        return(data_entry[[key]])
      } else {
        return(default)
      }
    } else {
      return(data_entry)
    }
  } else {
    return(default)
  }
}

#' Set / save data for an item.
#'
#' There can be multiple items on any given page. Items can be different
#' questions, or multiple variables that need to be saved from a single
#' question. The `question_text` is typically
#' saved in `run_before` and the reply (`response_text` and/or `response_id`) is
#' typically saved in `run_after`.
#' @param session The shiny session
#' @param page_id The page for which to retrieve data.
#' @param item_id The item for which to set/update data.
#'   This *has* to be different for different items on the same page.
#'   Since most pages contain only a single question/item, `item_id` is set to "default" if missing.
#' @param question_text The question's text. (optional)
#' @param response_text The user's response in text form. (optional)
#' @param response_id The user's response as an id from a set of choices.
#'   (optional)
#' @return nothing
#' @export
#' @seealso [get_item_data()]
#' @examples
#' \dontshow{data.table::setDTthreads(1)}
#'
#' \dontrun{
#' # Set up a "fake" shiny session to store data
#' session <- shiny::MockShinySession$new()
#' session$userData <- list(
#'   current_page_id = "other_page",
#'   questionnaire_data = list(
#'     example_page = list()
#'   )
#' )
#'
#' # This code is expected to be run in e.g. run_before or run_after
#' # It doesn't really make sense to run this code outside
#' set_item_data(
#'   session = session,
#'   page_id = "example_page",
#'   question_text = "How are you?"
#' )
#'
#' set_item_data(
#'   session = session,
#'   page_id = "example_page",
#'   response_id = 3,
#'   response_text = "I'm doing great! (response_id = 3)"
#' )
#' }
set_item_data <- function(session, page_id, item_id = NULL, question_text = NULL, response_text = NULL, response_id = NULL) {
  if (is.null(item_id)) {
    item_id <- "default"
  }
  # TODO: Maybe find a more elegant solution

  # As we can't update the question entry by reference, we first have to get all questions,
  # then the correct question. Change that and overwrite the question and questions again.
  questions <- get_page_data(
    session = session,
    page_id = page_id,
    key = "questions",
    default = list()
  )
  question <- if (!is.null(questions[[item_id]])) questions[[item_id]] else list()

  # Update supported fields on the question if they are not NULL
  supported_fields <- c("question_text", "response_text", "response_id")
  for (field in supported_fields) {
    value <- get(field)
    # Convert lists to character (e.g. lists may be passed from shiny HTML)
    if (is.list(value)) {
      value <- as.character(value)
    }
    if (!is.null(value)) {
      question[[field]] <- value
    }
  }

  questions[[item_id]] <- question

  # Set the questions data on the page again
  set_page_data(
    session = session,
    page_id = page_id,
    values = list(questions = questions)
  )
}

#' Retrieve data for an item.
#'
#' Each page in the questionnaire can have multiple items on it.
#' @param session The shiny session
#' @param page_id The page for which to retrieve data.
#' @param item_id The item for which to retrieve data.
#'   This *has* to be different for different items on the same page.
#'   Since most pages contain only a single question/item, `item_id` is set to "default" if missing.
#' @param key The key for which to retrieve a value. (Optional)
#'   If no key is provided, the items's whole data will be returned.
#' @param default A default value to return if the key or page is not
#'   present in the questionnaire data.
#' @return The items's data.
#' @export
#' @seealso [set_item_data()]
#' @examples
#' \dontshow{data.table::setDTthreads(1)}
#'
#' \dontrun{
#' # Set up a "fake" shiny session to store data
#' session <- shiny::MockShinySession$new()
#' session$userData <- list(
#'   current_page_id = "other_page",
#'   questionnaire_data = list(
#'     example_page = list()
#'   )
#' )
#'
#' # This code is expected to be run in e.g. run_before or run_after
#' # It doesn't really make sense to run this code outside
#' set_item_data(
#'   session = session,
#'   page_id = "example_page",
#'   question_text = "How are you?"
#' )
#'
#' # This code is expected to be run in e.g. run_before
#' get_item_data(
#'   session = session,
#'   page_id = "example_page"
#' )
#' }
get_item_data <- function(session, page_id, item_id = NULL, key = c("all", "question_text", "response_text", "response_id"), default = NULL) {
  if (is.null(item_id)) {
    item_id <- "default"
  }
  key <- match.arg(key)

  # When retrieving data for a different page, we have to check whether the data
  # is still fresh i.e. not marked as "old" from going back, else we return the
  # default value.
  if (page_id != session$userData$current_page_id) {
    status <- get_page_data(
      session = session,
      page_id = page_id,
      key = "status",
      default = "new"
    )
    if (status == "old") {
      return(default)
    }
  }

  questions <- get_page_data(
    session = session,
    page_id = page_id,
    key = "questions",
    default = list()
  )
  question <- questions[[item_id]]
  if (!is.null(question)) {
    if (!is.null(key) && key != "all") {
      if (!is.null(question[[key]])) {
        return(question[[key]])
      } else {
        return(default)
      }
    } else {
      return(question)
    }
  } else {
    return(default)
  }
}

# Data Handling Functions
init_page_data <- function(session, page_id) {
  # Overwrite certain values when navigation back to a page
  values_to_overwrite <- list(
    start = as.character(Sys.time()),
    questions = list()
  )

  if (is.null(session$userData$questionnaire_data[[page_id]])) {
    # Initialize page info
    session$userData$questionnaire_data[[page_id]] <- list(
      page_id = page_id,
      respondent_id = session$userData$user_info$respondent_id,
      session_id = session$userData$user_info$session_id,
      status = "new"
    )
  } else {
    # Page data exists already (so we're navigating backwards)
    values_to_overwrite[["status"]] <- "old"
  }

  session$userData$questionnaire_data[[page_id]] <- utils::modifyList(
    session$userData$questionnaire_data[[page_id]],
    values_to_overwrite
  )
}

# Finalize a page's data e.g. setting the timestamp, marking it as "new"
# forward corresponds to whether the participant navigated to the next (TRUE)
# or a previous page (FALSE)
finalize_data <- function(session, page_id, forward) {
  session$userData$questionnaire_data[[page_id]]$end <- as.character(Sys.time())

  if (forward) {
    session$userData$questionnaire_data[[page_id]]$status <- "new"
  }
}

save_page_data <- function(session, page_id) {
  save_data(
    "answers",
    extract_questions_df(
      page_data = get_page_data(session = session, page_id = page_id)
    ),
    session = session
  )
}
