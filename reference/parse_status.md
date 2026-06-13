# Checklist extraction status

One row per guideline for which a checklist extraction was attempted,
summarizing how reliable the extracted checklist is.

## Usage

``` r
parse_status
```

## Format

A data frame with columns:

- guideline_id:

  Foreign key to
  [guidelines](https://choxos.github.io/reportilo/reference/guidelines.md).

- n_files:

  Number of source files attempted.

- status:

  "parsed_ok", "partial" or "failed".

- n_items:

  Items in the chosen checklist.

- parse_confidence:

  Heuristic confidence from 0 to 1.

- parse_method:

  Extraction method used.

- verified:

  Logical; checklist was hand-verified via an override.

- needs_review:

  Logical; low confidence and not yet verified.

## Source

reportilo data pipeline (see `data-raw/`).
