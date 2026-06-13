# Search the reporting guideline catalog

Case-insensitive substring search across selected fields of the catalog.

## Usage

``` r
search_guidelines(
  query,
  fields = c("acronym", "title", "study_design", "clinical_area"),
  checklist_only = FALSE
)
```

## Arguments

- query:

  A single search string.

- fields:

  Character vector of columns to search. Defaults to acronym, title,
  study design and clinical area.

- checklist_only:

  Logical; restrict to guidelines with a checklist.

## Value

A data frame of matching guidelines with the most useful columns.

## See also

[`reportilo_guidelines()`](https://choxos.github.io/reportilo/reference/reportilo_guidelines.md),
[`guideline_info()`](https://choxos.github.io/reportilo/reference/guideline_info.md)

## Examples

``` r
search_guidelines("randomised trial")
#>                                                        guideline_id
#> 278                                                   ace-statement
#> 304                                                          sw-crt
#> 307                                                consort-spi-2018
#> 320                                                  consort-equity
#> 348                                                         consort
#> 349 consort-2010-statement-extension-checklist-for-reporting-within
#> 674                                                 consort-cluster
#> 684                                           consort-for-abstracts
#>                   acronym
#> 278         ACE Statement
#> 304                SW-CRT
#> 307      CONSORT-SPI 2018
#> 320        CONSORT-Equity
#> 348               CONSORT
#> 349                  <NA>
#> 674       CONSORT Cluster
#> 684 CONSORT for abstracts
#>                                                                                                                                                                          title
#> 278 The adaptive designs CONSORT extension (ACE) statement: a checklist with explanation and elaboration guideline for reporting randomised trials that use an adaptive design
#> 304                                             Reporting of stepped wedge cluster randomised trials: extension of the CONSORT 2010 statement with explanation and elaboration
#> 307                                                                      Reporting randomised trials of social and psychological interventions: the CONSORT-SPI 2018 Extension
#> 320                                                                   CONSORT-Equity 2017 extension and elaboration for better reporting of health equity in randomised trials
#> 348                                                                                                  CONSORT 2025 Statement: updated guideline for reporting randomised trials
#> 349                                                                                  CONSORT 2010 statement: extension checklist for reporting within person randomised trials
#> 674                                                                                                             Consort 2010 statement: extension to cluster randomised trials
#> 684                                                                                                CONSORT for reporting randomised trials in journal and conference abstracts
#>                              study_design has_checklist
#> 278 Clinical trials, Experimental studies          TRUE
#> 304 Clinical trials, Experimental studies          TRUE
#> 307 Clinical trials, Experimental studies          TRUE
#> 320 Clinical trials, Experimental studies         FALSE
#> 348 Clinical trials, Experimental studies          TRUE
#> 349 Clinical trials, Experimental studies         FALSE
#> 674 Clinical trials, Experimental studies         FALSE
#> 684 Clinical trials, Experimental studies         FALSE
search_guidelines("qualitative")
#>                                                                     guideline_id
#> 10                                                                        mentor
#> 14         reporting-guidelines-for-qualitative-research-a-values-based-approach
#> 55                                                                        direct
#> 59                                                                    delphistar
#> 63                                                                        epacir
#> 66                                                                       checkap
#> 68                                                                       obsqual
#> 78                                                                         sonhr
#> 83                                                                         rtarg
#> 84                                                                      retrieve
#> 95                                                                        accord
#> 109                       best-practice-guidelines-for-citizen-science-in-mental
#> 125                                                                        crisp
#> 128                                                                         crai
#> 130                                                                        noeco
#> 133                                                                        plirt
#> 139                                                                       chairs
#> 140                                                                      pricssa
#> 153                                                                        carda
#> 155                                                                     doctrine
#> 159                                                                   conferd-hp
#> 161                                                                       assess
#> 162                                                                     priproid
#> 165                                                                     describe
#> 169                      recommendations-for-reporting-the-results-of-studies-of
#> 186                                  a-scoping-review-of-the-use-of-ethnographic
#> 191 six-practical-recommendations-for-improved-implementation-outcomes-reporting
#> 195                  guidance-for-publishing-qualitative-research-in-informatics
#> 200                      using-qualitative-research-to-develop-an-elaboration-of
#> 205                                                                       gaming
#> 241                                                               rise2-genomics
#> 242                                                                        cross
#> 246                                                                       cosmin
#> 253      journal-article-reporting-standards-for-qualitative-primary-qualitative
#> 258                                                                         risa
#> 282                                                                     consider
#> 284                                                                        pacir
#> 288             criteria-for-describing-and-evaluating-training-interventions-in
#> 294                                                                       emerge
#> 300                                                                      c-a-r-e
#> 313                                                                       sundae
#> 344                                                                       gripp2
#> 363                                                                        stari
#> 371              recommendations-for-improving-the-quality-of-reporting-clinical
#> 380                                using-theory-of-change-to-design-and-evaluate
#> 395                                                                   rameses-ii
#> 426        developing-a-methodological-framework-for-organisational-case-studies
#> 429             a-checklist-to-improve-reporting-of-group-based-behaviour-change
#> 436                      a-reporting-guide-for-studies-on-individual-differences
#> 461             using-qualitative-methods-for-attribute-development-for-discrete
#> 470                                                                      dolbapp
#> 482                            minimum-data-elements-for-research-reports-on-cfs
#> 484                                                                         srqr
#> 611          evolving-guidelines-for-publication-of-qualitative-research-studies
#> 615                                                                         rats
#> 618                       revealing-the-wood-and-the-trees-reporting-qualitative
#> 626                     qualitative-research-standards-challenges-and-guidelines
#> 629                capturing-momentary-self-report-data-a-proposal-for-reporting
#> 651                    guidelines-for-conducting-and-reporting-mixed-research-in
#> 656                                                                       entreq
#> 699                                                                        coreq
#>            acronym
#> 10          MENTOR
#> 14            <NA>
#> 55          DIRECT
#> 59      DELPHISTAR
#> 63          EPaCIR
#> 66         ChecKAP
#> 68         ObsQual
#> 78           SoNHR
#> 83           RTARG
#> 84        RETRIEVE
#> 95          ACCORD
#> 109           <NA>
#> 125          CRISP
#> 128           CRAI
#> 130          NOECO
#> 133          PLIRT
#> 139         CHAIRS
#> 140        PRICSSA
#> 153          CARDA
#> 155       DoCTRINE
#> 159     CONFERD-HP
#> 161         ASSESS
#> 162       PRIPROID
#> 165       DESCRIBE
#> 169           <NA>
#> 186           <NA>
#> 191           <NA>
#> 195           <NA>
#> 200           <NA>
#> 205         GAMING
#> 241 RISE2 Genomics
#> 242          CROSS
#> 246         COSMIN
#> 253           <NA>
#> 258           RISA
#> 282       CONSIDER
#> 284          PaCIR
#> 288           <NA>
#> 294         eMERGe
#> 300       C.A.R.E.
#> 313         SUNDAE
#> 344         GRIPP2
#> 363          StaRI
#> 371           <NA>
#> 380           <NA>
#> 395     RAMESES II
#> 426           <NA>
#> 429           <NA>
#> 436           <NA>
#> 461           <NA>
#> 470        DOLBaPP
#> 482           <NA>
#> 484           SRQR
#> 611           <NA>
#> 615           RATS
#> 618           <NA>
#> 626           <NA>
#> 629           <NA>
#> 651           <NA>
#> 656         ENTREQ
#> 699          COREQ
#>                                                                                                                                                                                                         title
#> 10                                                                                                                                                    Reporting qualitative Methods in Mental Health Research
#> 14                                                                                                                                     Reporting guidelines for qualitative research: a values-based approach
#> 55                                                                                                                      A Reporting Checklist for Discrete Choice Experiments in Health: The DIRECT Checklist
#> 59                                                     Delphi studies in social and health sciences -Recommendations for an interdisciplinary standardized reporting (DELPHISTAR) . Results of a Delphi study
#> 63                                                                                                                                  Standardized reporting on studies of psychiatric pharmacist interventions
#> 66                                                                                                                       Chec KAP : A Checklist for Reporting a Knowledge, Attitude, and Practice (KAP) Study
#> 68                                                                 Development and validation of observational and qualitative study protocol reporting checklists for novice researchers (ObsQual checklist)
#> 78                                                                                                                             Introducing So NHR-Reporting guidelines for Social Networks In Health Research
#> 83  Supporting best practice in reflexive thematic analysis reporting in Palliative Medicine: A review of published research and introduction to the Reflexive Thematic Analysis Reporting Guidelines (RTARG)
#> 84                                                                               The RETRIEVE Checklist for Studies Reporting the Elicitation of Stated Preferences for Child Health -Related Quality of Life
#> 95                                                                 ACCORD (ACcurate COnsensus Reporting Document): A reporting guideline for consensus methods in biomedicine developed via a modified Delphi
#> 109                                                                                          Best practice guidelines for citizen science in mental health research: systematic review and evidence synthesis
#> 125                                                                               Improving the Reporting of Primary Care Research: Consensus Reporting Items for Studies in Primary Care-the CRISP Statement
#> 128                                                                                                        The adapted Autobiographical interview: A systematic review and proposal for conduct and reporting
#> 130                                                                                                            Initial Standardized Framework for Reporting Social Media Analytics in Emergency Care Research
#> 133                                                                                              Development, explanation, and presentation of the Physical Literacy Interventions Reporting Template (PLIRT)
#> 139                                                                                                                                           Reporting guidelines for allergy and immunology survey research
#> 140                                                                                                                                    Preferred Reporting Items for Complex Sample Survey Analysis (PRICSSA)
#> 153                                                                                                                                        Guiding document analyses in health professions education research
#> 155                                                                                                                             The Do CTRINE Guidelines: Defined Criteria To Report INnovations in Education
#> 159                                                                                                         CONFERD-HP : recommendations for reporting COmpeteNcy FramEwoRk Development in health professions
#> 161                         Development of the ASSESS tool: a comprehenSive tool to Support rEporting and critical appraiSal of qualitative, quantitative, and mixed methods implementation reSearch outcomes
#> 162                                                                                                   Advising on Preferred Reporting Items for patient-reported outcome instrument development: the PRIPROID
#> 165                                               Establishing reporting standards for participant characteristics in post-stroke aphasia research: An international e -Delphi exercise and consensus meeting
#> 169                                                                                                      Recommendations for reporting the results of studies of instrument and scale development and testing
#> 186                                                                                       A scoping review of the use of ethnographic approaches in implementation research and recommendations for reporting
#> 191                                                                                                                              Six practical recommendations for improved implementation outcomes reporting
#> 195                                                                                                                                               Guidance for publishing qualitative research in informatics
#> 200                                                         Using qualitative research to develop an elaboration of the TIDieR checklist for interventions to enhance vaccination communication: short report
#> 205                               Conceptual Ambiguity Surrounding Gamification and Serious Games in Health Care: Literature Review and Development of Game -Based Intervention Reporting Guidelines (GAMING)
#> 241                                                      Ensuring best practice in genomics education and evaluation: reporting item standards for education and its evaluation in genomics (RISE 2 Genomics)
#> 242                                                                                                                                      A Consensus -Based Checklist for Reporting of Survey Studies (CROSS)
#> 246                                                                                                     COSMIN reporting guideline for studies on measurement properties of patient-reported outcome measures
#> 253         Journal article reporting standards for qualitative primary, qualitative meta-analytic, and mixed methods research in psychology: The APA Publications and Communications Board task force report
#> 258                                                                                                                 Stakeholder analysis in health innovation planning processes: A systematic scoping review
#> 282                                                                                 Consolidated criteria for strengthening reporting of health research involving indigenous peoples: the CONSIDER statement
#> 284                                                                                                                                 Pa CIR : A tool to enhance pharmacist patient care intervention reporting
#> 288                                                                                                       Criteria for describing and evaluating training interventions in healthcare professions – CRe-DEPTH
#> 294                                                                                                                                 Improving reporting of Meta -Ethnography : The e MERGe Reporting Guidance
#> 300                                                                          Reporting guidelines for implementation research on nurturing care interventions designed to promote early childhood development
#> 313                                                                                         Standards for UNiversal reporting of patient Decision Aid Evaluation studies: the development of SUNDAE Checklist
#> 344                                                                                                    GRIPP 2 reporting checklists: tools to improve reporting of patient and public involvement in research
#> 363                                                                                                                                          Standards for Reporting Implementation Studies (StaRI) Statement
#> 371                                                                        Recommendations for improving the quality of reporting clinical electrochemotherapy studies based on qualitative systematic review
#> 380                                                                                                            Using theory of change to design and evaluate public health interventions: a systematic review
#> 395                                                                                                                                                    RAMESES II reporting standards for realist evaluations
#> 426                                                                                   Developing a methodological framework for organisational case studies: a rapid review and consensus development process
#> 429                                                                                                                            A checklist to improve reporting of group-based behaviour-change interventions
#> 436                                                                                                                                 A reporting guide for studies on individual differences in traffic safety
#> 461                                                                                           Using qualitative methods for attribute development for discrete choice experiments: issues and recommendations
#> 470                                                                                                    A consensus approach toward the standardization of back pain definitions for use in prevalence studies
#> 482                                                                                                                                                         Minimum data elements for research reports on CFS
#> 484                                                                                                                              Standards for reporting qualitative research: a synthesis of recommendations
#> 611                                                                                                      Evolving guidelines for publication of qualitative research studies in psychology and related fields
#> 615                                                                                                                                                             Qualitative research review guidelines – RATS
#> 618                                                                                                                                          Revealing the wood and the trees: reporting qualitative research
#> 626                                                                                                                                               Qualitative research: standards, challenges, and guidelines
#> 629                                                                                                                                Capturing momentary, self-report data: a proposal for reporting guidelines
#> 651                                                                                                              Guidelines for conducting and reporting mixed research in the field of counseling and beyond
#> 656                                                                                                                         Enhancing transparency in reporting the synthesis of qualitative research: ENTREQ
#> 699                                                                                    Consolidated criteria for reporting qualitative research (COREQ) : a 32-item checklist for interviews and focus groups
#>                                                                                                                                                                                                                    study_design
#> 10                                                                                                                                                                                                         Qualitative research
#> 14                                                                                                                                                                                                         Qualitative research
#> 55                                                                                                                                                                                   Economic evaluations, Qualitative research
#> 59                                                                                                                                                                           Clinical practice guidelines, Qualitative research
#> 63                                                                                                                                           Clinical trials, Experimental studies, Observational studies, Qualitative research
#> 66                                                                                                                                                                                                         Qualitative research
#> 68                                                                                                                                                                 Observational studies, Qualitative research, Study protocols
#> 78                                                                                                                                                                                  Observational studies, Qualitative research
#> 83                                                                                                                                                                                                         Qualitative research
#> 84                                                                                                                                                                                   Economic evaluations, Qualitative research
#> 95                                                                                                                                                                           Clinical practice guidelines, Qualitative research
#> 109 Clinical practice guidelines, Clinical trials, Economic evaluations, Experimental studies, Observational studies, Qualitative research, Quality improvement studies, Systematic reviews/Meta-analyses/Reviews/HTA/Overviews
#> 125                                                                                                                   Clinical trials, Experimental studies, Mixed methods studies, Observational studies, Qualitative research
#> 128                                                                                                                                                                                                        Qualitative research
#> 130                                                                                                                                                                                 Mixed methods studies, Qualitative research
#> 133                                                                                                                                                                 Clinical trials, Experimental studies, Qualitative research
#> 139                                                                                                                                                                                                        Qualitative research
#> 140                                                                                                                                                                                 Observational studies, Qualitative research
#> 153                                                                                                                         Mixed methods studies, Qualitative research, Systematic reviews/Meta-analyses/Reviews/HTA/Overviews
#> 155                                                                                                                                          Clinical trials, Experimental studies, Observational studies, Qualitative research
#> 159                                                                                                                                                                                 Mixed methods studies, Qualitative research
#> 161        Clinical trials, Economic evaluations, Experimental studies, Mixed methods studies, Observational studies, Qualitative research, Quality improvement studies, Systematic reviews/Meta-analyses/Reviews/HTA/Overviews
#> 162                                                                                                                                          Clinical trials, Experimental studies, Observational studies, Qualitative research
#> 165                                                                                                                                          Clinical trials, Experimental studies, Observational studies, Qualitative research
#> 169                                                                    Clinical trials, Diagnostic and prognostic studies, Experimental studies, Observational studies, Qualitative research, Reliability and agreement studies
#> 186                                                                                                                                                                                                        Qualitative research
#> 191                                                                Clinical trials, Economic evaluations, Experimental studies, Mixed methods studies, Observational studies, Qualitative research, Quality improvement studies
#> 195                                                                                                                                                                                                        Qualitative research
#> 200                                                                                                                                                                                       Clinical trials, Experimental studies
#> 205                                                                                                                                                                 Clinical trials, Experimental studies, Qualitative research
#> 241                                                                                                                                    Experimental studies, Mixed methods studies, Observational studies, Qualitative research
#> 242                                                                                                                                                                                 Observational studies, Qualitative research
#> 246                                                                                                                                              Observational studies, Qualitative research, Reliability and agreement studies
#> 253                                                                                                                         Mixed methods studies, Qualitative research, Systematic reviews/Meta-analyses/Reviews/HTA/Overviews
#> 258                                                                                                                                                                                                        Qualitative research
#> 282                                         Diagnostic and prognostic studies, Experimental studies, Mixed methods studies, Observational studies, Qualitative research, Systematic reviews/Meta-analyses/Reviews/HTA/Overviews
#> 284                                                                                                             Clinical trials, Experimental studies, Observational studies, Qualitative research, Quality improvement studies
#> 288                                                                                                                                                                Clinical trials, Observational studies, Qualitative research
#> 294                                                                                                                                                                                                        Qualitative research
#> 300                                                                                                                                          Clinical trials, Experimental studies, Observational studies, Qualitative research
#> 313                                                                                                                                          Clinical trials, Experimental studies, Observational studies, Qualitative research
#> 344 Clinical practice guidelines, Clinical trials, Economic evaluations, Experimental studies, Observational studies, Qualitative research, Quality improvement studies, Systematic reviews/Meta-analyses/Reviews/HTA/Overviews
#> 363                                                                Clinical trials, Economic evaluations, Experimental studies, Mixed methods studies, Observational studies, Qualitative research, Quality improvement studies
#> 371                                                                                                                                                                                       Clinical trials, Experimental studies
#> 380                                                                                                                                          Clinical trials, Experimental studies, Observational studies, Qualitative research
#> 395                                                                                                                                                                                 Mixed methods studies, Qualitative research
#> 426                                                                                                                             Mixed methods studies, Observational studies, Qualitative research, Quality improvement studies
#> 429                                                                                                                                    Experimental studies, Mixed methods studies, Observational studies, Qualitative research
#> 436                                                                                                                                                                                                        Qualitative research
#> 461                                                                                                                                                                                                        Economic evaluations
#> 470                                                                                                                                                                                 Observational studies, Qualitative research
#> 482                                                                                                                                                                                 Observational studies, Qualitative research
#> 484                                                                                                                                                                                                        Qualitative research
#> 611                                                                                                                                                                                                        Qualitative research
#> 615                                                                                                                                                                                                        Qualitative research
#> 618                                                                                                                                                                                                        Qualitative research
#> 626                                                                                                                                                                                                        Qualitative research
#> 629                                                                                                                                                                                 Observational studies, Qualitative research
#> 651                                                                                                                             Experimental studies, Mixed methods studies, Observational studies, Other, Qualitative research
#> 656                                                                                                                                                Qualitative research, Systematic reviews/Meta-analyses/Reviews/HTA/Overviews
#> 699                                                                                                                                                                                                        Qualitative research
#>     has_checklist
#> 10          FALSE
#> 14          FALSE
#> 55          FALSE
#> 59           TRUE
#> 63          FALSE
#> 66          FALSE
#> 68          FALSE
#> 78          FALSE
#> 83          FALSE
#> 84          FALSE
#> 95           TRUE
#> 109         FALSE
#> 125          TRUE
#> 128         FALSE
#> 130         FALSE
#> 133         FALSE
#> 139         FALSE
#> 140         FALSE
#> 153         FALSE
#> 155          TRUE
#> 159         FALSE
#> 161         FALSE
#> 162         FALSE
#> 165         FALSE
#> 169         FALSE
#> 186         FALSE
#> 191         FALSE
#> 195         FALSE
#> 200         FALSE
#> 205         FALSE
#> 241         FALSE
#> 242         FALSE
#> 246         FALSE
#> 253         FALSE
#> 258         FALSE
#> 282         FALSE
#> 284         FALSE
#> 288         FALSE
#> 294         FALSE
#> 300         FALSE
#> 313         FALSE
#> 344          TRUE
#> 363          TRUE
#> 371         FALSE
#> 380         FALSE
#> 395         FALSE
#> 426          TRUE
#> 429          TRUE
#> 436         FALSE
#> 461         FALSE
#> 470         FALSE
#> 482         FALSE
#> 484         FALSE
#> 611         FALSE
#> 615         FALSE
#> 618         FALSE
#> 626         FALSE
#> 629         FALSE
#> 651         FALSE
#> 656         FALSE
#> 699         FALSE
```
