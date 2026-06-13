test_that("new_flowchart builds known templates and rejects unknown ones", {
  fc <- new_flowchart("prisma_2020")
  expect_s3_class(fc, "reportilo_flowchart")
  expect_identical(fc$guideline_id, "prisma-2020")
  expect_true(length(fc$counts) > 0)
  expect_error(new_flowchart("nope"), "Unknown template")
})

test_that("flowchart_fields lists the fillable fields", {
  f <- flowchart_fields("consort_2010")
  expect_true(all(c("count_field", "label", "is_reasons", "value") %in% names(f)))
  expect_true("randomized" %in% f$count_field)
})

test_that("set_counts sets known fields and rejects unknown ones", {
  fc <- new_flowchart("prisma_2020")
  fc <- set_counts(fc, screened = 980, excluded = 700)
  expect_identical(fc$counts$screened, "980")
  expect_error(set_counts(fc, not_a_field = 1), "Unknown field")
  expect_error(set_counts(fc, 5), "must be named")
})

test_that("flowchart_dot substitutes counts and is valid-ish DOT", {
  fc <- set_counts(new_flowchart("prisma_2020"), screened = 980)
  dot <- flowchart_dot(fc)
  expect_type(dot, "character")
  expect_match(dot, "digraph reportilo")
  expect_match(dot, "Records screened", fixed = TRUE)
  expect_match(dot, "n = 980", fixed = TRUE)
  # stage_title nodes are not rendered as boxes
  expect_false(grepl("title_scr", dot, fixed = TRUE))
})

test_that("observational study templates are available and build", {
  tpl <- flowchart_templates
  for (t in c("cohort_study", "case_control", "cross_sectional")) {
    expect_true(t %in% tpl$template_id)
    fc <- new_flowchart(t)
    expect_s3_class(fc, "reportilo_flowchart")
    expect_gt(length(fc$counts), 0)
    expect_match(flowchart_dot(fc), "digraph reportilo")
  }
})

test_that("set_counts rejects invalid count values", {
  fc <- new_flowchart("prisma_2020")
  expect_error(set_counts(fc, screened = -1), "non-negative")
  expect_error(set_counts(fc, screened = "abc"), "non-negative")
  expect_error(set_counts(fc, screened = 2.5), "whole number")
  expect_error(set_counts(fc, screened = NA), "non-negative")
  # reason fields accept free text
  fc2 <- set_counts(fc, reports_excluded = "Reason A (n = 3)")
  expect_match(fc2$counts$reports_excluded, "Reason A")
})

test_that("flowchart_consistency flags impossible counts", {
  bad <- set_counts(new_flowchart("prisma_2020"), identified_db = 100, screened = 200)
  expect_gte(length(flowchart_consistency(bad)), 1)
  # exact PRISMA accounting: screened = identified - removals
  ok <- set_counts(new_flowchart("prisma_2020"),
    identified_db = 200, duplicates = 50, screened = 150, excluded = 100,
    sought = 50, not_retrieved = 10, assessed = 40, studies_included = 30
  )
  expect_length(flowchart_consistency(ok), 0)
})

test_that("case_control has consistency rules", {
  bad <- set_counts(new_flowchart("case_control"),
    cases_identified = 10, cases_eligible = 20
  )
  expect_gte(length(flowchart_consistency(bad)), 1)
})

test_that("consort and prisma encode removal/exclusion invariants", {
  # CONSORT: randomized should equal assessed - excluded_total
  cc <- set_counts(new_flowchart("consort_2010"),
    assessed = 100, excluded_total = 90, randomized = 100
  )
  expect_true(any(grepl("Randomised|Randomized", flowchart_consistency(cc))))
  # PRISMA: screened should equal identified minus removals
  pr <- set_counts(new_flowchart("prisma_2020"),
    identified_db = 100, duplicates = 0, screened = 500
  )
  expect_true(any(grepl("screened", flowchart_consistency(pr), ignore.case = TRUE)))
})

test_that("strict export blocks impossible flow diagrams", {
  skip_if_not_installed("DiagrammeRsvg")
  bad <- set_counts(new_flowchart("prisma_2020"), identified_db = 1, screened = 999)
  f <- tempfile(fileext = ".svg")
  expect_error(reportilo_export(bad, f, strict = TRUE), "inconsistent")
  expect_warning(reportilo_export(bad, f, strict = FALSE), "inconsistent")
})

test_that("background option sets the Graphviz bgcolor", {
  fc <- new_flowchart("cohort_study")
  expect_match(flowchart_dot(fc), 'bgcolor="white"', fixed = TRUE)
  expect_match(
    flowchart_dot(fc, background = "transparent"),
    'bgcolor="transparent"',
    fixed = TRUE
  )
})

test_that("render_flowchart returns a widget when DiagrammeR is available", {
  skip_if_not_installed("DiagrammeR")
  w <- render_flowchart(new_flowchart("stard_2015"))
  expect_s3_class(w, "htmlwidget")
})
