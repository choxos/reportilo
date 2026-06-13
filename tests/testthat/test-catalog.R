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
