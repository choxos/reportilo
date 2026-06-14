// Port of reportilo's flowchart_consistency(): accounting checks so the browser
// app flags inconsistent flow diagrams. Kept in step with R/flowchart.R.
//
// Each rule asserts a bound: sum(lhs) <= base - sum(minus). Bounds (not
// equality), so a partially filled draft is not flagged, but "more out than in"
// is. In complete mode a conservation rule is also checked for exact accounting
// (the count must equal the right-hand side): a rule with a `minus` term, or a
// split-only rule flagged `exact` (the parts must sum to the whole).

interface Rule {
  lhs: string[];
  base: string;
  minus?: string[];
  exact?: boolean;
}

const RULES: Record<string, Rule[]> = {
  prisma_2020: [
    { lhs: ["screened"], base: "identified_db", minus: ["duplicates", "auto_removed", "other_removed"] },
    { lhs: ["sought"], base: "screened", minus: ["excluded"] },
    { lhs: ["assessed"], base: "sought", minus: ["not_retrieved"] },
    { lhs: ["studies_included"], base: "assessed" },
  ],
  consort_2010: [
    { lhs: ["randomized"], base: "assessed", minus: ["excluded_total"] },
    // everyone randomized is allocated to one of the two arms (exact split)
    { lhs: ["alloc_int", "alloc_ctrl"], base: "randomized", exact: true },
    // per arm, allocated = received the allocation + did not receive it
    { lhs: ["alloc_int_received", "alloc_int_not"], base: "alloc_int", exact: true },
    { lhs: ["alloc_ctrl_received", "alloc_ctrl_not"], base: "alloc_ctrl", exact: true },
    { lhs: ["anal_int"], base: "alloc_int" },
    { lhs: ["anal_ctrl"], base: "alloc_ctrl" },
  ],
  stard_2015: [
    { lhs: ["index_test"], base: "eligible", minus: ["no_index"] },
    { lhs: ["reference"], base: "index_test", minus: ["no_reference"] },
    { lhs: ["analyzed"], base: "reference" },
  ],
  cohort_study: [
    { lhs: ["exposed", "unexposed"], base: "assessed", minus: ["excluded_total"] },
    // of each cohort, analyzed = entered - lost to follow-up - excluded
    { lhs: ["exp_analyzed"], base: "exposed", minus: ["exp_lost", "exp_excluded"] },
    { lhs: ["unexp_analyzed"], base: "unexposed", minus: ["unexp_lost", "unexp_excluded"] },
  ],
  case_control: [
    { lhs: ["cases_eligible"], base: "cases_identified" },
    { lhs: ["cases_enrolled"], base: "cases_eligible", minus: ["cases_excluded"] },
    { lhs: ["cases_analyzed"], base: "cases_enrolled" },
    { lhs: ["controls_eligible"], base: "controls_identified" },
    { lhs: ["controls_enrolled"], base: "controls_eligible", minus: ["controls_excluded"] },
    { lhs: ["controls_analyzed"], base: "controls_enrolled" },
  ],
  cross_sectional: [
    { lhs: ["invited"], base: "target", minus: ["not_eligible"] },
    { lhs: ["participated"], base: "invited", minus: ["nonresponse"] },
    { lhs: ["analyzed"], base: "participated" },
  ],
};

export function flowchartConsistency(
  templateId: string,
  counts: Record<string, string>,
  labels: Record<string, string>,
  complete = false,
): string[] {
  const rules = RULES[templateId];
  if (!rules) return [];
  const num = (f: string) => {
    const v = parseFloat(counts[f]);
    return Number.isFinite(v) ? v : NaN;
  };
  const lab = (k: string) => labels[k] ?? k;
  const issues: string[] = [];
  for (const r of rules) {
    const fields = [...r.lhs, r.base, ...(r.minus ?? [])];
    if (fields.map(num).some(Number.isNaN)) continue;
    const lhsVal = r.lhs.reduce((a, f) => a + num(f), 0);
    const rhsVal = num(r.base) - (r.minus ?? []).reduce((a, f) => a + num(f), 0);
    const lhsLab = r.lhs.map(lab).join(" + ");
    let rhsLab = lab(r.base);
    if (r.minus?.length) rhsLab += ` - ${r.minus.map(lab).join(" - ")}`;
    if (lhsVal > rhsVal) {
      issues.push(`${lhsLab} (${lhsVal}) exceeds ${rhsLab} (${rhsVal}).`);
    } else if (complete && (r.exact || r.minus) && lhsVal < rhsVal) {
      // conservation stage should balance: a shortfall means records unaccounted
      issues.push(
        `${lhsLab} (${lhsVal}) is less than ${rhsLab} (${rhsVal}); ${rhsVal - lhsVal} record(s) unaccounted.`,
      );
    }
  }
  return issues;
}
