# EQUATOR study-type categories

The main study-type categories used to group the catalog, in display
order, with the number of guidelines in each.

## Usage

``` r
reportilo_categories()
```

## Value

A data frame with `category`, `category_order` and `n`.

## See also

[`reportilo_guidelines()`](https://choxos.github.io/reportilo/reference/reportilo_guidelines.md)

## Examples

``` r
reportilo_categories()
#>                         category category_order   n
#> 1              Randomized trials              1  23
#> 2          Observational studies              2 174
#> 3             Systematic reviews              3  61
#> 4                Study protocols              4  24
#> 5  Diagnostic/prognostic studies              5  36
#> 6                   Case reports              6   3
#> 7   Clinical practice guidelines              7  15
#> 8           Qualitative research              8  50
#> 9    Animal pre-clinical studies              9  20
#> 10   Quality improvement studies             10   5
#> 11          Economic evaluations             11  21
#> 12                         Other             12 268
```
