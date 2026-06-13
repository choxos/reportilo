#!/usr/bin/env Rscript
# 00_make_id_map.R
# Assign a stable, unique guideline_id to every EQUATOR guideline.
#
# Strategy (deterministic, order-independent for unique cases):
#   base = slug(acronym) when present, else slug(first words of title)
#   collisions are resolved by appending a 4-digit year (when one appears in
#   the acronym/title) and, if still colliding, a 6-hex hash of the EQUATOR URL.
# The EQUATOR URL is unique per row and is used as the stable key: an existing
# URL never changes id between rebuilds (asserted when an old id_map exists).

suppressPackageStartupMessages(library(digest))

here <- function(...) file.path("data-raw", ...)
csv_in <- here("equator_guidelines.csv")
id_map_out <- here("id_map.csv")

stopifnot(file.exists(csv_in))
d <- read.csv(csv_in, stringsAsFactors = FALSE, check.names = FALSE)

slugify <- function(x) {
  x <- as.character(x)
  x <- iconv(x, to = "ASCII//TRANSLIT")
  x[is.na(x)] <- ""
  x <- tolower(x)
  x <- gsub("&", " and ", x, fixed = TRUE)
  x <- gsub("[^a-z0-9]+", "-", x)
  x <- gsub("(^-+)|(-+$)", "", x)
  x
}

first_words <- function(x, n = 8) {
  w <- strsplit(trimws(as.character(x)), "\\s+")[[1]]
  paste(utils::head(w, n), collapse = " ")
}

first_year <- function(x) {
  m <- regmatches(x, regexpr("(19|20)[0-9]{2}", x))
  if (length(m)) m else NA_character_
}

acronym <- d[["Reporting guideline acronym"]]
title <- d[["Title"]]
url <- d[["URL"]]

n <- nrow(d)
base <- character(n)
for (i in seq_len(n)) {
  ac <- trimws(acronym[i])
  if (is.na(ac) || ac == "") {
    base[i] <- slugify(first_words(title[i], 8))
  } else {
    base[i] <- slugify(ac)
  }
  if (base[i] == "") base[i] <- paste0("guideline-", substr(digest(url[i], "sha1"), 1, 6))
}

# Resolve collisions deterministically.
id <- rep(NA_character_, n)
used <- character(0)
assign_unique <- function(cand, u) {
  if (!cand %in% used) {
    return(cand)
  }
  yr <- first_year(paste(acronym[u], title[u]))
  if (!is.na(yr) && !grepl(yr, cand)) {
    cand2 <- paste0(cand, "-", yr)
    if (!cand2 %in% used) {
      return(cand2)
    }
  }
  paste0(cand, "-", substr(digest(url[u], "sha1"), 1, 6))
}
for (i in seq_len(n)) {
  id[i] <- assign_unique(base[i], i)
  used <- c(used, id[i])
}
stopifnot(!any(duplicated(id)))

id_map <- data.frame(
  equator_url = url,
  guideline_id = id,
  acronym = acronym,
  title = title,
  stringsAsFactors = FALSE
)

# Stability check against any existing map (same URL must keep its id).
if (file.exists(id_map_out)) {
  old <- read.csv(id_map_out, stringsAsFactors = FALSE)
  m <- merge(old[c("equator_url", "guideline_id")], id_map,
    by = "equator_url", suffixes = c("_old", "_new")
  )
  changed <- m[m$guideline_id_old != m$guideline_id_new, ]
  if (nrow(changed)) {
    stop(
      "guideline_id changed for ", nrow(changed),
      " existing URLs; ids must be stable. First: ",
      changed$guideline_id_old[1], " -> ", changed$guideline_id_new[1]
    )
  }
}

write.csv(id_map, id_map_out, row.names = FALSE)
cat(sprintf(
  "Wrote %s: %d guidelines, %d unique ids (%d disambiguated by year/hash)\n",
  id_map_out, nrow(id_map), length(unique(id)), sum(id != base)
))
