#' EQUATOR reporting guideline registry
#'
#' One row per reporting guideline in the EQUATOR Network library, with metadata
#' and a flag for whether a machine-readable checklist is bundled.
#'
#' @format A data frame with one row per guideline and columns including:
#' \describe{
#'   \item{guideline_id}{Stable unique identifier (slug).}
#'   \item{acronym}{Guideline acronym, when one exists.}
#'   \item{title}{Full title.}
#'   \item{equator_url}{Canonical EQUATOR page for the guideline.}
#'   \item{study_design, clinical_area, language}{Classification fields.}
#'   \item{reference, doi, pubmed_id, pub_date}{Bibliographic metadata.}
#'   \item{provided_for, applies_to}{Scope: what the guideline is provided for
#'     and whether it applies to the whole report or to sections.}
#'   \item{website_url, ee_papers, related_guidelines, prev_versions}{Links and history.}
#'   \item{other_languages}{Availability in additional languages.}
#'   \item{record_updated}{Date the EQUATOR record was last updated.}
#'   \item{equator_hosted_count}{Number of EQUATOR-hosted files.}
#'   \item{fulltext_urls, taxonomy_terms}{List columns of character vectors.}
#'   \item{downloadable_files}{List column of files (label, url, ext).}
#'   \item{has_checklist}{Logical; is a bundled checklist available.}
#'   \item{checklist_tier}{Factor: "checklist" or "catalog_only".}
#'   \item{category}{Factor; EQUATOR main study type (e.g. "Randomised trials",
#'     "Observational studies"), with "Other" as the catch-all.}
#'   \item{category_order}{Integer ordering of `category` for display.}
#'   \item{is_primary}{Logical; the flagship guideline of its family (shown first).}
#' }
#' @source EQUATOR Network reporting guideline library,
#'   \url{https://www.equator-network.org/}.
"guidelines"

#' Reporting guideline checklist items
#'
#' Long-format checklist items for the guidelines that have a machine-readable
#' checklist. Each row is one item the author fills in (typically with a page
#' number or response).
#'
#' @format A data frame with one row per checklist item and columns:
#' \describe{
#'   \item{item_uid}{Unique item identifier.}
#'   \item{guideline_id}{Foreign key to [guidelines].}
#'   \item{version, variant}{Checklist version and source variant.}
#'   \item{section, section_order}{Section grouping and order.}
#'   \item{item_no, item_order, sub_item}{Item label, global order, sub-item.}
#'   \item{item_text}{The checklist item / recommendation text.}
#'   \item{explanation}{Elaboration text, when available.}
#'   \item{response_type}{Expected response, e.g. "page_ref".}
#'   \item{source_url, source_format, parse_method, parse_confidence}{Provenance.}
#'   \item{is_override}{Logical; item came from a hand-verified override.}
#' }
#' @source Extracted from EQUATOR guideline source documents.
"checklist_items"

#' Checklist extraction status
#'
#' One row per guideline for which a checklist extraction was attempted,
#' summarizing how reliable the extracted checklist is.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{guideline_id}{Foreign key to [guidelines].}
#'   \item{n_files}{Number of source files attempted.}
#'   \item{status}{"parsed_ok", "partial" or "failed".}
#'   \item{n_items}{Items in the chosen checklist.}
#'   \item{parse_confidence}{Heuristic confidence from 0 to 1.}
#'   \item{parse_method}{Extraction method used.}
#'   \item{verified}{Logical; checklist was hand-verified via an override.}
#'   \item{needs_review}{Logical; low confidence and not yet verified.}
#' }
#' @source reportilo data pipeline (see `data-raw/`).
"parse_status"

#' Flow diagram template nodes
#'
#' Boxes for the bundled flow diagram templates (PRISMA 2020, CONSORT 2010,
#' STARD 2015). Labels embed `{count_field}` tokens that are replaced with
#' user-supplied counts at render time.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{template_id}{Template identifier.}
#'   \item{node_id}{Node identifier within the template.}
#'   \item{stage, stage_order, node_order}{Grouping and layout order.}
#'   \item{role}{"stage_title", "count_box", "exclusion_box" or "arm".}
#'   \item{label_template}{Box label with `{field}` placeholders.}
#'   \item{side}{"main", "left", "right" or "title".}
#'   \item{fill, tooltip}{Style and optional tooltip.}
#' }
#' @source reportilo (PRISMA 2020 derived from the PRISMA2020 package model).
"flowchart_nodes"

#' Flow diagram template edges
#'
#' Connections between [flowchart_nodes] for each template.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{template_id}{Template identifier.}
#'   \item{from_node, to_node}{Edge endpoints (node ids).}
#'   \item{edge_type}{"flow", "exclude" or "merge".}
#'   \item{style}{Line style.}
#' }
#' @source reportilo.
"flowchart_edges"

#' Flow diagram fillable counts
#'
#' The numbers (and reason lists) a user fills in for each flow diagram template,
#' with example defaults so a template renders out of the box.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{template_id}{Template identifier.}
#'   \item{count_field}{Field name referenced by node labels.}
#'   \item{label}{Human-readable label for the input.}
#'   \item{value}{Example/default value (character).}
#'   \item{field_order}{Display order.}
#'   \item{is_reasons}{Logical; field holds a semicolon-separated reasons list.}
#' }
#' @source reportilo.
"flowchart_counts"

#' Flow diagram templates
#'
#' Registry of the bundled flow diagram templates.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{template_id}{Template identifier.}
#'   \item{name}{Display name.}
#'   \item{guideline_id}{Linked guideline in [guidelines].}
#'   \item{study_type}{Study type the diagram applies to.}
#'   \item{n_count_fields}{Number of fillable fields.}
#' }
#' @source reportilo.
"flowchart_templates"

#' Risk-of-bias assessment tools
#'
#' The supported risk-of-bias tools.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{tool_id}{Tool identifier (e.g. "rob2", "robins_i").}
#'   \item{name}{Display name.}
#'   \item{study_type}{Study type the tool applies to.}
#'   \item{n_domains}{Number of domains.}
#'   \item{levels}{Allowed judgment levels, "; "-separated, in order.}
#' }
#' @source robvis (McGuinness & Higgins) and the underlying tool manuals.
"rob_tools"

#' Risk-of-bias tool domains
#'
#' The domains of each risk-of-bias tool (see [rob_tools]).
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{tool_id}{Tool identifier.}
#'   \item{domain_id}{Domain id within the tool (e.g. "D1").}
#'   \item{label}{Full domain description.}
#'   \item{domain_order}{Display order.}
#' }
#' @source robvis and the underlying tool manuals.
"rob_domains"

#' Risk-of-bias judgment levels
#'
#' The judgment levels used across the tools, with the color and symbol used to
#' render them (following robvis).
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{level}{Judgment level (e.g. "Low", "High", "Critical").}
#'   \item{color}{Hex fill color.}
#'   \item{symbol}{Symbol drawn on the traffic-light point.}
#'   \item{level_order}{Severity rank for ordering summary bars.}
#' }
#' @source robvis color scheme.
"rob_levels"

#' Example risk-of-bias assessments
#'
#' A small example assessment for each tool, used to seed [reportilo_rob()].
#'
#' @format A data frame in long format with columns:
#' \describe{
#'   \item{tool_id}{Tool identifier.}
#'   \item{study}{Study label.}
#'   \item{domain_id}{Domain id (or "Overall").}
#'   \item{judgment}{The judgment level.}
#' }
#' @source reportilo (illustrative).
"rob_example"
