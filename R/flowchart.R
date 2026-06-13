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
  is_reason <- stats::setNames(x$fields$is_reasons, x$fields$count_field)
  for (nm in names(vals)) {
    v <- vals[[nm]]
    if (isTRUE(is_reason[[nm]])) {
      x$counts[[nm]] <- as.character(v)
      next
    }
    # numeric count fields: require a single non-negative integer
    num <- suppressWarnings(as.numeric(v))
    if (length(v) != 1L || is.na(num) || !is.finite(num) || num < 0 || num != round(num)) {
      stop("Count `", nm, "` must be a single non-negative whole number; got ",
        deparse(v), ".",
        call. = FALSE
      )
    }
    x$counts[[nm]] <- as.character(as.integer(num))
  }
  x
}

# Template-specific consistency rules. Each rule asserts a bound: the left-hand
# side (sum of `lhs` fields) must not exceed a right-hand side built from a
# `base` field plus `plus` fields minus `minus` fields. This catches impossible
# counts (more out than in) without flagging legitimately incomplete diagrams.
.rule <- function(op, lhs, base = NULL, minus = NULL, plus = NULL) {
  list(op = op, lhs = lhs, base = base, minus = minus, plus = plus)
}
.flowchart_rules <- list(
  prisma_2020 = list(
    .rule("le", "screened", base = "identified_db", minus = c("duplicates", "auto_removed", "other_removed")),
    .rule("le", "sought", base = "screened", minus = "excluded"),
    .rule("le", "assessed", base = "sought", minus = "not_retrieved"),
    .rule("le", "studies_included", base = "assessed")
  ),
  consort_2010 = list(
    .rule("le", "randomized", base = "assessed", minus = "excluded_total"),
    .rule("le", c("alloc_int", "alloc_ctrl"), base = "randomized"),
    .rule("le", "anal_int", base = "alloc_int"),
    .rule("le", "anal_ctrl", base = "alloc_ctrl")
  ),
  stard_2015 = list(
    .rule("le", "index_test", base = "eligible", minus = "no_index"),
    .rule("le", "reference", base = "index_test", minus = "no_reference"),
    .rule("le", "analyzed", base = "reference")
  ),
  cohort_study = list(
    .rule("le", c("exposed", "unexposed"), base = "assessed", minus = "excluded_total"),
    .rule("le", "exp_analyzed", base = "exposed"),
    .rule("le", "unexp_analyzed", base = "unexposed")
  ),
  case_control = list(
    .rule("le", "cases_eligible", base = "cases_identified"),
    .rule("le", "cases_enrolled", base = "cases_eligible", minus = "cases_excluded"),
    .rule("le", "cases_analyzed", base = "cases_enrolled"),
    .rule("le", "controls_eligible", base = "controls_identified"),
    .rule("le", "controls_enrolled", base = "controls_eligible", minus = "controls_excluded"),
    .rule("le", "controls_analyzed", base = "controls_enrolled")
  ),
  cross_sectional = list(
    .rule("le", "invited", base = "target", minus = "not_eligible"),
    .rule("le", "participated", base = "invited", minus = "nonresponse"),
    .rule("le", "analyzed", base = "participated")
  )
)

#' Check a flow diagram for count inconsistencies
#'
#' Apply template-specific accounting bounds, including flow invariants where the
#' template has explicit removal/exclusion counts: for example PRISMA *screened*
#' cannot exceed *identified - duplicates - automation - other*, and CONSORT
#' *randomized* cannot exceed *assessed - excluded*. Reason fields are ignored.
#' Bounds are checked (not strict equality), so a partially filled diagram is not
#' flagged.
#'
#' @param x A `reportilo_flowchart`.
#'
#' @return A character vector of issue messages (empty if the counts are
#'   consistent).
#' @examples
#' fc <- set_counts(new_flowchart("prisma_2020"), identified_db = 100, screened = 200)
#' flowchart_consistency(fc)
#' @export
flowchart_consistency <- function(x) {
  if (!inherits(x, "reportilo_flowchart")) {
    stop("`x` must be a reportilo_flowchart (see new_flowchart()).", call. = FALSE)
  }
  rules <- .flowchart_rules[[x$template_id]]
  if (is.null(rules)) {
    return(character(0))
  }
  num <- function(field) suppressWarnings(as.numeric(x$counts[[field]]))
  lab <- stats::setNames(x$fields$label, x$fields$count_field)
  nm <- function(f) lab[[f]] %||% f
  issues <- character(0)
  for (r in rules) {
    fields <- c(r$lhs, r$base, r$minus, r$plus)
    vals <- vapply(fields, num, numeric(1))
    if (anyNA(vals)) next
    lhs_val <- sum(vapply(r$lhs, num, numeric(1)))
    rhs_val <- (if (!is.null(r$base)) num(r$base) else 0) +
      (if (!is.null(r$plus)) sum(vapply(r$plus, num, numeric(1))) else 0) -
      (if (!is.null(r$minus)) sum(vapply(r$minus, num, numeric(1))) else 0)
    lhs_lab <- paste(vapply(r$lhs, nm, character(1)), collapse = " + ")
    rhs_lab <- nm(r$base %||% r$lhs[1])
    if (!is.null(r$plus)) rhs_lab <- paste(rhs_lab, "+", paste(vapply(r$plus, nm, character(1)), collapse = " + "))
    if (!is.null(r$minus)) rhs_lab <- paste(rhs_lab, "-", paste(vapply(r$minus, nm, character(1)), collapse = " - "))
    if (r$op == "le" && lhs_val > rhs_val) {
      issues <- c(issues, sprintf("%s (%d) exceeds %s (%d).",
        lhs_lab, as.integer(lhs_val), rhs_lab, as.integer(rhs_val)))
    } else if (r$op == "eq" && lhs_val != rhs_val) {
      issues <- c(issues, sprintf("%s (%d) should equal %s (%d).",
        lhs_lab, as.integer(lhs_val), rhs_lab, as.integer(rhs_val)))
    }
  }
  issues
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
