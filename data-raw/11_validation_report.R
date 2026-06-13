#!/usr/bin/env Rscript
# 11_validation_report.R
# Build a worst-first HTML review of the parsed checklists so a human can spot
# mis-parses quickly. Not shipped (data-raw/reports/ is gitignored).

here <- function(...) file.path("data-raw", ...)
items <- readRDS(here("parsed", "checklist_items.rds"))
status <- readRDS(here("parsed", "parse_status.rds"))
repdir <- here("reports")
if (!dir.exists(repdir)) dir.create(repdir, recursive = TRUE)

esc <- function(x) {
  x <- as.character(x)
  x[is.na(x)] <- ""
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}

ord <- status[order(status$verified, status$parse_confidence, status$status), ]
con <- file(file.path(repdir, "parse_review.html"), "w", encoding = "UTF-8")
writeLines(c(
  "<!doctype html><meta charset='utf-8'><title>reportilo parse review</title>",
  "<style>body{font:14px/1.5 system-ui,sans-serif;max-width:1000px;margin:2rem auto;padding:0 1rem}",
  "table{border-collapse:collapse;width:100%;margin:.5rem 0 2rem}td,th{border:1px solid #ddd;padding:4px 8px;text-align:left;vertical-align:top}",
  ".low{background:#fff3f3}.ok{background:#f3fff3}h2{margin-top:2rem}.meta{color:#666;font-size:13px}</style>",
  sprintf("<h1>reportilo parse review (%d guidelines)</h1>", nrow(ord)),
  "<p class='meta'>Sorted worst-first. Verify low-confidence parses; add data-raw/overrides/&lt;id&gt;.csv to fix.</p>"
), con)
for (i in seq_len(nrow(ord))) {
  gid <- ord$guideline_id[i]
  it <- items[items$guideline_id == gid, ]
  cls <- if (isTRUE(ord$verified[i]) || ord$parse_confidence[i] >= 0.6) "ok" else "low"
  writeLines(sprintf(
    "<h2 class='%s'>%s</h2><p class='meta'>status: %s | confidence: %.2f | method: %s | items: %d | verified: %s</p>",
    cls, esc(gid), esc(ord$status[i]), ord$parse_confidence[i], esc(ord$parse_method[i]),
    nrow(it), ord$verified[i]
  ), con)
  if (nrow(it)) {
    writeLines("<table><tr><th>section</th><th>no</th><th>item</th></tr>", con)
    for (j in seq_len(nrow(it))) {
      writeLines(sprintf("<tr><td>%s</td><td>%s</td><td>%s</td></tr>",
        esc(it$section[j]), esc(it$item_no[j]), esc(it$item_text[j])), con)
    }
    writeLines("</table>", con)
  }
}
close(con)
cat("Wrote", file.path(repdir, "parse_review.html"), "\n")
