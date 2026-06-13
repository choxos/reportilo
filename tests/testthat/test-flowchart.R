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

test_that("render_flowchart returns a widget when DiagrammeR is available", {
  skip_if_not_installed("DiagrammeR")
  w <- render_flowchart(new_flowchart("stard_2015"))
  expect_s3_class(w, "htmlwidget")
})
