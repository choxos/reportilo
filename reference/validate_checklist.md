# Validate a filled checklist

Report how complete a `reportilo_checklist` is (how many items have a
response) and check that its structure is intact.

## Usage

``` r
validate_checklist(x)
```

## Arguments

- x:

  A `reportilo_checklist`, e.g. from
  [`get_checklist()`](https://choxos.github.io/reportilo/reference/get_checklist.md).

## Value

Invisibly, a list with `n_items`, `n_filled` and `complete`. Called
mainly for the message it prints.

## Examples

``` r
chk <- get_checklist("strobe")
validate_checklist(chk)
#> strobe: 0 of 22 items completed.
```
