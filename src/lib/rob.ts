import type { RobLevel } from "../types";

// Build robvis-style risk-of-bias figures as SVG, in the browser. Kept visually
// in line with the R package's rob_traffic_light() / rob_summary().

export interface RobInput {
  name: string;
  domains: { id: string; label: string }[]; // includes "Overall" last
  levels: RobLevel[]; // global level table (color + symbol)
  toolLevels: string[]; // ordered allowed levels for this tool
  rows: { study: string; values: Record<string, string> }[];
}

const esc = (s: string) =>
  (s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

function color(levels: RobLevel[], lvl: string): string {
  return levels.find((l) => l.level === lvl)?.color ?? "#cccccc";
}
function symbol(levels: RobLevel[], lvl: string): string {
  return levels.find((l) => l.level === lvl)?.symbol ?? "";
}

export function robTrafficLightSvg(input: RobInput, transparent = false): string {
  const { name, domains, levels, rows } = input;
  const cell = 48;
  const r = 17;
  const leftMargin = 120;
  const topMargin = 58;
  const nCols = domains.length;
  const nRows = rows.length;
  const overallIdx = domains.findIndex((d) => d.id === "Overall");

  // wrapped caption: domain id = label
  const caption = domains
    .filter((d) => d.id !== "Overall")
    .map((d) => `${d.id} = ${d.label}`);
  const capH = caption.length * 13 + 8;

  const width = leftMargin + nCols * cell + 20;
  const height = topMargin + nRows * cell + 16 + capH;

  const parts: string[] = [];
  parts.push(
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" font-family="Helvetica, Arial, sans-serif">`,
  );
  if (!transparent) {
    parts.push(`<rect width="${width}" height="${height}" fill="#ffffff"/>`);
  }
  parts.push(
    `<text x="${leftMargin}" y="22" font-size="15" font-weight="bold">${esc(name)}</text>`,
  );

  // column headers
  domains.forEach((d, c) => {
    const cx = leftMargin + c * cell + cell / 2;
    parts.push(
      `<text x="${cx}" y="${topMargin - 6}" font-size="11" font-weight="bold" text-anchor="middle">${esc(d.id)}</text>`,
    );
  });
  // divider before Overall
  if (overallIdx > 0) {
    const dx = leftMargin + overallIdx * cell;
    parts.push(
      `<line x1="${dx}" y1="${topMargin}" x2="${dx}" y2="${topMargin + nRows * cell}" stroke="#cccccc"/>`,
    );
  }

  rows.forEach((row, ri) => {
    const cy = topMargin + ri * cell + cell / 2;
    parts.push(
      `<text x="${leftMargin - 10}" y="${cy + 4}" font-size="12" text-anchor="end">${esc(row.study)}</text>`,
    );
    domains.forEach((d, c) => {
      const cx = leftMargin + c * cell + cell / 2;
      const lvl = row.values[d.id] ?? "";
      parts.push(
        `<circle cx="${cx}" cy="${cy}" r="${r}" fill="${color(levels, lvl)}" stroke="#555" stroke-width="1"/>`,
      );
      const sym = symbol(levels, lvl);
      if (sym) {
        parts.push(
          `<text x="${cx}" y="${cy + 5}" font-size="14" font-weight="bold" text-anchor="middle">${esc(sym)}</text>`,
        );
      }
    });
  });

  // caption
  const capY = topMargin + nRows * cell + 16;
  caption.forEach((line, i) => {
    parts.push(
      `<text x="${leftMargin}" y="${capY + i * 13}" font-size="9" fill="#444">${esc(line)}</text>`,
    );
  });

  parts.push("</svg>");
  return parts.join("");
}

export function robSummarySvg(input: RobInput, transparent = false): string {
  const { name, domains, levels, toolLevels, rows } = input;
  const doms = domains.filter((d) => d.id !== "Overall");
  // Keep every study in the denominator; blank/invalid -> a visible "Missing".
  const segLevels = [...toolLevels, "Missing"];
  const segColor = (lvl: string) => (lvl === "Missing" ? "#cccccc" : color(levels, lvl));
  const classify = (v: string | undefined) =>
    v && toolLevels.includes(v) ? v : "Missing";
  const barLeft = 64;
  const barWidth = 470;
  const rowH = 34;
  const top = 50;
  const legendH = 44;
  const width = barLeft + barWidth + 24;
  const height = top + doms.length * rowH + legendH;

  const parts: string[] = [];
  parts.push(
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" font-family="Helvetica, Arial, sans-serif">`,
  );
  if (!transparent) {
    parts.push(`<rect width="${width}" height="${height}" fill="#ffffff"/>`);
  }
  parts.push(
    `<text x="${barLeft}" y="24" font-size="15" font-weight="bold">${esc(name)}</text>`,
  );

  doms.forEach((d, di) => {
    const y = top + di * rowH;
    const classed = rows.map((row) => classify(row.values[d.id]));
    const total = classed.length || 1;
    parts.push(
      `<text x="${barLeft - 8}" y="${y + rowH / 2}" font-size="12" text-anchor="end" dominant-baseline="middle">${esc(d.id)}</text>`,
    );
    let x = barLeft;
    for (const lvl of segLevels) {
      const n = classed.filter((v) => v === lvl).length;
      if (!n) continue;
      const w = (n / total) * barWidth;
      parts.push(
        `<rect x="${x}" y="${y + 4}" width="${w}" height="${rowH - 10}" fill="${segColor(lvl)}" stroke="#555" stroke-width="0.5"/>`,
      );
      x += w;
    }
  });

  // legend (only levels that actually appear)
  const present = segLevels.filter((lvl) =>
    doms.some((d) => rows.some((row) => classify(row.values[d.id]) === lvl)),
  );
  const ly = top + doms.length * rowH + 16;
  let lx = barLeft;
  for (const lvl of present) {
    parts.push(
      `<rect x="${lx}" y="${ly}" width="12" height="12" fill="${segColor(lvl)}" stroke="#555" stroke-width="0.5"/>`,
    );
    parts.push(
      `<text x="${lx + 16}" y="${ly + 11}" font-size="11">${esc(lvl)}</text>`,
    );
    lx += 20 + lvl.length * 7;
  }

  parts.push("</svg>");
  return parts.join("");
}
