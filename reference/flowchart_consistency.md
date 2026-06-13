# Check a flow diagram for count inconsistencies

Apply template-specific accounting bounds, including flow invariants
where the template has explicit removal/exclusion counts: for example
PRISMA *screened* cannot exceed *identified - duplicates - automation -
other*, and CONSORT *randomized* cannot exceed *assessed - excluded*.
Reason fields are ignored. Bounds are checked (not strict equality), so
a partially filled diagram is not flagged.

## Usage

``` r
flowchart_consistency(x)
```

## Arguments

- x:

  A `reportilo_flowchart`.

## Value

A character vector of issue messages (empty if the counts are
consistent).

## Examples

``` r
fc <- set_counts(new_flowchart("prisma_2020"), identified_db = 100, screened = 200)
flowchart_consistency(fc)
#> [1] "Records screened (200) exceeds Records identified from databases and registers - Duplicate records removed - Records marked ineligible by automation tools - Records removed for other reasons (100)."
```
