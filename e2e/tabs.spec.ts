import { test, expect } from "@playwright/test";
import { openApp } from "./helpers";

test("all four tabs switch and render their primary control", async ({ page }) => {
  await openApp(page);

  // Catalog is the default tab.
  await expect(page.getByPlaceholder("Search acronym, title, topic…")).toBeVisible();

  await page.getByRole("button", { name: "Checklists" }).click();
  await expect(page.getByText(/items completed/)).toBeVisible();

  await page.getByRole("button", { name: "Flow diagrams" }).click();
  await expect(page.getByText("Final diagram (require exact accounting)")).toBeVisible();

  await page.getByRole("button", { name: "Risk of bias" }).click();
  await expect(page.getByText("Traffic light", { exact: true })).toBeVisible();

  await page.getByRole("button", { name: "Catalog" }).click();
  await expect(page.getByPlaceholder("Search acronym, title, topic…")).toBeVisible();
});

test("tabs are keyboard operable", async ({ page }) => {
  await openApp(page);
  const flow = page.getByRole("button", { name: "Flow diagrams" });
  await flow.focus();
  await expect(flow).toBeFocused();
  await page.keyboard.press("Enter");
  await expect(page.getByText("Final diagram (require exact accounting)")).toBeVisible();
});
