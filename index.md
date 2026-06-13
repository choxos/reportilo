# reportilo

`reportilo` turns the [EQUATOR
Network](https://www.equator-network.org/) library of health research
reporting guidelines into a working toolkit. Find a guideline, fill in
its reporting checklist or flow diagram, and export the result to Word,
Excel or an image.

It ships three coordinated front ends from a single source of truth:

- the **R package** (data and functions documented here),
- a bundled, modern **Shiny application**
  ([`launch_reportilo()`](https://choxos.github.io/reportilo/reference/launch_reportilo.md)),
  and
- a companion **browser application** at
  <https://choxos.github.io/reportilo/app/>.

## What is inside

- A searchable **catalog** of the EQUATOR reporting guidelines.
- Machine-readable **checklists** for the major families (CONSORT,
  STROBE, PRISMA, SPIRIT, STARD and more), with provenance and
  parse-confidence for every item.
- Data-driven **flow diagram** templates: PRISMA 2020, CONSORT and
  STARD.
- An **export engine** for Word (`.docx`), Excel (`.xlsx`) and image
  (`.png` / `.svg` / `.pdf`) output.

## Installation

``` r

# install.packages("pak")
pak::pak("choxos/reportilo")
```

## Quick start

``` r

library(reportilo)

# 1. Find a guideline
search_guidelines("randomised trial")
guideline_info("consort")

# 2. Fill in its checklist
chk <- get_checklist("prisma-2020")
chk$response[1:3] <- c("1", "2", "2")

# 3. Export
reportilo_export(chk, "prisma-checklist.docx")

# Flow diagrams work the same way
fc <- new_flowchart("prisma_2020")
fc <- set_counts(fc, identified_db = 1200, screened = 980)
reportilo_export(fc, "prisma-flow.png")
```

Prefer to point and click?

``` r

launch_reportilo()
```

## Data provenance

Guideline metadata is derived from the EQUATOR Network reporting
guideline library. Checklist items are extracted from the guideline
source documents; guidelines without a machine-readable checklist remain
available as catalog entries that link to their original source. See
`parse_status` for per-guideline coverage.

## License

GPL-3. The reporting guidelines themselves are the work of their
respective authors and are subject to their own terms; `reportilo` links
to each source.
