test_that("reportilo_guidelines returns the full catalog and a checklist subset", {
  all <- reportilo_guidelines()
  expect_s3_class(all, "data.frame")
  expect_gt(nrow(all), 600)
  expect_true(all(c("guideline_id", "acronym", "title", "has_checklist") %in% names(all)))

  withck <- reportilo_guidelines(checklist_only = TRUE)
  expect_true(all(withck$has_checklist))
  expect_lt(nrow(withck), nrow(all))
})

test_that("search_guidelines finds known guidelines case-insensitively", {
  res <- search_guidelines("PRISMA")
  expect_true(any(grepl("prisma", res$guideline_id)))
  expect_identical(search_guidelines("prisma")$guideline_id, res$guideline_id)
  expect_error(search_guidelines(c("a", "b")))
})

test_that("categories are assigned and filterable", {
  cats <- reportilo_categories()
  expect_true(all(c("category", "category_order", "n") %in% names(cats)))
  expect_true("Randomized trials" %in% cats$category)
  expect_identical(cats$category[1], "Randomized trials") # EQUATOR display order
  expect_identical(cats$category[nrow(cats)], "Other") # catch-all last

  rt <- reportilo_guidelines(category = "Randomized trials")
  expect_true(all(as.character(rt$category) == "Randomized trials"))
  expect_true("consort" %in% rt$guideline_id)
  expect_true(sum(rt$is_primary) >= 1)

  # CONSORT is the flagship of randomised trials; STROBE of observational
  g <- reportilo_guidelines()
  expect_true(g$is_primary[g$guideline_id == "consort"])
  expect_identical(as.character(g$category[g$guideline_id == "strobe"]), "Observational studies")
})

test_that("reportilo_coverage reports verified vs extracted by category", {
  cov <- reportilo_coverage()
  expect_true(all(c("category", "records", "with_checklist", "verified", "needs_review") %in% names(cov)))
  expect_identical(cov$category[nrow(cov)], "Total")
  total <- cov[cov$category == "Total", ]
  expect_identical(total$records, nrow(reportilo_guidelines()))
  expect_true(total$verified >= 3)
  expect_true(total$with_checklist >= total$verified)
})

test_that("guideline_info resolves ids and acronyms and reports checklist status", {
  info <- guideline_info("prisma-2020")
  expect_s3_class(info, "reportilo_guideline_info")
  expect_true(info$has_checklist)
  expect_identical(info$flowchart_template, "prisma_2020")
  expect_output(print(info), "PRISMA")

  # acronym convenience
  expect_identical(guideline_info("STROBE")$guideline_id, "strobe")
  expect_error(guideline_info("not-a-real-guideline"))
})
