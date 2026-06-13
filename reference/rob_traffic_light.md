# Risk-of-bias traffic-light plot

A study-by-domain grid of colored judgments (the classic robvis traffic
light), as a `ggplot`.

## Usage

``` r
rob_traffic_light(x)
```

## Arguments

- x:

  A `reportilo_rob` from
  [`reportilo_rob()`](https://choxos.github.io/reportilo/reference/reportilo_rob.md).

## Value

A `ggplot` object.

## See also

[`rob_summary()`](https://choxos.github.io/reportilo/reference/rob_summary.md)

## Examples

``` r
rob_traffic_light(reportilo_rob("rob2"))
```
