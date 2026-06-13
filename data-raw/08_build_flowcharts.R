#!/usr/bin/env Rscript
# 08_build_flowcharts.R
# Build the generic flow diagram data model: one set of node/edge/count tables
# that represents PRISMA 2020, CONSORT 2010 and STARD 2015 as templates. The
# renderer (R/flowchart-render.R) turns these into Graphviz DOT. Labels embed
# {count_field} tokens that are substituted with user-supplied values.

here <- function(...) file.path("data-raw", ...)

nodes <- list()
edges <- list()
counts <- list()

add_node <- function(template_id, node_id, stage, stage_order, node_order, role,
                     label_template, side = "main", fill = NA_character_,
                     tooltip = NA_character_) {
  nodes[[length(nodes) + 1L]] <<- data.frame(
    template_id, node_id, stage, stage_order, node_order, role,
    label_template, side, fill, tooltip, stringsAsFactors = FALSE
  )
}
add_edge <- function(template_id, from_node, to_node, edge_type = "flow", style = "solid") {
  edges[[length(edges) + 1L]] <<- data.frame(
    template_id, from_node, to_node, edge_type, style, stringsAsFactors = FALSE
  )
}
add_count <- function(template_id, count_field, label, value = 0, field_order = NA,
                      is_reasons = FALSE) {
  counts[[length(counts) + 1L]] <<- data.frame(
    template_id, count_field, label, value = as.character(value),
    field_order, is_reasons, stringsAsFactors = FALSE
  )
}

# ============================ PRISMA 2020 ==================================
# Standard "databases and registers" flow diagram.
tp <- "prisma_2020"
add_node(tp, "title_id", "Identification", 1, 0, "stage_title", "Identification", "title", "#94c4df")
add_node(tp, "title_scr", "Screening", 2, 0, "stage_title", "Screening", "title", "#94c4df")
add_node(tp, "title_inc", "Included", 3, 0, "stage_title", "Included", "title", "#94c4df")

add_node(tp, "identified", "Identification", 1, 1, "count_box",
  "Records identified from\\ndatabases and registers\\n(n = {identified_db})", "main", "#fde9b8")
add_node(tp, "removed", "Identification", 1, 1, "exclusion_box",
  "Records removed before screening:\\nDuplicate records removed (n = {duplicates})\\nRecords marked ineligible by\\nautomation tools (n = {auto_removed})\\nRecords removed for other\\nreasons (n = {other_removed})", "right", "#fde9b8")
add_node(tp, "screened", "Screening", 2, 1, "count_box",
  "Records screened\\n(n = {screened})", "main", "#d7e8f2")
add_node(tp, "excluded", "Screening", 2, 1, "exclusion_box",
  "Records excluded\\n(n = {excluded})", "right", "#d7e8f2")
add_node(tp, "sought", "Screening", 2, 2, "count_box",
  "Reports sought for retrieval\\n(n = {sought})", "main", "#d7e8f2")
add_node(tp, "not_retrieved", "Screening", 2, 2, "exclusion_box",
  "Reports not retrieved\\n(n = {not_retrieved})", "right", "#d7e8f2")
add_node(tp, "assessed", "Screening", 2, 3, "count_box",
  "Reports assessed for eligibility\\n(n = {assessed})", "main", "#d7e8f2")
add_node(tp, "reports_excluded", "Screening", 2, 3, "exclusion_box",
  "Reports excluded:\\n{reports_excluded}", "right", "#d7e8f2")
add_node(tp, "included", "Included", 3, 1, "count_box",
  "Studies included in review\\n(n = {studies_included})\\nReports of included studies\\n(n = {reports_included})", "main", "#d7e8f2")

add_edge(tp, "identified", "screened")
add_edge(tp, "identified", "removed", "exclude")
add_edge(tp, "screened", "sought")
add_edge(tp, "screened", "excluded", "exclude")
add_edge(tp, "sought", "assessed")
add_edge(tp, "sought", "not_retrieved", "exclude")
add_edge(tp, "assessed", "included")
add_edge(tp, "assessed", "reports_excluded", "exclude")

add_count(tp, "identified_db", "Records identified from databases and registers", 0, 1)
add_count(tp, "duplicates", "Duplicate records removed", 0, 2)
add_count(tp, "auto_removed", "Records marked ineligible by automation tools", 0, 3)
add_count(tp, "other_removed", "Records removed for other reasons", 0, 4)
add_count(tp, "screened", "Records screened", 0, 5)
add_count(tp, "excluded", "Records excluded", 0, 6)
add_count(tp, "sought", "Reports sought for retrieval", 0, 7)
add_count(tp, "not_retrieved", "Reports not retrieved", 0, 8)
add_count(tp, "assessed", "Reports assessed for eligibility", 0, 9)
add_count(tp, "reports_excluded", "Reports excluded (with reasons)",
  "Reason 1 (n = 0); Reason 2 (n = 0)", 10, TRUE)
add_count(tp, "studies_included", "Studies included in review", 0, 11)
add_count(tp, "reports_included", "Reports of included studies", 0, 12)

# ============================ CONSORT 2010 =================================
# Parallel two-arm randomised trial.
tc <- "consort_2010"
add_node(tc, "title_enrol", "Enrollment", 1, 0, "stage_title", "Enrollment", "title", "#cfe2d4")
add_node(tc, "title_alloc", "Allocation", 2, 0, "stage_title", "Allocation", "title", "#cfe2d4")
add_node(tc, "title_foll", "Follow-Up", 3, 0, "stage_title", "Follow-Up", "title", "#cfe2d4")
add_node(tc, "title_anal", "Analysis", 4, 0, "stage_title", "Analysis", "title", "#cfe2d4")

add_node(tc, "assessed", "Enrollment", 1, 1, "count_box",
  "Assessed for eligibility (n = {assessed})", "main", "#eef3ef")
add_node(tc, "excluded", "Enrollment", 1, 1, "exclusion_box",
  "Excluded (n = {excluded_total}):\\n{excluded}", "right", "#eef3ef")
add_node(tc, "randomized", "Enrollment", 1, 2, "count_box",
  "Randomised (n = {randomized})", "main", "#eef3ef")

add_node(tc, "alloc_int", "Allocation", 2, 1, "arm",
  "Allocated to intervention (n = {alloc_int})\\nReceived allocated intervention (n = {alloc_int_received})\\nDid not receive allocated\\nintervention (n = {alloc_int_not})", "left", "#eef3ef")
add_node(tc, "alloc_ctrl", "Allocation", 2, 1, "arm",
  "Allocated to control (n = {alloc_ctrl})\\nReceived allocated intervention (n = {alloc_ctrl_received})\\nDid not receive allocated\\nintervention (n = {alloc_ctrl_not})", "right", "#eef3ef")

add_node(tc, "foll_int", "Follow-Up", 3, 1, "arm",
  "Lost to follow-up (n = {foll_int_lost})\\nDiscontinued intervention (n = {foll_int_disc})", "left", "#eef3ef")
add_node(tc, "foll_ctrl", "Follow-Up", 3, 1, "arm",
  "Lost to follow-up (n = {foll_ctrl_lost})\\nDiscontinued intervention (n = {foll_ctrl_disc})", "right", "#eef3ef")

add_node(tc, "anal_int", "Analysis", 4, 1, "arm",
  "Analysed (n = {anal_int})\\nExcluded from analysis (n = {anal_int_excl})", "left", "#eef3ef")
add_node(tc, "anal_ctrl", "Analysis", 4, 1, "arm",
  "Analysed (n = {anal_ctrl})\\nExcluded from analysis (n = {anal_ctrl_excl})", "right", "#eef3ef")

add_edge(tc, "assessed", "randomized")
add_edge(tc, "assessed", "excluded", "exclude")
add_edge(tc, "randomized", "alloc_int")
add_edge(tc, "randomized", "alloc_ctrl")
add_edge(tc, "alloc_int", "foll_int")
add_edge(tc, "alloc_ctrl", "foll_ctrl")
add_edge(tc, "foll_int", "anal_int")
add_edge(tc, "foll_ctrl", "anal_ctrl")

cc <- function(field, label, value = 0, ord = NA, is_reasons = FALSE) add_count(tc, field, label, value, ord, is_reasons)
cc("assessed", "Assessed for eligibility", 0, 1)
cc("excluded_total", "Excluded (total)", 0, 2)
cc("excluded", "Excluded (reasons)", "Not meeting inclusion criteria (n = 0); Declined to participate (n = 0); Other reasons (n = 0)", 3, TRUE)
cc("randomized", "Randomised", 0, 4)
cc("alloc_int", "Allocated to intervention", 0, 5)
cc("alloc_int_received", "Received allocated intervention (intervention)", 0, 6)
cc("alloc_int_not", "Did not receive allocated intervention (intervention)", 0, 7)
cc("alloc_ctrl", "Allocated to control", 0, 8)
cc("alloc_ctrl_received", "Received allocated intervention (control)", 0, 9)
cc("alloc_ctrl_not", "Did not receive allocated intervention (control)", 0, 10)
cc("foll_int_lost", "Lost to follow-up (intervention)", 0, 11)
cc("foll_int_disc", "Discontinued intervention (intervention)", 0, 12)
cc("foll_ctrl_lost", "Lost to follow-up (control)", 0, 13)
cc("foll_ctrl_disc", "Discontinued intervention (control)", 0, 14)
cc("anal_int", "Analysed (intervention)", 0, 15)
cc("anal_int_excl", "Excluded from analysis (intervention)", 0, 16)
cc("anal_ctrl", "Analysed (control)", 0, 17)
cc("anal_ctrl_excl", "Excluded from analysis (control)", 0, 18)

# ============================ STARD 2015 ===================================
# Diagnostic accuracy study flow (linear simplification).
ts <- "stard_2015"
add_node(ts, "title_enrol", "Enrollment", 1, 0, "stage_title", "Enrollment", "title", "#e8d6e8")
add_node(ts, "title_test", "Testing", 2, 0, "stage_title", "Testing", "title", "#e8d6e8")
add_node(ts, "title_anal", "Analysis", 3, 0, "stage_title", "Analysis", "title", "#e8d6e8")

add_node(ts, "eligible", "Enrollment", 1, 1, "count_box",
  "Eligible patients (n = {eligible})", "main", "#f3ecf3")
add_node(ts, "excluded", "Enrollment", 1, 1, "exclusion_box",
  "Excluded patients (n = {excluded_total}):\\n{excluded}", "right", "#f3ecf3")
add_node(ts, "index", "Testing", 2, 1, "count_box",
  "Received index test (n = {index_test})", "main", "#f3ecf3")
add_node(ts, "no_index", "Testing", 2, 1, "exclusion_box",
  "Did not receive index test (n = {no_index})", "right", "#f3ecf3")
add_node(ts, "reference", "Testing", 2, 2, "count_box",
  "Received reference standard (n = {reference})", "main", "#f3ecf3")
add_node(ts, "no_reference", "Testing", 2, 2, "exclusion_box",
  "Did not receive reference\\nstandard (n = {no_reference})", "right", "#f3ecf3")
add_node(ts, "analyzed", "Analysis", 3, 1, "count_box",
  "Included in analysis (n = {analyzed})", "main", "#f3ecf3")

add_edge(ts, "eligible", "index")
add_edge(ts, "eligible", "excluded", "exclude")
add_edge(ts, "index", "reference")
add_edge(ts, "index", "no_index", "exclude")
add_edge(ts, "reference", "analyzed")
add_edge(ts, "reference", "no_reference", "exclude")

cs <- function(field, label, value = 0, ord = NA, is_reasons = FALSE) add_count(ts, field, label, value, ord, is_reasons)
cs("eligible", "Eligible patients", 0, 1)
cs("excluded_total", "Excluded patients (total)", 0, 2)
cs("excluded", "Excluded (reasons)", "Did not meet inclusion criteria (n = 0); Other (n = 0)", 3, TRUE)
cs("index_test", "Received index test", 0, 4)
cs("no_index", "Did not receive index test", 0, 5)
cs("reference", "Received reference standard", 0, 6)
cs("no_reference", "Did not receive reference standard", 0, 7)
cs("analyzed", "Included in analysis", 0, 8)

# ============================ assemble =====================================
flowchart_nodes <- do.call(rbind, nodes)
flowchart_edges <- do.call(rbind, edges)
flowchart_counts <- do.call(rbind, counts)
flowchart_counts$value[is.na(flowchart_counts$value)] <- "0"

flowchart_templates <- data.frame(
  template_id = c("prisma_2020", "consort_2010", "stard_2015"),
  name = c("PRISMA 2020 flow diagram", "CONSORT 2010 flow diagram", "STARD 2015 flow diagram"),
  guideline_id = c("prisma-2020", "consort", "stard-2015"),
  study_type = c("Systematic review", "Randomised trial", "Diagnostic accuracy"),
  n_count_fields = c(
    sum(flowchart_counts$template_id == "prisma_2020"),
    sum(flowchart_counts$template_id == "consort_2010"),
    sum(flowchart_counts$template_id == "stard_2015")
  ),
  stringsAsFactors = FALSE
)

saveRDS(list(
  nodes = flowchart_nodes, edges = flowchart_edges,
  counts = flowchart_counts, templates = flowchart_templates
), here("parsed", "flowcharts.rds"))

cat("Flowchart templates built:\n")
print(flowchart_templates[, c("template_id", "name", "n_count_fields")])
cat(sprintf("Total: %d nodes, %d edges, %d count fields\n",
  nrow(flowchart_nodes), nrow(flowchart_edges), nrow(flowchart_counts)))
