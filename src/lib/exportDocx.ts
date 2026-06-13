import { saveBlob } from "./download";

export interface ChecklistRow {
  section: string;
  item_no: string;
  item_text: string;
  response: string;
}

// `docx` is loaded lazily (its own chunk) so it stays out of the initial bundle.

export async function checklistDocx(
  title: string,
  rows: ChecklistRow[],
  filename: string,
): Promise<void> {
  const {
    Document,
    Packer,
    Paragraph,
    HeadingLevel,
    Table,
    TableRow,
    TableCell,
    TextRun,
    WidthType,
  } = await import("docx");

  const cell = (text: string, bold = false) =>
    new TableCell({
      children: [new Paragraph({ children: [new TextRun({ text: text ?? "", bold })] })],
    });

  const header = new TableRow({
    tableHeader: true,
    children: [
      cell("Section", true),
      cell("Item", true),
      cell("Checklist item", true),
      cell("Reported (page)", true),
    ],
  });
  const body = rows.map(
    (r) =>
      new TableRow({
        children: [cell(r.section), cell(r.item_no), cell(r.item_text), cell(r.response || "")],
      }),
  );
  const doc = new Document({
    sections: [
      {
        children: [
          new Paragraph({
            text: `${title} reporting checklist`,
            heading: HeadingLevel.HEADING_1,
          }),
          new Table({
            rows: [header, ...body],
            width: { size: 100, type: WidthType.PERCENTAGE },
          }),
        ],
      },
    ],
  });
  saveBlob(await Packer.toBlob(doc), filename);
}

export async function flowchartDocx(
  name: string,
  png: Blob,
  filename: string,
): Promise<void> {
  const { Document, Packer, Paragraph, HeadingLevel, ImageRun } = await import("docx");
  const data = await png.arrayBuffer();
  const { width, height } = await pngSize(png);
  const W = 600;
  const H = Math.round((height / width) * W);
  const doc = new Document({
    sections: [
      {
        children: [
          new Paragraph({ text: name, heading: HeadingLevel.HEADING_1 }),
          new Paragraph({
            children: [
              new ImageRun({ type: "png", data, transformation: { width: W, height: H } }),
            ],
          }),
        ],
      },
    ],
  });
  saveBlob(await Packer.toBlob(doc), filename);
}

function pngSize(blob: Blob): Promise<{ width: number; height: number }> {
  return new Promise((resolve, reject) => {
    const url = URL.createObjectURL(blob);
    const img = new Image();
    img.onload = () => {
      resolve({ width: img.naturalWidth, height: img.naturalHeight });
      URL.revokeObjectURL(url);
    };
    img.onerror = () => {
      URL.revokeObjectURL(url);
      reject(new Error("Could not read PNG size"));
    };
    img.src = url;
  });
}
