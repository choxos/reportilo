import type { Guideline, FlowCount, RobTool } from "../types";

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

export function validateChecklistFile(input: unknown, guidelines: Guideline[]): ChecklistFile {
  const obj = asObject(input);
  const guideline = String(obj.guideline ?? "");
  if (!guidelines.some((g) => g.has_checklist && g.guideline_id === guideline)) {
    throw new Error(`Unknown guideline "${guideline}" in file.`);
  }
  const responses =
    obj.responses && typeof obj.responses === "object"
      ? (obj.responses as Record<string, string>)
      : {};
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

export function validateRobFile(input: unknown, tools: RobTool[]): RobFile {
  const obj = asObject(input);
  const tool = String(obj.tool ?? "");
  if (!tools.some((t) => t.tool_id === tool)) {
    throw new Error(`Unknown risk-of-bias tool "${tool}" in file.`);
  }
  if (!Array.isArray(obj.rows)) {
    throw new Error("Not a valid reportilo risk-of-bias file (no rows).");
  }
  const rows: RobRow[] = (obj.rows as unknown[]).map((r) => {
    const row = (r ?? {}) as Record<string, unknown>;
    return {
      study: String(row.study ?? ""),
      values:
        row.values && typeof row.values === "object"
          ? (row.values as Record<string, string>)
          : {},
    };
  });
  return { tool, rows };
}
