# Blank risk-of-bias template

A blank wide table to fill in: one row per study, one column per domain
(by domain id) plus `Overall`. Pass the filled table to
[`reportilo_rob()`](https://choxos.github.io/reportilo/reference/reportilo_rob.md).

## Usage

``` r
rob_template(tool, n_studies = 5)
```

## Arguments

- tool:

  A `tool_id` (see
  [`rob_tools_available()`](https://choxos.github.io/reportilo/reference/rob_tools_available.md)).

- n_studies:

  Number of blank study rows to create (default 5).

## Value

A data frame with a `Study` column, one column per domain id and an
`Overall` column.

## Examples

``` r
rob_template("rob2")
#>     Study   D1   D2   D3   D4   D5 Overall
#> 1 Study 1 <NA> <NA> <NA> <NA> <NA>    <NA>
#> 2 Study 2 <NA> <NA> <NA> <NA> <NA>    <NA>
#> 3 Study 3 <NA> <NA> <NA> <NA> <NA>    <NA>
#> 4 Study 4 <NA> <NA> <NA> <NA> <NA>    <NA>
#> 5 Study 5 <NA> <NA> <NA> <NA> <NA>    <NA>
```
