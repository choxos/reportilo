// Manual layout editing for a rendered flow-diagram SVG. Drag any box to move it
// (the arrows touching it follow), and drag any arrow to bend it through a
// waypoint. Offsets are kept per node id and per edge ("from->to") so they can
// be reset. A box or arrow that has not been touched keeps Graphviz's original
// routing.

export interface NodeOffsets {
  [nodeId: string]: { dx: number; dy: number };
}
export interface EdgeOffsets {
  [edgeKey: string]: { dx: number; dy: number };
}

export interface FlowEditOptions {
  nodeOffsets: NodeOffsets;
  edgeOffsets: EdgeOffsets;
  onNodes: (next: NodeOffsets) => void;
  onEdges: (next: EdgeOffsets) => void;
}

const SVGNS = "http://www.w3.org/2000/svg";
const ARROW_ID = "reportilo-arrow";

interface Box {
  x: number;
  y: number;
  w: number;
  h: number;
}
interface Pt {
  x: number;
  y: number;
}

function ensureArrowMarker(svg: SVGSVGElement): void {
  if (svg.querySelector(`#${ARROW_ID}`)) return;
  let defs = svg.querySelector("defs");
  if (!defs) {
    defs = document.createElementNS(SVGNS, "defs");
    svg.insertBefore(defs, svg.firstChild);
  }
  const marker = document.createElementNS(SVGNS, "marker");
  marker.setAttribute("id", ARROW_ID);
  marker.setAttribute("viewBox", "0 0 10 10");
  marker.setAttribute("refX", "9");
  marker.setAttribute("refY", "5");
  marker.setAttribute("markerWidth", "7");
  marker.setAttribute("markerHeight", "7");
  marker.setAttribute("orient", "auto-start-reverse");
  const tip = document.createElementNS(SVGNS, "path");
  tip.setAttribute("d", "M0,0 L10,5 L0,10 z");
  tip.setAttribute("fill", "#555");
  marker.appendChild(tip);
  defs.appendChild(marker);
}

// point on box border toward (tx,ty)
function borderPoint(b: Box, tx: number, ty: number): Pt {
  const dx = tx - b.x;
  const dy = ty - b.y;
  if (dx === 0 && dy === 0) return { x: b.x, y: b.y };
  const sx = dx !== 0 ? b.w / 2 / Math.abs(dx) : Infinity;
  const sy = dy !== 0 ? b.h / 2 / Math.abs(dy) : Infinity;
  const s = Math.min(sx, sy);
  return { x: b.x + dx * s, y: b.y + dy * s };
}

export function enableFlowEditing(svg: SVGSVGElement, opts: FlowEditOptions): () => void {
  const { nodeOffsets, edgeOffsets, onNodes, onEdges } = opts;
  ensureArrowMarker(svg);

  const nodeEls = new Map<string, SVGGElement>();
  svg.querySelectorAll("g.node").forEach((g) => {
    const id = g.querySelector("title")?.textContent?.trim();
    if (id) nodeEls.set(id, g as SVGGElement);
  });

  const baseBox = (g: SVGGElement): Box => {
    const shape = (g.querySelector("path, polygon, ellipse, rect") ?? g) as SVGGraphicsElement;
    const bb = shape.getBBox();
    return { x: bb.x + bb.width / 2, y: bb.y + bb.height / 2, w: bb.width, h: bb.height };
  };
  const nodeBox = (id: string, override?: NodeOffsets): Box | null => {
    const g = nodeEls.get(id);
    if (!g) return null;
    const b = baseBox(g);
    const o = (override && override[id]) ?? nodeOffsets[id] ?? { dx: 0, dy: 0 };
    return { x: b.x + o.dx, y: b.y + o.dy, w: b.w, h: b.h };
  };

  // apply current node offsets
  nodeEls.forEach((g, id) => {
    g.style.cursor = "move";
    const o = nodeOffsets[id];
    if (o) g.setAttribute("transform", `translate(${o.dx},${o.dy})`);
    else g.removeAttribute("transform");
  });

  interface Edge {
    g: SVGGElement;
    from: string;
    to: string;
    key: string;
  }
  const edges: Edge[] = [];
  svg.querySelectorAll("g.edge").forEach((g) => {
    const parts = (g.querySelector("title")?.textContent ?? "").split("->");
    if (parts.length !== 2) return;
    const from = parts[0].trim();
    const to = parts[1].trim();
    edges.push({ g: g as SVGGElement, from, to, key: `${from}->${to}` });
  });

  // Draw an edge as a quadratic curve through a waypoint (box centers -> control
  // point = midpoint + offset), plus a transparent fat hit path for grabbing.
  const drawCurvedEdge = (e: Edge, nodeOverride?: NodeOffsets, edgeOverride?: { dx: number; dy: number }) => {
    const a = nodeBox(e.from, nodeOverride);
    const b = nodeBox(e.to, nodeOverride);
    if (!a || !b) return;
    const off = edgeOverride ?? edgeOffsets[e.key] ?? { dx: 0, dy: 0 };
    const ctrl = { x: (a.x + b.x) / 2 + off.dx, y: (a.y + b.y) / 2 + off.dy };
    const p1 = borderPoint(a, ctrl.x, ctrl.y);
    const p2 = borderPoint(b, ctrl.x, ctrl.y);
    const d = `M${p1.x},${p1.y} Q${ctrl.x},${ctrl.y} ${p2.x},${p2.y}`;
    e.g.querySelectorAll("path, polygon, line").forEach((el) => el.remove());
    const path = document.createElementNS(SVGNS, "path");
    path.setAttribute("d", d);
    path.setAttribute("fill", "none");
    path.setAttribute("stroke", "#555");
    path.setAttribute("stroke-width", "1");
    path.setAttribute("marker-end", `url(#${ARROW_ID})`);
    e.g.appendChild(path);
    const hit = document.createElementNS(SVGNS, "path");
    hit.setAttribute("d", d);
    hit.setAttribute("fill", "none");
    hit.setAttribute("stroke", "transparent");
    hit.setAttribute("stroke-width", "12");
    hit.style.cursor = "grab";
    e.g.appendChild(hit);
    e.g.dataset.custom = "1";
  };

  // give an untouched (Graphviz-routed) edge a transparent hit overlay so it can
  // be grabbed; first drag converts it to a curve
  const addHitOverlay = (e: Edge) => {
    if (e.g.querySelector("path[data-hit]")) return;
    const vis = e.g.querySelector("path");
    if (!vis) return;
    const hit = document.createElementNS(SVGNS, "path");
    hit.setAttribute("d", vis.getAttribute("d") ?? "");
    hit.setAttribute("data-hit", "1");
    hit.setAttribute("fill", "none");
    hit.setAttribute("stroke", "transparent");
    hit.setAttribute("stroke-width", "12");
    hit.style.cursor = "grab";
    e.g.appendChild(hit);
  };

  const isCustom = (e: Edge) =>
    !!edgeOffsets[e.key] || !!nodeOffsets[e.from] || !!nodeOffsets[e.to];

  edges.forEach((e) => (isCustom(e) ? drawCurvedEdge(e) : addHitOverlay(e)));

  const unitScale = () => {
    const rect = svg.getBoundingClientRect();
    const vb = svg.viewBox.baseVal;
    return vb && vb.width && rect.width ? vb.width / rect.width : 1;
  };

  type Drag =
    | { kind: "node"; id: string; g: SVGGElement; sx: number; sy: number; ox: number; oy: number }
    | { kind: "edge"; e: Edge; sx: number; sy: number; ox: number; oy: number };
  let drag: Drag | null = null;

  const cleanups: (() => void)[] = [];

  nodeEls.forEach((g, id) => {
    const fn = (ev: PointerEvent) => {
      ev.preventDefault();
      ev.stopPropagation();
      const o = nodeOffsets[id] ?? { dx: 0, dy: 0 };
      drag = { kind: "node", id, g, sx: ev.clientX, sy: ev.clientY, ox: o.dx, oy: o.dy };
    };
    g.addEventListener("pointerdown", fn);
    cleanups.push(() => g.removeEventListener("pointerdown", fn));
  });

  edges.forEach((e) => {
    const fn = (ev: PointerEvent) => {
      ev.preventDefault();
      ev.stopPropagation();
      const o = edgeOffsets[e.key] ?? { dx: 0, dy: 0 };
      drag = { kind: "edge", e, sx: ev.clientX, sy: ev.clientY, ox: o.dx, oy: o.dy };
    };
    e.g.addEventListener("pointerdown", fn);
    cleanups.push(() => e.g.removeEventListener("pointerdown", fn));
  });

  const onMove = (ev: PointerEvent) => {
    if (!drag) return;
    const k = unitScale();
    const dx = drag.ox + (ev.clientX - drag.sx) * k;
    const dy = drag.oy + (ev.clientY - drag.sy) * k;
    if (drag.kind === "node") {
      const id = drag.id;
      drag.g.setAttribute("transform", `translate(${dx},${dy})`);
      const override: NodeOffsets = { [id]: { dx, dy } };
      edges
        .filter((e) => e.from === id || e.to === id)
        .forEach((e) => drawCurvedEdge(e, override));
    } else {
      drawCurvedEdge(drag.e, undefined, { dx, dy });
    }
  };
  const onUp = (ev: PointerEvent) => {
    if (!drag) return;
    const k = unitScale();
    const dx = drag.ox + (ev.clientX - drag.sx) * k;
    const dy = drag.oy + (ev.clientY - drag.sy) * k;
    const d = drag;
    drag = null;
    if (d.kind === "node") onNodes({ ...nodeOffsets, [d.id]: { dx, dy } });
    else onEdges({ ...edgeOffsets, [d.e.key]: { dx, dy } });
  };
  svg.addEventListener("pointermove", onMove);
  window.addEventListener("pointerup", onUp);
  cleanups.push(() => svg.removeEventListener("pointermove", onMove));
  cleanups.push(() => window.removeEventListener("pointerup", onUp));

  return () => cleanups.forEach((fn) => fn());
}
