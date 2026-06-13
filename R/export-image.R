# Image export for flow diagrams (PNG / SVG / PDF) via Graphviz -> SVG -> raster.

# Render a flowchart's DOT to an SVG string.
flowchart_svg <- function(x, background = "white") {
  if (!requireNamespace("DiagrammeR", quietly = TRUE) ||
    !requireNamespace("DiagrammeRsvg", quietly = TRUE)) {
    stop("Packages `DiagrammeR` and `DiagrammeRsvg` are required for image export. ",
      "Install them with install.packages(c(\"DiagrammeR\", \"DiagrammeRsvg\")).",
      call. = FALSE
    )
  }
  DiagrammeRsvg::export_svg(DiagrammeR::grViz(flowchart_dot(x, background = background)))
}

export_flowchart_image <- function(x, file, format = c("png", "svg", "pdf"),
                                   width = 1000, background = "white") {
  format <- match.arg(format)
  svg <- flowchart_svg(x, background = background)
  if (format == "svg") {
    writeLines(svg, file)
    return(invisible(file))
  }
  if (!requireNamespace("rsvg", quietly = TRUE)) {
    stop("Package `rsvg` is required to export ", format,
      ". Install it with install.packages(\"rsvg\").",
      call. = FALSE
    )
  }
  raw <- charToRaw(svg)
  switch(format,
    png = rsvg::rsvg_png(raw, file, width = width),
    pdf = rsvg::rsvg_pdf(raw, file)
  )
  invisible(file)
}
