#!/usr/bin/env Rscript
# run_all.R - run the entire reportilo data pipeline in order.
# Usage: Rscript data-raw/run_all.R  (from the package root)

steps <- sprintf("data-raw/%s", c(
  "00_make_id_map.R",
  "01_build_manifest.R",
  "02_download.R",
  "03_detect_types.R",
  "04_parse_checklists.R",
  "05_apply_overrides.R",
  "06_build_guidelines.R",
  "07_normalize_checklists.R",
  "08_build_flowcharts.R",
  "09_save_rda.R",
  "10_export_json.R",
  "11_validation_report.R",
  "12_build_rob.R"
))

for (s in steps) {
  cat("\n========================================================\n")
  cat("==>", s, "\n")
  cat("========================================================\n")
  source(s, local = new.env(), echo = FALSE)
}
cat("\nPipeline complete.\n")
