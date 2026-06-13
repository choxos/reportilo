import { describe, it, expect } from "vitest";
import { toCsv, csvSafe } from "../download";
import { flowchartDot } from "../dot";
import { robTrafficLightSvg, robSummarySvg, type RobInput } from "../rob";
import { sanitizeSvg } from "../sanitize";
import { flowchartConsistency } from "../consistency";
import {
  validateChecklistFile,
  validateFlowchartFile,
  validateRobFile,
} from "../loadValidate";
import type {
  FlowNode,
  FlowEdge,
  Guideline,
  ChecklistItem,
  FlowCount,
  RobTool,
  RobDomain,
} from "../../types";

describe("csv safety", () => {
  it("neutralizes formula triggers", () => {
    expect(csvSafe("=HYPERLINK(1)")).toBe("'=HYPERLINK(1)");
    expect(csvSafe("+cmd")).toBe("'+cmd");
    expect(csvSafe("-1+2")).toBe("'-1+2");
    expect(csvSafe("@SUM(A1)")).toBe("'@SUM(A1)");
    expect(csvSafe("normal")).toBe("normal");
  });
  it("toCsv quotes and neutralizes", () => {
    const out = toCsv([{ Study: "=evil", Note: "a,b" }]);
    expect(out.split("\n")[1]).toContain("'=evil");
    expect(out).toContain('"a,b"');
  });
});

describe("flowchartDot", () => {
  const nodes: FlowNode[] = [
    { template_id: "t", node_id: "a", stage: "S", stage_order: 1, node_order: 1, role: "count_box", label_template: "n = {x}", side: "main", fill: "#fff" },
    { template_id: "t", node_id: "title", stage: "S", stage_order: 1, node_order: 0, role: "stage_title", label_template: "S", side: "title", fill: "#ccc" },
  ];
  const edges: FlowEdge[] = [];
  it("substitutes counts and respects background", () => {
    const dot = flowchartDot(nodes, edges, { x: "5" }, "transparent");
    expect(dot).toContain("n = 5");
    expect(dot).toContain('bgcolor="transparent"');
    expect(dot).toContain("digraph reportilo");
    expect(dot).not.toContain("title"); // stage_title nodes are not rendered
  });
});

describe("rob svg builders", () => {
  const input: RobInput = {
    name: "RoB 2",
    domains: [{ id: "D1", label: "Domain 1" }, { id: "Overall", label: "Overall" }],
    levels: [
      { level: "Low", color: "#02C100", symbol: "+", level_order: 1 },
      { level: "High", color: "#BF0000", symbol: "x", level_order: 3 },
    ],
    toolLevels: ["Low", "High"],
    rows: [{ study: "Study 1", values: { D1: "Low", Overall: "High" } }],
  };
  it("traffic light contains circles and the study label", () => {
    const svg = robTrafficLightSvg(input);
    expect(svg).toContain("<svg");
    expect(svg).toContain("Study 1");
    expect((svg.match(/<circle/g) || []).length).toBe(2);
  });
  it("summary contains bars", () => {
    const svg = robSummarySvg(input);
    expect(svg).toContain("<svg");
    expect((svg.match(/<rect/g) || []).length).toBeGreaterThan(0);
  });
});

describe("sanitizeSvg", () => {
  it("removes scripts and event handlers but keeps shapes", () => {
    const dirty = '<svg><script>alert(1)</script><circle cx="1" onload="x()"/></svg>';
    const clean = sanitizeSvg(dirty);
    expect(clean).not.toContain("<script");
    expect(clean).not.toContain("onload");
    expect(clean).toContain("circle");
  });
});

describe("flowchart consistency (webapp)", () => {
  const labels = { cases_identified: "Cases identified", cases_eligible: "Cases eligible" };
  it("flags case_control eligible > identified", () => {
    const issues = flowchartConsistency(
      "case_control",
      { cases_identified: "10", cases_eligible: "20" },
      labels,
    );
    expect(issues.length).toBeGreaterThan(0);
  });
  it("does not flag a partially filled diagram", () => {
    expect(flowchartConsistency("prisma_2020", { identified_db: "100" }, {})).toEqual([]);
  });
});

describe("save/load validators", () => {
  const guidelines = [
    { guideline_id: "prisma-2020", has_checklist: true },
    { guideline_id: "catalog-only", has_checklist: false },
  ] as unknown as Guideline[];
  const items = [
    { guideline_id: "prisma-2020", item_uid: "a" },
    { guideline_id: "prisma-2020", item_uid: "b" },
  ] as unknown as ChecklistItem[];
  const counts = [
    { template_id: "prisma_2020", count_field: "screened", is_reasons: false },
    { template_id: "prisma_2020", count_field: "reports_excluded", is_reasons: true },
  ] as unknown as FlowCount[];
  const tools = [
    { tool_id: "rob2", levels: "Low; Some concerns; High" },
  ] as unknown as RobTool[];
  const domains = [
    { tool_id: "rob2", domain_id: "D1" },
    { tool_id: "rob2", domain_id: "D2" },
  ] as unknown as RobDomain[];

  it("checklist: rejects unknown/ catalog-only guideline, accepts valid", () => {
    expect(() => validateChecklistFile({ guideline: "nope" }, guidelines)).toThrow();
    expect(() => validateChecklistFile({ guideline: "catalog-only" }, guidelines)).toThrow();
    expect(() => validateChecklistFile("not an object", guidelines)).toThrow();
    expect(validateChecklistFile({ guideline: "prisma-2020", responses: { a: "p1" } }, guidelines))
      .toEqual({ guideline: "prisma-2020", responses: { a: "p1" } });
  });

  it("checklist: drops stale item ids and coerces non-string responses", () => {
    const out = validateChecklistFile(
      { guideline: "prisma-2020", responses: { a: "p1", stale: "x", b: 5, c: { o: 1 } } },
      guidelines,
      items,
    );
    // "stale" is not a current item_uid -> dropped; b coerced to "5";
    // c maps to an object -> dropped (would otherwise crash .trim())
    expect(out.responses).toEqual({ a: "p1", b: "5" });
  });

  it("flowchart: drops unknown keys and negative counts, rejects unknown template", () => {
    expect(() => validateFlowchartFile({ template: "nope" }, counts, "prisma_2020")).toThrow();
    const out = validateFlowchartFile(
      { template: "prisma_2020", counts: { screened: "5", bogus: "9", reports_excluded: "R1 (n=2)" } },
      counts,
      "prisma_2020",
    );
    expect(out.counts).toEqual({ screened: "5", reports_excluded: "R1 (n=2)" });
    const neg = validateFlowchartFile({ counts: { screened: "-3" } }, counts, "prisma_2020");
    expect(neg.counts.screened).toBeUndefined();
  });

  it("rob: rejects unknown tool and non-array rows, sanitizes rows", () => {
    expect(() => validateRobFile({ tool: "nope", rows: [] }, tools)).toThrow();
    expect(() => validateRobFile({ tool: "rob2" }, tools)).toThrow();
    const out = validateRobFile({ tool: "rob2", rows: [{ study: "S1", values: { D1: "Low" } }] }, tools);
    expect(out.rows[0]).toEqual({ study: "S1", values: { D1: "Low" } });
  });

  it("rob: drops stale domains and blanks judgments invalid for the tool", () => {
    const out = validateRobFile(
      {
        tool: "rob2",
        rows: [
          { study: "S1", values: { D1: "Low", D9: "High", Overall: "Bogus", D2: { o: 1 } } },
        ],
      },
      tools,
      domains,
    );
    // D9 is not a domain of rob2 -> dropped; "Bogus" is not a valid level -> blanked;
    // D2 maps to an object -> blanked; D1 valid -> kept
    expect(out.rows[0]).toEqual({ study: "S1", values: { D1: "Low", Overall: "", D2: "" } });
  });
});
