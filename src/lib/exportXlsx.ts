import type { ChecklistRow } from "./exportDocx";

// SheetJS is loaded lazily (its own chunk) so it stays out of the initial bundle.

export async function checklistXlsx(
  rows: ChecklistRow[],
  filename: string,
): Promise<void> {
  const XLSX = await import("xlsx");
  const ws = XLSX.utils.json_to_sheet(
    rows.map((r) => ({
      Section: r.section,
      Item: r.item_no,
      "Checklist item": r.item_text,
      "Reported (page)": r.response || "",
    })),
  );
  ws["!cols"] = [{ wch: 22 }, { wch: 8 }, { wch: 70 }, { wch: 18 }];
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, "Checklist");
  XLSX.writeFile(wb, filename);
}

export async function flowchartXlsx(
  rows: { field: string; label: string; value: string }[],
  filename: string,
): Promise<void> {
  const XLSX = await import("xlsx");
  const ws = XLSX.utils.json_to_sheet(
    rows.map((r) => ({ Field: r.field, Label: r.label, Value: r.value })),
  );
  ws["!cols"] = [{ wch: 22 }, { wch: 55 }, { wch: 18 }];
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, "Flow diagram");
  XLSX.writeFile(wb, filename);
}
