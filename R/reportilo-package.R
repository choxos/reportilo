#' @details
#' The EQUATOR Network (Enhancing the QUAlity and Transparency Of health
#' Research) maintains the canonical library of reporting guidelines for health
#' research. `reportilo` turns that library into a working toolkit: a searchable
#' catalog of every guideline, machine-readable checklists for the major
#' families, and data-driven flow diagram templates.
#'
#' The package is organized around three verbs:
#' \itemize{
#'   \item \strong{Find} a guideline with `reportilo_guidelines()`,
#'     `search_guidelines()` and `guideline_info()`.
#'   \item \strong{Fill} a checklist with `get_checklist()` /
#'     `new_checklist()`, or a flow diagram with `new_flowchart()` and
#'     `set_counts()`.
#'   \item \strong{Export} the filled object to Word, Excel or an image with
#'     `reportilo_export()`.
#' }
#'
#' The data and the rendering logic are kept separate from the user interface so
#' that the same checklists and flow diagrams drive the package functions, the
#' bundled Shiny application ([launch_reportilo()]) and a companion browser
#' application.
#'
#' @section Data provenance:
#' Guideline metadata is derived from the EQUATOR Network reporting guideline
#' library. Checklist items are extracted from the guideline source documents;
#' each item records its provenance and a parse-confidence score, and the
#' coverage of each guideline is summarized in `parse_status`. Guidelines
#' without a machine-readable checklist remain available as catalog entries that
#' link to their original source.
#'
#' @references
#' EQUATOR Network. The EQUATOR Network: enhancing the quality and transparency
#' of health research. \url{https://www.equator-network.org/}
#'
#' @keywords internal
"_PACKAGE"

#' @importFrom utils packageVersion
NULL
