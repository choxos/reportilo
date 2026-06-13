import type { FlowNode, FlowEdge } from "../types";

// Port of reportilo's flowchart_dot(): build Graphviz DOT from the generic
// node/edge model, substituting {field} tokens with the user's counts. Kept in
// lock-step with R/flowchart-render.R so both front ends render identically.
export function flowchartDot(
  nodes: FlowNode[],
  edges: FlowEdge[],
  counts: Record<string, string>,
  background = "white",
): string {
  const visible = nodes.filter((n) => n.role !== "stage_title");

  const subst = (tmpl: string): string => {
    let s = tmpl;
    for (const [k, v] of Object.entries(counts)) {
      const val = v === undefined || v === null || v === "" ? "0" : v;
      s = s.split(`{${k}}`).join(val);
    }
    return s;
  };
  const esc = (s: string) => s.replace(/"/g, '\\"');

  const nodeLines = visible.map((n) => {
    const lbl = esc(subst(n.label_template));
    const fill = n.fill && n.fill !== "" ? n.fill : "#ffffff";
    const style =
      n.role === "exclusion_box"
        ? '"filled,rounded,dashed"'
        : '"filled,rounded"';
    return `"${n.node_id}" [label="${lbl}", fillcolor="${fill}", style=${style}];`;
  });

  const sideRank: Record<string, number> = {
    title: 0,
    left: 1,
    main: 2,
    right: 3,
  };
  const groups: Record<string, FlowNode[]> = {};
  for (const n of visible) {
    const key = `${n.stage_order}_${n.node_order}`;
    (groups[key] ||= []).push(n);
  }
  const rankLines: string[] = [];
  for (const key of Object.keys(groups)) {
    const grp = groups[key];
    if (grp.length < 2) continue;
    grp.sort((a, b) => (sideRank[a.side] ?? 9) - (sideRank[b.side] ?? 9));
    rankLines.push(
      `{rank=same; ${grp.map((n) => `"${n.node_id}"`).join("; ")}}`,
    );
  }

  const edgeLines = edges.map((e) => {
    const extra = e.edge_type === "exclude" ? " [constraint=false]" : "";
    return `"${e.from_node}" -> "${e.to_node}"${extra};`;
  });

  return [
    "digraph reportilo {",
    `  graph [rankdir=TB, splines=ortho, nodesep=0.45, ranksep=0.55, bgcolor="${background}"];`,
    '  node [shape=box, fontname="Helvetica", fontsize=10, margin="0.14,0.09"];',
    "  edge [arrowsize=0.7];",
    ...nodeLines.map((l) => "  " + l),
    ...rankLines.map((l) => "  " + l),
    ...edgeLines.map((l) => "  " + l),
    "}",
  ].join("\n");
}
