// Render Graphviz DOT to an SVG string in the browser (WASM, no server).
// The WASM module is large, so it is loaded lazily on first use (its own chunk)
// to keep the initial bundle small.
async function loadGraphviz() {
  const m = await import("@hpcc-js/wasm-graphviz");
  return m.Graphviz.load();
}

let gvPromise: ReturnType<typeof loadGraphviz> | null = null;

export async function dotToSvg(dot: string): Promise<string> {
  gvPromise ??= loadGraphviz();
  const gv = await gvPromise;
  return gv.dot(dot, "svg");
}
