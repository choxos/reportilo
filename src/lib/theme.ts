// Theme handling: light / dark / system, persisted to localStorage and applied
// as a `dark` class on <html> (Tailwind's class strategy). Default is system.

export type Theme = "light" | "dark" | "system";

const KEY = "reportilo-theme";

export function getTheme(): Theme {
  const t = (typeof localStorage !== "undefined" && localStorage.getItem(KEY)) as Theme | null;
  return t === "light" || t === "dark" || t === "system" ? t : "system";
}

function systemDark(): boolean {
  return typeof window !== "undefined" && window.matchMedia("(prefers-color-scheme: dark)").matches;
}

export function resolvedDark(theme: Theme): boolean {
  return theme === "dark" || (theme === "system" && systemDark());
}

export function applyTheme(theme: Theme): void {
  if (typeof document === "undefined") return;
  document.documentElement.classList.toggle("dark", resolvedDark(theme));
}

export function setTheme(theme: Theme): void {
  try {
    localStorage.setItem(KEY, theme);
  } catch {
    /* ignore */
  }
  applyTheme(theme);
}

// Keep "system" in sync with OS changes; returns an unsubscribe function.
export function onSystemThemeChange(cb: () => void): () => void {
  if (typeof window === "undefined") return () => {};
  const mq = window.matchMedia("(prefers-color-scheme: dark)");
  mq.addEventListener("change", cb);
  return () => mq.removeEventListener("change", cb);
}
