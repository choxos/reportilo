# Create a fillable flow diagram

Start a flow diagram from one of the bundled templates (PRISMA 2020,
CONSORT 2010 or STARD 2015). Fill in the counts with
[`set_counts()`](https://choxos.github.io/reportilo/reference/set_counts.md)
and render or export it with
[`render_flowchart()`](https://choxos.github.io/reportilo/reference/render_flowchart.md)
/
[`reportilo_export()`](https://choxos.github.io/reportilo/reference/reportilo_export.md).

## Usage

``` r
new_flowchart(template)
```

## Arguments

- template:

  A template id: `"prisma_2020"`, `"consort_2010"` or `"stard_2015"`.
  See
  [flowchart_templates](https://choxos.github.io/reportilo/reference/flowchart_templates.md).

## Value

An object of class `reportilo_flowchart`.

## See also

[`set_counts()`](https://choxos.github.io/reportilo/reference/set_counts.md),
[`flowchart_fields()`](https://choxos.github.io/reportilo/reference/flowchart_fields.md),
[`render_flowchart()`](https://choxos.github.io/reportilo/reference/render_flowchart.md)

## Examples

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
