# Getting started with reportilo

`reportilo` turns the [EQUATOR
Network](https://www.equator-network.org/) library of reporting
guidelines into a working toolkit. The workflow is three steps: **find**
a guideline, **fill** its checklist or flow diagram, and **export** the
result.

## Find

Browse or search the catalog of reporting guidelines.

``` r

# the whole catalog
nrow(reportilo_guidelines())
#> [1] 700

# only guidelines that ship a fillable checklist
nrow(reportilo_guidelines(checklist_only = TRUE))
#> [1] 86

# search across acronym, title, study design and clinical area
head(search_guidelines("randomised trial"), 5)
#>         guideline_id          acronym
#> 278    ace-statement    ACE Statement
#> 304           sw-crt           SW-CRT
#> 307 consort-spi-2018 CONSORT-SPI 2018
#> 320   consort-equity   CONSORT-Equity
#> 348          consort          CONSORT
#>                                                                                                                                                                          title
#> 278 The adaptive designs CONSORT extension (ACE) statement: a checklist with explanation and elaboration guideline for reporting randomised trials that use an adaptive design
#> 304                                             Reporting of stepped wedge cluster randomised trials: extension of the CONSORT 2010 statement with explanation and elaboration
#> 307                                                                      Reporting randomised trials of social and psychological interventions: the CONSORT-SPI 2018 Extension
#> 320                                                                   CONSORT-Equity 2017 extension and elaboration for better reporting of health equity in randomised trials
#> 348                                                                                                  CONSORT 2025 Statement: updated guideline for reporting randomised trials
#>              category                          study_design has_checklist
#> 278             Other Clinical trials, Experimental studies          TRUE
#> 304             Other Clinical trials, Experimental studies          TRUE
#> 307 Randomised trials Clinical trials, Experimental studies          TRUE
#> 320 Randomised trials Clinical trials, Experimental studies         FALSE
#> 348 Randomised trials Clinical trials, Experimental studies          TRUE
```

Look up one guideline (by `guideline_id` or an unambiguous acronym):

``` r

guideline_info("prisma-2020")
#> PRISMA 2020 - The PRISMA 2020 statement: An updated guideline for reporting systematic reviews
#> ------------------------------------------------------------
#> Category     : Systematic reviews
#> Study design : Systematic reviews/Meta-analyses/Reviews/HTA/Overviews
#> Checklist    : yes (get_checklist())
#> Flow diagram : prisma_2020 (new_flowchart())
#> EQUATOR      : https://www.equator-network.org/reporting-guidelines/prisma/
#> Source files : 41
#>   - PRISMA 2020 checklist (Word): https://www.prisma-statement.org/s/PRISMA_2020_checklist-gely.docx
#>   - PRISMA 2020 checklist (PDF): https://www.prisma-statement.org/s/PRISMA_2020_checklist-djgh.pdf
#>   - PRISMA 2020 expanded checklist (PDF): https://www.prisma-statement.org/s/PRISMA_2020_expanded_checklist-rp3l.pdf
#>   - Italian (PDF): https://www.prisma-statement.org/s/PRISMA-2020-Italian.pdf
#>   - Croation (PDF): https://www.prisma-statement.org/s/PRISMA_2020_statement_Croatian.pdf
#>   - Greek (PDF): https://www.prisma-statement.org/s/PRISMA_2020_Statement_Greek.pdf
#>   - Japanese (PDF): https://www.prisma-statement.org/s/PRISMA_2020_Japanese.pdf
#>   - Brazilian Portuguese (PDF): https://www.prisma-statement.org/s/PRISMA-2020-statement-BRAZILIAN-PORTUGUESE.pdf
#>   - Spanish (PDF): https://www.prisma-statement.org/s/PRISMA-2020-Spanish.pdf
#>   - Chinese Simplified (Word): https://www.prisma-statement.org/s/PRISMA_2020_checklist_Chinese.docx
#>   - Chinese Traditional (PDF): https://www.prisma-statement.org/s/PRISMA_2020-checklist_Traditional-Chinese_update.pdf
#>   - French (Word): https://www.prisma-statement.org/s/PRISMA_2020_checklist_fr-b26g.docx
#>   - Greek (PDF): https://www.prisma-statement.org/s/PRISMA_2020_checklist_Greek.pdf
#>   - Japanese (PDF): https://www.prisma-statement.org/s/PRISMA-Japanese-Table-1-PRISMA-2020-item-checklist.pdf
#>   - Korean (Word): https://www.prisma-statement.org/s/PRISMA_2020_Korean_Checklist-dyx5.docx
#>   - European Portuguese (Word): https://www.prisma-statement.org/s/PRISMA-2020-checklist-EUROPEAN-PORTUGUESE-8rrx.docx
#>   - Turkish (PDF): https://www.prisma-statement.org/s/PRISMA-2020-checklist-Turkish-version.pdf
#>   - Chinese Simplified (Word): https://www.prisma-statement.org/s/PRISMA_2020_abstract_checklist_Chinese.docx
#>   - Chinese Traditional (PDF): https://www.prisma-statement.org/s/PRISMA_2020_Abs-checklist_Traditional-Chinese_new.pdf
#>   - Japanese (PDF): https://www.prisma-statement.org/s/PRISMA-Japanese-Table-2-PRISMA-2020-for-Abstracts-checklist.pdf
#>   - Korean (Word): https://www.prisma-statement.org/s/PRISMA_2020_Korean_Abstract_Checklist-jna2.docx
#>   - European Portuguese (Word): https://www.prisma-statement.org/s/PRISMA-2020-abstract-checklist-EUROPEAN-PORTUGUESE-cytw.docx
#>   - Turkish (PDF): https://www.prisma-statement.org/s/PRISMA-2020-for-Abstract-checklist-Turkish-version.pdf
#>   - German (PDF): http://www.prisma-statement.org/documents/PRISMA%20German%20Statement.pdf
#>   - Italian (PDF): http://www.prisma-statement.org/documents/PRISMA%20Italian%20Statement.pdf
#>   - Korean (PDF): http://www.prisma-statement.org/documents/PRISMA%20Korean%20checklist.pdf
#>   - Portuguese (PDF): http://www.prisma-statement.org/documents/PRISMA%20Portugese%20checklist.pdf
#>   - Russian (PDF): http://www.prisma-statement.org/documents/PRISMA%20Russian%20checklist.pdf
#>   - German (PDF): http://www.prisma-statement.org/documents/PRISMA%20German%20checklist.pdf
#>   - Japanese (PDF): http://www.prisma-statement.org/documents/PRISMA%20Japanese%20checklist.pdf
#>   - Turkish (PDF): http://www.prisma-statement.org/documents/PRISMA%20Turkish%20checklist.pdf
#>   - Italian (PDF): http://www.prisma-statement.org/documents/PRISMA%20Italian%20checklist.pdf
#>   - French (PDF): http://www.prisma-statement.org/documents/PRISMA%20French%20Flow%20Diagram.pdf
#>   - German (PDF): http://www.prisma-statement.org/documents/PRISMA%20German%20flow%20diagram.pdf
#>   - Italian (PDF): http://www.prisma-statement.org/documents/PRISMA%20Italian%20flow%20diagram.pdf
#>   - Korean (PDF): http://www.prisma-statement.org/documents/PRISMA%20Korean%20flow%20diagram.pdf
#>   - Russian (PDF): http://www.prisma-statement.org/documents/PRISMA%20Russian%20flow%20diagram.pdf
#>   - Japanese (PDF): http://www.prisma-statement.org/documents/PRISMA%20Japanese%20flow%20diagram.pdf
#>   - Turkish (PDF): http://www.prisma-statement.org/documents/PRISMA%20Turkish%20flow%20diagram.pdf
#>   - Portuguese (PDF): http://www.prisma-statement.org/documents/PRISMA%20Portugese%20flow%20diagram.pdf
#>   - Italian (PDF): http://www.prisma-statement.org/documents/PRISMA%20Italian%20EandE.pdf
```

## Fill

Get a fillable checklist. Each row is one item; record where you address
it in the `response` column.

``` r

chk <- get_checklist("strobe")
head(chk)
#> <reportilo checklist> strobe (verified)
#> The Strengthening the Reporting of Observational Studies in Epidemiology (STROBE) Statement: guidelines for reporting observational studies
#>   item_no section           
#> 1 1       Title and abstract
#> 2 2       Introduction      
#> 3 3       Introduction      
#> 4 4       Methods           
#> 5 5       Methods           
#> 6 6       Methods           
#>   item_text                                                                                                                                                                                           
#> 1 Indicate the study's design with a commonly used term in the title or the abstract; provide in the abstract an informative and balanced summary of what was done and what was found.                
#> 2 Explain the scientific background and rationale for the investigation being reported.                                                                                                               
#> 3 State specific objectives, including any prespecified hypotheses.                                                                                                                                   
#> 4 Present key elements of study design early in the paper.                                                                                                                                            
#> 5 Describe the setting, locations, and relevant dates, including periods of recruitment, exposure, follow-up, and data collection.                                                                    
#> 6 Give the eligibility criteria, and the sources and methods of selection of participants; describe methods of follow-up (cohort), matching (case-control/cohort), or case ascertainment and controls.
#>   response
#> 1 <NA>    
#> 2 <NA>    
#> 3 <NA>    
#> 4 <NA>    
#> 5 <NA>    
#> 6 <NA>

chk$response[1:3] <- c("p1", "p2", "p2")
validate_checklist(chk)
#> strobe: 3 of 22 items completed.
```

Flow diagrams work the same way. Start from a template, set the counts,
and view it.

``` r

fc <- new_flowchart("prisma_2020")
fc <- set_counts(fc, identified_db = 1200, screened = 980, excluded = 700)
fc
#> <reportilo flowchart> PRISMA 2020 flow diagram (prisma_2020)
#>  field            label                                          
#>  identified_db    Records identified from databases and registers
#>  duplicates       Duplicate records removed                      
#>  auto_removed     Records marked ineligible by automation tools  
#>  other_removed    Records removed for other reasons              
#>  screened         Records screened                               
#>  excluded         Records excluded                               
#>  sought           Reports sought for retrieval                   
#>  not_retrieved    Reports not retrieved                          
#>  assessed         Reports assessed for eligibility               
#>  reports_excluded Reports excluded (with reasons)                
#>  studies_included Studies included in review                     
#>  reports_included Reports of included studies                    
#>  value                             
#>  1200                              
#>  0                                 
#>  0                                 
#>  0                                 
#>  980                               
#>  700                               
#>  0                                 
#>  0                                 
#>  0                                 
#>  Reason 1 (n = 0); Reason 2 (n = 0)
#>  0                                 
#>  0                                 
#> Render with render_flowchart() or export with reportilo_export().
```

``` r

render_flowchart(fc)
```

## Export

Write either object to Word, Excel or an image. The format follows the
file extension.

``` r

reportilo_export(chk, "strobe-checklist.docx")
reportilo_export(chk, "strobe-checklist.xlsx")
reportilo_export(fc, "prisma-flow.png")
```

## Three front ends

The same data and logic power three interfaces:

- the **R package** documented here;
- a bundled **Shiny app**,
  [`launch_reportilo()`](https://choxos.github.io/reportilo/reference/launch_reportilo.md);
  and
- a **browser app** at <https://choxos.github.io/reportilo/app/>.

## Data coverage and provenance

For v0.1.0 the main families (such as PRISMA 2020, CONSORT 2010 and
STROBE) ship as hand-verified checklists. Other guidelines are
best-effort auto-extracted from their source documents, and the rest are
catalog entries that link to the original. The `parse_status` dataset
records the coverage and confidence for every guideline.

``` r

table(parse_status$status)
#> 
#>    failed parsed_ok   partial 
#>        12        53        33
```
