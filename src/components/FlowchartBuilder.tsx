import { useEffect, useMemo, useRef, useState } from "react";
import type { Dataset } from "../lib/data";
import { flowchartDot } from "../lib/dot";
import { dotToSvg } from "../lib/graphviz";
import { downloadPng, downloadSvg, svgToPng } from "../lib/exportImage";
import { flowchartDocx } from "../lib/exportDocx";
import { flowchartXlsx } from "../lib/exportXlsx";
import { saveText, toCsv, saveJson, readJsonFile } from "../lib/download";
import { sanitizeSvg } from "../lib/sanitize";
import { flowchartConsistency } from "../lib/consistency";
import { validateFlowchartFile } from "../lib/loadValidate";

export default function FlowchartBuilder({ data }: { data: Dataset }) {
  const templates = data.flowcharts.templates;
  const [templateId, setTemplateId] = useState(templates[0]?.template_id ?? "");

  const fields = useMemo(
    () =>
      data.flowcharts.counts
        .filter((c) => c.template_id === templateId)
        .sort((a, b) => a.field_order - b.field_order),
    [data, templateId],
  );
  const nodes = useMemo(
    () => data.flowcharts.nodes.filter((n) => n.template_id === templateId),
    [data, templateId],
  );
  const edges = useMemo(
    () => data.flowcharts.edges.filter((e) => e.template_id === templateId),
    [data, templateId],
  );

  const [counts, setCounts] = useState<Record<string, string>>({});
  const [transparent, setTransparent] = useState(false);
  const [complete, setComplete] = useState(false);
  const [allowAnyway, setAllowAnyway] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const loadInput = useRef<HTMLInputElement>(null);
  // counts staged by a cross-template load, applied once the new fields are in
  const pending = useRef<Record<string, string> | null>(null);
  useEffect(() => {
    const init: Record<string, string> = {};
    for (const f of fields) init[f.count_field] = f.value;
    if (pending.current) {
      Object.assign(init, pending.current);
      pending.current = null;
    }
    setCounts(init);
  }, [templateId]); // eslint-disable-line react-hooks/exhaustive-deps

  const background = transparent ? "transparent" : "white";
  const dot = useMemo(
    () => flowchartDot(nodes, edges, counts, background),
    [nodes, edges, counts, background],
  );
  const [svg, setSvg] = useState("");
  const [busy, setBusy] = useState(false);
  useEffect(() => {
    let live = true;
    dotToSvg(dot)
      .then((s) => live && setSvg(s))
      .catch(() => live && setSvg(""));
    return () => {
      live = false;
    };
  }, [dot]);

  const templateName =
    templates.find((t) => t.template_id === templateId)?.name ?? templateId;
  const countsRows = () =>
    fields.map((f) => ({
      field: f.count_field,
      label: f.label,
      value: counts[f.count_field] ?? "",
    }));

  const issues = useMemo(() => {
    const labels = Object.fromEntries(fields.map((f) => [f.count_field, f.label]));
    return flowchartConsistency(templateId, counts, labels, complete);
  }, [templateId, counts, fields, complete]);
  // block final exports while the counts are inconsistent, unless the user opts
  // into a draft export; save/load stays available regardless
  const blockExport = issues.length > 0 && !allowAnyway;

  const runExport = (fn: () => void | Promise<void>) => async () => {
    setError(null);
    setBusy(true);
    try {
      await fn();
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  };

  const onLoad = async (file: File) => {
    setError(null);
    try {
      const obj = await readJsonFile<unknown>(file);
      const parsed = validateFlowchartFile(obj, data.flowcharts.counts, templateId);
      if (parsed.template !== templateId) {
        pending.current = parsed.counts; // applied after the template effect runs
        setTemplateId(parsed.template);
      } else {
        setCounts((c) => ({ ...c, ...parsed.counts }));
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    }
  };

  return (
    <div className="grid md:grid-cols-[360px_1fr] gap-6">
      <aside className="space-y-3">
        <label className="block text-sm font-medium">Template</label>
        <select
          className="w-full rounded border border-slate-300 px-3 py-2 text-sm bg-white"
          value={templateId}
          onChange={(e) => setTemplateId(e.target.value)}
        >
          {templates.map((t) => (
            <option key={t.template_id} value={t.template_id}>
              {t.name}
            </option>
          ))}
        </select>

        <div className="space-y-2 max-h-[38vh] overflow-auto pr-1">
          {fields.map((f) => (
            <div key={f.count_field}>
              <label className="block text-xs font-medium text-slate-600">{f.label}</label>
              <input
                type={f.is_reasons ? "text" : "number"}
                min={f.is_reasons ? undefined : 0}
                className="w-full rounded border border-slate-300 px-2 py-1 text-sm"
                value={counts[f.count_field] ?? ""}
                onChange={(e) =>
                  setCounts((c) => ({ ...c, [f.count_field]: e.target.value }))
                }
              />
            </div>
          ))}
        </div>

        <label className="flex items-center gap-2 text-sm pt-1">
          <input
            type="checkbox"
            checked={transparent}
            onChange={(e) => setTransparent(e.target.checked)}
          />
          Transparent background
        </label>

        <label className="flex items-center gap-2 text-sm">
          <input
            type="checkbox"
            checked={complete}
            onChange={(e) => setComplete(e.target.checked)}
          />
          Final diagram (require exact accounting)
        </label>

        {issues.length > 0 && (
          <label className="flex items-center gap-2 text-sm text-amber-800">
            <input
              type="checkbox"
              checked={allowAnyway}
              onChange={(e) => setAllowAnyway(e.target.checked)}
            />
            Export despite consistency warnings
          </label>
        )}

        <div className="grid grid-cols-2 gap-2 pt-2">
          <button className="rounded bg-ink text-white px-3 py-2 text-sm font-medium hover:bg-ink/90 disabled:opacity-50" disabled={!svg || busy || blockExport} onClick={runExport(() => downloadPng(svg, `${templateId}.png`, 2, transparent))}>PNG</button>
          <button className="rounded bg-teal text-white px-3 py-2 text-sm font-medium hover:bg-teal/90 disabled:opacity-50" disabled={!svg || busy || blockExport} onClick={runExport(() => downloadSvg(svg, `${templateId}.svg`))}>SVG</button>
          <button className="rounded border border-slate-300 px-3 py-2 text-sm hover:bg-slate-100 disabled:opacity-50" disabled={!svg || busy || blockExport} onClick={runExport(async () => { const png = await svgToPng(svg, 2, transparent); await flowchartDocx(templateName, png, `${templateId}.docx`); })}>Word</button>
          <button className="rounded border border-slate-300 px-3 py-2 text-sm hover:bg-slate-100 disabled:opacity-50" disabled={busy || blockExport} onClick={runExport(() => flowchartXlsx(countsRows(), `${templateId}.xlsx`))}>Excel</button>
          <button className="col-span-2 rounded border border-slate-300 px-3 py-2 text-sm hover:bg-slate-100 disabled:opacity-50" disabled={blockExport} onClick={runExport(() => saveText(toCsv(countsRows()), `${templateId}.csv`, "text/csv;charset=utf-8"))}>CSV (counts)</button>
        </div>

        <div className="flex gap-2 pt-1 text-sm">
          <button className="flex-1 rounded border border-slate-300 px-3 py-2 hover:bg-slate-100" onClick={() => saveJson({ template: templateId, counts }, `${templateId}.reportilo.json`)}>Save</button>
          <button className="flex-1 rounded border border-slate-300 px-3 py-2 hover:bg-slate-100" onClick={() => loadInput.current?.click()}>Load</button>
          <input ref={loadInput} type="file" accept="application/json" className="hidden" onChange={(e) => { const f = e.target.files?.[0]; if (f) onLoad(f); e.target.value = ""; }} />
        </div>

        {error && (
          <div className="rounded bg-red-50 border border-red-200 text-red-700 p-2 text-xs">{error}</div>
        )}
      </aside>

      <div className="border border-slate-200 rounded-md bg-white p-4">
        <h3 className="text-sm font-semibold text-ink mb-2">{templateName}</h3>
        {issues.length > 0 && (
          <div className="rounded bg-amber-50 border border-amber-200 text-amber-800 p-2 text-xs mb-3">
            <strong>Check these counts:</strong>
            <ul className="list-disc pl-5">
              {issues.map((m, i) => (
                <li key={i}>{m}</li>
              ))}
            </ul>
            <p className="mt-1">
              Exports are blocked until these are resolved. Tick "Export despite
              consistency warnings" to download a draft anyway.
            </p>
          </div>
        )}
        {svg ? (
          <div className="flow-preview" dangerouslySetInnerHTML={{ __html: sanitizeSvg(svg) }} />
        ) : (
          <p className="text-sm text-slate-500">Rendering…</p>
        )}
      </div>
    </div>
  );
}
