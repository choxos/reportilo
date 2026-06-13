import type {
  Guideline,
  ChecklistItem,
  Flowcharts,
  ParseStatus,
  RobData,
} from "../types";

const base = import.meta.env.BASE_URL;

async function loadJson<T>(name: string): Promise<T> {
  const res = await fetch(`${base}data/${name}`);
  if (!res.ok) throw new Error(`Failed to load ${name}: ${res.status}`);
  return res.json() as Promise<T>;
}

export interface Dataset {
  guidelines: Guideline[];
  checklistItems: ChecklistItem[];
  flowcharts: Flowcharts;
  parseStatus: ParseStatus[];
  rob: RobData;
}

let cache: Dataset | null = null;

export async function loadData(): Promise<Dataset> {
  if (cache) return cache;
  const [guidelines, checklistItems, flowcharts, parseStatus, rob] =
    await Promise.all([
      loadJson<Guideline[]>("guidelines.json"),
      loadJson<ChecklistItem[]>("checklist_items.json"),
      loadJson<Flowcharts>("flowcharts.json"),
      loadJson<ParseStatus[]>("parse_status.json"),
      loadJson<RobData>("rob.json"),
    ]);
  cache = { guidelines, checklistItems, flowcharts, parseStatus, rob };
  return cache;
}

export function checklistFor(
  data: Dataset,
  guidelineId: string,
): ChecklistItem[] {
  return data.checklistItems
    .filter((i) => i.guideline_id === guidelineId)
    .sort((a, b) => a.item_order - b.item_order);
}
