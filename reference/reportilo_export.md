# Export a checklist or flow diagram to a file

Write a filled
[reportilo_checklist](https://choxos.github.io/reportilo/reference/get_checklist.md)
or
[reportilo_flowchart](https://choxos.github.io/reportilo/reference/new_flowchart.md)
to Word, Excel, an image, or CSV. The output format is taken from
`format`, or inferred from the file extension.

## Usage

``` r
reportilo_export(x, file, format = NULL, ...)
```

## Arguments

- x:

  A `reportilo_checklist` or `reportilo_flowchart`.

- file:

  Output file path. Its extension sets the format unless `format` is
  given.

- format:

  Optional explicit format (e.g. `"docx"`). Defaults to the file
  extension.

- ...:

  Passed to the underlying writer (e.g. `width` for images).

## Value

The output `file` path, invisibly.

## Details

Supported formats:

- Checklist:

  `docx`, `xlsx`, `csv`.

- Flow diagram:

  `png`, `svg`, `pdf`, `docx`, `xlsx` (the counts), `csv` (the counts).

Word and Excel export need the suggested packages `officer` +
`flextable` and `openxlsx` respectively; image export needs
`DiagrammeR`, `DiagrammeRsvg` and `rsvg`.

## See also

[`get_checklist()`](https://choxos.github.io/reportilo/reference/get_checklist.md),
[`new_flowchart()`](https://choxos.github.io/reportilo/reference/new_flowchart.md)

## Examples

``` r
chk <- get_checklist("strobe")
reportilo_export(chk, tempfile(fileext = ".docx"))

fc <- set_counts(new_flowchart("prisma_2020"), identified_db = 1200)
reportilo_export(fc, tempfile(fileext = ".csv"))
```
