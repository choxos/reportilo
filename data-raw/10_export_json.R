#!/usr/bin/env Rscript
# 10_export_json.R
# Export the datasets as JSON in inst/extdata/ for the Shiny app and the browser
# app (single source of truth shared across all three front ends).

suppressPackageStartupMessages(library(jsonlite))
here <- function(...) file.path("data-raw", ...)
outdir <- file.path("inst", "extdata")
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

guidelines <- readRDS(here("parsed", "guidelines.rds"))
checklist_items <- readRDS(here("parsed", "checklist_items.rds"))
parse_status <- readRDS(here("parsed", "parse_status.rds"))
fc <- readRDS(here("parsed", "flowcharts.rds"))

wj <- function(x, file) write_json(x, file.path(outdir, file),
  auto_unbox = TRUE, na = "null", pretty = FALSE)

wj(guidelines, "guidelines.json")
wj(checklist_items, "checklist_items.json")
wj(parse_status, "parse_status.json")
wj(list(
  templates = fc$templates, nodes = fc$nodes,
  edges = fc$edges, counts = fc$counts
), "flowcharts.json")

cat("Wrote JSON to", outdir, ":\n")
print(list.files(outdir))
for (f in list.files(outdir, full.names = TRUE)) {
  cat(sprintf("  %-26s %.0f KB\n", basename(f), file.size(f) / 1024))
}
