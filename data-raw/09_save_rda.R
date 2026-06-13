#!/usr/bin/env Rscript
# 09_save_rda.R
# Save the normalized objects as lazy-loaded package datasets in data/.

here <- function(...) file.path("data-raw", ...)

guidelines <- readRDS(here("parsed", "guidelines.rds"))
checklist_items <- readRDS(here("parsed", "checklist_items.rds"))
parse_status <- readRDS(here("parsed", "parse_status.rds"))
fc <- readRDS(here("parsed", "flowcharts.rds"))
flowchart_nodes <- fc$nodes
flowchart_edges <- fc$edges
flowchart_counts <- fc$counts
flowchart_templates <- fc$templates

usethis::use_data(
  guidelines, checklist_items, parse_status,
  flowchart_nodes, flowchart_edges, flowchart_counts, flowchart_templates,
  overwrite = TRUE, compress = "xz"
)

cat("Saved data/:\n")
for (nm in c("guidelines", "checklist_items", "parse_status",
  "flowchart_nodes", "flowchart_edges", "flowchart_counts", "flowchart_templates")) {
  obj <- get(nm)
  cat(sprintf("  %-22s %d rows\n", nm, nrow(obj)))
}
