#!/usr/bin/env Rscript
# 06_build_guidelines.R
# Build the guideline registry (one row per EQUATOR guideline) from the catalog
# CSV + id_map, flagging which guidelines have a machine-readable checklist.
# Saves an RDS intermediate (list columns survive) for steps 09/10.

here <- function(...) file.path("data-raw", ...)
d <- read.csv(here("equator_guidelines.csv"), stringsAsFactors = FALSE, check.names = FALSE)
idm <- read.csv(here("id_map.csv"), stringsAsFactors = FALSE)
stopifnot(nrow(idm) == nrow(d), all(idm$equator_url == d$URL)) # id_map is row-aligned

merged_path <- here("parsed", "checklist_items_merged.csv")
merged <- if (file.exists(merged_path)) read.csv(merged_path, stringsAsFactors = FALSE) else data.frame()
checklist_counts <- if (nrow(merged)) table(merged$guideline_id) else integer(0)
has_checklist_id <- names(checklist_counts)[checklist_counts >= 3]

blank_to_na <- function(x) {
  x <- trimws(as.character(x))
  x[x == ""] <- NA_character_
  x
}
split_list <- function(x, split = "[;\n]") {
  lapply(x, function(s) {
    if (is.na(s) || !nzchar(trimws(s))) {
      return(character(0))
    }
    out <- trimws(strsplit(s, split)[[1]])
    out[nzchar(out)]
  })
}
parse_files <- function(x) {
  lapply(x, function(s) {
    if (is.na(s) || !nzchar(trimws(s))) {
      return(list())
    }
    parts <- trimws(strsplit(s, ";", fixed = TRUE)[[1]])
    parts <- parts[nzchar(parts)]
    lapply(parts, function(p) {
      bar <- regexpr("|", p, fixed = TRUE)
      label <- if (bar > 0) trimws(substr(p, 1, bar - 1)) else ""
      url <- if (bar > 0) trimws(substr(p, bar + 1, nchar(p))) else p
      ext <- tolower(sub(".*\\.([A-Za-z0-9]{1,5})(\\?.*)?$", "\\1", url))
      list(label = label, url = url, ext = ext)
    })
  })
}

gid <- idm$guideline_id

guidelines <- data.frame(
  guideline_id = gid,
  acronym = blank_to_na(d[["Reporting guideline acronym"]]),
  title = blank_to_na(d[["Title"]]),
  equator_url = d[["URL"]],
  study_design = blank_to_na(d[["Study design"]]),
  clinical_area = blank_to_na(d[["Clinical area"]]),
  language = blank_to_na(d[["Language"]]),
  provided_for = blank_to_na(d[["Reporting guideline provided for?"]]),
  applies_to = blank_to_na(d[["Applies to the whole report or to individual sections of the report?"]]),
  reference = blank_to_na(d[["Full bibliographic reference"]]),
  pubmed_id = blank_to_na(d[["PubMed ID"]]),
  doi = blank_to_na(d[["DOI"]]),
  pub_date = blank_to_na(d[["Date of publication / Ahead of print date"]]),
  website_url = blank_to_na(d[["Reporting guideline website URL"]]),
  ee_papers = blank_to_na(d[["Explanation and elaboration papers"]]),
  other_languages = blank_to_na(d[["Availability in additional languages"]]),
  related_guidelines = blank_to_na(d[["Relevant more generic / specialised reporting guidelines"]]),
  prev_versions = blank_to_na(d[["Previous versions of this guideline / Guideline history"]]),
  record_updated = blank_to_na(d[["Record last updated on"]]),
  equator_hosted_count = suppressWarnings(as.integer(d[["Equator-hosted files count"]])),
  stringsAsFactors = FALSE
)
guidelines$fulltext_urls <- split_list(d[["Relevant URLs(full-text if available)"]])
guidelines$taxonomy_terms <- split_list(d[["Taxonomy terms"]], split = ";")
guidelines$downloadable_files <- parse_files(d[["Downloadable files (name|url)"]])
guidelines$has_checklist <- guidelines$guideline_id %in% has_checklist_id
guidelines$checklist_tier <- factor(
  ifelse(guidelines$has_checklist, "checklist", "catalog_only"),
  levels = c("checklist", "catalog_only")
)

stopifnot(!any(is.na(guidelines$guideline_id)), !any(duplicated(guidelines$guideline_id)))

saveRDS(guidelines, here("parsed", "guidelines.rds"))
cat(sprintf("Built guidelines: %d rows, %d with a checklist (%d catalog-only)\n",
  nrow(guidelines), sum(guidelines$has_checklist), sum(!guidelines$has_checklist)))
