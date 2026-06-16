is_png <- function(file) {
  raw <- readBin(file, "raw", n = 8)
  identical(raw[1:4], as.raw(c(0x89, 0x50, 0x4E, 0x47)))
}

test_that("checklist exports to CSV with all items", {
  chk <- get_checklist("strobe")
  f <- tempfile(fileext = ".csv")
  reportilo_export(chk, f)
  back <- utils::read.csv(f, stringsAsFactors = FALSE)
  expect_identical(nrow(back), 22L)
  expect_true(all(c("item_no", "section", "item_text", "response") %in% names(back)))
})

test_that("checklist exports to Word with a table", {
  skip_if_not_installed("officer")
  skip_if_not_installed("flextable")
  chk <- get_checklist("strobe")
  chk$response[1] <- "p3"
  f <- tempfile(fileext = ".docx")
  reportilo_export(chk, f)
  expect_true(file.exists(f))
  s <- officer::docx_summary(officer::read_docx(f))
  expect_true(any(s$content_type == "table cell"))
  expect_true(any(grepl("scientific background", s$text, ignore.case = TRUE)))
})

test_that("checklist exports to Excel with a provenance sheet", {
  skip_if_not_installed("openxlsx")
  chk <- get_checklist("strobe")
  f <- tempfile(fileext = ".xlsx")
  reportilo_export(chk, f)
  back <- openxlsx::readWorkbook(f)
  expect_identical(nrow(back), 22L)
  expect_true("Provenance" %in% openxlsx::getSheetNames(f))
  prov <- openxlsx::readWorkbook(f, sheet = "Provenance")
  expect_true("Guideline" %in% prov$Field)
  expect_true("Verification" %in% prov$Field)
})

# A guideline that has a checklist but is not hand-verified, chosen from the data
# so the test does not hard-code a possibly-changing id.
an_unverified_checklist <- function() {
  ps <- parse_status
  ci <- get_data("checklist_items")
  cand <- intersect(unique(ci$guideline_id), ps$guideline_id[!ps$verified])
  cand[1]
}

test_that("exporting an unverified checklist warns on every path", {
  id <- an_unverified_checklist()
  skip_if(is.na(id) || !length(id))
  chk <- suppressWarnings(get_checklist(id))
  expect_warning(reportilo_export(chk, tempfile(fileext = ".csv")), "not hand-verified")
})

test_that("exporting a verified checklist does not warn", {
  chk <- get_checklist("strobe")
  expect_no_warning(reportilo_export(chk, tempfile(fileext = ".csv")))
})

test_that("flow diagram exports to PNG and SVG", {
  skip_if_not_installed("DiagrammeR")
  skip_if_not_installed("DiagrammeRsvg")
  skip_if_not_installed("rsvg")
  fc <- set_counts(new_flowchart("prisma_2020"), identified_db = 1200, screened = 980)

  png <- tempfile(fileext = ".png")
  reportilo_export(fc, png)
  expect_true(is_png(png))

  svg <- tempfile(fileext = ".svg")
  reportilo_export(fc, svg)
  expect_match(paste(readLines(svg, warn = FALSE), collapse = ""), "<svg")
})

test_that("flow diagram exports filled counts to CSV", {
  fc <- set_counts(new_flowchart("prisma_2020"), identified_db = 1200)
  f <- tempfile(fileext = ".csv")
  reportilo_export(fc, f)
  back <- utils::read.csv(f, stringsAsFactors = FALSE)
  expect_true("1200" %in% as.character(back$value))
})

test_that("CSV export neutralizes spreadsheet formula injection", {
  chk <- get_checklist("strobe")
  chk$response[1] <- "=HYPERLINK(\"http://evil\")"
  chk$response[2] <- "+cmd"
  f <- tempfile(fileext = ".csv")
  reportilo_export(chk, f)
  back <- utils::read.csv(f, stringsAsFactors = FALSE)
  expect_true(startsWith(back$response[1], "'="))
  expect_true(startsWith(back$response[2], "'+"))
})

test_that("format inference and errors behave", {
  chk <- get_checklist("strobe")
  expect_error(reportilo_export(chk, tempfile(fileext = ".png")), "Unsupported checklist")
  expect_error(reportilo_export(chk, "noext"), "determine the output format")
  expect_error(reportilo_export(list(), tempfile(fileext = ".csv")), "reportilo_checklist")
})
