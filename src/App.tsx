import { useEffect, useState } from "react";
import { loadData, type Dataset } from "./lib/data";
import Catalog from "./components/Catalog";
import ChecklistEditor from "./components/ChecklistEditor";
import FlowchartBuilder from "./components/FlowchartBuilder";
import RobBuilder from "./components/RobBuilder";
import ThemeToggle from "./components/ThemeToggle";

type Tab = "catalog" | "checklists" | "flow" | "rob";

const TABS: { id: Tab; label: string }[] = [
  { id: "catalog", label: "Catalog" },
  { id: "checklists", label: "Checklists" },
  { id: "flow", label: "Flow diagrams" },
  { id: "rob", label: "Risk of bias" },
];

export default function App() {
  const [data, setData] = useState<Dataset | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [tab, setTab] = useState<Tab>("catalog");

  useEffect(() => {
    loadData()
      .then(setData)
      .catch((e) => setError(String(e)));
  }, []);

  return (
    <div className="min-h-screen flex flex-col">
      <header className="bg-ink text-white">
        <div className="max-w-6xl mx-auto px-4 py-3 flex items-center gap-3">
          <img src={`${import.meta.env.BASE_URL}logo.png`} alt="" className="h-9 w-9" />
          <div className="flex-1">
            <h1 className="text-lg font-semibold leading-tight">reportilo</h1>
            <p className="text-xs text-slate-300">
              Fill in and export EQUATOR reporting checklists and flow diagrams
            </p>
          </div>
          <a
            className="text-sm text-slate-200 hover:text-white"
            href="https://choxos.github.io/reportilo/"
            target="_blank"
            rel="noreferrer"
          >
            Docs
          </a>
          <a
            className="text-sm text-slate-200 hover:text-white"
            href="https://github.com/choxos/reportilo"
            target="_blank"
            rel="noreferrer"
          >
            GitHub
          </a>
          <ThemeToggle />
        </div>
        <nav className="max-w-6xl mx-auto px-4 flex gap-1">
          {TABS.map((t) => (
            <button
              key={t.id}
              onClick={() => setTab(t.id)}
              className={
                "px-4 py-2 text-sm font-medium rounded-t-md " +
                (tab === t.id
                  ? "bg-slate-50 text-ink dark:bg-slate-900 dark:text-white"
                  : "text-slate-200 hover:bg-white/10")
              }
            >
              {t.label}
            </button>
          ))}
        </nav>
      </header>

      <main className="flex-1 max-w-6xl w-full mx-auto px-4 py-6">
        {error && (
          <div className="rounded-md bg-red-50 text-red-700 p-4 text-sm dark:bg-red-950 dark:text-red-300">
            Could not load data: {error}
          </div>
        )}
        {!data && !error && <p className="text-slate-500 dark:text-slate-400">Loading guideline data…</p>}
        {data && tab === "catalog" && <Catalog data={data} />}
        {data && tab === "checklists" && <ChecklistEditor data={data} />}
        {data && tab === "flow" && <FlowchartBuilder data={data} />}
        {data && tab === "rob" && <RobBuilder data={data} />}
      </main>

      <footer className="border-t border-slate-200 py-4 text-center text-xs text-slate-500 dark:border-slate-700 dark:text-slate-400">
        reportilo · data from the{" "}
        <a className="underline" href="https://www.equator-network.org/" target="_blank" rel="noreferrer">
          EQUATOR Network
        </a>{" "}
        · runs entirely in your browser
      </footer>
    </div>
  );
}
