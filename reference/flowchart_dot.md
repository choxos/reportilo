# Build the Graphviz DOT for a flow diagram

Turn a `reportilo_flowchart` into a Graphviz DOT string, substituting
the filled counts into the box labels. This is the shared core used by
[`render_flowchart()`](https://choxos.github.io/reportilo/reference/render_flowchart.md)
and by the image/Word exporters.

## Usage

``` r
flowchart_dot(x)
```

## Arguments

- x:

  A `reportilo_flowchart`.

## Value

A length-one character string of Graphviz DOT.

## Examples

``` r
fc <- new_flowchart("stard_2015")
cat(substr(flowchart_dot(fc), 1, 80))
#> digraph reportilo {
#>   graph [rankdir=TB, splines=ortho, nodesep=0.45, ranksep=0.
```
