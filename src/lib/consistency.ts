// Port of reportilo's flowchart_consistency(): template-specific sanity rules so
// the browser app flags impossible flow diagrams (kept in step with R/flowchart.R).

interface Rule {
  whole: string;
  parts: string[];
}

const RULES: Record<string, Rule[]> = {
  prisma_2020: [
    { whole: "identified_db", parts: ["screened"] },
    { whole: "screened", parts: ["sought"] },
    { whole: "sought", parts: ["assessed"] },
    { whole: "assessed", parts: ["studies_included"] },
  ],
  consort_2010: [
    { whole: "assessed", parts: ["randomized"] },
    { whole: "randomized", parts: ["alloc_int", "alloc_ctrl"] },
    { whole: "alloc_int", parts: ["anal_int"] },
    { whole: "alloc_ctrl", parts: ["anal_ctrl"] },
  ],
  stard_2015: [
    { whole: "eligible", parts: ["index_test"] },
    { whole: "index_test", parts: ["reference"] },
    { whole: "reference", parts: ["analyzed"] },
  ],
  cohort_study: [
    { whole: "assessed", parts: ["exposed", "unexposed"] },
    { whole: "exposed", parts: ["exp_analyzed"] },
    { whole: "unexposed", parts: ["unexp_analyzed"] },
  ],
  cross_sectional: [
    { whole: "target", parts: ["invited"] },
    { whole: "invited", parts: ["participated"] },
    { whole: "participated", parts: ["analyzed"] },
  ],
};

export function flowchartConsistency(
  templateId: string,
  counts: Record<string, string>,
  labels: Record<string, string>,
): string[] {
  const rules = RULES[templateId];
  if (!rules) return [];
  const num = (f: string) => {
    const v = parseFloat(counts[f]);
    return Number.isFinite(v) ? v : NaN;
  };
  const issues: string[] = [];
  for (const r of rules) {
    const whole = num(r.whole);
    const parts = r.parts.map(num);
    if ([whole, ...parts].some(Number.isNaN)) continue;
    const sum = parts.reduce((a, b) => a + b, 0);
    if (whole < sum) {
      const lab = (k: string) => labels[k] ?? k;
      issues.push(
        `${lab(r.whole)} (${whole}) is less than ${r.parts.map(lab).join(" + ")} (${sum}).`,
      );
    }
  }
  return issues;
}
