# Check a flow diagram for count inconsistencies

Apply template-specific accounting bounds, including flow invariants
where the template has explicit removal/exclusion counts: for example
PRISMA *screened* cannot exceed *identified - duplicates - automation -
other*, and CONSORT *randomized* cannot exceed *assessed - excluded*.
Reason fields are ignored.

## Usage

``` r
flowchart_consistency(x, complete = FALSE)
```

## Arguments

- x:

  A `reportilo_flowchart`.

- complete:

  If `TRUE`, also flag stages where the count is *less* than the base
  minus its fully specified removals (records unaccounted for), not only
  stages where it exceeds the bound. Use this for a final, fully filled
  diagram. Default `FALSE` (bounds only), which suits a draft.

## Value

A character vector of issue messages (empty if the counts are
consistent).

## Details

By default only bounds are checked (not strict equality), so a partially
filled draft is not flagged. Set `complete = TRUE` for a finished
diagram to additionally require *exact* accounting at every stage whose
removals or exclusions are fully specified: there the inflowing count
must equal base minus removals, not merely fall within it. This catches
records that are silently unaccounted for in an otherwise complete
diagram.

## Examples

``` r
fc <- set_counts(new_flowchart("prisma_2020"), identified_db = 100, screened = 200)
flowchart_consistency(fc)
#> [1] "Records screened (200) exceeds Records identified from databases and registers - Duplicate records removed - Records marked ineligible by automation tools - Records removed for other reasons (100)."

# complete mode catches under-accounting that bounds mode allows
draft <- set_counts(new_flowchart("prisma_2020"),
  identified_db = 200, duplicates = 50, screened = 100)
flowchart_consistency(draft) # ok within bounds
#> character(0)
flowchart_consistency(draft, complete = TRUE) # 50 records unaccounted
#> [1] "Records screened (100) is less than Records identified from databases and registers - Duplicate records removed - Records marked ineligible by automation tools - Records removed for other reasons (150); 50 record(s) unaccounted."
#> [2] "Reports sought for retrieval (0) is less than Records screened - Records excluded (100); 100 record(s) unaccounted."                                                                                                                 
```
