.onAttach <- function(libname, pkgname) {
  version <- packageVersion(pkgname)
  packageStartupMessage(sprintf(
    paste0(
      "reportilo %s: fill in and export EQUATOR reporting guidelines and flow diagrams.\n",
      "Browse guidelines with reportilo_guidelines(); launch the app with launch_reportilo().\n",
      "Docs: https://choxos.github.io/reportilo/ | GitHub: https://github.com/choxos/reportilo"
    ),
    version
  ))
  invisible()
}
