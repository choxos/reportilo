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

test_that("complete mode flags under-accounted diagrams that bounds mode allows", {
  # identified 210 - 50 removed = 160 should flow to screened, but only 150 do:
  # 10 records unaccounted. Within bounds (150 <= 160), so default mode is silent.
  fc <- set_counts(new_flowchart("prisma_2020"),
    identified_db = 210, duplicates = 50, auto_removed = 0, other_removed = 0,
    screened = 150, excluded = 100, sought = 50, not_retrieved = 10,
    assessed = 40, studies_included = 30
  )
  expect_length(flowchart_consistency(fc), 0)
  comp <- flowchart_consistency(fc, complete = TRUE)
  expect_gte(length(comp), 1)
  expect_true(any(grepl("unaccounted", comp)))
  expect_true(any(grepl("screened", comp, ignore.case = TRUE)))
})

test_that("complete mode passes a fully balanced diagram", {
  fc <- set_counts(new_flowchart("prisma_2020"),
    identified_db = 200, duplicates = 50, auto_removed = 0, other_removed = 0,
    screened = 150, excluded = 100, sought = 50, not_retrieved = 10,
    assessed = 40, studies_included = 30
  )
  expect_length(flowchart_consistency(fc, complete = TRUE), 0)
})

test_that("complete mode catches under-accounting across templates", {
  # each: bounds pass (lhs <= base - minus) but lhs < base - minus -> flagged
  consort <- set_counts(new_flowchart("consort_2010"),
    assessed = 110, excluded_total = 10, randomized = 90, alloc_int = 45, alloc_ctrl = 45
  )
  expect_length(flowchart_consistency(consort), 0)
  expect_true(any(grepl("unaccounted", flowchart_consistency(consort, complete = TRUE))))

  stard <- set_counts(new_flowchart("stard_2015"),
    eligible = 100, no_index = 10, index_test = 80, no_reference = 0, reference = 80
  )
  expect_length(flowchart_consistency(stard), 0)
  expect_true(any(grepl("unaccounted", flowchart_consistency(stard, complete = TRUE))))

  cohort <- set_counts(new_flowchart("cohort_study"),
    assessed = 110, excluded_total = 10, exposed = 40, unexposed = 50
  )
  expect_length(flowchart_consistency(cohort), 0)
  expect_true(any(grepl("unaccounted", flowchart_consistency(cohort, complete = TRUE))))

  cc <- set_counts(new_flowchart("case_control"),
    cases_identified = 100, cases_eligible = 100, cases_excluded = 10, cases_enrolled = 80
  )
  expect_length(flowchart_consistency(cc), 0)
  expect_true(any(grepl("unaccounted", flowchart_consistency(cc, complete = TRUE))))

  cs <- set_counts(new_flowchart("cross_sectional"),
    target = 100, not_eligible = 10, invited = 80, nonresponse = 0, participated = 80
  )
  expect_length(flowchart_consistency(cs), 0)
  expect_true(any(grepl("unaccounted", flowchart_consistency(cs, complete = TRUE))))
})

test_that("complete mode does not flag stages without specified removals", {
  # studies_included (30) < assessed (40) is legitimate (full-text exclusions are
  # a reason field, not a count), so complete mode must not flag that stage even
  # though every upstream stage balances exactly.
  fc <- set_counts(new_flowchart("prisma_2020"),
    identified_db = 50, duplicates = 0, auto_removed = 0, other_removed = 0,
    screened = 50, excluded = 0, sought = 50, not_retrieved = 10,
    assessed = 40, studies_included = 30
  )
  expect_length(flowchart_consistency(fc, complete = TRUE), 0)
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
