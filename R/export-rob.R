# Export for risk-of-bias assessments: traffic-light / summary plots to image or
# Word, and the judgment table to Excel / CSV.

rob_plot <- function(x, type = c("traffic_light", "summary")) {
  type <- match.arg(type)
  if (type == "summary") rob_summary(x) else rob_traffic_light(x)
}

# Sensible plot dimensions (inches) given the assessment size.
rob_dims <- function(x, type) {
  n_studies <- length(x$studies)
  n_domains <- nrow(x$domains)
  if (type == "summary") {
    c(width = 8, height = max(2.2, 1.4 + 0.45 * (n_domains - 1)))
  } else {
    c(width = max(4, 2 + 0.8 * n_domains), height = max(2.5, 1.6 + 0.45 * n_studies))
  }
}

export_rob_image <- function(x, file, format = c("png", "svg", "pdf"),
                             type = c("traffic_light", "summary"), width = NULL,
                             height = NULL, background = "white") {
  format <- match.arg(format)
  type <- match.arg(type)
  rob_require_ggplot2()
  if (format == "svg" && !requireNamespace("svglite", quietly = TRUE)) {
    stop("Package `svglite` is required to export RoB plots as SVG. ",
      "Install it with install.packages(\"svglite\"), or use png/pdf.",
      call. = FALSE
    )
  }
  p <- rob_plot(x, type)
  if (identical(background, "transparent")) {
    p <- p + ggplot2::theme(rect = ggplot2::element_rect(fill = "transparent", colour = NA))
  }
  d <- rob_dims(x, type)
  ggplot2::ggsave(
    filename = file, plot = p,
    width = width %||% unname(d["width"]), height = height %||% unname(d["height"]),
    dpi = 300, bg = background, limitsize = FALSE
  )
  invisible(file)
}

export_rob_docx <- function(x, file, type = c("traffic_light", "summary"), width = NULL,
                            background = "white") {
  type <- match.arg(type)
  require_officer()
  png <- tempfile(fileext = ".png")
  on.exit(unlink(png), add = TRUE)
  export_rob_image(x, png, format = "png", type = type, width = width, background = background)
  d <- rob_dims(x, type)
  w_in <- min(6.5, unname(d["width"]))
  h_in <- w_in * (unname(d["height"]) / unname(d["width"]))
  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, paste0(x$name, " - risk of bias"), style = "heading 1")
  doc <- officer::body_add_img(doc, src = png, width = w_in, height = h_in)
  print(doc, target = file)
  invisible(file)
}

export_rob_xlsx <- function(x, file) {
  require_openxlsx()
  wb <- openxlsx::createWorkbook()
  sheet <- "Risk of bias"
  openxlsx::addWorksheet(wb, sheet)
  hs <- openxlsx::createStyle(textDecoration = "bold", fgFill = "#0E3A5F", fontColour = "#FFFFFF")
  openxlsx::writeData(wb, sheet, rob_wide(x), headerStyle = hs)
  openxlsx::setColWidths(wb, sheet, cols = 1:(nrow(x$domains) + 1), widths = "auto")
  openxlsx::saveWorkbook(wb, file, overwrite = TRUE)
  invisible(file)
}
