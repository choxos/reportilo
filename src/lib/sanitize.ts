import DOMPurify from "dompurify";

// Sanitize generated SVG markup before it is injected with
// dangerouslySetInnerHTML. Our SVG is produced from Graphviz and our own
// builders, but sanitizing is cheap defense-in-depth and matters once user
// imports can reach diagram labels.
export function sanitizeSvg(svg: string): string {
  return DOMPurify.sanitize(svg, {
    USE_PROFILES: { svg: true, svgFilters: true },
  });
}
