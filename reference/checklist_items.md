# Reporting guideline checklist items

Long-format checklist items for the guidelines that have a
machine-readable checklist. Each row is one item the author fills in
(typically with a page number or response).

## Usage

``` r
checklist_items
```

## Format

A data frame with one row per checklist item and columns:

- item_uid:

  Unique item identifier.

- guideline_id:

  Foreign key to
  [guidelines](https://choxos.github.io/reportilo/reference/guidelines.md).

- version, variant:

  Checklist version and source variant.

- section, section_order:

  Section grouping and order.

- item_no, item_order, sub_item:

  Item label, global order, sub-item.

- item_text:

  The checklist item / recommendation text.

- explanation:

  Elaboration text, when available.

- response_type:

  Expected response, e.g. "page_ref".

- source_url, source_format, parse_method, parse_confidence:

  Provenance.

- is_override:

  Logical; item came from a hand-verified override.

## Source

Extracted from EQUATOR guideline source documents.
