# Changelog

## reportilo 0.1.0

First development release.

- Package skeleton: documentation, tests, continuous integration
  (R-CMD-check) and a pkgdown website.
- [`launch_reportilo()`](https://choxos.github.io/reportilo/reference/launch_reportilo.md)
  starts the bundled Shiny application.
- [`flowchart_consistency()`](https://choxos.github.io/reportilo/reference/flowchart_consistency.md)
  gains a `complete` argument: with `complete = TRUE` it requires exact
  accounting (no silently unaccounted records) at every stage whose
  removals or exclusions are fully specified, for checking a finished
  diagram. The default remains bounds-only, suited to a draft.

Subsequent pull requests add the EQUATOR guideline catalog and checklist
data, the checklist and flow diagram API, the Word / Excel / image
export engine, the full Shiny application and a companion browser
application.
