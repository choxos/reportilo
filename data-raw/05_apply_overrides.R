#!/usr/bin/env Rscript
# 05_apply_overrides.R
# Merge hand-verified overrides over the auto-parsed checklist items. An override
# file data-raw/overrides/<guideline_id>.csv fully replaces the auto-parsed items
# for that guideline (variant "main"), marking them verified.
#
# Override CSV columns (header required): section, item_no, item_text
#   optional: explanation, response_type, version, variant

here <- function(...) file.path("data-raw", ...)
raw_path <- here("parsed", "checklist_items_raw.csv")
items <- if (file.exists(raw_path)) read.csv(raw_path, stringsAsFactors = FALSE) else data.frame()
if (nrow(items) && is.null(items$is_override)) items$is_override <- FALSE

ov_dir <- here("overrides")
ov_files <- list.files(ov_dir, pattern = "\\.csv$", full.names = TRUE)
ov_files <- ov_files[!grepl("__patch\\.csv$", ov_files)]

if (length(ov_files)) {
  cat("Applying", length(ov_files), "override(s):\n")
  for (f in ov_files) {
    gid <- sub("\\.csv$", "", basename(f))
    ov <- read.csv(f, stringsAsFactors = FALSE)
    stopifnot(all(c("item_no", "item_text") %in% names(ov)))
    ov$guideline_id <- gid
    ov$variant <- if (!is.null(ov$variant)) ov$variant else "main"
    if (is.null(ov$section)) ov$section <- NA_character_
    if (is.null(ov$explanation)) ov$explanation <- NA_character_
    if (is.null(ov$response_type)) ov$response_type <- "page_ref"
    ov$source_format <- "override"
    ov$parse_method <- "manual_override"
    ov$parse_confidence <- 1
    ov$source_url <- NA_character_
    ov$source_file <- basename(f)
    ov$is_override <- TRUE
    # drop any auto-parsed rows for this guideline
    if (nrow(items)) items <- items[items$guideline_id != gid, ]
    # align columns
    if (nrow(items)) {
      for (col in setdiff(names(items), names(ov))) ov[[col]] <- NA
      ov <- ov[, names(items)[names(items) %in% names(ov)], drop = FALSE]
    }
    items <- if (nrow(items)) rbind(items, ov[, names(items)]) else ov
    cat(sprintf("  %-30s %d items\n", gid, nrow(ov)))
  }
} else {
  cat("No overrides found in", ov_dir, "\n")
}

if (nrow(items) && is.null(items$is_override)) items$is_override <- FALSE
items$is_override[is.na(items$is_override)] <- FALSE

write.csv(items, here("parsed", "checklist_items_merged.csv"), row.names = FALSE)
cat(sprintf("Wrote merged items: %d rows, %d guidelines (%d overridden)\n",
  nrow(items), length(unique(items$guideline_id)),
  length(unique(items$guideline_id[items$is_override]))))
