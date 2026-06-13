test_that("the package can be loaded and reports a version", {
  expect_s3_class(packageVersion("reportilo"), "package_version")
})

test_that("launch_reportilo is exported and points at a bundled app", {
  expect_true(is.function(launch_reportilo))
  app_dir <- system.file("shiny-apps", "reportilo", package = "reportilo")
  expect_true(dir.exists(app_dir))
  expect_true(file.exists(file.path(app_dir, "app.R")))
})
