import { useMemo, useState } from "react";
import type { Dataset } from "../lib/data";
import { robTrafficLightSvg, robSummarySvg, type RobInput } from "../lib/rob";
import { downloadPng, downloadSvg } from "../lib/exportImage";
import { saveText, toCsv } from "../lib/download";

interface Row {
  study: string;
  values: Record<string, string>;
}

export default function RobBuilder({ data }: { data: Dataset }) {
  const tools = data.rob.tools;
  const [toolId, setToolId] = useState(tools[0]?.tool_id ?? "");
  const [ptype, setPtype] = useState<"traffic_light" | "summary">("traffic_light");

  const tool = tools.find((t) => t.tool_id === toolId)!;
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

  const input: RobInput = {
    name: tool.name,
    domains,
    levels: data.rob.levels,
    toolLevels,
    rows,
  };
  const svg = ptype === "summary" ? robSummarySvg(input) : robTrafficLightSvg(input);

  const setCell = (ri: number, domainId: string, value: string) => {
    const next = rows.map((r, i) =>
      i === ri ? { ...r, values: { ...r.values, [domainId]: value } } : r,
    );
    setRows(next);
  };
  const setStudy = (ri: number, value: string) =>
    setRows(rows.map((r, i) => (i === ri ? { ...r, study: value } : r)));

  const addRow = () =>
    setRows([...rows, { study: `Study ${rows.length + 1}`, values: {} }]);
  const removeRow = (ri: number) => setRows(rows.filter((_, i) => i !== ri));

  const csvRows = () =>
    rows.map((r) => {
      const o: Record<string, string> = { Study: r.study };
      for (const d of domains) o[d.id] = r.values[d.id] ?? "";
      return o;
    });

  return (
    <div className="grid md:grid-cols-[330px_1fr] gap-6">
      <aside className="space-y-3">
        <label className="block text-sm font-medium">Tool</label>
        <select
          className="w-full rounded border border-slate-300 px-3 py-2 text-sm bg-white"
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
              <input
                type="radio"
                checked={ptype === p}
                onChange={() => setPtype(p)}
              />
              {p === "traffic_light" ? "Traffic light" : "Summary"}
            </label>
          ))}
        </div>

        <div className="grid grid-cols-2 gap-2 pt-1">
          <button
            className="rounded bg-ink text-white px-3 py-2 text-sm font-medium hover:bg-ink/90"
            onClick={() => downloadPng(svg, `${toolId}_rob.png`)}
          >
            PNG
          </button>
          <button
            className="rounded bg-teal text-white px-3 py-2 text-sm font-medium hover:bg-teal/90"
            onClick={() => downloadSvg(svg, `${toolId}_rob.svg`)}
          >
            SVG
          </button>
          <button
            className="col-span-2 rounded border border-slate-300 px-3 py-2 text-sm hover:bg-slate-100"
            onClick={() =>
              saveText(toCsv(csvRows()), `${toolId}_rob.csv`, "text/csv;charset=utf-8")
            }
          >
            CSV
          </button>
        </div>
        <button
          className="text-sm text-teal hover:underline"
          onClick={addRow}
        >
          + Add study
        </button>
      </aside>

      <div className="space-y-4">
        <div className="overflow-auto border border-slate-200 rounded-md bg-white">
          <table className="w-full text-sm">
            <thead className="bg-slate-100 text-left">
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
                <tr key={ri} className="border-t border-slate-100">
                  <td className="px-2 py-1">
                    <input
                      className="w-28 rounded border border-slate-300 px-1 py-0.5"
                      value={r.study}
                      onChange={(e) => setStudy(ri, e.target.value)}
                    />
                  </td>
                  {domains.map((d) => (
                    <td key={d.id} className="px-2 py-1">
                      <select
                        className="rounded border border-slate-300 px-1 py-0.5"
                        value={r.values[d.id] ?? ""}
                        onChange={(e) => setCell(ri, d.id, e.target.value)}
                      >
                        <option value="">—</option>
                        {toolLevels.map((lv) => (
                          <option key={lv} value={lv}>
                            {lv}
                          </option>
                        ))}
                      </select>
                    </td>
                  ))}
                  <td className="px-2 py-1">
                    <button
                      className="text-slate-400 hover:text-red-600"
                      onClick={() => removeRow(ri)}
                      title="Remove study"
                    >
                      ✕
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="border border-slate-200 rounded-md bg-white p-4 overflow-auto">
          <div dangerouslySetInnerHTML={{ __html: svg }} />
        </div>
      </div>
    </div>
  );
}
