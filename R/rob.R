#' Risk-of-bias assessment tools
#'
#' List the supported risk-of-bias assessment tools (RoB 2, RoB 1, ROBINS-I,
#' ROBINS-E, QUADAS-2, QUIPS and the cluster RoB 2 variant).
#'
#' @return A data frame with `tool_id`, `name`, `study_type`, `n_domains` and the
#'   allowed judgment `levels`.
#' @seealso [reportilo_rob()], [rob_traffic_light()], [rob_summary()]
#' @examples
#' rob_tools_available()
#' @export
rob_tools_available <- function() {
  get_data("rob_tools")
}

#' Blank risk-of-bias template
#'
#' A blank wide table to fill in: one row per study, one column per domain (by
#' domain id) plus `Overall`. Pass the filled table to [reportilo_rob()].
#'
#' @param tool A `tool_id` (see [rob_tools_available()]).
#' @param n_studies Number of blank study rows to create (default 5).
#'
#' @return A data frame with a `Study` column, one column per domain id and an
#'   `Overall` column.
#' @examples
#' rob_template("rob2")
#' @export
rob_template <- function(tool, n_studies = 5) {
  doms <- rob_tool_domains(tool)
  cols <- c(doms$domain_id, "Overall")
  out <- data.frame(Study = sprintf("Study %d", seq_len(n_studies)), stringsAsFactors = FALSE)
  for (cc in cols) out[[cc]] <- NA_character_
  out
}

rob_tool_domains <- function(tool) {
  d <- get_data("rob_domains")
  d <- d[d$tool_id == tool, , drop = FALSE]
  if (!nrow(d)) {
    stop("Unknown RoB tool '", tool, "'. See rob_tools_available().", call. = FALSE)
  }
  d[order(d$domain_order), , drop = FALSE]
}

rob_tool_levels <- function(tool) {
  tools <- get_data("rob_tools")
  row <- tools[tools$tool_id == tool, , drop = FALSE]
  if (!nrow(row)) stop("Unknown RoB tool '", tool, "'.", call. = FALSE)
  strsplit(row$levels, "; ", fixed = TRUE)[[1]]
}

#' Create a risk-of-bias assessment
#'
#' Build a risk-of-bias object from a table of per-study, per-domain judgments,
#' ready to plot with [rob_traffic_light()] / [rob_summary()] or export with
#' [reportilo_export()].
#'
#' @param tool A `tool_id` (see [rob_tools_available()]).
#' @param data A wide data frame: a study-name column (`Study`) plus one column
#'   per domain id (and optionally `Overall`). If `NULL`, a bundled example for
#'   the tool is used. Get a blank one with [rob_template()].
#'
#' @return An object of class `reportilo_rob`.
#' @seealso [rob_traffic_light()], [rob_summary()], [reportilo_export()]
#' @examples
#' rob <- reportilo_rob("rob2")
#' rob
#' @export
reportilo_rob <- function(tool, data = NULL) {
  tools <- get_data("rob_tools")
  trow <- tools[tools$tool_id == tool, , drop = FALSE]
  if (!nrow(trow)) {
    stop("Unknown RoB tool '", tool, "'. See rob_tools_available().", call. = FALSE)
  }
  doms <- rob_tool_domains(tool)
  levels_ord <- rob_tool_levels(tool)
  dom_ids <- c(doms$domain_id, "Overall")

  if (is.null(data)) {
    ex <- get_data("rob_example")
    long <- ex[ex$tool_id == tool, c("study", "domain_id", "judgment")]
  } else {
    long <- rob_melt(data, dom_ids)
  }
  # validate judgments against the tool's levels (blank/NA allowed)
  bad <- setdiff(stats::na.omit(unique(long$judgment)), c(levels_ord, ""))
  if (length(bad)) {
    warning("Judgments not in the ", tool, " scale will plot as 'No information': ",
      paste(bad, collapse = ", "),
      call. = FALSE
    )
  }
  studies <- unique(long$study)
  structure(
    list(
      tool_id = tool,
      name = trow$name,
      study_type = trow$study_type,
      levels = levels_ord,
      domains = rbind(
        doms[, c("domain_id", "label", "domain_order")],
        data.frame(domain_id = "Overall", label = "Overall", domain_order = nrow(doms) + 1L)
      ),
      studies = studies,
      judgments = long
    ),
    class = "reportilo_rob"
  )
}

# Melt a wide judgment table (Study + domain columns) to long form.
rob_melt <- function(data, dom_ids) {
  data <- as.data.frame(data)
  study_col <- intersect(c("Study", "study"), names(data))[1]
  if (is.na(study_col)) stop("`data` must have a 'Study' column.", call. = FALSE)
  present <- intersect(dom_ids, names(data))
  if (!length(present)) {
    stop("`data` has no domain columns. Expected some of: ",
      paste(dom_ids, collapse = ", "), ".",
      call. = FALSE
    )
  }
  out <- do.call(rbind, lapply(present, function(dc) {
    data.frame(
      study = as.character(data[[study_col]]),
      domain_id = dc,
      judgment = as.character(data[[dc]]),
      stringsAsFactors = FALSE
    )
  }))
  out
}

# Wide representation (for xlsx/csv export and printing).
rob_wide <- function(x) {
  dom_ids <- x$domains$domain_id
  out <- data.frame(Study = x$studies, stringsAsFactors = FALSE)
  for (dc in dom_ids) {
    m <- x$judgments[x$judgments$domain_id == dc, ]
    out[[dc]] <- m$judgment[match(x$studies, m$study)]
  }
  out
}

# Attach color + symbol from the global level table.
rob_decorate <- function(judgments) {
  lev <- get_data("rob_levels")
  i <- match(judgments$judgment, lev$level)
  judgments$color <- lev$color[i]
  judgments$symbol <- lev$symbol[i]
  judgments$level_order <- lev$level_order[i]
  judgments$color[is.na(judgments$color)] <- "#cccccc"
  judgments$symbol[is.na(judgments$symbol)] <- ""
  judgments
}

#' @description
#' `as.data.frame()` returns the wide judgment table (one row per study, one
#' column per domain plus `Overall`).
#' @param x A `reportilo_rob` object.
#' @param row.names,optional Ignored; for S3 consistency.
#' @param ... Ignored.
#' @rdname reportilo_rob
#' @export
as.data.frame.reportilo_rob <- function(x, row.names = NULL, optional = FALSE, ...) { # nolint: object_name_linter.
  rob_wide(x)
}

#' @export
print.reportilo_rob <- function(x, ...) {
  cat(sprintf("<reportilo risk of bias> %s\n%d studies, %d domains\n",
    x$name, length(x$studies), nrow(x$domains) - 1L))
  print(rob_wide(x), row.names = FALSE)
  cat("Plot with rob_traffic_light() / rob_summary(); export with reportilo_export().\n")
  invisible(x)
}

#' Risk-of-bias traffic-light plot
#'
#' A study-by-domain grid of colored judgments (the classic robvis traffic
#' light), as a `ggplot`.
#'
#' @param x A `reportilo_rob` from [reportilo_rob()].
#'
#' @return A `ggplot` object.
#' @seealso [rob_summary()]
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' rob_traffic_light(reportilo_rob("rob2"))
#' @export
rob_traffic_light <- function(x) {
  if (!inherits(x, "reportilo_rob")) stop("`x` must be a reportilo_rob.", call. = FALSE)
  rob_require_ggplot2()
  jl <- rob_decorate(x$judgments)
  jl$x <- match(jl$domain_id, x$domains$domain_id)
  jl$study <- factor(jl$study, levels = rev(x$studies))
  overall_x <- which(x$domains$domain_id == "Overall")
  ggplot2::ggplot(jl, ggplot2::aes(x = x, y = study)) +
    ggplot2::geom_vline(xintercept = overall_x - 0.5, color = "grey80") +
    ggplot2::geom_point(ggplot2::aes(fill = color),
      shape = 21, size = 8, color = "grey40", stroke = 0.5) +
    ggplot2::geom_text(ggplot2::aes(label = symbol), fontface = "bold", size = 4) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_x_continuous(
      breaks = x$domains$domain_order, labels = x$domains$domain_id,
      position = "top", expand = ggplot2::expansion(add = 0.6)
    ) +
    ggplot2::labs(x = NULL, y = NULL, title = x$name,
      caption = paste(paste0(x$domains$domain_id, " = ", x$domains$label), collapse = "  |  ")) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(face = "bold"),
      plot.caption = ggplot2::element_text(hjust = 0, size = 7, color = "grey30")
    )
}

#' Risk-of-bias summary plot
#'
#' A stacked bar chart of the distribution of judgments across studies, per
#' domain (the robvis summary plot), as a `ggplot`.
#'
#' @param x A `reportilo_rob` from [reportilo_rob()].
#'
#' @return A `ggplot` object.
#' @seealso [rob_traffic_light()]
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' rob_summary(reportilo_rob("robins_i"))
#' @export
rob_summary <- function(x) {
  if (!inherits(x, "reportilo_rob")) stop("`x` must be a reportilo_rob.", call. = FALSE)
  rob_require_ggplot2()
  lev <- get_data("rob_levels")
  jl <- x$judgments[x$judgments$domain_id != "Overall", ]
  # Keep every study in the denominator: blank, NA or out-of-scale judgments
  # become a visible "Missing" category rather than being silently dropped.
  valid <- !is.na(jl$judgment) & jl$judgment %in% x$levels
  jl$judgment[!valid] <- "Missing"
  # order domains top-to-bottom and levels by severity within the tool
  jl$domain <- factor(jl$domain_id,
    levels = rev(x$domains$domain_id[x$domains$domain_id != "Overall"]))
  lvls <- c(x$levels, "Missing")
  jl$judgment <- factor(jl$judgment, levels = lvls)
  pal <- stats::setNames(lev$color[match(lvls, lev$level)], lvls)
  pal[["Missing"]] <- "#cccccc"
  ggplot2::ggplot(jl, ggplot2::aes(y = domain, fill = judgment)) +
    ggplot2::geom_bar(position = "fill", width = 0.7, color = "grey40", linewidth = 0.3) +
    ggplot2::scale_fill_manual(values = pal, drop = FALSE, name = NULL) +
    ggplot2::scale_x_continuous(labels = function(v) paste0(v * 100, "%"),
      expand = ggplot2::expansion(mult = c(0, 0.02))) +
    ggplot2::labs(x = NULL, y = NULL, title = x$name) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank(),
      legend.position = "bottom"
    )
}

rob_require_ggplot2 <- function() {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package `ggplot2` is required for risk-of-bias plots. ",
      "Install it with install.packages(\"ggplot2\").",
      call. = FALSE
    )
  }
}
