export interface DownloadableFile {
  label: string;
  url: string;
  ext: string;
}

export interface Guideline {
  guideline_id: string;
  acronym: string | null;
  title: string | null;
  equator_url: string | null;
  study_design: string | null;
  clinical_area: string | null;
  reference: string | null;
  doi: string | null;
  website_url: string | null;
  has_checklist: boolean;
  checklist_tier: string;
  downloadable_files: DownloadableFile[];
  [key: string]: unknown;
}

export interface ChecklistItem {
  item_uid: string;
  guideline_id: string;
  section: string;
  item_no: string;
  item_order: number;
  item_text: string;
  response_type: string;
  is_override: boolean;
}

export interface FlowNode {
  template_id: string;
  node_id: string;
  stage: string;
  stage_order: number;
  node_order: number;
  role: string;
  label_template: string;
  side: string;
  fill: string | null;
}

export interface FlowEdge {
  template_id: string;
  from_node: string;
  to_node: string;
  edge_type: string;
  style: string;
}

export interface FlowCount {
  template_id: string;
  count_field: string;
  label: string;
  value: string;
  field_order: number;
  is_reasons: boolean;
}

export interface FlowTemplate {
  template_id: string;
  name: string;
  guideline_id: string;
  study_type: string;
  n_count_fields: number;
}

export interface Flowcharts {
  templates: FlowTemplate[];
  nodes: FlowNode[];
  edges: FlowEdge[];
  counts: FlowCount[];
}

export interface ParseStatus {
  guideline_id: string;
  status: string;
  n_items: number | null;
  parse_confidence: number | null;
  verified: boolean;
  needs_review: boolean;
}
