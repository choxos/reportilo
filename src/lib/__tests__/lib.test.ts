import { describe, it, expect } from "vitest";
import { toCsv, csvSafe } from "../download";
import { flowchartDot } from "../dot";
import { robTrafficLightSvg, robSummarySvg, type RobInput } from "../rob";
import { sanitizeSvg } from "../sanitize";
import type { FlowNode, FlowEdge } from "../../types";

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
