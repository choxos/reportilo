# Checklist coverage report

Summarize how much of the catalog has machine-readable checklists and
how much is hand-verified, by EQUATOR study-type category. Use this to
be explicit about coverage rather than implying the whole catalog is
fillable.

## Usage

``` r
reportilo_coverage()
```

## Value

A data frame with one row per category plus a `Total` row, with columns:
`records`, `with_checklist`, `verified`, `needs_review`.

## See also

[`reportilo_guidelines()`](https://choxos.github.io/reportilo/reference/reportilo_guidelines.md),
[parse_status](https://choxos.github.io/reportilo/reference/parse_status.md)

## Examples

``` r
reportilo_coverage()
#>                         category records with_checklist verified needs_review
#> 1              Randomized trials      23              6        1            3
#> 2          Observational studies     174             17        1            7
#> 3             Systematic reviews      61             20        1            4
#> 4                Study protocols      24              7        0            4
#> 5  Diagnostic/prognostic studies      36              7        0            0
#> 6                   Case reports       3              1        0            1
#> 7   Clinical practice guidelines      15              4        0            2
#> 8           Qualitative research      50              7        0            2
#> 9    Animal pre-clinical studies      20              1        0            0
#> 10   Quality improvement studies       5              1        0            1
#> 11          Economic evaluations      21              0        0            0
#> 12                         Other     268             15        0            9
#> 13                         Total     700             86        3           33
```
