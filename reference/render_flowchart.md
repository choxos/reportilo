# Render a flow diagram for viewing

Render a `reportilo_flowchart` as an interactive Graphviz widget (for
use in the console, RStudio Viewer, R Markdown or Shiny). To save to a
file, use
[`reportilo_export()`](https://choxos.github.io/reportilo/reference/reportilo_export.md).

## Usage

``` r
render_flowchart(x, background = "white")
```

## Arguments

- x:

  A `reportilo_flowchart`.

- background:

  Diagram background color (default `"white"`; use `"transparent"` for
  no background).

## Value

A `DiagrammeR` `grViz` htmlwidget.

## See also

[`reportilo_export()`](https://choxos.github.io/reportilo/reference/reportilo_export.md),
[`flowchart_dot()`](https://choxos.github.io/reportilo/reference/flowchart_dot.md)

## Examples

``` r
fc <- new_flowchart("prisma_2020")
render_flowchart(fc)

{"x":{"diagram":"digraph reportilo {\n  graph [rankdir=TB, splines=ortho, nodesep=0.45, ranksep=0.55, bgcolor=\"white\"];\n  node [shape=box, fontname=\"Helvetica\", fontsize=10, margin=\"0.14,0.09\"];\n  edge [arrowsize=0.7];\n  \"identified\" [label=\"Records identified from\\ndatabases and registers\\n(n = 0)\", fillcolor=\"#fde9b8\", style=\"filled,rounded\"];\n  \"removed\" [label=\"Records removed before screening:\\nDuplicate records removed (n = 0)\\nRecords marked ineligible by\\nautomation tools (n = 0)\\nRecords removed for other\\nreasons (n = 0)\", fillcolor=\"#fde9b8\", style=\"filled,rounded,dashed\"];\n  \"screened\" [label=\"Records screened\\n(n = 0)\", fillcolor=\"#d7e8f2\", style=\"filled,rounded\"];\n  \"excluded\" [label=\"Records excluded\\n(n = 0)\", fillcolor=\"#d7e8f2\", style=\"filled,rounded,dashed\"];\n  \"sought\" [label=\"Reports sought for retrieval\\n(n = 0)\", fillcolor=\"#d7e8f2\", style=\"filled,rounded\"];\n  \"not_retrieved\" [label=\"Reports not retrieved\\n(n = 0)\", fillcolor=\"#d7e8f2\", style=\"filled,rounded,dashed\"];\n  \"assessed\" [label=\"Reports assessed for eligibility\\n(n = 0)\", fillcolor=\"#d7e8f2\", style=\"filled,rounded\"];\n  \"reports_excluded\" [label=\"Reports excluded:\\nReason 1 (n = 0); Reason 2 (n = 0)\", fillcolor=\"#d7e8f2\", style=\"filled,rounded,dashed\"];\n  \"included\" [label=\"Studies included in review\\n(n = 0)\\nReports of included studies\\n(n = 0)\", fillcolor=\"#d7e8f2\", style=\"filled,rounded\"];\n  {rank=same; \"identified\"; \"removed\"}\n  {rank=same; \"screened\"; \"excluded\"}\n  {rank=same; \"sought\"; \"not_retrieved\"}\n  {rank=same; \"assessed\"; \"reports_excluded\"}\n  \"identified\" -> \"screened\";\n  \"identified\" -> \"removed\" [constraint=false];\n  \"screened\" -> \"sought\";\n  \"screened\" -> \"excluded\" [constraint=false];\n  \"sought\" -> \"assessed\";\n  \"sought\" -> \"not_retrieved\" [constraint=false];\n  \"assessed\" -> \"included\";\n  \"assessed\" -> \"reports_excluded\" [constraint=false];\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}
```
