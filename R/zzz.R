# ggplot2 aes() column names referenced without .data (ggplot2 is Suggests, so
# its .data pronoun cannot be imported); declare them to satisfy R CMD check.
utils::globalVariables(c("x", "study", "color", "symbol", "domain", "judgment"))

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
