#' Browse the EQUATOR reporting guideline catalog
#'
#' Return the registry of reporting guidelines, optionally limited to those that
#' ship a machine-readable checklist.
#'
#' @param checklist_only Logical; if `TRUE`, return only guidelines that have a
#'   bundled fillable checklist. Default `FALSE` (all guidelines).
#' @param category Optional EQUATOR study-type category to filter by (see
#'   [reportilo_categories()] for valid values).
#'
#' @return A data frame of guidelines (see [guidelines]).
#' @seealso [search_guidelines()], [guideline_info()], [reportilo_categories()]
#' @examples
#' head(reportilo_guidelines())
#' nrow(reportilo_guidelines(checklist_only = TRUE))
#' nrow(reportilo_guidelines(category = "Randomized trials"))
#' @export
reportilo_guidelines <- function(checklist_only = FALSE, category = NULL) {
  g <- get_data("guidelines")
  if (isTRUE(checklist_only)) g <- g[g$has_checklist, , drop = FALSE]
  if (!is.null(category)) {
    g <- g[!is.na(g$category) & as.character(g$category) == category, , drop = FALSE]
  }
  g
}

#' EQUATOR study-type categories
#'
#' The main study-type categories used to group the catalog, in display order,
#' with the number of guidelines in each.
#'
#' @return A data frame with `category`, `category_order` and `n`.
#' @seealso [reportilo_guidelines()]
#' @examples
#' reportilo_categories()
#' @export
reportilo_categories <- function() {
  g <- get_data("guidelines")
  tab <- as.data.frame(table(category = g$category), stringsAsFactors = FALSE)
  tab$category_order <- match(tab$category, levels(g$category))
  tab <- tab[order(tab$category_order), c("category", "category_order", "Freq")]
  names(tab)[names(tab) == "Freq"] <- "n"
  rownames(tab) <- NULL
  tab
}

#' Checklist coverage report
#'
#' Summarize how much of the catalog has machine-readable checklists and how much
#' is hand-verified, by EQUATOR study-type category. Use this to be explicit
#' about coverage rather than implying the whole catalog is fillable.
#'
#' @return A data frame with one row per category plus a `Total` row, with
#'   columns: `records`, `with_checklist`, `verified`, `needs_review`.
#' @seealso [reportilo_guidelines()], [parse_status]
#' @examples
#' reportilo_coverage()
#' @export
reportilo_coverage <- function() {
  g <- get_data("guidelines")
  ps <- get_data("parse_status")
  verified_ids <- ps$guideline_id[is_true_vec(ps$verified)]
  review_ids <- ps$guideline_id[is_true_vec(ps$needs_review)]
  cats <- levels(g$category)
  rows <- lapply(cats, function(cat) {
    sub <- g[!is.na(g$category) & g$category == cat, , drop = FALSE]
    data.frame(
      category = cat,
      records = nrow(sub),
      with_checklist = sum(sub$has_checklist),
      verified = sum(sub$guideline_id %in% verified_ids),
      needs_review = sum(sub$has_checklist & sub$guideline_id %in% review_ids),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  out <- out[out$records > 0, , drop = FALSE]
  total <- data.frame(
    category = "Total", records = sum(out$records),
    with_checklist = sum(out$with_checklist), verified = sum(out$verified),
    needs_review = sum(out$needs_review), stringsAsFactors = FALSE
  )
  rownames(out) <- NULL
  rbind(out, total)
}

# small helper: TRUE for TRUE values, FALSE for FALSE/NA (vectorized)
is_true_vec <- function(x) !is.na(x) & x

#' Search the reporting guideline catalog
#'
#' Case-insensitive substring search across selected fields of the catalog.
#'
#' @param query A single search string.
#' @param fields Character vector of columns to search. Defaults to acronym,
#'   title, study design and clinical area.
#' @param checklist_only Logical; restrict to guidelines with a checklist.
#'
#' @return A data frame of matching guidelines with the most useful columns.
#' @seealso [reportilo_guidelines()], [guideline_info()]
#' @examples
#' search_guidelines("randomized trial")
#' search_guidelines("qualitative")
#' @export
search_guidelines <- function(query,
                              fields = c("acronym", "title", "study_design", "clinical_area"),
                              checklist_only = FALSE) {
  stopifnot(is.character(query), length(query) == 1L)
  g <- reportilo_guidelines(checklist_only = checklist_only)
  fields <- intersect(fields, names(g))
  hay <- tolower(do.call(paste, c(
    lapply(fields, function(f) ifelse(is.na(g[[f]]), "", as.character(g[[f]]))),
    sep = " | "
  )))
  hit <- grepl(tolower(query), hay, fixed = TRUE)
  cols <- intersect(
    c("guideline_id", "acronym", "title", "category", "study_design", "has_checklist"),
    names(g)
  )
  g[hit, cols, drop = FALSE]
}

#' Look up a single reporting guideline
#'
#' Return a structured summary of one guideline: metadata, whether a checklist
#' is bundled, the flow diagram template (if any), and links to source files.
#'
#' @param id A `guideline_id` (or an unambiguous acronym).
#'
#' @return An object of class `reportilo_guideline_info` (a list) with a print
#'   method.
#' @seealso [reportilo_guidelines()], [get_checklist()]
#' @examples
#' guideline_info("prisma-2020")
#' @export
guideline_info <- function(id) {
  id <- resolve_guideline_id(id)
  g <- get_data("guidelines")
  row <- g[g$guideline_id == id, , drop = FALSE]
  tpl <- get_data("flowchart_templates")
  template <- tpl$template_id[tpl$guideline_id == id]
  structure(
    list(
      guideline_id = id,
      acronym = row$acronym,
      title = row$title,
      category = as.character(row$category),
      study_design = row$study_design,
      clinical_area = row$clinical_area,
      reference = row$reference,
      doi = row$doi,
      equator_url = row$equator_url,
      website_url = row$website_url,
      has_checklist = row$has_checklist,
      flowchart_template = if (length(template)) template else NA_character_,
      downloadable_files = row$downloadable_files[[1]]
    ),
    class = "reportilo_guideline_info"
  )
}

#' @export
print.reportilo_guideline_info <- function(x, ...) {
  cat0 <- function(...) cat(..., "\n", sep = "")
  cat0(x$acronym %||% x$guideline_id, " - ", x$title %||% "")
  cat0(strrep("-", 60))
  if (!is.na(x$category %||% NA)) cat0("Category     : ", x$category)
  if (!is.na(x$study_design %||% NA)) cat0("Study design : ", x$study_design)
  if (!is.na(x$clinical_area %||% NA)) cat0("Clinical area: ", x$clinical_area)
  cat0("Checklist    : ", if (isTRUE(x$has_checklist)) "yes (get_checklist())" else "no (catalog only)")
  if (!is.na(x$flowchart_template)) cat0("Flow diagram : ", x$flowchart_template, " (new_flowchart())")
  if (!is.na(x$doi %||% NA)) cat0("DOI          : ", x$doi)
  if (!is.na(x$equator_url %||% NA)) cat0("EQUATOR      : ", x$equator_url)
  files <- x$downloadable_files
  if (length(files)) {
    cat0("Source files : ", length(files))
    for (f in files) cat0("  - ", f$label %||% f$url, ": ", f$url)
  }
  invisible(x)
}
