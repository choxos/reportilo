import { useEffect, useState } from "react";
import { getTheme, setTheme, applyTheme, onSystemThemeChange, type Theme } from "../lib/theme";

const ORDER: Theme[] = ["system", "light", "dark"];
const ICON: Record<Theme, string> = { system: "🖥", light: "☀", dark: "🌙" };
const LABEL: Record<Theme, string> = { system: "System", light: "Light", dark: "Dark" };

export default function ThemeToggle() {
  const [theme, setThemeState] = useState<Theme>(() => getTheme());

  // re-apply on mount and whenever the OS preference changes while in system mode
  useEffect(() => {
    applyTheme(theme);
    if (theme !== "system") return;
    return onSystemThemeChange(() => applyTheme("system"));
  }, [theme]);

  const cycle = () => {
    const next = ORDER[(ORDER.indexOf(theme) + 1) % ORDER.length];
    setTheme(next);
    setThemeState(next);
  };

  return (
    <button
      onClick={cycle}
      title={`Theme: ${LABEL[theme]} (click to change)`}
      aria-label={`Theme: ${LABEL[theme]}`}
      className="flex items-center gap-1 rounded px-2 py-1 text-sm text-slate-200 hover:bg-white/10"
    >
      <span aria-hidden="true">{ICON[theme]}</span>
      <span className="hidden sm:inline">{LABEL[theme]}</span>
    </button>
  );
}
