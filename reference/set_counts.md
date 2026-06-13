# Set counts on a flow diagram

Fill in one or more numeric counts (or reason lists) by field name.
Unknown field names raise an error; use
[`flowchart_fields()`](https://choxos.github.io/reportilo/reference/flowchart_fields.md)
to see valid names.

## Usage

``` r
set_counts(x, ...)
```

## Arguments

- x:

  A `reportilo_flowchart` from
  [`new_flowchart()`](https://choxos.github.io/reportilo/reference/new_flowchart.md).

- ...:

  Named values, e.g. `screened = 980, excluded = 700`. Reason fields
  take a string like `"Reason 1 (n = 5); Reason 2 (n = 3)"`.

## Value

The updated `reportilo_flowchart`.

## Examples

``` r
fc <- new_flowchart("consort_2010")
fc <- set_counts(fc, assessed = 200, randomized = 150)
```
