import { useMemo, useRef, useState } from "react";
import { checklistFor, type Dataset } from "../lib/data";
import { checklistDocx, type ChecklistRow } from "../lib/exportDocx";
import { checklistXlsx } from "../lib/exportXlsx";
import { saveText, toCsv, saveJson, readJsonFile } from "../lib/download";
import { validateChecklistFile } from "../lib/loadValidate";

export default function ChecklistEditor({ data }: { data: Dataset }) {
  const options = useMemo(
    () =>
      data.guidelines
        .filter((g) => g.has_checklist)
        .map((g) => ({
          id: g.guideline_id,
          // dropdown shows only the name (acronym, or the title when there is no acronym)
          name: g.acronym ?? g.title ?? g.guideline_id,
          description: g.title ?? "",
        }))
        .sort((a, b) => a.name.localeCompare(b.name)),
    [data],
  );

  const [guidelineId, setGuidelineId] = useState(options[0]?.id ?? "");
  const [responses, setResponses] = useState<Record<string, string>>({});
  const [error, setError] = useState<string | null>(null);
  const loadInput = useRef<HTMLInputElement>(null);

  const items = useMemo(() => checklistFor(data, guidelineId), [data, guidelineId]);
  // provenance is a guideline-level property: read it from parse_status
  const status = useMemo(
    () => data.parseStatus.find((p) => p.guideline_id === guidelineId),
    [data, guidelineId],
  );
  const verified = status?.verified ?? false;
  const filled = items.filter((i) => (responses[i.item_uid] ?? "").trim()).length;

  const rows = (): ChecklistRow[] =>
    items.map((i) => ({
      section: i.section,
      item_no: i.item_no,
      item_text: i.item_text,
      response: responses[i.item_uid] ?? "",
    }));

  const selected = options.find((o) => o.id === guidelineId);
  const title = selected?.name ?? guidelineId;
  const description = selected?.description ?? "";

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
      const parsed = validateChecklistFile(obj, data.guidelines, data.checklistItems);
      if (parsed.guideline !== guidelineId) setGuidelineId(parsed.guideline);
      setResponses(parsed.responses);
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    }
  };

  return (
    <div className="grid md:grid-cols-[320px_1fr] gap-6">
      <aside className="space-y-3">
        <label className="block text-sm font-medium">Guideline</label>
        <select
          className="w-full rounded border border-slate-300 px-3 py-2 text-sm bg-white"
          value={guidelineId}
          onChange={(e) => {
            setGuidelineId(e.target.value);
            setResponses({});
          }}
        >
          {options.map((o) => (
            <option key={o.id} value={o.id}>
              {o.name}
            </option>
          ))}
        </select>
        {description && description !== title && (
          <p className="text-xs text-slate-600 -mt-1">{description}</p>
        )}

        <div className="space-y-1">
          <span
            className={
              "inline-block rounded px-2 py-1 text-xs font-medium " +
              (verified
                ? "bg-teal/20 text-teal"
                : status?.status === "parsed_ok"
                  ? "bg-sky-100 text-sky-800"
                  : "bg-amber-100 text-amber-800")
            }
          >
            {verified
              ? "Hand-verified"
              : status?.status === "parsed_ok"
                ? "Auto-extracted"
                : `Auto-extracted (${status?.status ?? "unverified"})`}
          </span>
          {status && (
            <p className="text-[11px] text-slate-500">
              method: {status.parse_method ?? "unknown"}
              {status.parse_confidence != null &&
                ` | confidence: ${status.parse_confidence.toFixed(2)}`}
            </p>
          )}
        </div>

        {!verified && (status?.needs_review || ["partial", "failed"].includes(status?.status ?? "")) && (
          <div className="rounded bg-amber-50 border border-amber-200 text-amber-800 p-2 text-xs">
            <strong>Verify against the source.</strong> This checklist was extracted
            automatically and may be incomplete or mislabeled. Check each item against
            the original guideline (see the Catalog tab for source links).
          </div>
        )}

        <p className="text-xs text-slate-500">
          {filled} of {items.length} items completed
        </p>

        <div className="space-y-2 pt-2">
          <button
            className="w-full rounded bg-ink text-white px-3 py-2 text-sm font-medium hover:bg-ink/90"
            onClick={runExport(() => checklistDocx(guidelineId, rows(), `${guidelineId}_checklist.docx`))}
          >
            Download Word (.docx)
          </button>
          <button
            className="w-full rounded bg-teal text-white px-3 py-2 text-sm font-medium hover:bg-teal/90"
            onClick={runExport(() => checklistXlsx(rows(), `${guidelineId}_checklist.xlsx`))}
          >
            Download Excel (.xlsx)
          </button>
          <button
            className="w-full rounded border border-slate-300 px-3 py-2 text-sm hover:bg-slate-100"
            onClick={runExport(() =>
              saveText(
                toCsv(rows() as unknown as Record<string, string>[]),
                `${guidelineId}_checklist.csv`,
                "text/csv;charset=utf-8",
              ),
            )}
          >
            Download CSV
          </button>
          <div className="flex gap-2">
            <button className="flex-1 rounded border border-slate-300 px-3 py-2 text-sm hover:bg-slate-100" onClick={() => saveJson({ guideline: guidelineId, responses }, `${guidelineId}_checklist.reportilo.json`)}>Save</button>
            <button className="flex-1 rounded border border-slate-300 px-3 py-2 text-sm hover:bg-slate-100" onClick={() => loadInput.current?.click()}>Load</button>
            <input ref={loadInput} type="file" accept="application/json" className="hidden" onChange={(e) => { const f = e.target.files?.[0]; if (f) onLoad(f); e.target.value = ""; }} />
          </div>
        </div>

        {error && (
          <div className="rounded bg-red-50 border border-red-200 text-red-700 p-2 text-xs">{error}</div>
        )}
      </aside>

      <div className="overflow-auto border border-slate-200 rounded-md bg-white max-h-[78vh]">
        <table className="w-full text-sm">
          <thead className="sticky top-0 bg-slate-100 text-left">
            <tr>
              <th className="px-3 py-2 font-semibold w-40">Section</th>
              <th className="px-3 py-2 font-semibold w-12">Item</th>
              <th className="px-3 py-2 font-semibold">Checklist item</th>
              <th className="px-3 py-2 font-semibold w-40">Reported (page)</th>
            </tr>
          </thead>
          <tbody>
            {items.map((i) => (
              <tr key={i.item_uid} className="border-t border-slate-100 align-top">
                <td className="px-3 py-2 text-slate-600">{i.section}</td>
                <td className="px-3 py-2 font-medium">{i.item_no}</td>
                <td className="px-3 py-2">{i.item_text}</td>
                <td className="px-3 py-2">
                  <input
                    className="w-full rounded border border-slate-300 px-2 py-1"
                    value={responses[i.item_uid] ?? ""}
                    onChange={(e) =>
                      setResponses((r) => ({ ...r, [i.item_uid]: e.target.value }))
                    }
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        <p className="px-3 py-2 text-xs text-slate-500">{title}</p>
      </div>
    </div>
  );
}
