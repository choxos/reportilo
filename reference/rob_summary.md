# Risk-of-bias summary plot

A stacked bar chart of the distribution of judgments across studies, per
domain (the robvis summary plot), as a `ggplot`.

## Usage

``` r
rob_summary(x)
```

## Arguments

- x:

  A `reportilo_rob` from
  [`reportilo_rob()`](https://choxos.github.io/reportilo/reference/reportilo_rob.md).

## Value

A `ggplot` object.

## See also

[`rob_traffic_light()`](https://choxos.github.io/reportilo/reference/rob_traffic_light.md)

## Examples

``` r
rob_summary(reportilo_rob("robins_i"))
```
