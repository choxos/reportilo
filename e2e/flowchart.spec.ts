import { test, expect } from "@playwright/test";
import { openApp, downloadOf } from "./helpers";

const screened = 'label:text-is("Records screened") + input';
const identified =
  'label:text-is("Records identified from databases and registers") + input';

test("inconsistent counts block export until the user opts into a draft", async ({ page }) => {
  await openApp(page);
  await page.getByRole("button", { name: "Flow diagrams" }).click();

  // More screened than identified: a bounds violation, so exports are blocked.
  await page.locator(screened).fill("100");
  await expect(page.getByText("Exports are blocked until these are resolved.")).toBeVisible();

  const png = page.getByRole("button", { name: "PNG", exact: true });
  await expect(png).toBeDisabled();

  await page.getByRole("checkbox", { name: /Export despite consistency warnings/ }).check();
  await expect(page.locator(".flow-preview svg")).toBeVisible();
  await expect(png).toBeEnabled();

  const dl = await downloadOf(page, () => png.click());
  expect(dl.suggestedFilename()).toBe("prisma_2020.png");
});

test("consistent PRISMA counts export PNG and SVG", async ({ page }) => {
  await openApp(page);
  await page.getByRole("button", { name: "Flow diagrams" }).click();

  await page.locator(identified).fill("1200");
  await page.locator(screened).fill("900");
  await expect(page.getByText("Exports are blocked until these are resolved.")).toHaveCount(0);
  await expect(page.locator(".flow-preview svg")).toBeVisible();

  const png = await downloadOf(page, () => page.getByRole("button", { name: "PNG", exact: true }).click());
  expect(png.suggestedFilename()).toBe("prisma_2020.png");

  const svg = await downloadOf(page, () => page.getByRole("button", { name: "SVG", exact: true }).click());
  expect(svg.suggestedFilename()).toBe("prisma_2020.svg");
});
