# Flow diagram fillable counts

The numbers (and reason lists) a user fills in for each flow diagram
template, with example defaults so a template renders out of the box.

## Usage

``` r
flowchart_counts
```

## Format

A data frame with columns:

- template_id:

  Template identifier.

- count_field:

  Field name referenced by node labels.

- label:

  Human-readable label for the input.

- value:

  Example/default value (character).

- field_order:

  Display order.

- is_reasons:

  Logical; field holds a semicolon-separated reasons list.

## Source

reportilo.
