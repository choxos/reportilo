#' Get a fillable reporting checklist
#'
#' Return the checklist for a guideline as a fillable table: one row per item,
#' with an empty `response` column for you to record the page number (or other
#' response) where each item is addressed.
#'
#' @param id A `guideline_id` (or an unambiguous acronym). See
#'   [reportilo_guidelines()].
#'
#' @return An object of class `reportilo_checklist` (a data frame with columns
#'   `item_no`, `section`, `item_text`, `response`), or `NULL` (invisibly) if the
#'   guideline has no bundled checklist.
#' @seealso [validate_checklist()], `reportilo_export()`
#' @examples
#' chk <- get_checklist("prisma-2020")
#' head(chk)
#' chk$response[1:3] <- c("p1", "p2", "p2")
#' @export
get_checklist <- function(id) {
  id <- resolve_guideline_id(id)
  ci <- get_data("checklist_items")
  sub <- ci[ci$guideline_id == id, , drop = FALSE]
  if (!nrow(sub)) {
    message(
      "No bundled checklist for '", id, "'. ",
      "It is a catalog entry; see guideline_info(\"", id, "\") for source links."
    )
    return(invisible(NULL))
  }
  sub <- sub[order(sub$item_order), , drop = FALSE]
  g <- get_data("guidelines")
  title <- g$title[g$guideline_id == id]
  out <- data.frame(
    item_no = sub$item_no,
    section = sub$section,
    item_text = sub$item_text,
    response = NA_character_,
    stringsAsFactors = FALSE
  )
  structure(out,
    class = c("reportilo_checklist", "data.frame"),
    guideline_id = id,
    title = if (length(title)) title else id,
    response_type = sub$response_type[1],
    verified = isTRUE(unique(sub$is_override)[1])
  )
}

#' @rdname get_checklist
#' @export
new_checklist <- function(id) get_checklist(id)

#' Validate a filled checklist
#'
#' Report how complete a `reportilo_checklist` is (how many items have a
#' response) and check that its structure is intact.
#'
#' @param x A `reportilo_checklist`, e.g. from [get_checklist()].
#'
#' @return Invisibly, a list with `n_items`, `n_filled` and `complete`. Called
#'   mainly for the message it prints.
#' @examples
#' chk <- get_checklist("strobe")
#' validate_checklist(chk)
#' @export
validate_checklist <- function(x) {
  if (!inherits(x, "reportilo_checklist")) {
    stop("`x` must be a reportilo_checklist (see get_checklist()).", call. = FALSE)
  }
  req <- c("item_no", "section", "item_text", "response")
  if (!all(req %in% names(x))) {
    stop("Checklist is missing columns: ", paste(setdiff(req, names(x)), collapse = ", "),
      call. = FALSE
    )
  }
  n_items <- nrow(x)
  n_filled <- sum(!is.na(x$response) & nzchar(trimws(x$response)))
  complete <- n_filled == n_items
  message(sprintf(
    "%s: %d of %d items completed%s.",
    attr(x, "guideline_id"), n_filled, n_items,
    if (complete) " (complete)" else ""
  ))
  invisible(list(n_items = n_items, n_filled = n_filled, complete = complete))
}

#' @export
print.reportilo_checklist <- function(x, ...) {
  cat(sprintf(
    "<reportilo checklist> %s%s\n%s\n",
    attr(x, "guideline_id"),
    if (isTRUE(attr(x, "verified"))) " (verified)" else "",
    attr(x, "title") %||% ""
  ))
  print(as.data.frame(x), right = FALSE, ...)
  invisible(x)
}
