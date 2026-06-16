/// <reference types="vitest/config" />
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// Dev serves at /, production is published under /reportilo/app/. `vite preview`
// serves the production build, so it uses the production base too: that way
// `npm run preview` exercises the real /reportilo/app/ deployment layout instead
// of a misleading root mount that 404s on every asset.
export default defineConfig(({ command, isPreview }) => ({
  base: command === "build" || isPreview ? "/reportilo/app/" : "/",
  plugins: [react()],
  build: {
    // the Graphviz WASM module is large but loads once; keep the log clean
    chunkSizeWarningLimit: 2000,
  },
  test: {
    environment: "jsdom",
    include: ["src/**/*.test.ts"],
  },
}));
