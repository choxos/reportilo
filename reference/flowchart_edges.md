# Flow diagram template edges

Connections between
[flowchart_nodes](https://choxos.github.io/reportilo/reference/flowchart_nodes.md)
for each template.

## Usage

``` r
flowchart_edges
```

## Format

A data frame with columns:

- template_id:

  Template identifier.

- from_node, to_node:

  Edge endpoints (node ids).

- edge_type:

  "flow", "exclude" or "merge".

- style:

  Line style.

## Source

reportilo.
