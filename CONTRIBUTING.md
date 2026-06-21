# Contributing to reportilo

Thank you for helping improve `reportilo`. This project includes an R package,
a bundled Shiny app, a companion browser app, and curated reporting-guideline
data. Contributions should preserve correctness, provenance, and honest claims
about checklist coverage.

## Before You Start

- Open an issue for substantial changes before starting implementation.
- Keep public claims consistent with the current data: checklist coverage is
  partial and only a small core is hand-verified.
- Do not add guideline or checklist text unless its source, provenance, and
  redistribution rights are clear.
- Keep generated artifacts, downloaded source files, local audit files,
  `node_modules`, `dist`, and R check/build outputs out of commits.

## Development Setup

For R package work:

```r
install.packages(c("devtools", "testthat", "rcmdcheck"))
devtools::load_all()
testthat::test_local()
```

For browser app work, use the `webapp` branch:

```bash
npm ci
npm run typecheck
npm test
npm run build
npm audit --omit=dev --audit-level=high
```

## Pull Request Checklist

Before opening a pull request:

- Run the relevant checks for the surface you changed.
- Add or update tests when behavior changes.
- Update documentation when user-facing behavior, exported functions, data
  provenance, or checklist coverage changes.
- For flow diagram changes, check R, Shiny, and browser parity.
- For data changes, document the source and rebuild path.
- For CRAN-facing changes, run `R CMD build` and `R CMD check --as-cran` when
  practical.

## Reporting Data Problems

When reporting a checklist, catalog, flowchart, or risk-of-bias data issue,
include:

- the guideline or tool identifier;
- the source document or URL;
- the expected item/count/domain text;
- the observed `reportilo` output;
- whether the issue affects R, Shiny, browser app, or all surfaces.

## Code Style

- Prefer small, focused changes.
- Keep R user-facing messages clear and actionable.
- Keep browser UI controls accessible and usable on small screens.
- Avoid overstating automated extraction quality or guideline completeness.
