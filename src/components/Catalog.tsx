import { useMemo, useState } from "react";
import type { Dataset } from "../lib/data";
import type { Guideline } from "../types";

export default function Catalog({ data }: { data: Dataset }) {
  const [search, setSearch] = useState("");
  const [design, setDesign] = useState("");
  const [checklistOnly, setChecklistOnly] = useState(false);
  const [selected, setSelected] = useState<Guideline | null>(null);

  const designs = useMemo(
    () =>
      Array.from(
        new Set(
          data.guidelines
            .map((g) => g.study_design)
            .filter((d): d is string => !!d),
        ),
      ).sort(),
    [data],
  );

  const filtered = useMemo(() => {
    const q = search.toLowerCase();
    return data.guidelines.filter((g) => {
      if (checklistOnly && !g.has_checklist) return false;
      if (design && g.study_design !== design) return false;
      if (q) {
        const hay = `${g.acronym ?? ""} ${g.title ?? ""} ${g.study_design ?? ""} ${g.clinical_area ?? ""}`.toLowerCase();
        if (!hay.includes(q)) return false;
      }
      return true;
    });
  }, [data, search, design, checklistOnly]);

  return (
    <div className="grid md:grid-cols-[300px_1fr] gap-6">
      <aside className="space-y-3">
        <input
          className="w-full rounded border border-slate-300 px-3 py-2 text-sm"
          placeholder="Search acronym, title, topic…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <select
          className="w-full rounded border border-slate-300 px-3 py-2 text-sm bg-white"
          value={design}
          onChange={(e) => setDesign(e.target.value)}
        >
          <option value="">All study designs</option>
          {designs.map((d) => (
            <option key={d} value={d}>
              {d}
            </option>
          ))}
        </select>
        <label className="flex items-center gap-2 text-sm">
          <input
            type="checkbox"
            checked={checklistOnly}
            onChange={(e) => setChecklistOnly(e.target.checked)}
          />
          Only guidelines with a checklist
        </label>
        <p className="text-xs text-slate-500">{filtered.length} guidelines</p>
        {selected && <DetailCard g={selected} />}
      </aside>

      <div className="overflow-auto border border-slate-200 rounded-md bg-white max-h-[75vh]">
        <table className="w-full text-sm">
          <thead className="sticky top-0 bg-slate-100 text-left">
            <tr>
              <th className="px-3 py-2 font-semibold">Acronym</th>
              <th className="px-3 py-2 font-semibold">Title</th>
              <th className="px-3 py-2 font-semibold">Checklist</th>
            </tr>
          </thead>
          <tbody>
            {filtered.slice(0, 400).map((g) => (
              <tr
                key={g.guideline_id}
                onClick={() => setSelected(g)}
                className={
                  "cursor-pointer border-t border-slate-100 hover:bg-teal/10 " +
                  (selected?.guideline_id === g.guideline_id ? "bg-teal/10" : "")
                }
              >
                <td className="px-3 py-2 font-medium">{g.acronym ?? "—"}</td>
                <td className="px-3 py-2">{g.title}</td>
                <td className="px-3 py-2">{g.has_checklist ? "✓" : ""}</td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length > 400 && (
          <p className="p-3 text-xs text-slate-500">
            Showing the first 400 of {filtered.length}. Refine your search to see more.
          </p>
        )}
      </div>
    </div>
  );
}

function DetailCard({ g }: { g: Guideline }) {
  return (
    <div className="rounded-md border border-slate-200 bg-white p-4 text-sm space-y-2">
      <h3 className="font-semibold text-ink">
        {g.acronym ?? g.guideline_id} — {g.title}
      </h3>
      {g.study_design && (
        <p>
          <span className="font-medium">Study design:</span> {g.study_design}
        </p>
      )}
      <p>
        <span className="font-medium">Checklist:</span>{" "}
        {g.has_checklist ? "available (Checklists tab)" : "catalog only"}
      </p>
      {g.equator_url && (
        <p>
          <a className="text-teal underline" href={g.equator_url} target="_blank" rel="noreferrer">
            EQUATOR page
          </a>
        </p>
      )}
      {g.downloadable_files?.length > 0 && (
        <div>
          <p className="font-medium">Source files</p>
          <ul className="list-disc pl-5">
            {g.downloadable_files.map((f, i) => (
              <li key={i}>
                <a className="text-teal underline" href={f.url} target="_blank" rel="noreferrer">
                  {f.label || f.url}
                </a>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
