# reportilo data pipeline

This directory builds the package datasets from the EQUATOR Network reporting
guideline library. It is excluded from the built package (`.Rbuildignore`) and
the downloaded source documents are excluded from version control
(`.gitignore`); only the normalized, derived data is committed and shipped.

The pipeline is written entirely in **R**.

## Inputs (committed)

* `equator_guidelines.csv` — the EQUATOR reporting guideline library export
  (one row per guideline, metadata only).
* `flowcharts/prisma_2020_source.csv` — the PRISMA 2020 node model (from the
  PRISMA2020 package) used to build the flow diagram templates.
* `overrides/<guideline_id>.csv` — hand-verified checklists that take
  precedence over auto-extracted data.
* `id_map.csv` — frozen, stable `guideline_id` for every guideline.

## Pipeline (run in order, all R)

| Step | Script | Output |
| --- | --- | --- |
| 00 | `00_make_id_map.R` | `id_map.csv` |
| 01 | `01_build_manifest.R` | `download_manifest.csv` |
| 02 | `02_download.R` | `downloads/` (gitignored) |
| 03 | `03_detect_types.R` | type-checked manifest |
| 04 | `04_parse_checklists.R` | `parsed/` (gitignored) |
| 05 | `05_apply_overrides.R` | merged checklist items |
| 06 | `06_build_guidelines.R` | `guidelines` |
| 07 | `07_normalize_checklists.R` | `checklist_items` |
| 08 | `08_build_flowcharts.R` | `flowchart_*` |
| 09 | `09_save_rda.R` | `data/*.rda` |
| 10 | `10_export_json.R` | `inst/extdata/*.json` |
| 11 | `11_validation_report.R` | `reports/parse_review.html` (gitignored) |
| 12 | `12_build_rob.R` | risk-of-bias datasets (`data/rob_*.rda`) + `inst/extdata/rob.json` |

Output policy:

* `data/*.rda` — committed and shipped in the package tarball.
* `inst/extdata/*.json` — committed for the browser app, but `.Rbuildignore`d
  (not shipped in the tarball); copied to `public/data/` on the `webapp` branch.
* `data-raw/downloads/`, `parsed/`, `reports/` — gitignored scratch.

Run the whole thing with `Rscript data-raw/run_all.R`. Each step reads and
writes committed intermediates, so the `.rda` and JSON artifacts can be rebuilt
from `parsed/` without re-downloading.

## R packages used at build time

These are needed only to rebuild the data; they are not runtime dependencies of
the package.

* `curl` — download the guideline source files (with retries and a connection
  cap), driven from `download_manifest.csv`.
* `officer` — read tables from `.docx` checklists (`docx_summary()`).
* `pdftools` — read text and word positions from `.pdf` checklists.
* `xml2` — fall back to raw WordprocessingML when needed.
* `jsonlite` — write the `inst/extdata/*.json` parity files.
* `usethis`, `readr` — save datasets and read/write intermediates.

Legacy `.doc` (OLE2) files are converted to `.docx` with LibreOffice
(`soffice`) if it is available on the PATH; otherwise they are routed to a
manual override.
