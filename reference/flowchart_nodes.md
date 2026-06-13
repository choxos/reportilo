# Flow diagram template nodes

Boxes for the bundled flow diagram templates (PRISMA 2020, CONSORT 2010,
STARD 2015). Labels embed `{count_field}` tokens that are replaced with
user-supplied counts at render time.

## Usage

``` r
flowchart_nodes
```

## Format

A data frame with columns:

- template_id:

  Template identifier.

- node_id:

  Node identifier within the template.

- stage, stage_order, node_order:

  Grouping and layout order.

- role:

  "stage_title", "count_box", "exclusion_box" or "arm".

- label_template:

  Box label with `{field}` placeholders.

- side:

  "main", "left", "right" or "title".

- fill, tooltip:

  Style and optional tooltip.

## Source

reportilo (PRISMA 2020 derived from the PRISMA2020 package model).
