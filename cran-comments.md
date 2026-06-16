# cran-comments

## Submission

This is a new submission (reportilo 0.1.0).

## Test environments

- local: macOS (aarch64-apple-darwin), R 4.6.0
- GitHub Actions: ubuntu-latest (R release, R devel), macOS-latest, windows-latest
- win-builder: R devel

(Confirm the GitHub Actions and win-builder runs before submitting.)

## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Ahmad Sofi-Mahmudi <ahmad.pub@gmail.com>'
  New submission.

The new-submission NOTE is expected. No other notes remain; the previously slow
`reportilo_export` example now uses a fast CSV export, with the Word example
moved to `\donttest{}`.

## Bundled data: provenance and licensing

reportilo bundles data derived from third-party sources. The provenance and the
rights position for each bundled dataset are documented in `inst/COPYRIGHTS` and
referenced from the `Copyright` field in `DESCRIPTION`. In summary:

- Guideline catalog metadata is factual bibliographic information derived from
  the EQUATOR Network reporting guideline library; reportilo's selection and
  arrangement is released under GPL-3 and each entry links to its source.
- Reporting checklist item text is a normalized, machine-readable representation
  of the published guideline documents. The wording remains the property of the
  respective guideline authors; reportilo does not claim copyright over it, links
  to each source, and removes any item whose terms do not permit redistribution.
- Flow diagram and risk-of-bias templates were authored for reportilo and are
  released under GPL-3.

Most bundled checklists are automatically extracted and are flagged as such;
only PRISMA 2020, CONSORT and STROBE are hand-verified. The extraction status and
confidence are recorded in the `parse_status` dataset and surfaced through
`reportilo_coverage()`, the user interfaces, and every export path.

## Reverse dependencies

None (new package).
