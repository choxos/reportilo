import writeXlsxFile from "write-excel-file";
import type { ChecklistRow } from "./exportDocx";

// `write-excel-file` is a maintained, vulnerability-free XLSX writer (replacing
// SheetJS). String cells are written as text, so spreadsheet formula injection
// does not apply to these exports.

const H = (t: string) => ({ value: t, fontWeight: "bold" as const });

export async function checklistXlsx(
  rows: ChecklistRow[],
  filename: string,
): Promise<void> {
  const data = [
    [H("Section"), H("Item"), H("Checklist item"), H("Reported (page)"), H("Excerpt from manuscript")],
    ...rows.map((r) => [
      { value: r.section },
      { value: r.item_no },
      { value: r.item_text },
      { value: r.response || "" },
      { value: r.excerpt || "" },
    ]),
  ];
  await writeXlsxFile(data, {
    fileName: filename,
    columns: [{ width: 22 }, { width: 8 }, { width: 60 }, { width: 16 }, { width: 60 }],
  });
}

export async function flowchartXlsx(
  rows: { field: string; label: string; value: string }[],
  filename: string,
): Promise<void> {
  const data = [
    [H("Field"), H("Label"), H("Value")],
    ...rows.map((r) => [{ value: r.field }, { value: r.label }, { value: r.value }]),
  ];
  await writeXlsxFile(data, {
    fileName: filename,
    columns: [{ width: 22 }, { width: 55 }, { width: 18 }],
  });
}

export async function robXlsx(
  headers: string[],
  rows: string[][],
  filename: string,
): Promise<void> {
  const data = [
    headers.map(H),
    ...rows.map((r) => r.map((v) => ({ value: v || "" }))),
  ];
  await writeXlsxFile(data, { fileName: filename });
}
