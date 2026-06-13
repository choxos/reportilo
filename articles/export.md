# Exporting to Word, Excel and images

One function,
[`reportilo_export()`](https://choxos.github.io/reportilo/reference/reportilo_export.md),
writes both checklists and flow diagrams. The output format comes from
the file extension, or from an explicit `format` argument.

## Supported formats

| Object | Formats |
|----|----|
| Checklist ([`get_checklist()`](https://choxos.github.io/reportilo/reference/get_checklist.md)) | `docx`, `xlsx`, `csv` |
| Flow diagram ([`new_flowchart()`](https://choxos.github.io/reportilo/reference/new_flowchart.md)) | `png`, `svg`, `pdf`, `docx`, `xlsx`, `csv` |

For flow diagrams, `xlsx` and `csv` export the counts table; `docx`
embeds the rendered diagram as an image.

## Checklists

``` r

chk <- get_checklist("strobe")
chk$response[1] <- "p3"

reportilo_export(chk, "strobe.docx") # formatted Word table
reportilo_export(chk, "strobe.xlsx") # styled Excel sheet
reportilo_export(chk, "strobe.csv") # plain CSV
```

## Flow diagrams

``` r

fc <- set_counts(new_flowchart("consort_2010"), assessed = 520, randomized = 350)

reportilo_export(fc, "consort.png", width = 1400) # high-resolution PNG
reportilo_export(fc, "consort.svg") # scalable vector
reportilo_export(fc, "consort.pdf") # print-ready PDF
reportilo_export(fc, "consort.docx") # Word with embedded image
```

## Choosing the format explicitly

When the path has no usable extension (for example a temp file), pass
`format`:

``` r

tmp <- tempfile()
reportilo_export(chk, tmp, format = "docx")
```

## Optional packages

Exporters load their dependencies only when used, keeping the core
install light:

- Word: `officer` and `flextable`
- Excel: `openxlsx`
- Images: `DiagrammeR`, `DiagrammeRsvg` and `rsvg`

If one is missing,
[`reportilo_export()`](https://choxos.github.io/reportilo/reference/reportilo_export.md)
stops with an informative message telling you what to install.
