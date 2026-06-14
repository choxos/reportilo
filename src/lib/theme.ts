// Theme handling: light / dark, applied as a `dark` class on <html> (Tailwind's
// class strategy). On first load the app adopts the operating system's setting;
// once the user picks a theme it is persisted and the OS is no longer followed.

export type Theme = "light" | "dark";

const KEY = "reportilo-theme";

export function systemPrefersDark(): boolean {
  return typeof window !== "undefined" && window.matchMedia("(prefers-color-scheme: dark)").matches;
}

// the user's explicit choice, or null if they have not chosen one yet
export function storedTheme(): Theme | null {
  const t = typeof localStorage !== "undefined" ? localStorage.getItem(KEY) : null;
  return t === "light" || t === "dark" ? t : null;
}

// what to show right now: the stored choice, else the OS setting
export function getTheme(): Theme {
  return storedTheme() ?? (systemPrefersDark() ? "dark" : "light");
}

export function applyTheme(theme: Theme): void {
  if (typeof document === "undefined") return;
  document.documentElement.classList.toggle("dark", theme === "dark");
}

export function setTheme(theme: Theme): void {
  try {
    localStorage.setItem(KEY, theme);
  } catch {
    /* ignore */
  }
  applyTheme(theme);
}

// Notify when the OS preference changes; returns an unsubscribe function.
export function onSystemThemeChange(cb: () => void): () => void {
  if (typeof window === "undefined") return () => {};
  const mq = window.matchMedia("(prefers-color-scheme: dark)");
  mq.addEventListener("change", cb);
  return () => mq.removeEventListener("change", cb);
}
