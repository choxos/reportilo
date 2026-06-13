# List the fillable fields of a flow diagram template

List the fillable fields of a flow diagram template

## Usage

``` r
flowchart_fields(template)
```

## Arguments

- template:

  A template id (see
  [`new_flowchart()`](https://choxos.github.io/reportilo/reference/new_flowchart.md))
  or a `reportilo_flowchart` object.

## Value

A data frame with `count_field`, `label`, `is_reasons` and the example
default `value`.

## Examples

``` r
flowchart_fields("consort_2010")
#>            count_field                                                 label
#> 13            assessed                              Assessed for eligibility
#> 14      excluded_total                                      Excluded (total)
#> 15            excluded                                    Excluded (reasons)
#> 16          randomized                                            Randomised
#> 17           alloc_int                             Allocated to intervention
#> 18  alloc_int_received        Received allocated intervention (intervention)
#> 19       alloc_int_not Did not receive allocated intervention (intervention)
#> 20          alloc_ctrl                                  Allocated to control
#> 21 alloc_ctrl_received             Received allocated intervention (control)
#> 22      alloc_ctrl_not      Did not receive allocated intervention (control)
#> 23       foll_int_lost                      Lost to follow-up (intervention)
#> 24       foll_int_disc              Discontinued intervention (intervention)
#> 25      foll_ctrl_lost                           Lost to follow-up (control)
#> 26      foll_ctrl_disc                   Discontinued intervention (control)
#> 27            anal_int                               Analysed (intervention)
#> 28       anal_int_excl                 Excluded from analysis (intervention)
#> 29           anal_ctrl                                    Analysed (control)
#> 30      anal_ctrl_excl                      Excluded from analysis (control)
#>    is_reasons
#> 13      FALSE
#> 14      FALSE
#> 15       TRUE
#> 16      FALSE
#> 17      FALSE
#> 18      FALSE
#> 19      FALSE
#> 20      FALSE
#> 21      FALSE
#> 22      FALSE
#> 23      FALSE
#> 24      FALSE
#> 25      FALSE
#> 26      FALSE
#> 27      FALSE
#> 28      FALSE
#> 29      FALSE
#> 30      FALSE
#>                                                                                             value
#> 13                                                                                              0
#> 14                                                                                              0
#> 15 Not meeting inclusion criteria (n = 0); Declined to participate (n = 0); Other reasons (n = 0)
#> 16                                                                                              0
#> 17                                                                                              0
#> 18                                                                                              0
#> 19                                                                                              0
#> 20                                                                                              0
#> 21                                                                                              0
#> 22                                                                                              0
#> 23                                                                                              0
#> 24                                                                                              0
#> 25                                                                                              0
#> 26                                                                                              0
#> 27                                                                                              0
#> 28                                                                                              0
#> 29                                                                                              0
#> 30                                                                                              0
```
