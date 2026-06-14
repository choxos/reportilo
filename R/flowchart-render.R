#' Build the Graphviz DOT for a flow diagram
#'
#' Turn a `reportilo_flowchart` into a Graphviz DOT string, substituting the
#' filled counts into the box labels. This is the shared core used by
#' [render_flowchart()] and by the image/Word exporters.
#'
#' @param x A `reportilo_flowchart`.
#' @param background Diagram background color. Use `"white"` (default) for a solid
#'   white background, or `"transparent"` for no background (useful for slides and
#'   figures). Any Graphviz color name or hex value is accepted.
#'
#' @return A length-one character string of Graphviz DOT.
#' @examples
#' fc <- new_flowchart("stard_2015")
#' cat(substr(flowchart_dot(fc), 1, 80))
#' cat(substr(flowchart_dot(fc, background = "transparent"), 1, 80))
#' @export
flowchart_dot <- function(x, background = "white") {
  if (!inherits(x, "reportilo_flowchart")) {
    stop("`x` must be a reportilo_flowchart (see new_flowchart()).", call. = FALSE)
  }
  stopifnot(is.character(background), length(background) == 1L)
  nodes <- x$nodes
  nodes <- nodes[nodes$role != "stage_title", , drop = FALSE]
  edges <- x$edges
  counts <- x$counts

  # Escape a user-supplied value before it goes into a DOT label: backslash first
  # (so the escapes added next are not doubled), then quotes, then real line
  # breaks to Graphviz's "\n", tabs to spaces, then drop control characters. This
  # is applied to the substituted values only, never to the authored template, so
  # the template's own "\n" line breaks survive while a free-text reason field
  # cannot break the DOT or inject attributes.
  esc_val <- function(s) {
    s <- gsub("\\", "\\\\", s, fixed = TRUE)
    s <- gsub('"', '\\"', s, fixed = TRUE)
    s <- gsub("\r\n|\r|\n", "\\\\n", s)
    s <- gsub("\t", " ", s, fixed = TRUE)
    gsub("[[:cntrl:]]", "", s)
  }
  subst <- function(tmpl) {
    for (f in names(counts)) {
      val <- counts[[f]]
      if (is.null(val) || is.na(val) || !nzchar(val)) val <- "0"
      frag <- esc_val(as.character(val))
      # reason lists are entered as "A (n = 1); B (n = 2)"; put each reason on its
      # own line instead of one long line, dropping empties (counts have no ";")
      parts <- trimws(strsplit(frag, ";[[:space:]]*")[[1]])
      parts <- parts[nzchar(parts)]
      if (length(parts) > 1) frag <- paste(parts, collapse = "\\n")
      # fixed = TRUE takes the replacement literally, so inject the already
      # escaped fragment as-is (no backslash doubling)
      tmpl <- gsub(paste0("{", f, "}"), frag, tmpl, fixed = TRUE)
    }
    tmpl
  }

  node_lines <- character(0)
  for (i in seq_len(nrow(nodes))) {
    lbl <- subst(nodes$label_template[i])
    fill <- nodes$fill[i]
    if (is.na(fill) || !nzchar(fill)) fill <- "#ffffff"
    style <- if (nodes$role[i] == "exclusion_box") "\"filled,rounded,dashed\"" else "\"filled,rounded\""
    node_lines <- c(node_lines, sprintf(
      '"%s" [label="%s", fillcolor="%s", style=%s];',
      nodes$node_id[i], lbl, fill, style
    ))
  }

  # nodes that share a (stage_order, node_order) cell sit on the same rank,
  # ordered left -> right by side
  side_rank <- c(title = 0, left = 1, main = 2, right = 3)
  key <- paste(nodes$stage_order, nodes$node_order, sep = "_")
  rank_lines <- character(0)
  for (k in unique(key)) {
    grp <- nodes[key == k, , drop = FALSE]
    if (nrow(grp) < 2) next
    grp <- grp[order(side_rank[grp$side]), , drop = FALSE]
    rank_lines <- c(rank_lines, sprintf(
      "{rank=same; %s}", paste(sprintf('"%s"', grp$node_id), collapse = "; ")
    ))
  }

  edge_lines <- character(0)
  for (i in seq_len(nrow(edges))) {
    extra <- if (edges$edge_type[i] == "exclude") " [constraint=false]" else ""
    edge_lines <- c(edge_lines, sprintf(
      '"%s" -> "%s"%s;', edges$from_node[i], edges$to_node[i], extra
    ))
  }

  paste(c(
    "digraph reportilo {",
    sprintf(
      "  graph [rankdir=TB, splines=ortho, nodesep=0.45, ranksep=0.55, bgcolor=\"%s\"];",
      background
    ),
    '  node [shape=box, fontname="Helvetica", fontsize=10, margin="0.14,0.09"];',
    "  edge [arrowsize=0.7];",
    paste0("  ", node_lines),
    paste0("  ", rank_lines),
    paste0("  ", edge_lines),
    "}"
  ), collapse = "\n")
}

#' Render a flow diagram for viewing
#'
#' Render a `reportilo_flowchart` as an interactive Graphviz widget (for use in
#' the console, RStudio Viewer, R Markdown or Shiny). To save to a file, use
#' `reportilo_export()`.
#'
#' @param x A `reportilo_flowchart`.
#' @param background Diagram background color (default `"white"`; use
#'   `"transparent"` for no background).
#'
#' @return A `DiagrammeR` `grViz` htmlwidget.
#' @seealso `reportilo_export()`, [flowchart_dot()]
#' @examplesIf requireNamespace("DiagrammeR", quietly = TRUE)
#' fc <- new_flowchart("prisma_2020")
#' render_flowchart(fc)
#' @export
render_flowchart <- function(x, background = "white") {
  if (!requireNamespace("DiagrammeR", quietly = TRUE)) {
    stop("Package `DiagrammeR` is required to render flow diagrams. ",
      "Install it with install.packages(\"DiagrammeR\").",
      call. = FALSE
    )
  }
  DiagrammeR::grViz(flowchart_dot(x, background = background))
}
