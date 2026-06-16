import { test, expect } from "@playwright/test";
import { openApp, downloadOf } from "./helpers";

test("fill, track progress, export, and save/load round-trip", async ({ page }, testInfo) => {
  await openApp(page);
  await page.getByRole("button", { name: "Checklists" }).click();

  const firstPage = page.getByPlaceholder("p. 4").first();
  await firstPage.fill("p. 9");
  await expect(page.getByText(/^1 of \d+ items completed$/)).toBeVisible();

  const csv = await downloadOf(page, () => page.getByRole("button", { name: "Download CSV" }).click());
  expect(csv.suggestedFilename()).toMatch(/\.csv$/);

  const xlsx = await downloadOf(page, () => page.getByRole("button", { name: /Download Excel/ }).click());
  expect(xlsx.suggestedFilename()).toMatch(/\.xlsx$/);

  const docx = await downloadOf(page, () => page.getByRole("button", { name: /Download Word/ }).click());
  expect(docx.suggestedFilename()).toMatch(/\.docx$/);

  // Save the filled checklist to disk.
  const saved = await downloadOf(page, () =>
    page.getByRole("button", { name: "Save", exact: true }).click(),
  );
  const savedPath = testInfo.outputPath("checklist.reportilo.json");
  await saved.saveAs(savedPath);

  // Change the answer, then load the saved file back and confirm it is restored.
  await firstPage.fill("overwritten");
  const chooser = page.waitForEvent("filechooser");
  await page.getByRole("button", { name: "Load", exact: true }).click();
  (await chooser).setFiles(savedPath);
  await expect(firstPage).toHaveValue("p. 9");
});
