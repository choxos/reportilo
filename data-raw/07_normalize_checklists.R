#!/usr/bin/env Rscript
# 07_normalize_checklists.R
# Choose one primary checklist per guideline (override > docx > pdf, then by
# confidence and item count), assign stable ordering and ids, and produce the
# normalized checklist_items table plus a per-guideline parse_status summary.

here <- function(...) file.path("data-raw", ...)
merged <- read.csv(here("parsed", "checklist_items_merged.csv"), stringsAsFactors = FALSE)
raw_status <- read.csv(here("parsed", "parse_status_raw.csv"), stringsAsFactors = FALSE)

variant_key <- function(df) {
  # higher is better
  is_ov <- isTRUE(df$is_override[1])
  is_docx <- df$source_format[1] == "docx"
  conf <- max(df$parse_confidence, na.rm = TRUE)
  c(override = as.numeric(is_ov), conf = conf, docx = as.numeric(is_docx), n = nrow(df))
}

pick_primary <- function(g) {
  variants <- split(g, g$variant)
  if (length(variants) == 1) {
    return(variants[[1]])
  }
  keys <- lapply(variants, variant_key)
  mat <- do.call(rbind, keys)
  ord <- order(-mat[, "override"], -mat[, "conf"], -mat[, "docx"], -mat[, "n"])
  variants[[ord[1]]]
}

items_list <- list()
for (gid in unique(merged$guideline_id)) {
  g <- merged[merged$guideline_id == gid, ]
  prim <- pick_primary(g)
  prim <- prim[nzchar(trimws(prim$item_text)), ]
  if (!nrow(prim)) next
  sec <- prim$section
  sec[is.na(sec) | !nzchar(trimws(sec))] <- "General"
  section_order <- match(sec, unique(sec))
  items_list[[length(items_list) + 1L]] <- data.frame(
    item_uid = sprintf("%s::%s::%03d", gid, prim$variant, seq_len(nrow(prim))),
    guideline_id = gid,
    version = "primary",
    variant = prim$variant,
    section = sec,
    section_order = section_order,
    item_no = as.character(prim$item_no),
    item_order = seq_len(nrow(prim)),
    sub_item = NA_character_,
    item_text = trimws(prim$item_text),
    explanation = if (!is.null(prim$explanation)) prim$explanation else NA_character_,
    response_type = if (!is.null(prim$response_type)) prim$response_type else "page_ref",
    source_url = prim$source_url,
    source_format = prim$source_format,
    parse_method = prim$parse_method,
    parse_confidence = prim$parse_confidence,
    is_override = isTRUE(prim$is_override[1]) | (!is.null(prim$is_override) & prim$is_override),
    stringsAsFactors = FALSE
  )
}
checklist_items <- do.call(rbind, items_list)
checklist_items$is_override[is.na(checklist_items$is_override)] <- FALSE
stopifnot(!any(duplicated(checklist_items$item_uid)))

# ---- per-guideline parse_status summary -----------------------------------
# best outcome per guideline from the raw per-file status, then overlay the
# chosen primary checklist (which may be an override).
rank_status <- c(parsed_ok = 3, partial = 2, failed = 1)
agg <- list()
for (gid in unique(raw_status$guideline_id)) {
  r <- raw_status[raw_status$guideline_id == gid, ]
  best <- r[order(-rank_status[r$status], -r$parse_confidence, -r$n_items), ][1, ]
  agg[[length(agg) + 1L]] <- data.frame(
    guideline_id = gid, n_files = nrow(r), status = best$status,
    n_items = best$n_items, parse_confidence = best$parse_confidence,
    parse_method = best$parse_method, stringsAsFactors = FALSE
  )
}
parse_status <- if (length(agg)) do.call(rbind, agg) else data.frame()

# overlay chosen primary (handles overrides and final item counts)
prim_summary <- aggregate(item_order ~ guideline_id, checklist_items, max)
names(prim_summary)[2] <- "final_items"
ov_ids <- unique(checklist_items$guideline_id[checklist_items$is_override])
parse_status <- merge(parse_status, prim_summary, by = "guideline_id", all = TRUE)
parse_status$verified <- parse_status$guideline_id %in% ov_ids
parse_status$status[parse_status$verified] <- "parsed_ok"
parse_status$n_items[!is.na(parse_status$final_items)] <-
  parse_status$final_items[!is.na(parse_status$final_items)]
parse_status$final_items <- NULL
parse_status$needs_review <- parse_status$status == "partial" & !parse_status$verified

saveRDS(checklist_items, here("parsed", "checklist_items.rds"))
saveRDS(parse_status, here("parsed", "parse_status.rds"))
write.csv(parse_status, here("parse_status.csv"), row.names = FALSE)

cat(sprintf("Normalized: %d items across %d guidelines\n",
  nrow(checklist_items), length(unique(checklist_items$guideline_id))))
cat("parse_status by status:\n"); print(table(parse_status$status))
cat("verified (override):", sum(parse_status$verified), "\n")
