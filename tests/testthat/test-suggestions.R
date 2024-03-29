test_that("suggestions are generated correctly for 'Koch' in default format (auxco)", {
  expect_snapshot_value(style = "json2", tolerance = .001, as.data.frame(get_job_suggestions("Koch")))
})

test_that("suggestions are generated correctly for 'Koch' in kldb format", {
  skip_if_kldb_unavailable()

  expect_snapshot_value(style = "json2", tolerance = .001, as.data.frame(get_job_suggestions("Koch", suggestion_type = "kldb-2010")))
})

test_that("similarity based reasoning works as expected", {
  expect_snapshot_value(style = "json2", tolerance = .001, as.data.frame(algo_similarity_based_reasoning("KOCH", suggestion_type = "auxco-1.2.x")))
})

test_that("Special cases in the default training data don't lead to errors", {
  # In the default german training data there are negative KldB codes for the special categories
  # "Zeitarbeit", "studentische Hilfskraft", "FSJ" and "Arbeiter".
  # With this test case we just want to check that these don't lead to weird behaviour / errors.
  # Predictions are expected to be bad for these cases.
  expect_snapshot_value(style = "json2", tolerance = .001, as.data.frame(get_job_suggestions("Arbeiter")))

  expect_snapshot_value(style = "json2", tolerance = .001, as.data.frame(get_job_suggestions("studentische Hilfskraft")))
})

test_that("followup questions are correctly returned", {
  prep_followup_questions <- function(followup_questions) {
    # Convert the questions' answers to data.frame (from data.table)
    # to make testthat serialization work
    followup_questions <- lapply(followup_questions, function(question) {
      question$answers <- question$answers |>
        as.data.frame()
      return(question)
    })

    return(followup_questions)
  }

  get_followup_questions("1710") |>
    prep_followup_questions() |>
    expect_snapshot_value(style = "json2")

  get_followup_questions("1733") |>
    prep_followup_questions() |>
    expect_snapshot_value(style = "json2")
})

test_that("suggestions and final codes are correctly generated for 'Soldat' (leading 0 in ISCO)", {
  # Check suggestions
  expect_snapshot_value(style = "json2", tolerance = .001, as.data.frame(get_job_suggestions("Soldat")))

  # Check final codes for default case
  expect_snapshot_value(style = "json2", tolerance = .001, get_final_codes("9999", followup_answers = list()))
  # and when supplying a followup answer
  expect_snapshot_value(style = "json2", tolerance = .001, get_final_codes("9999", followup_answers = list(Q9999_1 = 3)))
})

test_that("suggestions and final codes are correctly generated for 'Student Research Assistant' (not in KldB)", {
  # Check suggestions
  expect_snapshot_value(style = "json2", tolerance = .001, as.data.frame(get_job_suggestions("Hiwi")))

  # Check final codes for default case
  expect_snapshot_value(style = "json2", tolerance = .001, get_final_codes("9910"))
})

test_that("final codes are correctly generated answers which depend on multiple followup questions", {
  # Electronics engineers
  expect_equal(
    get_final_codes(
      "1733",
      followup_answers = list(
        Q1733_1 = 1,
        Q1733_2 = 2
      )
    ),
    list(
      isco_08 = "3113",
      kldb_10 = "26303",
      message = ""
    )
  )

  # Electronics engineering technicians
  expect_equal(
    get_final_codes(
      "1733",
      followup_answers = list(
        Q1733_1 = 2,
        Q1733_2 = 2
      )
    ),
    list(
      isco_08 = "3114",
      kldb_10 = "26303",
      message = ""
    )
  )

  # Electronics engineering technicians with wrong input (Q1733_3 does not exist).
  expect_equal(
    get_final_codes(
      "1733",
      followup_answers = list(
        Q1733_1 = 2,
        Q1733_3 = 2
      )
    ),
    list(
      isco_08 = "3113",
      kldb_10 = "26303",
      message = "Required question_ids (Q1733_1,Q1733_2) and provided question_ids (Q1733_1,Q1733_3) do not match. |&| Entry missing for Q1733_2 in followup_answers. |&| answer_kldb_id and answer_isco_id of selected answer from occupationMeasurement::auxco$followup_questions are empty. |&| Returning default code: Improve followup_answers (or standardized_answer_levels) to obtain more exact codings."
    )
  )
})

test_that("final codes are irrespective of the question order", {
  expect_equal(
    get_final_codes(
      "1710",
      followup_answers = list(
        Q1710_2 = 3,
        Q1710_1 = 2
      )
    ),
    list(
      isco_08 = "6123",
      kldb_10 = "11293",
      message = ""
    )
  )

  # Electronics engineering technicians (dependend on both follow up question answers)
  expect_equal(
    get_final_codes(
      "1733",
      followup_answers = list(
        Q1733_2 = 2,
        Q1733_1 = 1
      )
    ),
    list(
      isco_08 = "3113",
      kldb_10 = "26303",
      message = ""
    )
  )
})

test_that("final codes are properly generated when they depend only on the first question", {
  expect_equal(
    get_final_codes(
      "1710",
      followup_answers = list(
        Q1710_1 = 1
      )
    ),
    list(
      isco_08 = "1311",
      kldb_10 = "11294",
      message = ""
    )
  )
})

test_that("Default codes are returned when first answer is missing", {
  expect_equal(
    get_final_codes(
      "1710",
      followup_answers = list(
        Q1710_2 = 3
      )
    ),
    list(
      isco_08 = "6129",
      kldb_10 = "11293",
      message = "Entry missing for Q1710_1 in followup_answers. |&| Returning default code: Improve followup_answers (or standardized_answer_levels) to obtain more exact codings."
    )
  )
})

test_that("final_codes are properly generated when using standardized_answer_levels", {
  # Replace the answer to one followup question with a standardized answer level
  expect_equal(
    get_final_codes(
      "1733",
      followup_answers = list(
        Q1733_1 = 1
      ),
      standardized_answer_levels = list(
        isco_skill_level = "isco_skill_level_3"
      )
    ),
    list(
      isco_08 = "3113",
      kldb_10 = "26303",
      message = "Exact match: isco_skill_level_3 -> Q1733_2=2"
    )
  )

  # Use only a standardized answer level (dropping followup_answers)
  expect_equal(
    get_final_codes(
      "3553",
      standardized_answer_levels = list(
        isco_skill_level = "isco_skill_level_2"
      )
    ),
    list(
      isco_08 = "4415",
      kldb_10 = "73312",
      message = "Exact match: isco_skill_level_2 -> Q3553_1=1"
    )
  )

  # Ignore irrelevant standardized answer levels
  expect_equal(
    get_final_codes(
      "1005",
      standardized_answer_levels = list(
        isco_skill_level = "isco_skill_level_2",
        isco_supervisor_manager = "isco_manager"
      )
    ),
    list(
      isco_08 = "1324",
      kldb_10 = "51394",
      message = "Exact match: isco_manager -> Q1005_1=1"
    )
  )

  # duplicates in corresponding_answer level
  expect_equal(
    get_final_codes(
      "1709",
      standardized_answer_levels = list(
        isco_skill_level = "isco_skill_level_2"
      )
    ),
    list(
      isco_08 = "3119",
      kldb_10 = "27182",
      message = "Exact match: isco_skill_level_2 -> Q1709_1=1"
    )
  )

  # approximate matching: skill level
  expect_equal(
    get_final_codes(
      "1706",
      standardized_answer_levels = list(
        isco_skill_level = "isco_skill_level_1"
      )
    ),
    list(
      isco_08 = "3115",
      kldb_10 = "25183",
      message = "Approximate match: isco_skill_level_1 -> isco_skill_level_3 -> Q1706_1=2"
    )
  )

  # approximate matching: isco_manager
  expect_equal(
    get_final_codes(
      "1783",
      standardized_answer_levels = list(
        isco_supervisor_manager = "isco_manager"
      )
    ),
    list(
      isco_08 = "3123",
      kldb_10 = "34293",
      message = "Approximate match: isco_manager -> isco_supervisor -> Q1783_1=1"
    )
  )

  # no approximate matching: isco_manager
  expect_equal(
    get_final_codes(
      "1783",
      standardized_answer_levels = list(
        isco_supervisor_manager = "isco_manager"
      ),
      approximate_standardized_answer_levels = FALSE
    ),
    list(
      isco_08 = "3115",
      kldb_10 = "34233",
      message = "Failed to find an exact match for standardized_answer_levels=isco_manager. |&| Returning default code: Improve followup_answers (or standardized_answer_levels) to obtain more exact codings."
    )
  )
})

test_that("final_codes are properly generated for special cases depending on auxco >= v1.2.1", {
  # Electronics engineering technicians (v1.2.1)
  expect_equal(
    get_final_codes(
      "4038",
      followup_answers = list("Q4038_1" = 2, "Q4038_2" = 1)
    ),
    list(
      isco_08 = "3512",
      kldb_10 = "43102",
      message = ""
    )
  )
})

test_that("final_codes throws an error when used improperly", {
  # Electronics engineering technicians
  expect_error(
    get_final_codes(
      "1733",
      followup_answers = list(
        1,
        2
      )
    )
  )
})
