# Word (.docx) export for checklists and flow diagrams via officer + flextable.

require_officer <- function() {
  if (!requireNamespace("officer", quietly = TRUE)) {
    stop("Package `officer` is required for Word export. ",
      "Install it with install.packages(\"officer\").",
      call. = FALSE
    )
  }
}

checklist_flextable <- function(x) {
  if (!requireNamespace("flextable", quietly = TRUE)) {
    stop("Package `flextable` is required for Word checklist export. ",
      "Install it with install.packages(\"flextable\").",
      call. = FALSE
    )
  }
  df <- as.data.frame(x)[, c("section", "item_no", "item_text", "response"), drop = FALSE]
  df$response[is.na(df$response)] <- ""
  ft <- flextable::flextable(df)
  ft <- flextable::set_header_labels(ft,
    section = "Section", item_no = "Item", item_text = "Checklist item",
    response = "Reported (page)"
  )
  ft <- flextable::theme_booktabs(ft)
  ft <- flextable::width(ft, j = "section", width = 1.3)
  ft <- flextable::width(ft, j = "item_no", width = 0.5)
  ft <- flextable::width(ft, j = "item_text", width = 4.2)
  ft <- flextable::width(ft, j = "response", width = 1.2)
  ft <- flextable::valign(ft, valign = "top", part = "all")
  ft <- flextable::fontsize(ft, size = 9, part = "all")
  ft
}

export_checklist_docx <- function(x, file) {
  require_officer()
  title <- attr(x, "title") %||% attr(x, "guideline_id")
  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, paste0(title, " reporting checklist"), style = "heading 1")
  doc <- officer::body_add_par(doc, "", style = "Normal")
  doc <- flextable::body_add_flextable(doc, checklist_flextable(x))
  print(doc, target = file)
  invisible(file)
}

export_flowchart_docx <- function(x, file, width = 1400) {
  require_officer()
  svg <- flowchart_svg(x)
  # aspect ratio from the SVG canvas (no png dependency)
  m <- regmatches(svg, regexec('width="([0-9.]+)pt"[^>]*height="([0-9.]+)pt"', svg))[[1]]
  aspect <- if (length(m) == 3) as.numeric(m[3]) / as.numeric(m[2]) else 1.3
  if (!requireNamespace("rsvg", quietly = TRUE)) {
    stop("Package `rsvg` is required for Word flow diagram export. ",
      "Install it with install.packages(\"rsvg\").",
      call. = FALSE
    )
  }
  png <- tempfile(fileext = ".png")
  on.exit(unlink(png), add = TRUE)
  rsvg::rsvg_png(charToRaw(svg), png, width = width)
  w_in <- 6.5
  h_in <- min(8.5, w_in * aspect)
  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, x$name, style = "heading 1")
  doc <- officer::body_add_img(doc, src = png, width = w_in, height = h_in)
  print(doc, target = file)
  invisible(file)
}
