# End-to-end smoke for the bundled Shiny app via shinytest2. Drives the real app
# in a headless Chrome: it launches, switches tabs, fills a checklist and a flow
# diagram, sees the consistency check fire, and exports through the app. Skipped
# on CRAN and wherever Chrome / shinytest2 is unavailable.

skip_on_cran()
skip_if_not_installed("shinytest2")
skip_if_not_installed("chromote")
skip_if_not_installed("shiny")
skip_if_not_installed("DiagrammeR")
skip_if_not_installed("DT")
skip_if_not_installed("bslib")

# need a real Chrome/Chromium/Edge for chromote
has_chrome <- tryCatch(nzchar(chromote::find_chrome()), error = function(e) FALSE)
skip_if(!isTRUE(has_chrome), "No Chrome available for shinytest2")

app_dir <- system.file("shiny-apps", "reportilo", package = "reportilo")
skip_if(!nzchar(app_dir) || !file.exists(file.path(app_dir, "app.R")), "App not installed")

test_that("the Shiny app launches and the core modules respond", {
  app <- shinytest2::AppDriver$new(
    app_dir,
    name = "reportilo",
    load_timeout = 60 * 1000,
    timeout = 30 * 1000
  )
  on.exit(app$stop(), add = TRUE)

  # Catalog is the default tab and renders its detail panel.
  expect_false(is.null(app$get_html("#catalog-detail")))

  # Checklists: a hand-verified guideline shows the verified badge and a table.
  app$set_inputs(main = "Checklists")
  app$set_inputs(`checklist-guideline` = "prisma-2020")
  app$wait_for_idle()
  expect_match(app$get_html("#checklist-badge"), "Hand-verified")
  expect_false(is.null(app$get_html("#checklist-table")))

  # Flow diagrams: inconsistent counts trigger the consistency warning and the
  # diagram still renders.
  app$set_inputs(main = "Flow diagrams")
  app$wait_for_idle()
  app$set_inputs(`flow-fld_identified_db` = 0, `flow-fld_screened` = 100)
  app$wait_for_idle()
  expect_match(app$get_html("#flow-consistency"), "Check these counts")
  expect_false(is.null(app$get_html("#flow-preview")))

  # A draft CSV export goes through once warnings are acknowledged.
  app$set_inputs(`flow-allow_warn` = TRUE)
  app$wait_for_idle()
  csv <- app$get_download("flow-dl_csv")
  expect_true(file.exists(csv))

  # Risk of bias: the plot panel renders.
  app$set_inputs(main = "Risk of bias")
  app$wait_for_idle()
  expect_false(is.null(app$get_html("#rob-plot")))
})
