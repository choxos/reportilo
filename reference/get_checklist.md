# Get a fillable reporting checklist

Return the checklist for a guideline as a fillable table: one row per
item, with an empty `response` column for you to record the page number
(or other response) where each item is addressed.

## Usage

``` r
get_checklist(id)

new_checklist(id)
```

## Arguments

- id:

  A `guideline_id` (or an unambiguous acronym). See
  [`reportilo_guidelines()`](https://choxos.github.io/reportilo/reference/reportilo_guidelines.md).

## Value

An object of class `reportilo_checklist` (a data frame with columns
`item_no`, `section`, `item_text`, `response`), or `NULL` (invisibly) if
the guideline has no bundled checklist.

## See also

[`validate_checklist()`](https://choxos.github.io/reportilo/reference/validate_checklist.md),
[`reportilo_export()`](https://choxos.github.io/reportilo/reference/reportilo_export.md)

## Examples

``` r
chk <- get_checklist("prisma-2020")
head(chk)
#> <reportilo checklist> prisma-2020 (verified)
#> The PRISMA 2020 statement: An updated guideline for reporting systematic reviews
#>   item_no section     
#> 1 1       Title       
#> 2 2       Abstract    
#> 3 3       Introduction
#> 4 4       Introduction
#> 5 5       Methods     
#> 6 6       Methods     
#>   item_text                                                                                                                                                                     
#> 1 Identify the report as a systematic review.                                                                                                                                   
#> 2 See the PRISMA 2020 for Abstracts checklist.                                                                                                                                  
#> 3 Describe the rationale for the review in the context of existing knowledge.                                                                                                   
#> 4 Provide an explicit statement of the objective(s) or question(s) the review addresses.                                                                                        
#> 5 Specify the inclusion and exclusion criteria for the review and how studies were grouped for the syntheses.                                                                   
#> 6 Specify all databases, registers, websites, organizations, reference lists and other sources searched or consulted; specify the date when each was last searched or consulted.
#>   response
#> 1 <NA>    
#> 2 <NA>    
#> 3 <NA>    
#> 4 <NA>    
#> 5 <NA>    
#> 6 <NA>    
chk$response[1:3] <- c("p1", "p2", "p2")
```
