# Changelog

## reportilo 0.1.0

First development release.

- Package skeleton: documentation, tests, continuous integration
  (R-CMD-check) and a pkgdown website.
- [`launch_reportilo()`](https://choxos.github.io/reportilo/reference/launch_reportilo.md)
  starts the bundled Shiny application.
- [`flowchart_consistency()`](https://choxos.github.io/reportilo/reference/flowchart_consistency.md)
  gains a `complete` argument: with `complete = TRUE` it requires exact
  accounting (no silently unaccounted records) at every conservation
  stage, both stages whose removals/exclusions are fully specified and
  split-only stages (the parts must sum to the whole, e.g. CONSORT
  randomized = intervention arm + control arm, and the per-arm received
  splits). The default remains bounds-only, suited to a draft.
- [`reportilo_export()`](https://choxos.github.io/reportilo/reference/reportilo_export.md)
  gains a matching `complete` argument for flow diagrams; combined with
  `strict = TRUE` it blocks export of a final diagram that does not
  balance exactly. The Shiny app exposes this as a “Final diagram”
  toggle.
- Checklist exports now carry their provenance: Word files gain a
  verification line, Excel files gain a “Provenance” sheet, and
  exporting an auto-extracted (not hand-verified) checklist in any
  format warns that each item should be verified against the original
  guideline.
- Bundled data rights are documented in `inst/COPYRIGHTS` (referenced
  from the `Copyright` field), and `cran-comments.md` records the
  provenance and licensing basis for submission.

Subsequent pull requests add the EQUATOR guideline catalog and checklist
data, the checklist and flow diagram API, the Word / Excel / image
export engine, the full Shiny application and a companion browser
application.
