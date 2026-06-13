#' Export a checklist or flow diagram to a file
#'
#' Write a filled [reportilo_checklist][get_checklist] or
#' [reportilo_flowchart][new_flowchart] to Word, Excel, an image, or CSV. The
#' output format is taken from `format`, or inferred from the file extension.
#'
#' Supported formats:
#' \describe{
#'   \item{Checklist}{`docx`, `xlsx`, `csv`.}
#'   \item{Flow diagram}{`png`, `svg`, `pdf`, `docx`, `xlsx` (the counts), `csv`
#'     (the counts).}
#'   \item{Risk of bias}{`png`, `svg`, `pdf`, `docx`, `xlsx` (the table), `csv`
#'     (the table). Pass `type = "traffic_light"` (default) or `type = "summary"`.}
#' }
#'
#' Word and Excel export need the suggested packages `officer` + `flextable` and
#' `openxlsx` respectively; image export needs `DiagrammeR`, `DiagrammeRsvg` and
#' `rsvg`.
#'
#' @param x A `reportilo_checklist`, `reportilo_flowchart` or `reportilo_rob`.
#' @param file Output file path. Its extension sets the format unless `format` is
#'   given.
#' @param format Optional explicit format (e.g. `"docx"`). Defaults to the file
#'   extension.
#' @param ... Passed to the underlying writer. For flow diagrams: `width` (image
#'   pixel width) and `background` (`"white"` or `"transparent"`).
#'
#' @return The output `file` path, invisibly.
#' @seealso [get_checklist()], [new_flowchart()]
#' @examplesIf requireNamespace("officer", quietly = TRUE)
#' chk <- get_checklist("strobe")
#' reportilo_export(chk, tempfile(fileext = ".docx"))
#'
#' fc <- set_counts(new_flowchart("prisma_2020"), identified_db = 1200)
#' reportilo_export(fc, tempfile(fileext = ".csv"))
#' @export
reportilo_export <- function(x, file, format = NULL, ...) {
  fmt <- tolower(format %||% tools::file_ext(file))
  if (!nzchar(fmt)) {
    stop("Could not determine the output format. ",
      "Give a file with an extension or set `format`.",
      call. = FALSE
    )
  }
  if (inherits(x, "reportilo_checklist")) {
    switch(fmt,
      docx = export_checklist_docx(x, file),
      xlsx = export_checklist_xlsx(x, file),
      csv = utils::write.csv(as.data.frame(x), file, row.names = FALSE),
      stop("Unsupported checklist format '", fmt, "'. Use docx, xlsx or csv.",
        call. = FALSE
      )
    )
    return(invisible(file))
  }
  if (inherits(x, "reportilo_rob")) {
    switch(fmt,
      png = ,
      svg = ,
      pdf = export_rob_image(x, file, format = fmt, ...),
      docx = export_rob_docx(x, file, ...),
      xlsx = export_rob_xlsx(x, file),
      csv = utils::write.csv(rob_wide(x), file, row.names = FALSE),
      stop("Unsupported risk-of-bias format '", fmt,
        "'. Use png, svg, pdf, docx, xlsx or csv.",
        call. = FALSE
      )
    )
    return(invisible(file))
  }
  if (inherits(x, "reportilo_flowchart")) {
    switch(fmt,
      png = ,
      svg = ,
      pdf = export_flowchart_image(x, file, format = fmt, ...),
      docx = export_flowchart_docx(x, file, ...),
      xlsx = export_flowchart_xlsx(x, file),
      csv = utils::write.csv(flowchart_counts_df(x), file, row.names = FALSE),
      stop("Unsupported flow diagram format '", fmt,
        "'. Use png, svg, pdf, docx, xlsx or csv.",
        call. = FALSE
      )
    )
    return(invisible(file))
  }
  stop("`x` must be a reportilo_checklist, reportilo_flowchart or reportilo_rob.",
    call. = FALSE
  )
}
