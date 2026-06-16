import { test, expect } from "@playwright/test";
import { openApp, downloadOf } from "./helpers";

test("edit a judgment, switch plot type, and export PNG and CSV", async ({ page }) => {
  await openApp(page);
  await page.getByRole("button", { name: "Risk of bias" }).click();

  // Set the first study's first domain to its first real level.
  const firstCell = page.locator("tbody tr").first().locator("select").first();
  await firstCell.selectOption({ index: 1 });

  await page.getByText("Summary", { exact: true }).click();
  await expect(page.locator("svg").first()).toBeVisible();
  await page.getByText("Traffic light", { exact: true }).click();
  await expect(page.locator("svg").first()).toBeVisible();

  const png = await downloadOf(page, () => page.getByRole("button", { name: "PNG", exact: true }).click());
  expect(png.suggestedFilename()).toMatch(/_rob\.png$/);

  const csv = await downloadOf(page, () => page.getByRole("button", { name: "CSV", exact: true }).click());
  expect(csv.suggestedFilename()).toMatch(/_rob\.csv$/);
});

test("add and remove a study row", async ({ page }) => {
  await openApp(page);
  await page.getByRole("button", { name: "Risk of bias" }).click();

  const rows = page.locator("tbody tr");
  const before = await rows.count();
  await page.getByRole("button", { name: "+ Add study" }).click();
  await expect(rows).toHaveCount(before + 1);
  await rows.last().getByTitle("Remove study").click();
  await expect(rows).toHaveCount(before);
});
