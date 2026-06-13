# Internal helpers.

# Load a bundled dataset by name without relying on lazy-data global bindings
# (keeps R CMD check happy and works under load_all and when installed).
get_data <- function(name) {
  e <- new.env(parent = emptyenv())
  utils::data(list = name, package = "reportilo", envir = e)
  e[[name]]
}

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0 || (length(a) == 1 && is.na(a))) b else a

# Resolve a guideline_id, allowing a case-insensitive acronym as a convenience.
resolve_guideline_id <- function(id) {
  g <- get_data("guidelines")
  if (id %in% g$guideline_id) {
    return(id)
  }
  hit <- which(tolower(g$acronym) == tolower(id))
  if (length(hit) == 1) {
    return(g$guideline_id[hit])
  }
  if (length(hit) > 1) {
    stop("Acronym '", id, "' matches several guidelines (",
      paste(g$guideline_id[hit], collapse = ", "),
      "). Use a guideline_id.",
      call. = FALSE
    )
  }
  stop("Unknown guideline '", id, "'. See reportilo_guidelines().", call. = FALSE)
}
