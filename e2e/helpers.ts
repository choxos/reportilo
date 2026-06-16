import { type Download, type Page, expect } from "@playwright/test";

// Open the app and wait until guideline data has finished loading.
export async function openApp(page: Page): Promise<void> {
  await page.goto("/reportilo/app/");
  await expect(page.getByRole("heading", { name: "reportilo", level: 1 })).toBeVisible();
  await expect(page.getByText("Loading guideline data")).toHaveCount(0);
}

// Run an action that triggers a browser download and return the Download.
export async function downloadOf(page: Page, action: () => Promise<void>): Promise<Download> {
  const [dl] = await Promise.all([page.waitForEvent("download"), action()]);
  return dl;
}
