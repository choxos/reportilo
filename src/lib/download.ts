// Trigger a browser download for a Blob.
export function saveBlob(blob: Blob, filename: string): void {
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

export function saveText(text: string, filename: string, mime: string): void {
  saveBlob(new Blob([text], { type: mime }), filename);
}

// Save/load a project object as JSON (for filled checklists, flowcharts, RoB).
export function saveJson(obj: unknown, filename: string): void {
  saveText(JSON.stringify(obj, null, 2), filename, "application/json");
}

export function readJsonFile<T>(file: File): Promise<T> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      try {
        resolve(JSON.parse(String(reader.result)) as T);
      } catch (e) {
        reject(e instanceof Error ? e : new Error("Invalid JSON file"));
      }
    };
    reader.onerror = () => reject(new Error("Could not read file"));
    reader.readAsText(file);
  });
}

// Neutralize spreadsheet formula injection: a cell beginning with = + - @ tab or
// CR is prefixed with a single quote so spreadsheet software treats it as text.
export function csvSafe(value: string): string {
  const s = value ?? "";
  return /^[=+\-@\t\r]/.test(s) ? `'${s}` : s;
}

export function toCsv(rows: Record<string, string>[]): string {
  if (!rows.length) return "";
  const cols = Object.keys(rows[0]);
  const esc = (v: string) => {
    const s = csvSafe(v ?? "");
    return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
  };
  const header = cols.join(",");
  const body = rows.map((r) => cols.map((c) => esc(String(r[c] ?? ""))).join(","));
  return [header, ...body].join("\n");
}
