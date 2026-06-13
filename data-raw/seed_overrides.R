#!/usr/bin/env Rscript
# seed_overrides.R
# Author hand-verified checklists for the flagship guidelines and write them as
# data-raw/overrides/<id>.csv. These take precedence over auto-parsed data
# (see 05_apply_overrides.R). Run once to seed; the CSVs are then the source of
# truth and may be edited by hand. Not part of run_all.R.

ov_dir <- file.path("data-raw", "overrides")
if (!dir.exists(ov_dir)) dir.create(ov_dir, recursive = TRUE)

write_ov <- function(id, df) {
  df$response_type <- "page_ref"
  write.csv(df, file.path(ov_dir, paste0(id, ".csv")), row.names = FALSE)
  cat(sprintf("  %-14s %d items\n", id, nrow(df)))
}

# ---------------------------------------------------------------- PRISMA 2020
prisma <- function(section, item_no, item_text) data.frame(section, item_no, item_text, stringsAsFactors = FALSE)
prisma_2020 <- rbind(
  prisma("Title", "1", "Identify the report as a systematic review."),
  prisma("Abstract", "2", "See the PRISMA 2020 for Abstracts checklist."),
  prisma("Introduction", "3", "Describe the rationale for the review in the context of existing knowledge."),
  prisma("Introduction", "4", "Provide an explicit statement of the objective(s) or question(s) the review addresses."),
  prisma("Methods", "5", "Specify the inclusion and exclusion criteria for the review and how studies were grouped for the syntheses."),
  prisma("Methods", "6", "Specify all databases, registers, websites, organizations, reference lists and other sources searched or consulted; specify the date when each was last searched or consulted."),
  prisma("Methods", "7", "Present the full search strategies for all databases, registers and websites, including any filters and limits used."),
  prisma("Methods", "8", "Specify the methods used to decide whether a study met the inclusion criteria of the review, including how many reviewers screened each record and each report retrieved, whether they worked independently, and any automation tools used in the process."),
  prisma("Methods", "9", "Specify the methods used to collect data from reports, including how many reviewers collected data from each report, whether they worked independently, any processes for obtaining or confirming data from study investigators, and any automation tools used in the process."),
  prisma("Methods", "10a", "List and define all outcomes for which data were sought; specify whether all results compatible with each outcome domain in each study were sought and, if not, the methods used to decide which results to collect."),
  prisma("Methods", "10b", "List and define all other variables for which data were sought (e.g. participant and intervention characteristics, funding sources); describe any assumptions made about any missing or unclear information."),
  prisma("Methods", "11", "Specify the methods used to assess risk of bias in the included studies, including details of the tool(s) used, how many reviewers assessed each study and whether they worked independently, and any automation tools used in the process."),
  prisma("Methods", "12", "Specify for each outcome the effect measure(s) (e.g. risk ratio, mean difference) used in the synthesis or presentation of results."),
  prisma("Methods", "13a", "Describe the processes used to decide which studies were eligible for each synthesis (e.g. tabulating the study intervention characteristics and comparing against the planned groups for each synthesis)."),
  prisma("Methods", "13b", "Describe any methods required to prepare the data for presentation or synthesis, such as handling of missing summary statistics or data conversions."),
  prisma("Methods", "13c", "Describe any methods used to tabulate or visually display results of individual studies and syntheses."),
  prisma("Methods", "13d", "Describe any methods used to synthesize results and provide a rationale for the choice(s); if meta-analysis was performed, describe the model(s), method(s) to identify the presence and extent of statistical heterogeneity, and software package(s) used."),
  prisma("Methods", "13e", "Describe any methods used to explore possible causes of heterogeneity among study results (e.g. subgroup analysis, meta-regression)."),
  prisma("Methods", "13f", "Describe any sensitivity analyses conducted to assess robustness of the synthesized results."),
  prisma("Methods", "14", "Describe any methods used to assess risk of bias due to missing results in a synthesis (arising from reporting biases)."),
  prisma("Methods", "15", "Describe any methods used to assess certainty (or confidence) in the body of evidence for an outcome."),
  prisma("Results", "16a", "Describe the results of the search and selection process, from the number of records identified in the search to the number of studies included in the review, ideally using a flow diagram."),
  prisma("Results", "16b", "Cite studies that might appear to meet the inclusion criteria, but which were excluded, and explain why they were excluded."),
  prisma("Results", "17", "Cite each included study and present its characteristics."),
  prisma("Results", "18", "Present assessments of risk of bias for each included study."),
  prisma("Results", "19", "For all outcomes, present, for each study, summary statistics for each group (where appropriate) and an effect estimate and its precision (e.g. confidence/credible interval), ideally using structured tables or plots."),
  prisma("Results", "20a", "For each synthesis, briefly summarize the characteristics and risk of bias among contributing studies."),
  prisma("Results", "20b", "Present results of all statistical syntheses conducted; if meta-analysis was done, present for each the summary estimate and its precision and measures of statistical heterogeneity; if comparing groups, describe the direction of the effect."),
  prisma("Results", "20c", "Present results of all investigations of possible causes of heterogeneity among study results."),
  prisma("Results", "20d", "Present results of all sensitivity analyses conducted to assess the robustness of the synthesized results."),
  prisma("Results", "21", "Present assessments of risk of bias due to missing results (arising from reporting biases) for each synthesis assessed."),
  prisma("Results", "22", "Present assessments of certainty (or confidence) in the body of evidence for each outcome assessed."),
  prisma("Discussion", "23a", "Provide a general interpretation of the results in the context of other evidence."),
  prisma("Discussion", "23b", "Discuss any limitations of the evidence included in the review."),
  prisma("Discussion", "23c", "Discuss any limitations of the review processes used."),
  prisma("Discussion", "23d", "Discuss implications of the results for practice, policy and future research."),
  prisma("Other information", "24a", "Provide registration information for the review, including the register name and registration number, or state that the review was not registered."),
  prisma("Other information", "24b", "Indicate where the review protocol can be accessed, or state that a protocol was not prepared."),
  prisma("Other information", "24c", "Describe and explain any amendments to information provided at registration or in the protocol."),
  prisma("Other information", "25", "Describe sources of financial or non-financial support for the review, and the role of the funders or sponsors in the review."),
  prisma("Other information", "26", "Declare any competing interests of review authors."),
  prisma("Other information", "27", "Report which of the following are publicly available and where: template data collection forms; data extracted from included studies; data used for all analyses; analytic code; any other materials used in the review.")
)
write_ov("prisma-2020", prisma_2020)

# --------------------------------------------------------------- CONSORT 2010
consort <- function(section, item_no, item_text) data.frame(section, item_no, item_text, stringsAsFactors = FALSE)
consort_2010 <- rbind(
  consort("Title and abstract", "1a", "Identification as a randomized trial in the title."),
  consort("Title and abstract", "1b", "Structured summary of trial design, methods, results, and conclusions (for specific guidance see CONSORT for abstracts)."),
  consort("Introduction", "2a", "Scientific background and explanation of rationale."),
  consort("Introduction", "2b", "Specific objectives or hypotheses."),
  consort("Methods", "3a", "Description of trial design (such as parallel, factorial) including allocation ratio."),
  consort("Methods", "3b", "Important changes to methods after trial commencement (such as eligibility criteria), with reasons."),
  consort("Methods", "4a", "Eligibility criteria for participants."),
  consort("Methods", "4b", "Settings and locations where the data were collected."),
  consort("Methods", "5", "The interventions for each group with sufficient details to allow replication, including how and when they were actually administered."),
  consort("Methods", "6a", "Completely defined pre-specified primary and secondary outcome measures, including how and when they were assessed."),
  consort("Methods", "6b", "Any changes to trial outcomes after the trial commenced, with reasons."),
  consort("Methods", "7a", "How sample size was determined."),
  consort("Methods", "7b", "When applicable, explanation of any interim analyses and stopping guidelines."),
  consort("Methods", "8a", "Method used to generate the random allocation sequence."),
  consort("Methods", "8b", "Type of randomization; details of any restriction (such as blocking and block size)."),
  consort("Methods", "9", "Mechanism used to implement the random allocation sequence (such as sequentially numbered containers), describing any steps taken to conceal the sequence until interventions were assigned."),
  consort("Methods", "10", "Who generated the random allocation sequence, who enrolled participants, and who assigned participants to interventions."),
  consort("Methods", "11a", "If done, who was blinded after assignment to interventions (for example, participants, care providers, those assessing outcomes) and how."),
  consort("Methods", "11b", "If relevant, description of the similarity of interventions."),
  consort("Methods", "12a", "Statistical methods used to compare groups for primary and secondary outcomes."),
  consort("Methods", "12b", "Methods for additional analyses, such as subgroup analyses and adjusted analyses."),
  consort("Results", "13a", "For each group, the numbers of participants who were randomly assigned, received intended treatment, and were analyzed for the primary outcome."),
  consort("Results", "13b", "For each group, losses and exclusions after randomization, together with reasons."),
  consort("Results", "14a", "Dates defining the periods of recruitment and follow-up."),
  consort("Results", "14b", "Why the trial ended or was stopped."),
  consort("Results", "15", "A table showing baseline demographic and clinical characteristics for each group."),
  consort("Results", "16", "For each group, number of participants (denominator) included in each analysis and whether the analysis was by original assigned groups."),
  consort("Results", "17a", "For each primary and secondary outcome, results for each group, and the estimated effect size and its precision (such as 95% confidence interval)."),
  consort("Results", "17b", "For binary outcomes, presentation of both absolute and relative effect sizes is recommended."),
  consort("Results", "18", "Results of any other analyses performed, including subgroup analyses and adjusted analyses, distinguishing pre-specified from exploratory."),
  consort("Results", "19", "All important harms or unintended effects in each group (for specific guidance see CONSORT for harms)."),
  consort("Discussion", "20", "Trial limitations, addressing sources of potential bias, imprecision, and, if relevant, multiplicity of analyses."),
  consort("Discussion", "21", "Generalisability (external validity, applicability) of the trial findings."),
  consort("Discussion", "22", "Interpretation consistent with results, balancing benefits and harms, and considering other relevant evidence."),
  consort("Other information", "23", "Registration number and name of trial registry."),
  consort("Other information", "24", "Where the full trial protocol can be accessed, if available."),
  consort("Other information", "25", "Sources of funding and other support (such as supply of drugs), role of funders.")
)
write_ov("consort", consort_2010)

# -------------------------------------------------------------------- STROBE
strobe <- function(section, item_no, item_text) data.frame(section, item_no, item_text, stringsAsFactors = FALSE)
strobe_v <- rbind(
  strobe("Title and abstract", "1", "Indicate the study's design with a commonly used term in the title or the abstract; provide in the abstract an informative and balanced summary of what was done and what was found."),
  strobe("Introduction", "2", "Explain the scientific background and rationale for the investigation being reported."),
  strobe("Introduction", "3", "State specific objectives, including any prespecified hypotheses."),
  strobe("Methods", "4", "Present key elements of study design early in the paper."),
  strobe("Methods", "5", "Describe the setting, locations, and relevant dates, including periods of recruitment, exposure, follow-up, and data collection."),
  strobe("Methods", "6", "Give the eligibility criteria, and the sources and methods of selection of participants; describe methods of follow-up (cohort), matching (case-control/cohort), or case ascertainment and controls."),
  strobe("Methods", "7", "Clearly define all outcomes, exposures, predictors, potential confounders, and effect modifiers; give diagnostic criteria, if applicable."),
  strobe("Methods", "8", "For each variable of interest, give sources of data and details of methods of assessment (measurement); describe comparability of assessment methods if there is more than one group."),
  strobe("Methods", "9", "Describe any efforts to address potential sources of bias."),
  strobe("Methods", "10", "Explain how the study size was arrived at."),
  strobe("Methods", "11", "Explain how quantitative variables were handled in the analyses; if applicable, describe which groupings were chosen and why."),
  strobe("Methods", "12", "Describe all statistical methods, including those used to control for confounding; methods to examine subgroups and interactions; how missing data were addressed; analytical approach to loss to follow-up / matching / sampling; and any sensitivity analyses."),
  strobe("Results", "13", "Report numbers of individuals at each stage of the study; give reasons for non-participation at each stage; consider use of a flow diagram."),
  strobe("Results", "14", "Give characteristics of study participants and information on exposures and potential confounders; indicate number of participants with missing data for each variable of interest; (cohort) summarize follow-up time."),
  strobe("Results", "15", "Report numbers of outcome events or summary measures (cohort/case-control/cross-sectional as applicable)."),
  strobe("Results", "16", "Give unadjusted estimates and, if applicable, confounder-adjusted estimates and their precision (e.g. 95% confidence interval); report category boundaries when continuous variables were categorized; if relevant, translate estimates of relative risk into absolute risk."),
  strobe("Results", "17", "Report other analyses done, e.g. analyses of subgroups and interactions, and sensitivity analyses."),
  strobe("Discussion", "18", "Summarize key results with reference to study objectives."),
  strobe("Discussion", "19", "Discuss limitations of the study, taking into account sources of potential bias or imprecision; discuss both direction and magnitude of any potential bias."),
  strobe("Discussion", "20", "Give a cautious overall interpretation of results considering objectives, limitations, multiplicity of analyses, results from similar studies, and other relevant evidence."),
  strobe("Discussion", "21", "Discuss the generalisability (external validity) of the study results."),
  strobe("Other information", "22", "Give the source of funding and the role of the funders for the present study and, if applicable, for the original study on which the present article is based.")
)
write_ov("strobe", strobe_v)

cat("Seeded overrides in", ov_dir, "\n")
