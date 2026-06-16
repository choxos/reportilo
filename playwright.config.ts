import { defineConfig, devices } from "@playwright/test";

// End-to-end tests drive the built browser app exactly as GitHub Pages serves
// it: `vite preview` mounts the production build under /reportilo/app/, so these
// tests double as a deployment smoke for the real base path.
const BASE = "http://127.0.0.1:4173/reportilo/app/";

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? [["github"], ["list"]] : "list",
  use: {
    baseURL: BASE,
    trace: "on-first-retry",
  },
  projects: [
    {
      name: "desktop",
      use: { ...devices["Desktop Chrome"] },
      testIgnore: /mobile\.spec\.ts/,
    },
    {
      name: "mobile",
      use: { ...devices["Pixel 5"] },
      testMatch: /mobile\.spec\.ts/,
    },
  ],
  webServer: {
    // build + preview so `npm run test:e2e` works standalone; the extra build in
    // CI is a couple of seconds and keeps the preview self-sufficient
    command: "npm run build && npm run preview -- --port 4173 --strictPort --host 127.0.0.1",
    url: BASE,
    reuseExistingServer: !process.env.CI,
    timeout: 180_000,
  },
});
