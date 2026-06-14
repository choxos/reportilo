import { useEffect, useState } from "react";
import {
  getTheme,
  setTheme,
  applyTheme,
  storedTheme,
  systemPrefersDark,
  onSystemThemeChange,
  type Theme,
} from "../lib/theme";

const ICON: Record<Theme, string> = { light: "☀", dark: "🌙" };
const LABEL: Record<Theme, string> = { light: "Light", dark: "Dark" };

export default function ThemeToggle() {
  // start from the OS setting (or the user's saved choice if they made one)
  const [theme, setThemeState] = useState<Theme>(() => getTheme());

  useEffect(() => {
    applyTheme(theme);
  }, [theme]);

  // follow the OS until the user makes an explicit choice
  useEffect(() => {
    if (storedTheme()) return;
    return onSystemThemeChange(() => setThemeState(systemPrefersDark() ? "dark" : "light"));
  }, []);

  const next: Theme = theme === "dark" ? "light" : "dark";
  const toggle = () => {
    setTheme(next);
    setThemeState(next);
  };

  return (
    <button
      onClick={toggle}
      title={`Switch to ${LABEL[next]} theme`}
      aria-label={`Switch to ${LABEL[next]} theme`}
      className="flex items-center gap-1 rounded px-2 py-1 text-sm text-slate-200 hover:bg-white/10"
    >
      <span aria-hidden="true">{ICON[next]}</span>
      <span className="hidden sm:inline">{LABEL[next]}</span>
    </button>
  );
}
