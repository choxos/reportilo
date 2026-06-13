# Look up a single reporting guideline

Return a structured summary of one guideline: metadata, whether a
checklist is bundled, the flow diagram template (if any), and links to
source files.

## Usage

``` r
guideline_info(id)
```

## Arguments

- id:

  A `guideline_id` (or an unambiguous acronym).

## Value

An object of class `reportilo_guideline_info` (a list) with a print
method.

## See also

[`reportilo_guidelines()`](https://choxos.github.io/reportilo/reference/reportilo_guidelines.md),
[`get_checklist()`](https://choxos.github.io/reportilo/reference/get_checklist.md)

## Examples

``` r
guideline_info("prisma-2020")
#> PRISMA 2020 - The PRISMA 2020 statement: An updated guideline for reporting systematic reviews
#> ------------------------------------------------------------
#> Category     : Systematic reviews
#> Study design : Systematic reviews/Meta-analyses/Reviews/HTA/Overviews
#> Checklist    : yes (get_checklist())
#> Flow diagram : prisma_2020 (new_flowchart())
#> EQUATOR      : https://www.equator-network.org/reporting-guidelines/prisma/
#> Source files : 41
#>   - PRISMA 2020 checklist (Word): https://www.prisma-statement.org/s/PRISMA_2020_checklist-gely.docx
#>   - PRISMA 2020 checklist (PDF): https://www.prisma-statement.org/s/PRISMA_2020_checklist-djgh.pdf
#>   - PRISMA 2020 expanded checklist (PDF): https://www.prisma-statement.org/s/PRISMA_2020_expanded_checklist-rp3l.pdf
#>   - Italian (PDF): https://www.prisma-statement.org/s/PRISMA-2020-Italian.pdf
#>   - Croation (PDF): https://www.prisma-statement.org/s/PRISMA_2020_statement_Croatian.pdf
#>   - Greek (PDF): https://www.prisma-statement.org/s/PRISMA_2020_Statement_Greek.pdf
#>   - Japanese (PDF): https://www.prisma-statement.org/s/PRISMA_2020_Japanese.pdf
#>   - Brazilian Portuguese (PDF): https://www.prisma-statement.org/s/PRISMA-2020-statement-BRAZILIAN-PORTUGUESE.pdf
#>   - Spanish (PDF): https://www.prisma-statement.org/s/PRISMA-2020-Spanish.pdf
#>   - Chinese Simplified (Word): https://www.prisma-statement.org/s/PRISMA_2020_checklist_Chinese.docx
#>   - Chinese Traditional (PDF): https://www.prisma-statement.org/s/PRISMA_2020-checklist_Traditional-Chinese_update.pdf
#>   - French (Word): https://www.prisma-statement.org/s/PRISMA_2020_checklist_fr-b26g.docx
#>   - Greek (PDF): https://www.prisma-statement.org/s/PRISMA_2020_checklist_Greek.pdf
#>   - Japanese (PDF): https://www.prisma-statement.org/s/PRISMA-Japanese-Table-1-PRISMA-2020-item-checklist.pdf
#>   - Korean (Word): https://www.prisma-statement.org/s/PRISMA_2020_Korean_Checklist-dyx5.docx
#>   - European Portuguese (Word): https://www.prisma-statement.org/s/PRISMA-2020-checklist-EUROPEAN-PORTUGUESE-8rrx.docx
#>   - Turkish (PDF): https://www.prisma-statement.org/s/PRISMA-2020-checklist-Turkish-version.pdf
#>   - Chinese Simplified (Word): https://www.prisma-statement.org/s/PRISMA_2020_abstract_checklist_Chinese.docx
#>   - Chinese Traditional (PDF): https://www.prisma-statement.org/s/PRISMA_2020_Abs-checklist_Traditional-Chinese_new.pdf
#>   - Japanese (PDF): https://www.prisma-statement.org/s/PRISMA-Japanese-Table-2-PRISMA-2020-for-Abstracts-checklist.pdf
#>   - Korean (Word): https://www.prisma-statement.org/s/PRISMA_2020_Korean_Abstract_Checklist-jna2.docx
#>   - European Portuguese (Word): https://www.prisma-statement.org/s/PRISMA-2020-abstract-checklist-EUROPEAN-PORTUGUESE-cytw.docx
#>   - Turkish (PDF): https://www.prisma-statement.org/s/PRISMA-2020-for-Abstract-checklist-Turkish-version.pdf
#>   - German (PDF): http://www.prisma-statement.org/documents/PRISMA%20German%20Statement.pdf
#>   - Italian (PDF): http://www.prisma-statement.org/documents/PRISMA%20Italian%20Statement.pdf
#>   - Korean (PDF): http://www.prisma-statement.org/documents/PRISMA%20Korean%20checklist.pdf
#>   - Portuguese (PDF): http://www.prisma-statement.org/documents/PRISMA%20Portugese%20checklist.pdf
#>   - Russian (PDF): http://www.prisma-statement.org/documents/PRISMA%20Russian%20checklist.pdf
#>   - German (PDF): http://www.prisma-statement.org/documents/PRISMA%20German%20checklist.pdf
#>   - Japanese (PDF): http://www.prisma-statement.org/documents/PRISMA%20Japanese%20checklist.pdf
#>   - Turkish (PDF): http://www.prisma-statement.org/documents/PRISMA%20Turkish%20checklist.pdf
#>   - Italian (PDF): http://www.prisma-statement.org/documents/PRISMA%20Italian%20checklist.pdf
#>   - French (PDF): http://www.prisma-statement.org/documents/PRISMA%20French%20Flow%20Diagram.pdf
#>   - German (PDF): http://www.prisma-statement.org/documents/PRISMA%20German%20flow%20diagram.pdf
#>   - Italian (PDF): http://www.prisma-statement.org/documents/PRISMA%20Italian%20flow%20diagram.pdf
#>   - Korean (PDF): http://www.prisma-statement.org/documents/PRISMA%20Korean%20flow%20diagram.pdf
#>   - Russian (PDF): http://www.prisma-statement.org/documents/PRISMA%20Russian%20flow%20diagram.pdf
#>   - Japanese (PDF): http://www.prisma-statement.org/documents/PRISMA%20Japanese%20flow%20diagram.pdf
#>   - Turkish (PDF): http://www.prisma-statement.org/documents/PRISMA%20Turkish%20flow%20diagram.pdf
#>   - Portuguese (PDF): http://www.prisma-statement.org/documents/PRISMA%20Portugese%20flow%20diagram.pdf
#>   - Italian (PDF): http://www.prisma-statement.org/documents/PRISMA%20Italian%20EandE.pdf
```
