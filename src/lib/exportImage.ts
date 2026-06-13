import { saveBlob, saveText } from "./download";

export function downloadSvg(svg: string, filename: string): void {
  saveText(svg, filename, "image/svg+xml;charset=utf-8");
}

// Rasterize an SVG string to a PNG Blob via an offscreen canvas.
export async function svgToPng(svg: string, scale = 2): Promise<Blob> {
  // derive intrinsic size from the SVG canvas (Graphviz emits pt dimensions)
  const m = svg.match(/width="([0-9.]+)pt"[^>]*height="([0-9.]+)pt"/);
  const wpt = m ? parseFloat(m[1]) : 800;
  const hpt = m ? parseFloat(m[2]) : 1000;

  const img = new Image();
  const url = URL.createObjectURL(
    new Blob([svg], { type: "image/svg+xml;charset=utf-8" }),
  );
  try {
    await new Promise<void>((resolve, reject) => {
      img.onload = () => resolve();
      img.onerror = () => reject(new Error("Failed to render SVG"));
      img.src = url;
    });
    const canvas = document.createElement("canvas");
    canvas.width = Math.round(wpt * scale);
    canvas.height = Math.round(hpt * scale);
    const ctx = canvas.getContext("2d");
    if (!ctx) throw new Error("Canvas not supported");
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
    return await new Promise<Blob>((resolve, reject) =>
      canvas.toBlob(
        (b) => (b ? resolve(b) : reject(new Error("toBlob failed"))),
        "image/png",
      ),
    );
  } finally {
    URL.revokeObjectURL(url);
  }
}

export async function downloadPng(
  svg: string,
  filename: string,
  scale = 2,
): Promise<void> {
  saveBlob(await svgToPng(svg, scale), filename);
}
