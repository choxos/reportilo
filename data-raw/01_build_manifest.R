#!/usr/bin/env Rscript
# 01_build_manifest.R
# Expand the EQUATOR "Downloadable files (name|url)" column into one row per
# file, joined to the stable guideline_id. This manifest drives the download.

suppressPackageStartupMessages(library(digest))

here <- function(...) file.path("data-raw", ...)
d <- read.csv(here("equator_guidelines.csv"), stringsAsFactors = FALSE, check.names = FALSE)
idm <- read.csv(here("id_map.csv"), stringsAsFactors = FALSE)
stopifnot(nrow(idm) == nrow(d), all(idm$equator_url == d$URL)) # id_map is row-aligned

url_ext <- function(u) {
  path <- sub("\\?.*$", "", u) # drop query
  path <- sub("#.*$", "", path)
  ext <- tolower(sub(".*\\.([A-Za-z0-9]{1,5})$", "\\1", basename(path)))
  if (ext == basename(path) || nchar(ext) > 5) ext <- "" # no extension found
  ext
}
url_host <- function(u) sub("^[a-z]+://([^/]+).*$", "\\1", u)

dl <- d[["Downloadable files (name|url)"]]
rows <- list()
for (i in seq_len(nrow(d))) {
  cell <- dl[i]
  if (is.na(cell) || trimws(cell) == "") next
  gid <- idm$guideline_id[i]
  parts <- strsplit(cell, ";", fixed = TRUE)[[1]]
  k <- 0L
  for (p in parts) {
    p <- trimws(p)
    if (p == "") next
    bar <- regexpr("|", p, fixed = TRUE)
    if (bar > 0) {
      label <- trimws(substr(p, 1, bar - 1))
      u <- trimws(substr(p, bar + 1, nchar(p)))
    } else {
      label <- ""
      u <- p
    }
    if (!grepl("^https?://", u)) next
    k <- k + 1L
    ext <- url_ext(u)
    # Name by a short URL hash to keep paths unique and short (the human label
    # is retained in the file_label column).
    fname <- sprintf("%02d_%s%s", k, substr(digest(u, "sha1"), 1, 8),
      if (ext != "") paste0(".", ext) else ""
    )
    rows[[length(rows) + 1L]] <- data.frame(
      guideline_id = gid,
      acronym = d[["Reporting guideline acronym"]][i],
      file_index = k,
      file_label = label,
      source_url = u,
      host = url_host(u),
      ext = ext,
      local_path = file.path("data-raw", "downloads", gid, fname),
      status = "pending",
      stringsAsFactors = FALSE
    )
  }
}
man <- do.call(rbind, rows)
# One download per unique URL; guarantee unique destinations.
man <- man[!duplicated(man$source_url), ]
if (any(duplicated(man$local_path))) {
  stop("duplicate local_path after dedupe: ",
    man$local_path[duplicated(man$local_path)][1])
}
write.csv(man, here("download_manifest.csv"), row.names = FALSE)

cat(sprintf("Wrote %s: %d files across %d guidelines\n",
  here("download_manifest.csv"), nrow(man), length(unique(man$guideline_id))
))
cat("Extensions:\n"); print(table(man$ext))
cat("Top hosts:\n"); print(utils::head(sort(table(man$host), decreasing = TRUE), 8))
