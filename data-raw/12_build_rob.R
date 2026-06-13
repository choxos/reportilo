#!/usr/bin/env Rscript
# 12_build_rob.R
# Build the risk-of-bias (RoB) assessment data model: the supported tools, their
# domains, the judgment levels (colors + symbols, following robvis), and an
# example dataset per tool. Powers rob_traffic_light() / rob_summary() in the
# package, the Shiny RoB tab and the browser app. Self-contained: writes data/
# and inst/extdata/rob.json directly. Run after 00..11 (added to run_all.R).

here <- function(...) file.path("data-raw", ...)

# ---- judgment levels (global): color + symbol, following robvis -----------
rob_levels <- data.frame(
  level = c(
    "Low", "Some concerns", "Moderate", "Unclear",
    "Serious", "High", "Critical", "Very high", "No information"
  ),
  color = c(
    "#02C100", "#E2DF07", "#E2DF07", "#E2DF07",
    "#BF0000", "#BF0000", "#993404", "#993404", "#4EA1F7"
  ),
  symbol = c("+", "?", "?", "?", "x", "x", "!", "!", "?"),
  # severity rank used to order the stacked summary bars
  level_order = c(1L, 2L, 2L, 2L, 3L, 3L, 4L, 4L, 5L),
  stringsAsFactors = FALSE
)

# ---- tools and their domains ----------------------------------------------
# Each tool: id, display name, study type, ordered judgment levels, and the
# ordered domains (D-id + full label).
tool_defs <- list(
  rob2 = list(
    name = "RoB 2 (randomized trials)", study_type = "Randomized trial",
    levels = c("Low", "Some concerns", "High"),
    domains = c(
      D1 = "Bias arising from the randomization process",
      D2 = "Bias due to deviations from intended interventions",
      D3 = "Bias due to missing outcome data",
      D4 = "Bias in measurement of the outcome",
      D5 = "Bias in selection of the reported result"
    )
  ),
  rob2_cluster = list(
    name = "RoB 2 (cluster-randomized trials)", study_type = "Cluster-randomized trial",
    levels = c("Low", "Some concerns", "High"),
    domains = c(
      D1 = "Bias arising from the randomization process",
      D1b = "Bias arising from the timing of identification and recruitment of participants",
      D2 = "Bias due to deviations from intended interventions",
      D3 = "Bias due to missing outcome data",
      D4 = "Bias in measurement of the outcome",
      D5 = "Bias in selection of the reported result"
    )
  ),
  rob1 = list(
    name = "RoB 1 (Cochrane)", study_type = "Randomized trial",
    levels = c("Low", "Unclear", "High"),
    domains = c(
      D1 = "Random sequence generation",
      D2 = "Allocation concealment",
      D3 = "Blinding of participants and personnel",
      D4 = "Blinding of outcome assessment",
      D5 = "Incomplete outcome data",
      D6 = "Selective reporting",
      D7 = "Other sources of bias"
    )
  ),
  robins_i = list(
    name = "ROBINS-I (non-randomized interventions)", study_type = "Non-randomized intervention study",
    levels = c("Low", "Moderate", "Serious", "Critical", "No information"),
    domains = c(
      D1 = "Bias due to confounding",
      D2 = "Bias due to selection of participants",
      D3 = "Bias in classification of interventions",
      D4 = "Bias due to deviations from intended interventions",
      D5 = "Bias due to missing data",
      D6 = "Bias in measurement of outcomes",
      D7 = "Bias in selection of the reported result"
    )
  ),
  robins_e = list(
    name = "ROBINS-E (exposures)", study_type = "Non-randomized exposure study",
    levels = c("Low", "Some concerns", "High", "Very high", "No information"),
    domains = c(
      D1 = "Bias due to confounding",
      D2 = "Bias arising from measurement of the exposure",
      D3 = "Bias in selection of participants into the study",
      D4 = "Bias due to post-exposure interventions",
      D5 = "Bias due to missing data",
      D6 = "Bias arising from measurement of the outcome",
      D7 = "Bias in selection of the reported result"
    )
  ),
  quadas2 = list(
    name = "QUADAS-2 (diagnostic accuracy)", study_type = "Diagnostic accuracy study",
    levels = c("Low", "Unclear", "High"),
    domains = c(
      D1 = "Patient selection",
      D2 = "Index test",
      D3 = "Reference standard",
      D4 = "Flow and timing"
    )
  ),
  quips = list(
    name = "QUIPS (prognostic factors)", study_type = "Prognostic study",
    levels = c("Low", "Moderate", "High"),
    domains = c(
      D1 = "Study participation",
      D2 = "Study attrition",
      D3 = "Prognostic factor measurement",
      D4 = "Outcome measurement",
      D5 = "Study confounding",
      D6 = "Statistical analysis and reporting"
    )
  )
)

rob_tools <- do.call(rbind, lapply(names(tool_defs), function(id) {
  td <- tool_defs[[id]]
  data.frame(
    tool_id = id, name = td$name, study_type = td$study_type,
    n_domains = length(td$domains), levels = paste(td$levels, collapse = "; "),
    stringsAsFactors = FALSE
  )
}))

rob_domains <- do.call(rbind, lapply(names(tool_defs), function(id) {
  td <- tool_defs[[id]]
  data.frame(
    tool_id = id,
    domain_id = names(td$domains),
    label = unname(td$domains),
    domain_order = seq_along(td$domains),
    stringsAsFactors = FALSE
  )
}))

# ---- example dataset per tool (deterministic, 6 studies) ------------------
rob_example <- do.call(rbind, lapply(names(tool_defs), function(id) {
  td <- tool_defs[[id]]
  lv <- td$levels
  studies <- sprintf("Study %d", seq_len(6))
  rows <- list()
  for (si in seq_along(studies)) {
    worst <- 1L
    for (di in seq_along(td$domains)) {
      k <- ((si + di) %% length(lv)) + 1L
      worst <- max(worst, k)
      rows[[length(rows) + 1L]] <- data.frame(
        tool_id = id, study = studies[si],
        domain_id = names(td$domains)[di], judgment = lv[k],
        stringsAsFactors = FALSE
      )
    }
    rows[[length(rows) + 1L]] <- data.frame(
      tool_id = id, study = studies[si],
      domain_id = "Overall", judgment = lv[worst],
      stringsAsFactors = FALSE
    )
  }
  do.call(rbind, rows)
}))

usethis::use_data(rob_tools, rob_domains, rob_levels, rob_example,
  overwrite = TRUE, compress = "xz"
)

# JSON for the browser app
suppressPackageStartupMessages(library(jsonlite))
outdir <- file.path("inst", "extdata")
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)
write_json(
  list(tools = rob_tools, domains = rob_domains, levels = rob_levels, example = rob_example),
  file.path(outdir, "rob.json"),
  auto_unbox = TRUE, na = "null", pretty = FALSE
)

cat(sprintf(
  "RoB data: %d tools, %d domains, %d levels, %d example rows\n",
  nrow(rob_tools), nrow(rob_domains), nrow(rob_levels), nrow(rob_example)
))
print(rob_tools[, c("tool_id", "n_domains")])
