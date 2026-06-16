import { test, expect } from "@playwright/test";
import { openApp } from "./helpers";

// Runs only under the "mobile" project (Pixel 5 viewport); see playwright.config.ts.
test("tabs work and the checklist hides the Section column on small screens", async ({ page }) => {
  await openApp(page);

  await page.getByRole("button", { name: "Checklists" }).click();
  await expect(page.getByText(/items completed/)).toBeVisible();

  // Section column is hidden below the md breakpoint; Item stays visible.
  await expect(page.getByRole("columnheader", { name: "Section" })).toBeHidden();
  await expect(page.getByRole("columnheader", { name: "Item", exact: true })).toBeVisible();

  await page.getByRole("button", { name: "Flow diagrams" }).click();
  await expect(page.getByText("Final diagram (require exact accounting)")).toBeVisible();
});
