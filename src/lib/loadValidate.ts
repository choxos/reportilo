import type { Guideline, ChecklistItem, FlowCount, RobTool, RobDomain } from "../types";

// Validators for saved project files (save/load). Pure functions so they can be
// unit-tested; each throws a clear Error on malformed/unknown/stale input.

export interface ChecklistFile {
  guideline: string;
  responses: Record<string, string>;
}
export interface FlowchartFile {
  template: string;
  counts: Record<string, string>;
}
export interface RobRow {
  study: string;
  values: Record<string, string>;
}
export interface RobFile {
  tool: string;
  rows: RobRow[];
}

function asObject(x: unknown): Record<string, unknown> {
  if (!x || typeof x !== "object" || Array.isArray(x)) {
    throw new Error("File is not a valid reportilo project (expected an object).");
  }
  return x as Record<string, unknown>;
}

// A response value is only kept if it coerces to a primitive string; objects and
// arrays (a malformed file with a known item_uid mapped to an object) are
// dropped so downstream string operations like .trim() cannot crash.
function asResponseString(v: unknown): string | null {
  if (v == null || typeof v === "object") return null;
  return String(v);
}

export function validateChecklistFile(
  input: unknown,
  guidelines: Guideline[],
  items?: ChecklistItem[],
): ChecklistFile {
  const obj = asObject(input);
  const guideline = String(obj.guideline ?? "");
  if (!guidelines.some((g) => g.has_checklist && g.guideline_id === guideline)) {
    throw new Error(`Unknown guideline "${guideline}" in file.`);
  }
  const raw =
    obj.responses && typeof obj.responses === "object" && !Array.isArray(obj.responses)
      ? (obj.responses as Record<string, unknown>)
      : {};
  // when the checklist items are supplied, keep only keys that are current
  // item_uids for this guideline (drops stale ids from older versions)
  const allowed = items
    ? new Set(items.filter((i) => i.guideline_id === guideline).map((i) => i.item_uid))
    : null;
  const responses: Record<string, string> = {};
  for (const [k, v] of Object.entries(raw)) {
    if (allowed && !allowed.has(k)) continue;
    const s = asResponseString(v);
    if (s !== null) responses[k] = s;
  }
  return { guideline, responses };
}

export function validateFlowchartFile(
  input: unknown,
  counts: FlowCount[],
  fallbackTemplate: string,
): FlowchartFile {
  const obj = asObject(input);
  const template = typeof obj.template === "string" ? obj.template : fallbackTemplate;
  const tmplFields = counts.filter((c) => c.template_id === template);
  if (!tmplFields.length) throw new Error(`Unknown flow diagram template "${template}" in file.`);
  const reasons = new Set(tmplFields.filter((c) => c.is_reasons).map((c) => c.count_field));
  const allowed = new Set(tmplFields.map((c) => c.count_field));
  const cleaned: Record<string, string> = {};
  for (const [k, v] of Object.entries((obj.counts as Record<string, unknown>) ?? {})) {
    if (!allowed.has(k)) continue; // drop keys not in this template
    if (reasons.has(k)) {
      cleaned[k] = String(v ?? "");
    } else {
      const n = Number(v);
      if (Number.isInteger(n) && n >= 0) cleaned[k] = String(n); // reject negative/non-integer
    }
  }
  return { template, counts: cleaned };
}

export function validateRobFile(
  input: unknown,
  tools: RobTool[],
  domains?: RobDomain[],
): RobFile {
  const obj = asObject(input);
  const tool = String(obj.tool ?? "");
  const toolDef = tools.find((t) => t.tool_id === tool);
  if (!toolDef) {
    throw new Error(`Unknown risk-of-bias tool "${tool}" in file.`);
  }
  if (!Array.isArray(obj.rows)) {
    throw new Error("Not a valid reportilo risk-of-bias file (no rows).");
  }
  // allowed cell keys for this tool: its domains plus the always-present Overall.
  // When domains are not supplied, no domain filtering is done.
  const allowedDomains = domains
    ? new Set([
        ...domains.filter((d) => d.tool_id === tool).map((d) => d.domain_id),
        "Overall",
      ])
    : null;
  // allowed judgments for this tool (levels is a "; "-joined string), plus blank
  const allowedLevels = new Set(["", ...(toolDef.levels ?? "").split("; ").filter(Boolean)]);
  const rows: RobRow[] = (obj.rows as unknown[]).map((r) => {
    const row = (r ?? {}) as Record<string, unknown>;
    const rawValues =
      row.values && typeof row.values === "object" && !Array.isArray(row.values)
        ? (row.values as Record<string, unknown>)
        : {};
    const values: Record<string, string> = {};
    for (const [k, v] of Object.entries(rawValues)) {
      if (allowedDomains && !allowedDomains.has(k)) continue; // drop stale domains
      const s = v == null || typeof v === "object" ? "" : String(v);
      values[k] = allowedLevels.has(s) ? s : ""; // blank judgments not valid for this tool
    }
    return { study: String(row.study ?? ""), values };
  });
  return { tool, rows };
}
