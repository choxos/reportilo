import { useMemo, useRef, useState } from "react";
import type { Dataset } from "../lib/data";
import { robTrafficLightSvg, robSummarySvg, type RobInput } from "../lib/rob";
import { downloadPng, downloadSvg, svgToPng } from "../lib/exportImage";
import { flowchartDocx } from "../lib/exportDocx";
import { robXlsx } from "../lib/exportXlsx";
import { saveText, toCsv, saveJson, readJsonFile } from "../lib/download";
import { validateRobFile } from "../lib/loadValidate";
import { sanitizeSvg } from "../lib/sanitize";

interface Row {
  study: string;
  values: Record<string, string>;
}

export default function RobBuilder({ data }: { data: Dataset }) {
  const tools = data.rob.tools;
  const [toolId, setToolId] = useState(tools[0]?.tool_id ?? "");
  const [ptype, setPtype] = useState<"traffic_light" | "summary">("traffic_light");
  const [transparent, setTransparent] = useState(false);
  const [dpi, setDpi] = useState(300);
  const [error, setError] = useState<string | null>(null);
  const loadInput = useRef<HTMLInputElement>(null);

  // defensive: never crash if toolId is somehow unknown (e.g. a stale saved file)
  const tool = tools.find((t) => t.tool_id === toolId) ?? tools[0];
  const toolLevels = useMemo(() => tool.levels.split("; "), [tool]);

  const domains = useMemo(() => {
    const ds = data.rob.domains
      .filter((d) => d.tool_id === toolId)
      .sort((a, b) => a.domain_order - b.domain_order)
      .map((d) => ({ id: d.domain_id, label: d.label }));
    return [...ds, { id: "Overall", label: "Overall" }];
  }, [data, toolId]);

  const exampleRows = useMemo<Row[]>(() => {
    const ex = data.rob.example.filter((e) => e.tool_id === toolId);
    const byStudy = new Map<string, Record<string, string>>();
    for (const e of ex) {
      if (!byStudy.has(e.study)) byStudy.set(e.study, {});
      byStudy.get(e.study)![e.domain_id] = e.judgment;
    }
    return [...byStudy.entries()].map(([study, values]) => ({ study, values }));
  }, [data, toolId]);

  const [rowsByTool, setRowsByTool] = useState<Record<string, Row[]>>({});
  const rows = rowsByTool[toolId] ?? exampleRows;
  const setRows = (next: Row[]) => setRowsByTool((m) => ({ ...m, [toolId]: next }));

  const input: RobInput = { name: tool.name, domains, levels: data.rob.levels, toolLevels, rows };
  const svg =
    ptype === "summary"
      ? robSummarySvg(input, transparent)
      : robTrafficLightSvg(input, transparent);

  const setCell = (ri: number, domainId: string, value: string) =>
    setRows(rows.map((r, i) => (i === ri ? { ...r, values: { ...r.values, [domainId]: value } } : r)));
  const setStudy = (ri: number, value: string) =>
    setRows(rows.map((r, i) => (i === ri ? { ...r, study: value } : r)));
  const addRow = () => setRows([...rows, { study: `Study ${rows.length + 1}`, values: {} }]);
  const removeRow = (ri: number) => setRows(rows.filter((_, i) => i !== ri));

  const csvRows = () =>
    rows.map((r) => {
      const o: Record<string, string> = { Study: r.study };
      for (const d of domains) o[d.id] = r.values[d.id] ?? "";
      return o;
    });

  const runExport = (fn: () => void | Promise<void>) => async () => {
    setError(null);
    try {
      await fn();
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    }
  };

  const onLoad = async (file: File) => {
    setError(null);
    try {
      const obj = await readJsonFile<unknown>(file);
      const parsed = validateRobFile(obj, tools, data.rob.domains);
      if (parsed.tool !== toolId) setToolId(parsed.tool);
      setRowsByTool((m) => ({ ...m, [parsed.tool]: parsed.rows }));
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    }
  };

  const exportWord = runExport(async () => {
    const png = await svgToPng(svg, dpi / 96, transparent);
    await flowchartDocx(tool.name, svg, png, `${toolId}_rob.docx`);
  });
  const exportExcel = runExport(() =>
    robXlsx(
      ["Study", ...domains.map((d) => d.id)],
      rows.map((r) => [r.study, ...domains.map((d) => r.values[d.id] ?? "")]),
      `${toolId}_rob.xlsx`,
    ),
  );

  return (
    <div className="grid md:grid-cols-[330px_1fr] gap-6">
      <aside className="space-y-3">
        <label className="block text-sm font-medium">Tool</label>
        <select
          className="w-full rounded border border-slate-300 dark:border-slate-600 px-3 py-2 text-sm bg-white dark:bg-slate-800 dark:text-slate-100"
          value={toolId}
          onChange={(e) => setToolId(e.target.value)}
        >
          {tools.map((t) => (
            <option key={t.tool_id} value={t.tool_id}>
              {t.name}
            </option>
          ))}
        </select>

        <div className="flex gap-3 text-sm">
          {(["traffic_light", "summary"] as const).map((p) => (
            <label key={p} className="flex items-center gap-1">
              <input type="radio" checked={ptype === p} onChange={() => setPtype(p)} />
              {p === "traffic_light" ? "Traffic light" : "Summary"}
            </label>
          ))}
        </div>

        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" checked={transparent} onChange={(e) => setTransparent(e.target.checked)} />
          Transparent background
        </label>

        <label className="flex items-center gap-2 text-sm">
          <span className="text-slate-600 dark:text-slate-300">Image DPI</span>
          <select
            className="rounded border border-slate-300 dark:border-slate-600 px-2 py-1 text-sm bg-white dark:bg-slate-800 dark:text-slate-100"
            value={dpi}
            onChange={(e) => setDpi(Number(e.target.value))}
          >
            {[150, 300, 600].map((d) => (
              <option key={d} value={d}>
                {d}
              </option>
            ))}
          </select>
        </label>

        <div className="grid grid-cols-2 gap-2 pt-1">
          <button className="rounded bg-ink text-white px-3 py-2 text-sm font-medium hover:bg-ink/90" onClick={runExport(() => downloadPng(svg, `${toolId}_rob.png`, dpi / 96, transparent))}>PNG</button>
          <button className="rounded bg-teal text-white px-3 py-2 text-sm font-medium hover:bg-teal/90" onClick={runExport(() => downloadSvg(svg, `${toolId}_rob.svg`))}>SVG</button>
          <button className="rounded border border-slate-300 dark:border-slate-600 px-3 py-2 text-sm hover:bg-slate-100 dark:hover:bg-slate-700" onClick={exportWord}>Word</button>
          <button className="rounded border border-slate-300 dark:border-slate-600 px-3 py-2 text-sm hover:bg-slate-100 dark:hover:bg-slate-700" onClick={exportExcel}>Excel</button>
          <button className="col-span-2 rounded border border-slate-300 dark:border-slate-600 px-3 py-2 text-sm hover:bg-slate-100 dark:hover:bg-slate-700" onClick={runExport(() => saveText(toCsv(csvRows()), `${toolId}_rob.csv`, "text/csv;charset=utf-8"))}>CSV</button>
        </div>

        <div className="flex gap-2 text-sm">
          <button className="flex-1 rounded border border-slate-300 dark:border-slate-600 px-3 py-2 hover:bg-slate-100 dark:hover:bg-slate-700" onClick={() => saveJson({ tool: toolId, rows }, `${toolId}_rob.reportilo.json`)}>Save</button>
          <button className="flex-1 rounded border border-slate-300 dark:border-slate-600 px-3 py-2 hover:bg-slate-100 dark:hover:bg-slate-700" onClick={() => loadInput.current?.click()}>Load</button>
          <input ref={loadInput} type="file" accept="application/json" className="hidden" onChange={(e) => { const f = e.target.files?.[0]; if (f) onLoad(f); e.target.value = ""; }} />
        </div>

        <button className="text-sm text-teal hover:underline" onClick={addRow}>+ Add study</button>

        {error && (
          <div className="rounded bg-red-50 border border-red-200 text-red-700 p-2 text-xs dark:bg-red-950 dark:border-red-800 dark:text-red-300">{error}</div>
        )}
      </aside>

      <div className="space-y-4">
        <div className="overflow-auto border border-slate-200 rounded-md bg-white dark:border-slate-700 dark:bg-slate-800">
          <table className="w-full text-sm">
            <thead className="bg-slate-100 text-left dark:bg-slate-700">
              <tr>
                <th className="px-2 py-2 font-semibold">Study</th>
                {domains.map((d) => (
                  <th key={d.id} className="px-2 py-2 font-semibold" title={d.label}>
                    {d.id}
                  </th>
                ))}
                <th></th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r, ri) => (
                <tr key={ri} className="border-t border-slate-100 dark:border-slate-700">
                  <td className="px-2 py-1">
                    <input className="w-28 rounded border border-slate-300 dark:border-slate-600 px-1 py-0.5 dark:bg-slate-900 dark:text-slate-100" value={r.study} onChange={(e) => setStudy(ri, e.target.value)} />
                  </td>
                  {domains.map((d) => (
                    <td key={d.id} className="px-2 py-1">
                      <select className="rounded border border-slate-300 dark:border-slate-600 px-1 py-0.5 dark:bg-slate-900 dark:text-slate-100" value={r.values[d.id] ?? ""} onChange={(e) => setCell(ri, d.id, e.target.value)}>
                        <option value="">—</option>
                        {toolLevels.map((lv) => (
                          <option key={lv} value={lv}>{lv}</option>
                        ))}
                      </select>
                    </td>
                  ))}
                  <td className="px-2 py-1">
                    <button className="text-slate-400 hover:text-red-600" onClick={() => removeRow(ri)} title="Remove study">✕</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div
          className={
            "border border-slate-200 rounded-md p-4 overflow-auto dark:border-slate-700 " +
            (transparent ? "bg-checkerboard" : "bg-white")
          }
        >
          <div dangerouslySetInnerHTML={{ __html: sanitizeSvg(svg) }} />
        </div>
      </div>
    </div>
  );
}
