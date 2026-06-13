# Create a risk-of-bias assessment

Build a risk-of-bias object from a table of per-study, per-domain
judgments, ready to plot with
[`rob_traffic_light()`](https://choxos.github.io/reportilo/reference/rob_traffic_light.md)
/
[`rob_summary()`](https://choxos.github.io/reportilo/reference/rob_summary.md)
or export with
[`reportilo_export()`](https://choxos.github.io/reportilo/reference/reportilo_export.md).

[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) returns
the wide judgment table (one row per study, one column per domain plus
`Overall`).

## Usage

``` r
reportilo_rob(tool, data = NULL)

# S3 method for class 'reportilo_rob'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- tool:

  A `tool_id` (see
  [`rob_tools_available()`](https://choxos.github.io/reportilo/reference/rob_tools_available.md)).

- data:

  A wide data frame: a study-name column (`Study`) plus one column per
  domain id (and optionally `Overall`). If `NULL`, a bundled example for
  the tool is used. Get a blank one with
  [`rob_template()`](https://choxos.github.io/reportilo/reference/rob_template.md).

- x:

  A `reportilo_rob` object.

- row.names, optional:

  Ignored; for S3 consistency.

- ...:

  Ignored.

## Value

An object of class `reportilo_rob`.

## See also

[`rob_traffic_light()`](https://choxos.github.io/reportilo/reference/rob_traffic_light.md),
[`rob_summary()`](https://choxos.github.io/reportilo/reference/rob_summary.md),
[`reportilo_export()`](https://choxos.github.io/reportilo/reference/reportilo_export.md)

## Examples

``` r
rob <- reportilo_rob("rob2")
rob
#> <reportilo risk of bias> RoB 2 (randomised trials)
#> 6 studies, 5 domains
#>    Study            D1            D2            D3            D4            D5
#>  Study 1          High           Low Some concerns          High           Low
#>  Study 2           Low Some concerns          High           Low Some concerns
#>  Study 3 Some concerns          High           Low Some concerns          High
#>  Study 4          High           Low Some concerns          High           Low
#>  Study 5           Low Some concerns          High           Low Some concerns
#>  Study 6 Some concerns          High           Low Some concerns          High
#>  Overall
#>     High
#>     High
#>     High
#>     High
#>     High
#>     High
#> Plot with rob_traffic_light() / rob_summary(); export with reportilo_export().
```
