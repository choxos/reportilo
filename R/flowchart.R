#' Create a fillable flow diagram
#'
#' Start a flow diagram from one of the bundled templates (PRISMA 2020, CONSORT
#' 2010 or STARD 2015). Fill in the counts with [set_counts()] and render or
#' export it with [render_flowchart()] / `reportilo_export()`.
#'
#' @param template A template id: `"prisma_2020"`, `"consort_2010"` or
#'   `"stard_2015"`. See [flowchart_templates].
#'
#' @return An object of class `reportilo_flowchart`.
#' @seealso [set_counts()], [flowchart_fields()], [render_flowchart()]
#' @examples
#' fc <- new_flowchart("prisma_2020")
#' fc <- set_counts(fc, identified_db = 1200, screened = 980, excluded = 700)
#' fc
#' @export
new_flowchart <- function(template) {
  tpl <- get_data("flowchart_templates")
  if (!template %in% tpl$template_id) {
    stop("Unknown template '", template, "'. Available: ",
      paste(tpl$template_id, collapse = ", "), ".",
      call. = FALSE
    )
  }
  nodes <- get_data("flowchart_nodes")
  edges <- get_data("flowchart_edges")
  cnt <- get_data("flowchart_counts")
  nodes <- nodes[nodes$template_id == template, , drop = FALSE]
  edges <- edges[edges$template_id == template, , drop = FALSE]
  cnt <- cnt[cnt$template_id == template, , drop = FALSE]
  cnt <- cnt[order(cnt$field_order), , drop = FALSE]
  structure(
    list(
      template_id = template,
      name = tpl$name[tpl$template_id == template],
      guideline_id = tpl$guideline_id[tpl$template_id == template],
      nodes = nodes,
      edges = edges,
      fields = cnt,
      counts = stats::setNames(as.list(cnt$value), cnt$count_field)
    ),
    class = "reportilo_flowchart"
  )
}

#' List the fillable fields of a flow diagram template
#'
#' @param template A template id (see [new_flowchart()]) or a
#'   `reportilo_flowchart` object.
#'
#' @return A data frame with `count_field`, `label`, `is_reasons` and the example
#'   default `value`.
#' @examples
#' flowchart_fields("consort_2010")
#' @export
flowchart_fields <- function(template) {
  if (inherits(template, "reportilo_flowchart")) {
    return(template$fields[, c("count_field", "label", "is_reasons", "value")])
  }
  fc <- new_flowchart(template)
  fc$fields[, c("count_field", "label", "is_reasons", "value")]
}

#' Set counts on a flow diagram
#'
#' Fill in one or more numeric counts (or reason lists) by field name. Unknown
#' field names raise an error; use [flowchart_fields()] to see valid names.
#'
#' @param x A `reportilo_flowchart` from [new_flowchart()].
#' @param ... Named values, e.g. `screened = 980, excluded = 700`. Reason fields
#'   take a string like `"Reason 1 (n = 5); Reason 2 (n = 3)"`.
#'
#' @return The updated `reportilo_flowchart`.
#' @examples
#' fc <- new_flowchart("consort_2010")
#' fc <- set_counts(fc, assessed = 200, randomized = 150)
#' @export
set_counts <- function(x, ...) {
  if (!inherits(x, "reportilo_flowchart")) {
    stop("`x` must be a reportilo_flowchart (see new_flowchart()).", call. = FALSE)
  }
  vals <- list(...)
  if (!length(vals)) {
    return(x)
  }
  if (is.null(names(vals)) || any(!nzchar(names(vals)))) {
    stop("All arguments to set_counts() must be named.", call. = FALSE)
  }
  bad <- setdiff(names(vals), names(x$counts))
  if (length(bad)) {
    stop("Unknown field(s): ", paste(bad, collapse = ", "),
      ". See flowchart_fields(\"", x$template_id, "\").",
      call. = FALSE
    )
  }
  for (nm in names(vals)) x$counts[[nm]] <- as.character(vals[[nm]])
  x
}

#' @export
print.reportilo_flowchart <- function(x, ...) {
  cat(sprintf("<reportilo flowchart> %s (%s)\n", x$name, x$template_id))
  f <- x$fields
  vals <- vapply(f$count_field, function(k) as.character(x$counts[[k]]), character(1))
  df <- data.frame(field = f$count_field, label = f$label, value = vals, stringsAsFactors = FALSE)
  print(df, right = FALSE, row.names = FALSE)
  cat("Render with render_flowchart() or export with reportilo_export().\n")
  invisible(x)
}
