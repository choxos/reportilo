# Excel (.xlsx) export for checklists and flow diagram counts via openxlsx.

require_openxlsx <- function() {
  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    stop("Package `openxlsx` is required for Excel export. ",
      "Install it with install.packages(\"openxlsx\").",
      call. = FALSE
    )
  }
}

export_checklist_xlsx <- function(x, file) {
  require_openxlsx()
  df <- as.data.frame(x)[, c("section", "item_no", "item_text", "response"), drop = FALSE]
  names(df) <- c("Section", "Item", "Checklist item", "Reported (page)")
  wb <- openxlsx::createWorkbook()
  sheet <- "Checklist"
  openxlsx::addWorksheet(wb, sheet)
  hs <- openxlsx::createStyle(
    textDecoration = "bold", fgFill = "#0E3A5F", fontColour = "#FFFFFF",
    halign = "left", valign = "center", border = "TopBottomLeftRight"
  )
  openxlsx::writeData(wb, sheet, df, headerStyle = hs)
  openxlsx::addStyle(wb, sheet,
    openxlsx::createStyle(wrapText = TRUE, valign = "top"),
    rows = seq_len(nrow(df)) + 1L, cols = 3, gridExpand = TRUE
  )
  openxlsx::setColWidths(wb, sheet, cols = 1:4, widths = c(22, 8, 70, 18))
  openxlsx::freezePane(wb, sheet, firstRow = TRUE)
  add_provenance_sheet(wb, checklist_provenance(x))
  openxlsx::saveWorkbook(wb, file, overwrite = TRUE)
  invisible(file)
}

# A second worksheet recording where the checklist came from and whether it has
# been hand-verified. Added after the data sheet so "Checklist" stays sheet 1.
add_provenance_sheet <- function(wb, prov) {
  conf <- if (is.na(prov$parse_confidence)) {
    NA_character_
  } else {
    sprintf("%.0f%%", 100 * prov$parse_confidence)
  }
  df <- data.frame(
    Field = c(
      "Guideline", "Title", "Verification", "Parse status", "Parse method",
      "Parse confidence", "Needs review", "Note"
    ),
    Value = c(
      prov$guideline_id %||% "",
      prov$title %||% "",
      if (prov$verified) "Hand-verified" else "Auto-extracted, not verified",
      prov$status,
      prov$parse_method,
      conf %||% "",
      if (prov$needs_review) "Yes" else "No",
      prov$note
    ),
    stringsAsFactors = FALSE
  )
  sheet <- "Provenance"
  openxlsx::addWorksheet(wb, sheet)
  hs <- openxlsx::createStyle(textDecoration = "bold", fgFill = "#0E3A5F", fontColour = "#FFFFFF")
  openxlsx::writeData(wb, sheet, df, headerStyle = hs)
  openxlsx::addStyle(wb, sheet,
    openxlsx::createStyle(wrapText = TRUE, valign = "top"),
    rows = seq_len(nrow(df)) + 1L, cols = 2, gridExpand = TRUE
  )
  openxlsx::setColWidths(wb, sheet, cols = 1:2, widths = c(18, 80))
  invisible(wb)
}

# Current (filled) counts of a flowchart as a tidy data frame.
flowchart_counts_df <- function(x) {
  f <- x$fields
  data.frame(
    field = f$count_field,
    label = f$label,
    value = vapply(f$count_field, function(k) as.character(x$counts[[k]]), character(1)),
    stringsAsFactors = FALSE
  )
}

export_flowchart_xlsx <- function(x, file) {
  require_openxlsx()
  d <- flowchart_counts_df(x)
  df <- data.frame(Field = d$field, Label = d$label, Value = d$value, stringsAsFactors = FALSE)
  wb <- openxlsx::createWorkbook()
  sheet <- "Flow diagram"
  openxlsx::addWorksheet(wb, sheet)
  hs <- openxlsx::createStyle(textDecoration = "bold", fgFill = "#0E3A5F", fontColour = "#FFFFFF")
  openxlsx::writeData(wb, sheet, df, headerStyle = hs)
  openxlsx::setColWidths(wb, sheet, cols = 1:3, widths = c(22, 55, 18))
  openxlsx::saveWorkbook(wb, file, overwrite = TRUE)
  invisible(file)
}
