# reportilo: Fill in and Export EQUATOR Reporting Guidelines and Flow Diagrams

A toolkit for the health research reporting guidelines curated by the
EQUATOR Network. 'reportilo' bundles a searchable catalog of reporting
guidelines, machine-readable checklists for the major families (such as
CONSORT, STROBE, PRISMA, SPIRIT and STARD), and data-driven flow diagram
templates (PRISMA 2020, CONSORT and STARD). Users fill in checklist
responses and flow diagram counts and export the result to Word, Excel
or image files. A bundled 'shiny' application provides a point-and-click
front end, and the same data powers a companion browser application.

## Details

The EQUATOR Network (Enhancing the QUAlity and Transparency Of health
Research) maintains the canonical library of reporting guidelines for
health research. `reportilo` turns that library into a working toolkit:
a searchable catalog of every guideline, machine-readable checklists for
the major families, and data-driven flow diagram templates.

The package is organized around three verbs:

- **Find** a guideline with
  [`reportilo_guidelines()`](https://choxos.github.io/reportilo/reference/reportilo_guidelines.md),
  [`search_guidelines()`](https://choxos.github.io/reportilo/reference/search_guidelines.md)
  and
  [`guideline_info()`](https://choxos.github.io/reportilo/reference/guideline_info.md).

- **Fill** a checklist with
  [`get_checklist()`](https://choxos.github.io/reportilo/reference/get_checklist.md)
  /
  [`new_checklist()`](https://choxos.github.io/reportilo/reference/get_checklist.md),
  or a flow diagram with
  [`new_flowchart()`](https://choxos.github.io/reportilo/reference/new_flowchart.md)
  and
  [`set_counts()`](https://choxos.github.io/reportilo/reference/set_counts.md).

- **Export** the filled object to Word, Excel or an image with
  [`reportilo_export()`](https://choxos.github.io/reportilo/reference/reportilo_export.md).

The data and the rendering logic are kept separate from the user
interface so that the same checklists and flow diagrams drive the
package functions, the bundled Shiny application
([`launch_reportilo()`](https://choxos.github.io/reportilo/reference/launch_reportilo.md))
and a companion browser application.

## Data provenance

Guideline metadata is derived from the EQUATOR Network reporting
guideline library. Checklist items are extracted from the guideline
source documents; each item records its provenance and a
parse-confidence score, and the coverage of each guideline is summarized
in `parse_status`. Guidelines without a machine-readable checklist
remain available as catalog entries that link to their original source.

## References

EQUATOR Network. The EQUATOR Network: enhancing the quality and
transparency of health research. <https://www.equator-network.org/>

## See also

Useful links:

- <https://github.com/choxos/reportilo>

- <https://choxos.github.io/reportilo/>

- Report bugs at <https://github.com/choxos/reportilo/issues>

## Author

**Maintainer**: Ahmad Sofi-Mahmudi <ahmad.pub@gmail.com>
([ORCID](https://orcid.org/0000-0001-6829-0823))

Authors:

- Ahmad Sofi-Mahmudi <ahmad.pub@gmail.com>
  ([ORCID](https://orcid.org/0000-0001-6829-0823))
