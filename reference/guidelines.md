# EQUATOR reporting guideline registry

One row per reporting guideline in the EQUATOR Network library, with
metadata and a flag for whether a machine-readable checklist is bundled.

## Usage

``` r
guidelines
```

## Format

A data frame with one row per guideline and columns including:

- guideline_id:

  Stable unique identifier (slug).

- acronym:

  Guideline acronym, when one exists.

- title:

  Full title.

- equator_url:

  Canonical EQUATOR page for the guideline.

- study_design, clinical_area, language:

  Classification fields.

- reference, doi, pubmed_id, pub_date:

  Bibliographic metadata.

- provided_for, applies_to:

  Scope: what the guideline is provided for and whether it applies to
  the whole report or to sections.

- website_url, ee_papers, related_guidelines, prev_versions:

  Links and history.

- other_languages:

  Availability in additional languages.

- record_updated:

  Date the EQUATOR record was last updated.

- equator_hosted_count:

  Number of EQUATOR-hosted files.

- fulltext_urls, taxonomy_terms:

  List columns of character vectors.

- downloadable_files:

  List column of files (label, url, ext).

- has_checklist:

  Logical; is a bundled checklist available.

- checklist_tier:

  Factor: "checklist" or "catalog_only".

- category:

  Factor; EQUATOR main study type (e.g. "Randomised trials",
  "Observational studies"), with "Other" as the catch-all.

- category_order:

  Integer ordering of `category` for display.

- is_primary:

  Logical; the flagship guideline of its family (shown first).

## Source

EQUATOR Network reporting guideline library,
<https://www.equator-network.org/>.
