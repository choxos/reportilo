# Building flow diagrams

`reportilo` ships three fillable flow diagram templates, all built on
one generic node/edge/count model:

``` r

flowchart_templates[, c("template_id", "name", "study_type", "n_count_fields")]
#>    template_id                      name          study_type n_count_fields
#> 1  prisma_2020  PRISMA 2020 flow diagram   Systematic review             12
#> 2 consort_2010 CONSORT 2010 flow diagram    Randomised trial             18
#> 3   stard_2015   STARD 2015 flow diagram Diagnostic accuracy              8
```

## Start a diagram

``` r

fc <- new_flowchart("prisma_2020")
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
#>  0                                 
#>  0                                 
#>  0                                 
#>  0                                 
#>  0                                 
#>  0                                 
#>  0                                 
#>  0                                 
#>  0                                 
#>  Reason 1 (n = 0); Reason 2 (n = 0)
#>  0                                 
#>  0                                 
#> Render with render_flowchart() or export with reportilo_export().
```

## See the fields

Each template exposes a set of fillable fields. Most are numeric counts;
some hold a semicolon-separated list of exclusion reasons.

``` r

head(flowchart_fields("prisma_2020"), 8)
#>     count_field                                           label is_reasons
#> 1 identified_db Records identified from databases and registers      FALSE
#> 2    duplicates                       Duplicate records removed      FALSE
#> 3  auto_removed   Records marked ineligible by automation tools      FALSE
#> 4 other_removed               Records removed for other reasons      FALSE
#> 5      screened                                Records screened      FALSE
#> 6      excluded                                Records excluded      FALSE
#> 7        sought                    Reports sought for retrieval      FALSE
#> 8 not_retrieved                           Reports not retrieved      FALSE
#>   value
#> 1     0
#> 2     0
#> 3     0
#> 4     0
#> 5     0
#> 6     0
#> 7     0
#> 8     0
```

## Fill in the counts

Set fields by name with
[`set_counts()`](https://choxos.github.io/reportilo/reference/set_counts.md).
Unknown names raise an error, so typos are caught early.

``` r

fc <- set_counts(fc,
  identified_db = 2451,
  duplicates = 320,
  screened = 2034,
  excluded = 1789,
  sought = 245,
  assessed = 237,
  reports_excluded = "Wrong population (n = 120); Wrong outcome (n = 73)",
  studies_included = 42,
  reports_included = 48
)
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
#>  2451                                              
#>  320                                               
#>  0                                                 
#>  0                                                 
#>  2034                                              
#>  1789                                              
#>  245                                               
#>  0                                                 
#>  237                                               
#>  Wrong population (n = 120); Wrong outcome (n = 73)
#>  42                                                
#>  48                                                
#> Render with render_flowchart() or export with reportilo_export().
```

## View it

[`render_flowchart()`](https://choxos.github.io/reportilo/reference/render_flowchart.md)
returns an interactive Graphviz widget.

``` r

render_flowchart(fc)
```

The underlying Graphviz source is available with
[`flowchart_dot()`](https://choxos.github.io/reportilo/reference/flowchart_dot.md),
which is also what the image and Word exporters use.

``` r

cat(substr(flowchart_dot(fc), 1, 120), "...")
#> digraph reportilo {
#>   graph [rankdir=TB, splines=ortho, nodesep=0.45, ranksep=0.55];
#>   node [shape=box, fontname="Helvet ...
```

## Export

``` r

reportilo_export(fc, "prisma-flow.png") # also svg, pdf
reportilo_export(fc, "prisma-flow.docx") # embedded image
reportilo_export(fc, "prisma-counts.xlsx") # the counts as a table
```

## The CONSORT and STARD templates

`"consort_2010"` is a two-arm parallel trial diagram and `"stard_2015"`
is a diagnostic accuracy flow. They are filled the same way; use
[`flowchart_fields()`](https://choxos.github.io/reportilo/reference/flowchart_fields.md)
to discover their fields.

``` r

nrow(flowchart_fields("consort_2010"))
#> [1] 18
nrow(flowchart_fields("stard_2015"))
#> [1] 8
```
