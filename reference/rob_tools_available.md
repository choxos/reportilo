# Risk-of-bias assessment tools

List the supported risk-of-bias assessment tools (RoB 2, RoB 1,
ROBINS-I, ROBINS-E, QUADAS-2, QUIPS and the cluster RoB 2 variant).

## Usage

``` r
rob_tools_available()
```

## Value

A data frame with `tool_id`, `name`, `study_type`, `n_domains` and the
allowed judgment `levels`.

## See also

[`reportilo_rob()`](https://choxos.github.io/reportilo/reference/reportilo_rob.md),
[`rob_traffic_light()`](https://choxos.github.io/reportilo/reference/rob_traffic_light.md),
[`rob_summary()`](https://choxos.github.io/reportilo/reference/rob_summary.md)

## Examples

``` r
rob_tools_available()
#>        tool_id                                    name
#> 1         rob2               RoB 2 (randomised trials)
#> 2 rob2_cluster       RoB 2 (cluster-randomised trials)
#> 3         rob1                        RoB 1 (Cochrane)
#> 4     robins_i ROBINS-I (non-randomised interventions)
#> 5     robins_e                    ROBINS-E (exposures)
#> 6      quadas2          QUADAS-2 (diagnostic accuracy)
#> 7        quips              QUIPS (prognostic factors)
#>                          study_type n_domains
#> 1                  Randomised trial         5
#> 2          Cluster-randomised trial         6
#> 3                  Randomised trial         7
#> 4 Non-randomised intervention study         7
#> 5     Non-randomised exposure study         7
#> 6         Diagnostic accuracy study         4
#> 7                  Prognostic study         6
#>                                                levels
#> 1                            Low; Some concerns; High
#> 2                            Low; Some concerns; High
#> 3                                  Low; Unclear; High
#> 4    Low; Moderate; Serious; Critical; No information
#> 5 Low; Some concerns; High; Very high; No information
#> 6                                  Low; Unclear; High
#> 7                                 Low; Moderate; High
```
