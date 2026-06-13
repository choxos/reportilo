# Launch the reportilo Shiny application

Starts the bundled Shiny application, a point-and-click front end to the
package: browse the EQUATOR guideline catalog, fill in a reporting
checklist or a flow diagram, and download the result as Word, Excel or
an image.

## Usage

``` r
launch_reportilo(...)
```

## Arguments

- ...:

  Additional arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Value

Called for its side effect of launching the app; invisibly returns the
value of [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Details

The application requires the suggested packages `shiny`, `bslib`, `DT`
and `DiagrammeR`. Install them with
`install.packages(c("shiny", "bslib", "DT", "DiagrammeR"))` if they are
not already available. Word, Excel and image downloads additionally use
`officer`, `flextable`, `openxlsx`, `DiagrammeRsvg` and `rsvg`.

## Examples

``` r
if (FALSE) { # interactive()
launch_reportilo()
}
```
