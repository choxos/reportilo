test_that("get_checklist returns a fillable verified checklist for PRISMA 2020", {
  chk <- get_checklist("prisma-2020")
  expect_s3_class(chk, "reportilo_checklist")
  expect_identical(nrow(chk), 42L)
  expect_true(all(c("item_no", "section", "item_text", "response") %in% names(chk)))
  expect_true(all(is.na(chk$response)))
  expect_true(isTRUE(attr(chk, "verified")))
  expect_identical(attr(chk, "guideline_id"), "prisma-2020")
})

test_that("new_checklist is an alias for get_checklist", {
  expect_equal(new_checklist("strobe"), get_checklist("strobe"))
})

test_that("catalog-only guidelines return NULL with a message", {
  cat_only <- reportilo_guidelines()
  cat_only <- cat_only$guideline_id[!cat_only$has_checklist][1]
  expect_message(res <- get_checklist(cat_only), "catalog entry")
  expect_null(res)
})

test_that("validate_checklist counts completed items", {
  chk <- get_checklist("strobe")
  chk$response[1:5] <- "p1"
  expect_message(v <- validate_checklist(chk), "5 of 22")
  expect_identical(v$n_filled, 5L)
  expect_false(v$complete)
  expect_error(validate_checklist(data.frame(a = 1)))
})
