# Check a flow diagram for count inconsistencies

Apply template-specific sanity rules (for example, *screened* cannot
exceed *identified*, *randomized* cannot exceed *assessed for
eligibility*). Reason fields are ignored.

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
#> [1] "Records identified from databases and registers (100) is less than Records screened (200)."
```
