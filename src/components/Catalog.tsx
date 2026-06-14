import { useMemo, useState } from "react";
import type { Dataset } from "../lib/data";
import type { Guideline } from "../types";

export default function Catalog({ data }: { data: Dataset }) {
  const [search, setSearch] = useState("");
  const [activeCat, setActiveCat] = useState("All");
  const [checklistOnly, setChecklistOnly] = useState(false);
  const [selected, setSelected] = useState<Guideline | null>(null);

  // categories in EQUATOR display order, plus an "All" tab
  const tabs = useMemo(() => {
    const order = new Map<string, number>();
    for (const g of data.guidelines) {
      if (!order.has(g.category)) order.set(g.category, g.category_order);
    }
    const cats = [...order.entries()].sort((a, b) => a[1] - b[1]).map((e) => e[0]);
    return ["All", ...cats];
  }, [data]);

  // the flagship (starred) acronym for each category, used to surface a family's
  // main guideline and its extensions at the top of that category
  const flagshipByCat = useMemo(() => {
    const m = new Map<string, string>();
    for (const g of data.guidelines) {
      if (g.is_primary && g.acronym && !m.has(g.category)) {
        m.set(g.category, g.acronym.toUpperCase());
      }
    }
    return m;
  }, [data]);

  // rank within a category: 0 = flagship, 1 = its extension, 2 = everything else
  const rank = (g: Guideline): number => {
    if (g.is_primary) return 0;
    const flag = flagshipByCat.get(g.category);
    if (flag) {
      const acr = (g.acronym ?? "").toUpperCase();
      const title = (g.title ?? "").toUpperCase();
      if (acr.startsWith(flag) || title.includes(flag)) return 1;
    }
    return 2;
  };

  const filtered = useMemo(() => {
    const q = search.toLowerCase();
    return data.guidelines
      .filter((g) => {
        if (checklistOnly && !g.has_checklist) return false;
        if (activeCat !== "All" && g.category !== activeCat) return false;
        if (q) {
          const hay = `${g.acronym ?? ""} ${g.title ?? ""} ${g.study_design ?? ""} ${g.clinical_area ?? ""}`.toLowerCase();
          if (!hay.includes(q)) return false;
        }
        return true;
      })
      .sort((a, b) => {
        // group by category (so each family stays together), then flagship +
        // its extensions first, then the rest alphabetically (no-acronym last)
        if (a.category_order !== b.category_order) return a.category_order - b.category_order;
        const ra = rank(a);
        const rb = rank(b);
        if (ra !== rb) return ra - rb;
        const aBlank = !a.acronym;
        const bBlank = !b.acronym;
        if (aBlank !== bBlank) return aBlank ? 1 : -1;
        const aa = ((aBlank ? a.title : a.acronym) ?? "").toLowerCase();
        const bb = ((bBlank ? b.title : b.acronym) ?? "").toLowerCase();
        return aa.localeCompare(bb);
      });
  }, [data, search, activeCat, checklistOnly, flagshipByCat]);

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap gap-1">
        {tabs.map((c) => (
          <button
            key={c}
            onClick={() => setActiveCat(c)}
            className={
              "px-3 py-1.5 text-sm rounded-full border " +
              (activeCat === c
                ? "bg-ink text-white border-ink"
                : "bg-white text-slate-700 border-slate-300 hover:bg-slate-100 dark:bg-slate-800 dark:text-slate-200 dark:border-slate-600 dark:hover:bg-slate-700")
            }
          >
            {c}
          </button>
        ))}
      </div>

      <div className="grid md:grid-cols-[300px_1fr] gap-6">
        <aside className="space-y-3">
          <input
            className="w-full rounded border border-slate-300 px-3 py-2 text-sm dark:bg-slate-800 dark:border-slate-600 dark:text-slate-100 dark:placeholder:text-slate-400"
            placeholder="Search acronym, title, topic…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={checklistOnly}
              onChange={(e) => setChecklistOnly(e.target.checked)}
            />
            Only guidelines with a checklist
          </label>
          <p className="text-xs text-slate-500 dark:text-slate-400">{filtered.length} guidelines</p>
          {selected && <DetailCard g={selected} />}
        </aside>

        <div className="overflow-y-auto border border-slate-200 rounded-md bg-white max-h-[72vh] dark:border-slate-700 dark:bg-slate-800">
          <table className="w-full table-fixed text-sm">
            <colgroup>
              <col className="w-[30%] sm:w-44" />
              <col />
              <col className="w-40 hidden sm:table-cell" />
              <col className="w-16" />
            </colgroup>
            <thead className="sticky top-0 bg-slate-100 text-left dark:bg-slate-700">
              <tr>
                <th className="px-3 py-2 font-semibold">Acronym</th>
                <th className="px-3 py-2 font-semibold">Title</th>
                <th className="px-3 py-2 font-semibold hidden sm:table-cell">Category</th>
                <th className="px-3 py-2 font-semibold text-center">List</th>
              </tr>
            </thead>
            <tbody>
              {filtered.slice(0, 400).map((g) => {
                const isExt = rank(g) === 1;
                return (
                  <tr
                    key={g.guideline_id}
                    onClick={() => setSelected(g)}
                    className={
                      "cursor-pointer border-t border-slate-100 hover:bg-teal/10 dark:border-slate-700 dark:hover:bg-teal/20 " +
                      (selected?.guideline_id === g.guideline_id ? "bg-teal/10 dark:bg-teal/20" : "")
                    }
                  >
                    <td className="px-3 py-2 font-medium align-top break-words">
                      {isExt && <span className="text-slate-400 dark:text-slate-500">↳ </span>}
                      {g.acronym ?? "—"}
                      {g.is_primary && (
                        <span className="ml-1 text-teal" title="Main guideline of this family">
                          ★
                        </span>
                      )}
                    </td>
                    <td className="px-3 py-2 align-top break-words">{g.title}</td>
                    <td className="px-3 py-2 align-top text-slate-600 hidden sm:table-cell dark:text-slate-400">
                      {g.category}
                    </td>
                    <td className="px-3 py-2 align-top text-center text-teal">
                      {g.has_checklist ? "✓" : ""}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          {filtered.length > 400 && (
            <p className="p-3 text-xs text-slate-500 dark:text-slate-400">
              Showing the first 400 of {filtered.length}. Refine your search to see more.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}

function DetailCard({ g }: { g: Guideline }) {
  return (
    <div className="rounded-md border border-slate-200 bg-white p-4 text-sm space-y-2 dark:border-slate-700 dark:bg-slate-800">
      <h3 className="font-semibold text-ink dark:text-slate-100">
        {g.acronym ?? g.guideline_id} — {g.title}
      </h3>
      <p>
        <span className="font-medium">Category:</span> {g.category}
      </p>
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
