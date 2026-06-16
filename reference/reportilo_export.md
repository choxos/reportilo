# Export a checklist or flow diagram to a file

Write a filled
[reportilo_checklist](https://choxos.github.io/reportilo/reference/get_checklist.md)
or
[reportilo_flowchart](https://choxos.github.io/reportilo/reference/new_flowchart.md)
to Word, Excel, an image, or CSV. The output format is taken from
`format`, or inferred from the file extension.

## Usage

``` r
reportilo_export(x, file, format = NULL, ..., strict = FALSE, complete = FALSE)
```

## Arguments

- x:

  A `reportilo_checklist`, `reportilo_flowchart` or `reportilo_rob`.

- file:

  Output file path. Its extension sets the format unless `format` is
  given.

- format:

  Optional explicit format (e.g. `"docx"`). Defaults to the file
  extension.

- ...:

  Passed to the underlying writer. Flow diagrams and risk-of-bias plots
  accept `background` (`"white"` or `"transparent"`); flow diagrams also
  accept `width`, and risk-of-bias accepts `type`.

- strict:

  For flow diagrams: if `TRUE`, refuse to export when
  [`flowchart_consistency()`](https://choxos.github.io/reportilo/reference/flowchart_consistency.md)
  reports issues (otherwise a warning is issued and the file is still
  written). Default `FALSE`.

- complete:

  For flow diagrams: passed to
  [`flowchart_consistency()`](https://choxos.github.io/reportilo/reference/flowchart_consistency.md).
  If `TRUE`, also treat under-accounted conservation stages as issues
  (use for a final, fully filled diagram). Combine with `strict = TRUE`
  to block export of a final diagram that does not balance exactly.
  Default `FALSE`.

## Value

The output `file` path, invisibly.

## Details

Supported formats:

- Checklist:

  `docx`, `xlsx`, `csv`.

- Flow diagram:

  `png`, `svg`, `pdf`, `docx`, `xlsx` (the counts), `csv` (the counts).

- Risk of bias:

  `png`, `svg`, `pdf`, `docx`, `xlsx` (the table), `csv` (the table).
  Pass `type = "traffic_light"` (default) or `type = "summary"`, and
  `background = "transparent"` for no background.

Word and Excel export need the suggested packages `officer` +
`flextable` and `openxlsx` respectively; image export needs
`DiagrammeR`, `DiagrammeRsvg` and `rsvg`.

## See also

[`get_checklist()`](https://choxos.github.io/reportilo/reference/get_checklist.md),
[`new_flowchart()`](https://choxos.github.io/reportilo/reference/new_flowchart.md)

## Examples

``` r
# CSV export is fast and needs no extra packages.
chk <- get_checklist("strobe")
reportilo_export(chk, tempfile(fileext = ".csv"))

fc <- set_counts(new_flowchart("prisma_2020"), identified_db = 1200)
reportilo_export(fc, tempfile(fileext = ".csv"))

# Word export needs the 'officer' and 'flextable' packages.
# \donttest{
if (requireNamespace("officer", quietly = TRUE) &&
  requireNamespace("flextable", quietly = TRUE)) {
  reportilo_export(chk, tempfile(fileext = ".docx"))
}
# }
```
