// Manual layout editing for a rendered flow-diagram SVG: drag any box to a new
// position and the arrows touching it follow. Offsets are kept per node id so
// they can be persisted (save/load) and reset. Unmoved edges keep Graphviz's
// original routing; an edge touching a moved box is redrawn as a straight
// connector with an arrowhead.

export interface NodeOffsets {
  [nodeId: string]: { dx: number; dy: number };
}

const SVGNS = "http://www.w3.org/2000/svg";
const ARROW_ID = "reportilo-arrow";

interface Box {
  x: number;
  y: number;
  w: number;
  h: number;
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

// point on box border in the direction of (tx,ty)
function borderPoint(b: Box, tx: number, ty: number): { x: number; y: number } {
  const dx = tx - b.x;
  const dy = ty - b.y;
  if (dx === 0 && dy === 0) return { x: b.x, y: b.y };
  const sx = dx !== 0 ? b.w / 2 / Math.abs(dx) : Infinity;
  const sy = dy !== 0 ? b.h / 2 / Math.abs(dy) : Infinity;
  const s = Math.min(sx, sy);
  return { x: b.x + dx * s, y: b.y + dy * s };
}

// Wire drag editing onto a freshly rendered SVG. Returns a cleanup function that
// removes the listeners it added (node-level listeners die with the DOM).
export function enableFlowEditing(
  svg: SVGSVGElement,
  offsets: NodeOffsets,
  onCommit: (next: NodeOffsets) => void,
): () => void {
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
  const boxOf = (id: string, override?: { dx: number; dy: number }): Box | null => {
    const g = nodeEls.get(id);
    if (!g) return null;
    const b = baseBox(g);
    const o = override ?? offsets[id] ?? { dx: 0, dy: 0 };
    return { x: b.x + o.dx, y: b.y + o.dy, w: b.w, h: b.h };
  };

  // apply current offsets to node groups
  nodeEls.forEach((g, id) => {
    const o = offsets[id];
    g.style.cursor = "move";
    if (o) g.setAttribute("transform", `translate(${o.dx},${o.dy})`);
    else g.removeAttribute("transform");
  });

  // index edges by their endpoints (title is "from->to")
  const edges: { g: SVGGElement; from: string; to: string }[] = [];
  svg.querySelectorAll("g.edge").forEach((g) => {
    const parts = (g.querySelector("title")?.textContent ?? "").split("->");
    if (parts.length === 2) edges.push({ g: g as SVGGElement, from: parts[0].trim(), to: parts[1].trim() });
  });

  const drawStraight = (g: SVGGElement, a: Box, b: Box) => {
    const p1 = borderPoint(a, b.x, b.y);
    const p2 = borderPoint(b, a.x, a.y);
    g.querySelectorAll("path, polygon, line").forEach((el) => el.remove());
    const line = document.createElementNS(SVGNS, "line");
    line.setAttribute("x1", String(p1.x));
    line.setAttribute("y1", String(p1.y));
    line.setAttribute("x2", String(p2.x));
    line.setAttribute("y2", String(p2.y));
    line.setAttribute("stroke", "#555");
    line.setAttribute("stroke-width", "1");
    line.setAttribute("marker-end", `url(#${ARROW_ID})`);
    g.appendChild(line);
  };

  const rerouteFor = (id: string, override?: { dx: number; dy: number }) => {
    for (const e of edges) {
      if (e.from !== id && e.to !== id) continue;
      const a = boxOf(e.from, e.from === id ? override : undefined);
      const b = boxOf(e.to, e.to === id ? override : undefined);
      if (a && b) drawStraight(e.g, a, b);
    }
  };

  // redraw any edge already touching a moved node (from persisted offsets)
  for (const id of Object.keys(offsets)) rerouteFor(id);

  // pixel delta -> SVG user units
  const unitScale = () => {
    const rect = svg.getBoundingClientRect();
    const vb = svg.viewBox.baseVal;
    return vb && vb.width && rect.width ? vb.width / rect.width : 1;
  };

  let drag: { id: string; g: SVGGElement; sx: number; sy: number; ox: number; oy: number } | null = null;

  const onMove = (ev: PointerEvent) => {
    if (!drag) return;
    const k = unitScale();
    const dx = drag.ox + (ev.clientX - drag.sx) * k;
    const dy = drag.oy + (ev.clientY - drag.sy) * k;
    drag.g.setAttribute("transform", `translate(${dx},${dy})`);
    rerouteFor(drag.id, { dx, dy });
  };
  const onUp = (ev: PointerEvent) => {
    if (!drag) return;
    const k = unitScale();
    const dx = drag.ox + (ev.clientX - drag.sx) * k;
    const dy = drag.oy + (ev.clientY - drag.sy) * k;
    const id = drag.id;
    drag = null;
    onCommit({ ...offsets, [id]: { dx, dy } });
  };

  const downHandlers: { g: SVGGElement; fn: (e: PointerEvent) => void }[] = [];
  nodeEls.forEach((g, id) => {
    const fn = (ev: PointerEvent) => {
      ev.preventDefault();
      ev.stopPropagation();
      const o = offsets[id] ?? { dx: 0, dy: 0 };
      drag = { id, g, sx: ev.clientX, sy: ev.clientY, ox: o.dx, oy: o.dy };
    };
    g.addEventListener("pointerdown", fn);
    downHandlers.push({ g, fn });
  });
  svg.addEventListener("pointermove", onMove);
  window.addEventListener("pointerup", onUp);

  return () => {
    downHandlers.forEach(({ g, fn }) => g.removeEventListener("pointerdown", fn));
    svg.removeEventListener("pointermove", onMove);
    window.removeEventListener("pointerup", onUp);
  };
}
