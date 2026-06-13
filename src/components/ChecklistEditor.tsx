import { useMemo, useState } from "react";
import { checklistFor, type Dataset } from "../lib/data";
import { checklistDocx, type ChecklistRow } from "../lib/exportDocx";
import { checklistXlsx } from "../lib/exportXlsx";
import { saveText, toCsv } from "../lib/download";

export default function ChecklistEditor({ data }: { data: Dataset }) {
  const options = useMemo(
    () =>
      data.guidelines
        .filter((g) => g.has_checklist)
        .map((g) => ({
          id: g.guideline_id,
          label: `${g.acronym ?? g.guideline_id} — ${(g.title ?? "").slice(0, 70)}`,
        }))
        .sort((a, b) => a.label.localeCompare(b.label)),
    [data],
  );

  const [guidelineId, setGuidelineId] = useState(options[0]?.id ?? "");
  const [responses, setResponses] = useState<Record<string, string>>({});

  const items = useMemo(() => checklistFor(data, guidelineId), [data, guidelineId]);
  const verified = items[0]?.is_override ?? false;
  const filled = items.filter((i) => (responses[i.item_uid] ?? "").trim()).length;

  const rows = (): ChecklistRow[] =>
    items.map((i) => ({
      section: i.section,
      item_no: i.item_no,
      item_text: i.item_text,
      response: responses[i.item_uid] ?? "",
    }));

  const title = options.find((o) => o.id === guidelineId)?.label ?? guidelineId;

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
              {o.label}
            </option>
          ))}
        </select>

        <span
          className={
            "inline-block rounded px-2 py-1 text-xs font-medium " +
            (verified ? "bg-teal/20 text-teal" : "bg-amber-100 text-amber-800")
          }
        >
          {verified ? "Hand-verified checklist" : "Auto-extracted (verify against source)"}
        </span>

        <p className="text-xs text-slate-500">
          {filled} of {items.length} items completed
        </p>

        <div className="space-y-2 pt-2">
          <button
            className="w-full rounded bg-ink text-white px-3 py-2 text-sm font-medium hover:bg-ink/90"
            onClick={() => checklistDocx(guidelineId, rows(), `${guidelineId}_checklist.docx`)}
          >
            Download Word (.docx)
          </button>
          <button
            className="w-full rounded bg-teal text-white px-3 py-2 text-sm font-medium hover:bg-teal/90"
            onClick={() => checklistXlsx(rows(), `${guidelineId}_checklist.xlsx`)}
          >
            Download Excel (.xlsx)
          </button>
          <button
            className="w-full rounded border border-slate-300 px-3 py-2 text-sm hover:bg-slate-100"
            onClick={() =>
              saveText(
                toCsv(rows() as unknown as Record<string, string>[]),
                `${guidelineId}_checklist.csv`,
                "text/csv;charset=utf-8",
              )
            }
          >
            Download CSV
          </button>
        </div>
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
