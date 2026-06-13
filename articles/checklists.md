# Filling in reporting checklists

## Getting a checklist

[`get_checklist()`](https://choxos.github.io/reportilo/reference/get_checklist.md)
(or its alias
[`new_checklist()`](https://choxos.github.io/reportilo/reference/get_checklist.md))
returns a fillable checklist for a guideline: one row per item, with an
empty `response` column.

``` r

chk <- get_checklist("prisma-2020")
class(chk)
#> [1] "reportilo_checklist" "data.frame"
nrow(chk)
#> [1] 42
head(chk[, c("item_no", "section", "item_text")])
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
#> 6 Specify all databases, registers, websites, organisations, reference lists and other sources searched or consulted; specify the date when each was last searched or consulted.
```

The object carries the guideline id, title and whether the checklist was
hand-verified:

``` r

attr(chk, "guideline_id")
#> [1] "prisma-2020"
attr(chk, "verified")
#> [1] TRUE
```

## Filling it in

`response` is an ordinary character column. Record the page number (or
any note) where each item is addressed.

``` r

chk$response[chk$item_no == "1"] <- "p1"
chk$response[chk$item_no == "16a"] <- "p7, Figure 1"

validate_checklist(chk)
#> prisma-2020: 2 of 42 items completed.
```

## Verified versus auto-extracted

The main families ship as hand-verified checklists. Many other
guidelines are auto-extracted from their source documents; treat those
as a starting point and check them against the original. Use
`parse_status` to see which is which.

``` r

ps <- parse_status
head(ps[ps$verified, c("guideline_id", "n_items", "status")])
#>    guideline_id n_items    status
#> 19      consort      37 parsed_ok
#> 53  prisma-2020      42 parsed_ok
#> 86       strobe      22 parsed_ok

# guidelines flagged for review (lower-confidence auto-extraction)
sum(ps$needs_review)
#> [1] 33
```

## Catalog-only guidelines

Guidelines without a machine-readable checklist return `NULL` with a
pointer to their source.

``` r

catalog_only <- reportilo_guidelines()
catalog_only <- catalog_only$guideline_id[!catalog_only$has_checklist][1]
res <- get_checklist(catalog_only)
#> No bundled checklist for 'consort-children-and-adolescents'. It is a catalog entry; see guideline_info("consort-children-and-adolescents") for source links.
is.null(res)
#> [1] TRUE
```

For those,
[`guideline_info()`](https://choxos.github.io/reportilo/reference/guideline_info.md)
gives the metadata and source links so you can work from the original
document.

## Exporting

Write the filled checklist to Word, Excel or CSV:

``` r

reportilo_export(chk, "prisma-2020-checklist.docx")
reportilo_export(chk, "prisma-2020-checklist.xlsx")
reportilo_export(chk, "prisma-2020-checklist.csv")
```

See
[`vignette("export")`](https://choxos.github.io/reportilo/articles/export.md)
for the full list of formats.
