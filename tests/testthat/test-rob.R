test_that("rob tools and domains are available", {
  tools <- rob_tools_available()
  expect_gte(nrow(tools), 7)
  expect_true(all(c("rob2", "robins_i", "quadas2", "quips", "rob1") %in% tools$tool_id))
})

test_that("reportilo_rob builds from the example and has the right shape", {
  rob <- reportilo_rob("rob2")
  expect_s3_class(rob, "reportilo_rob")
  expect_identical(rob$levels, c("Low", "Some concerns", "High"))
  expect_identical(length(rob$studies), 6L)
  # domains include the 5 RoB2 domains plus Overall
  expect_true("Overall" %in% rob$domains$domain_id)
  expect_identical(sum(rob$domains$domain_id != "Overall"), 5L)
  expect_error(reportilo_rob("nope"), "Unknown RoB tool")
})

test_that("rob_template is a blank wide table with the right columns", {
  tmpl <- rob_template("rob2", n_studies = 3)
  expect_identical(nrow(tmpl), 3L)
  expect_true(all(c("Study", "D1", "D5", "Overall") %in% names(tmpl)))
})

test_that("reportilo_rob accepts a custom wide table", {
  d <- rob_template("quadas2", n_studies = 2)
  d$D1 <- c("Low", "High")
  d$Overall <- c("Low", "High")
  rob <- reportilo_rob("quadas2", d)
  w <- rob_wide(rob)
  expect_identical(w$D1, c("Low", "High"))
  expect_identical(nrow(w), 2L)
})

test_that("invalid judgments warn", {
  d <- rob_template("rob2", n_studies = 1)
  d$D1 <- "Bananas"
  expect_warning(reportilo_rob("rob2", d), "No information")
})

test_that("rob plots return ggplot objects", {
  skip_if_not_installed("ggplot2")
  expect_s3_class(rob_traffic_light(reportilo_rob("rob2")), "ggplot")
  expect_s3_class(rob_summary(reportilo_rob("robins_i")), "ggplot")
})

test_that("rob exports to image, Excel and CSV", {
  skip_if_not_installed("ggplot2")
  rob <- reportilo_rob("rob2")

  png <- tempfile(fileext = ".png")
  reportilo_export(rob, png, type = "summary")
  expect_true(file.exists(png) && file.size(png) > 0)

  f <- tempfile(fileext = ".csv")
  reportilo_export(rob, f)
  back <- utils::read.csv(f, stringsAsFactors = FALSE)
  expect_identical(nrow(back), 6L)
  expect_true("Overall" %in% names(back))

  skip_if_not_installed("openxlsx")
  x <- tempfile(fileext = ".xlsx")
  reportilo_export(rob, x)
  expect_identical(nrow(openxlsx::readWorkbook(x)), 6L)
})
