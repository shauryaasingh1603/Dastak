"use client";

import { useState } from "react";
import { parseBooths } from "@/lib/booths";
import { supabase } from "@/lib/supabase";
import {
  CATEGORY,
  CONTACT_RELATION,
  DOC,
  FLAG,
  FORM_STATUS,
  GENDER,
  NEW_REASON,
  OUTCOME,
  RELATION,
  ROUTE,
  istDate,
  istTime,
  label,
} from "@/lib/labels";

export type ExportFilters = {
  kind: "visits" | "forms";
  from: string;
  to: string;
  user_id: string;
  booths: string;
  form_type: string;
  status: string;
  category: string;
  outcome: string;
  met: string;
  photo: string;
};

export const EMPTY_FILTERS: ExportFilters = {
  kind: "visits",
  from: "",
  to: "",
  user_id: "",
  booths: "",
  form_type: "",
  status: "",
  category: "",
  outcome: "",
  met: "",
  photo: "",
};

type Row = Record<string, unknown>;
type Column = [header: string, value: (r: Row) => unknown];

const s = (r: Row, k: string) => r[k] as string | null;
const docs = (v: unknown) =>
  String(v ?? "")
    .split(", ")
    .filter(Boolean)
    .map((d) => label(DOC, d))
    .join(", ");

const PERSON: Column[] = [
  ["Booth", (r) => r.part_no],
  ["Polling station", (r) => r.polling_station],
  ["House no", (r) => r.house_no],
  ["Name", (r) => r.name],
  ["Relation", (r) => label(RELATION, s(r, "relation"))],
  ["Relative's name", (r) => r.relative],
  ["Age", (r) => r.age],
  ["Gender", (r) => label(GENDER, s(r, "gender"))],
  ["EPIC", (r) => r.epic],
  ["Category", (r) => label(CATEGORY, s(r, "category"))],
  ["New voter reason", (r) => label(NEW_REASON, s(r, "new_reason"))],
  ["2027 draft part", (r) => r.draft_part],
  ["2027 draft section", (r) => r.draft_section],
];

const VISIT_COLUMNS: Column[] = [
  ["Visited at", (r) => istTime(s(r, "visited_at"))],
  ["Volunteer", (r) => r.volunteer],
  ["Volunteer mobile", (r) => r.volunteer_mobile],
  ...PERSON,
  ["Result", (r) => label(OUTCOME, s(r, "outcome"))],
  ["Documents seen", (r) => docs(r.docs)],
  ["Person's mobile", (r) => r.person_mobile],
  ["Spoke to", (r) => r.contact_name],
  ["Their relation", (r) => label(CONTACT_RELATION, s(r, "contact_relation"))],
  ["Their mobile", (r) => r.contact_mobile ?? (r.contact_refused ? "refused" : "")],
  ["Remarks", (r) => r.remarks],
  ["Revisit on", (r) => r.revisit_on],
  ["Latitude", (r) => r.gps_lat],
  ["Longitude", (r) => r.gps_lng],
  ["Location accuracy (m)", (r) => (r.gps_accuracy_m == null ? "" : Math.round(Number(r.gps_accuracy_m)))],
  ["Checks", (r) => String(r.flags ?? "").split(", ").filter(Boolean).map((f) => label(FLAG, f)).join(", ")],
  ["Form", (r) => (r.form_type ? `Form ${r.form_type}` : "")],
  ["Form status", (r) => label(FORM_STATUS, s(r, "form_status"))],
  ["Form route", (r) => label(ROUTE, s(r, "form_route"))],
  ["Receipt no", (r) => r.reference_no],
  ["Filed on", (r) => r.filed_on],
  ["Photo / ECI", (r) => (r.form_type ? (r.has_photo ? "yes" : "no") : "")],
  ["Sent at", (r) => istTime(s(r, "received_at"))],
];

const FORM_COLUMNS: Column[] = [
  ["Form", (r) => `Form ${r.form_type}`],
  ["Status", (r) => label(FORM_STATUS, s(r, "form_status"))],
  ["Route", (r) => label(ROUTE, s(r, "form_route"))],
  ["Receipt no", (r) => r.reference_no],
  ["Filed on", (r) => r.filed_on],
  ["Filled at", (r) => istTime(s(r, "created_at"))],
  ["Filled by", (r) => r.filed_by],
  ["Filled by mobile", (r) => r.filed_by_mobile],
  ["Photo / ECI", (r) => (r.has_photo ? "yes" : "no")],
  ...PERSON,
  ["New voter note", (r) => r.new_reason_note],
  ["Person's mobile", (r) => r.person_mobile],
  ["Last visit", (r) => istTime(s(r, "visited_at"))],
  ["Last result", (r) => label(OUTCOME, s(r, "outcome"))],
  ["Documents seen", (r) => docs(r.docs)],
  ["Spoke to", (r) => r.contact_name],
  ["Their relation", (r) => label(CONTACT_RELATION, s(r, "contact_relation"))],
  ["Their mobile", (r) => r.contact_mobile ?? (r.contact_refused ? "refused" : "")],
  ["Remarks", (r) => r.remarks],
  ["Latitude", (r) => r.gps_lat],
  ["Longitude", (r) => r.gps_lng],
];

/** The filters as the database function takes them. */
export function toRpcFilters(f: ExportFilters): Record<string, unknown> {
  return {
    from: f.from,
    to: f.to,
    user_id: f.user_id,
    parts: f.booths.trim() ? parseBooths(f.booths) : [],
    form_type: f.form_type,
    status: f.status,
    category: f.category,
    outcome: f.outcome,
    met: f.met,
    photo: f.photo,
  };
}

function toCsv(rows: Row[], columns: Column[]): string {
  const cell = (v: unknown) => {
    const text = v === null || v === undefined ? "" : String(v);
    return /[",\n]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
  };
  return "﻿" + [columns.map(([h]) => cell(h)).join(","), ...rows.map((r) => columns.map(([, f]) => cell(f(r))).join(","))].join("\n");
}

/**
 * "Export": choose people visited (one row per person per visit) or forms
 * (one row per form, with the applicant and their last visit), narrow it
 * down, and download a CSV that opens in Excel or Google Sheets.
 */
export default function ExportDialog({
  initial,
  volunteers,
  onClose,
}: {
  initial: Partial<ExportFilters>;
  volunteers: { id: string; name: string }[];
  onClose: () => void;
}) {
  const [f, setF] = useState<ExportFilters>({ ...EMPTY_FILTERS, ...initial });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [done, setDone] = useState("");
  const set = (patch: Partial<ExportFilters>) => {
    setDone("");
    setError("");
    setF((old) => ({ ...old, ...patch }));
  };

  function preset(days: number | null) {
    if (days === null) set({ from: "", to: "" });
    else if (days === -1) set({ from: istDate(-1), to: istDate(-1) });
    else set({ from: istDate(-days), to: istDate() });
  }

  async function download() {
    let filters: Record<string, unknown>;
    try {
      filters = toRpcFilters(f);
    } catch (e) {
      setError((e as Error).message);
      return;
    }
    setBusy(true);
    setError("");
    const { data, error } = await supabase.rpc("admin_rows", { p_kind: f.kind, p_filters: filters });
    setBusy(false);
    if (error) {
      setError("Could not prepare the file. Check your connection and try again.");
      return;
    }
    const rows = (data ?? []) as Row[];
    if (rows.length === 0) {
      setError("Nothing matches these filters.");
      return;
    }
    const csv = toCsv(rows, f.kind === "visits" ? VISIT_COLUMNS : FORM_COLUMNS);
    const url = URL.createObjectURL(new Blob([csv], { type: "text/csv;charset=utf-8" }));
    const a = document.createElement("a");
    a.href = url;
    a.download = `dastak-${f.kind === "visits" ? "people-visited" : "forms"}-${f.from || "all"}${f.to && f.to !== f.from ? `-to-${f.to}` : ""}.csv`;
    a.click();
    URL.revokeObjectURL(url);
    setDone(`${rows.length.toLocaleString("en-IN")} rows downloaded.`);
  }

  return (
    <div className="panel-backdrop centered" onClick={onClose}>
      <div className="dialog" role="dialog" aria-label="Export" onClick={(e) => e.stopPropagation()}>
        <div className="panel-head">
          <h2>Export to CSV</h2>
          <button className="small" onClick={onClose}>
            Close
          </button>
        </div>

        <div className="field">
          <label>What</label>
          <div className="segmented">
            <button className={f.kind === "visits" ? "on" : ""} onClick={() => set({ kind: "visits" })}>
              People visited
            </button>
            <button className={f.kind === "forms" ? "on" : ""} onClick={() => set({ kind: "forms" })}>
              Forms
            </button>
          </div>
          <div className="hint">
            {f.kind === "visits"
              ? "One row per person per visit: who, when, result, phones, documents, location, and their form."
              : "One row per form: applicant details, form status and receipt, and their last visit."}
          </div>
        </div>

        <div className="field">
          <label>{f.kind === "visits" ? "Visit dates" : "Form dates"}</label>
          <div className="toolbar">
            <button className="small" onClick={() => preset(0)}>
              Today
            </button>
            <button className="small" onClick={() => preset(-1)}>
              Yesterday
            </button>
            <button className="small" onClick={() => preset(6)}>
              Last 7 days
            </button>
            <button className="small" onClick={() => preset(null)}>
              All dates
            </button>
          </div>
          <div className="form-row two">
            <input type="date" value={f.from} onChange={(e) => set({ from: e.target.value })} aria-label="From" />
            <input type="date" value={f.to} onChange={(e) => set({ to: e.target.value })} aria-label="To" />
          </div>
        </div>

        <div className="form-row two">
          <div className="field">
            <label>Volunteer</label>
            <select value={f.user_id} onChange={(e) => set({ user_id: e.target.value })}>
              <option value="">Everyone</option>
              {volunteers.map((v) => (
                <option key={v.id} value={v.id}>
                  {v.name}
                </option>
              ))}
            </select>
          </div>
          <div className="field">
            <label>Booths</label>
            <input value={f.booths} onChange={(e) => set({ booths: e.target.value })} placeholder="All, or e.g. 12, 40-45" />
          </div>
          <div className="field">
            <label>Category</label>
            <select value={f.category} onChange={(e) => set({ category: e.target.value })}>
              <option value="">All</option>
              {Object.entries(CATEGORY).map(([k, v]) => (
                <option key={k} value={k}>
                  {v}
                </option>
              ))}
            </select>
          </div>
          <div className="field">
            <label>Result</label>
            <select value={f.outcome} onChange={(e) => set({ outcome: e.target.value })}>
              <option value="">All</option>
              {Object.entries(OUTCOME).map(([k, v]) => (
                <option key={k} value={k}>
                  {v}
                </option>
              ))}
            </select>
          </div>
          {f.kind === "visits" && (
            <div className="field">
              <label>Met</label>
              <select value={f.met} onChange={(e) => set({ met: e.target.value })}>
                <option value="">Met or not</option>
                <option value="yes">Met only</option>
                <option value="no">Not met only</option>
              </select>
            </div>
          )}
          <div className="field">
            <label>Form</label>
            <select value={f.form_type} onChange={(e) => set({ form_type: e.target.value })}>
              <option value="">{f.kind === "visits" ? "With or without a form" : "Form 6 and 8"}</option>
              <option value="6">Form 6</option>
              <option value="8">Form 8</option>
            </select>
          </div>
          <div className="field">
            <label>Form status</label>
            <select value={f.status} onChange={(e) => set({ status: e.target.value })}>
              <option value="">Any</option>
              {Object.entries(FORM_STATUS).map(([k, v]) => (
                <option key={k} value={k}>
                  {v}
                </option>
              ))}
            </select>
          </div>
          <div className="field">
            <label>Photo / ECI</label>
            <select value={f.photo} onChange={(e) => set({ photo: e.target.value })}>
              <option value="">Any</option>
              <option value="yes">With photo</option>
              <option value="no">Without photo</option>
            </select>
          </div>
        </div>

        {error && <div className="notice error">{error}</div>}
        {done && <div className="notice success">{done}</div>}
        <div className="toolbar">
          <button className="primary" onClick={download} disabled={busy}>
            {busy ? "Preparing…" : "Download CSV"}
          </button>
          <button onClick={() => setF({ ...EMPTY_FILTERS, kind: f.kind })} disabled={busy}>
            Clear filters
          </button>
        </div>
        <p className="muted small-text">
          The file holds people&apos;s phone numbers and locations. Keep it to the campaign office and delete it when done.
        </p>
      </div>
    </div>
  );
}
