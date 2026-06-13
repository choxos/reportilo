#!/usr/bin/env Rscript
# 04_parse_checklists.R
# Extract checklist items from downloaded .docx (officer table extraction) and
# .pdf (pdftools text heuristic) files. Every file is attempted in a tryCatch so
# one bad file never halts the run. Outputs go to data-raw/parsed/ (gitignored);
# later steps apply overrides and normalize.

suppressPackageStartupMessages({
  library(officer)
  library(pdftools)
})

here <- function(...) file.path("data-raw", ...)
outdir <- here("parsed")
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

man <- read.csv(here("download_manifest.csv"), stringsAsFactors = FALSE)
man <- man[!is.na(man$detected) & man$detected %in% c("docx", "pdf"), ]

kw_item <- "item|^no\\.?$|number|^#$"
kw_section <- "section|topic|domain|heading|sub-?section"
kw_text <- "checklist|recommendation|description|item|guidance|standard|element"
kw_page <- "page|reported|response|location|line|where|address"

score_header <- function(hdr) {
  h <- tolower(paste(hdr, collapse = " "))
  sum(grepl(kw_item, h), grepl(kw_section, h), grepl(kw_text, h), grepl(kw_page, h))
}

# Reconstruct one docx table (table_index) into a character matrix.
table_matrix <- function(tc, ti) {
  d <- tc[tc$table_index == ti, ]
  nr <- max(d$row_id)
  nc <- max(d$cell_id)
  m <- matrix("", nrow = nr, ncol = nc)
  for (i in seq_len(nrow(d))) m[d$row_id[i], d$cell_id[i]] <- d$text[i]
  m
}

parse_docx <- function(path) {
  s <- docx_summary(read_docx(path))
  tc <- s[s$content_type == "table cell" & !is.na(s$text), ]
  if (!nrow(tc)) return(NULL)
  best <- NULL
  best_score <- -1
  for (ti in unique(tc$table_index)) {
    m <- table_matrix(tc, ti)
    if (ncol(m) < 2 || nrow(m) < 4) next
    hdr <- m[1, ]
    sc <- score_header(hdr) + (nrow(m) >= 5 && nrow(m) <= 80)
    if (sc > best_score) {
      best_score <- sc
      best <- m
    }
  }
  if (is.null(best)) return(NULL)
  m <- best
  hdr <- tolower(m[1, ])
  col_item <- which(grepl(kw_item, hdr))[1]
  col_sec <- which(grepl(kw_section, hdr))[1]
  col_page <- which(grepl(kw_page, hdr))[1]
  # item text = the widest text column not already claimed
  claimed <- c(col_item, col_sec, col_page)
  textcols <- setdiff(seq_len(ncol(m)), claimed[!is.na(claimed)])
  if (!length(textcols)) textcols <- setdiff(seq_len(ncol(m)), col_item)
  widths <- vapply(textcols, function(j) mean(nchar(m[, j])), numeric(1))
  col_text <- textcols[which.max(widths)]

  body <- m[-1, , drop = FALSE]
  section <- NA_character_
  out <- list()
  for (r in seq_len(nrow(body))) {
    cells <- body[r, ]
    nonempty <- which(nzchar(trimws(cells)))
    if (length(nonempty) <= 1) {
      if (length(nonempty) == 1) section <- trimws(cells[nonempty])
      next
    }
    item_no <- if (!is.na(col_item)) trimws(cells[col_item]) else NA_character_
    sec <- if (!is.na(col_sec) && nzchar(trimws(cells[col_sec]))) trimws(cells[col_sec]) else section
    if (!is.na(col_sec) && nzchar(trimws(cells[col_sec]))) section <- sec
    item_text <- trimws(cells[col_text])
    if (!nzchar(item_text)) next
    out[[length(out) + 1L]] <- data.frame(
      section = sec, item_no = item_no, item_text = item_text,
      response_type = if (!is.na(col_page)) "page_ref" else "free_text",
      stringsAsFactors = FALSE
    )
  }
  if (!length(out)) return(NULL)
  res <- do.call(rbind, out)
  attr(res, "confidence") <- min(1, 0.5 + 0.12 * best_score)
  attr(res, "method") <- "docx_table"
  res
}

parse_pdf <- function(path) {
  txt <- tryCatch(pdf_text(path), error = function(e) character(0))
  if (!length(txt)) return(NULL)
  lines <- unlist(strsplit(txt, "\n"))
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]
  item_re <- "^(\\d{1,2}[a-z]?)[.)]?\\s+(.{6,})$"
  out <- list()
  section <- NA_character_
  for (ln in lines) {
    if (grepl(item_re, ln)) {
      mm <- regmatches(ln, regexec(item_re, ln))[[1]]
      out[[length(out) + 1L]] <- data.frame(
        section = section, item_no = mm[2], item_text = trimws(mm[3]),
        response_type = "page_ref", stringsAsFactors = FALSE
      )
    } else if (nchar(ln) <= 60 && grepl("^[A-Z]", ln) &&
      !grepl("[.]$", ln) && length(out) > 0) {
      # short Title-ish line with no trailing period: treat as a section header
      section <- ln
    }
  }
  if (length(out) < 3) return(NULL) # too few to trust
  res <- do.call(rbind, out)
  attr(res, "confidence") <- 0.3
  attr(res, "method") <- "pdf_text_regex"
  res
}

items <- list()
status <- list()
for (i in seq_len(nrow(man))) {
  gid <- man$guideline_id[i]
  variant <- if (nzchar(man$file_label[i])) tolower(gsub("[^a-z0-9]+", "-", tolower(man$file_label[i]))) else paste0("file", man$file_index[i])
  path <- man$local_path[i]
  fmt <- man$detected[i]
  parsed <- tryCatch(
    if (fmt == "docx") parse_docx(path) else parse_pdf(path),
    error = function(e) {
      message("parse error ", gid, ": ", conditionMessage(e))
      NULL
    }
  )
  if (is.null(parsed) || !nrow(parsed)) {
    status[[length(status) + 1L]] <- data.frame(
      guideline_id = gid, variant = variant, source_format = fmt,
      parse_method = NA_character_, parse_confidence = 0, n_items = 0L,
      status = "failed", source_url = man$source_url[i], source_file = basename(path),
      stringsAsFactors = FALSE
    )
    next
  }
  parsed$guideline_id <- gid
  parsed$variant <- variant
  parsed$source_format <- fmt
  parsed$parse_method <- attr(parsed, "method")
  parsed$parse_confidence <- attr(parsed, "confidence")
  parsed$source_url <- man$source_url[i]
  parsed$source_file <- basename(path)
  items[[length(items) + 1L]] <- parsed
  status[[length(status) + 1L]] <- data.frame(
    guideline_id = gid, variant = variant, source_format = fmt,
    parse_method = attr(parsed, "method"), parse_confidence = attr(parsed, "confidence"),
    n_items = nrow(parsed),
    status = if (attr(parsed, "confidence") >= 0.6) "parsed_ok" else "partial",
    source_url = man$source_url[i], source_file = basename(path),
    stringsAsFactors = FALSE
  )
}

items_df <- if (length(items)) do.call(rbind, items) else data.frame()
status_df <- do.call(rbind, status)
write.csv(items_df, file.path(outdir, "checklist_items_raw.csv"), row.names = FALSE)
write.csv(status_df, file.path(outdir, "parse_status_raw.csv"), row.names = FALSE)

cat(sprintf("Parsed %d files: %d items from %d guidelines\n",
  nrow(man), nrow(items_df), length(unique(items_df$guideline_id))))
cat("Status:\n"); print(table(status_df$status))
cat("Method:\n"); print(table(status_df$parse_method, useNA = "ifany"))
