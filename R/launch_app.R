#' Launch the reportilo Shiny application
#'
#' Starts the bundled Shiny application, a point-and-click front end to the
#' package: browse the EQUATOR guideline catalog, fill in a reporting checklist
#' or a flow diagram, and download the result as Word, Excel or an image.
#'
#' The application requires the suggested packages `shiny`, `bslib` and `DT`.
#' Install them with `install.packages(c("shiny", "bslib", "DT"))` if they are
#' not already available.
#'
#' @param ... Additional arguments passed to [shiny::runApp()].
#'
#' @return Called for its side effect of launching the app; invisibly returns
#'   the value of [shiny::runApp()].
#'
#' @examplesIf interactive()
#' launch_reportilo()
#' @export
launch_reportilo <- function(...) {
  app_dir <- system.file("shiny-apps", "reportilo", package = "reportilo")
  if (app_dir == "") {
    stop(
      "Could not find the Shiny app directory. Try re-installing `reportilo`.",
      call. = FALSE
    )
  }
  for (pkg in c("shiny", "bslib", "DT")) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(
        "Package `", pkg, "` is required to run the app. Install it with ",
        "install.packages(\"", pkg, "\").",
        call. = FALSE
      )
    }
  }
  shiny::runApp(app_dir, ...)
}
