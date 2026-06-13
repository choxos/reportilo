import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// Dev serves at /, production is published under /reportilo/app/.
export default defineConfig(({ command }) => ({
  base: command === "build" ? "/reportilo/app/" : "/",
  plugins: [react()],
  build: {
    // the Graphviz WASM module is large but loads once; keep the log clean
    chunkSizeWarningLimit: 2000,
  },
}));
