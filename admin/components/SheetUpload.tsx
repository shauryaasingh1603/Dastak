"use client";

import { useRef, useState } from "react";
import { formatBooths, parseBooths } from "@/lib/booths";
import { ROLE_LABEL, supabase } from "@/lib/supabase";

/** One row as read from the sheet, before the database checks it. */
type SheetRow = { name: string; mobile: string; role: string; booths: string[]; boothError?: string };

/** One row as the database checked it. */
type CheckedRow = {
  row: number;
  name: string | null;
  mobile: string;
  role: string;
  booths: number[];
  error: string | null;
};

const PROBLEM: Record<string, string> = {
  NAME_MISSING: "Name is empty",
  MOBILE_INVALID: "Mobile is not 10 digits starting 6–9",
  MOBILE_REPEATED: "Same mobile as an earlier row",
  MOBILE_TAKEN: "Mobile already registered",
  ROLE_INVALID: "Role must be volunteer or BLA-2",
  BOOTH_INVALID: "Booth number not in 1–443",
};

// Column titles people are likely to use, in English or Hindi.
const COLUMNS: Record<keyof Omit<SheetRow, "boothError">, string[]> = {
  name: ["name", "volunteer name", "volunteer", "full name", "नाम"],
  mobile: ["mobile", "mobile number", "mobile no", "phone", "phone number", "number", "मोबाइल", "मोबाइल नंबर", "फ़ोन"],
  booths: ["booth", "booths", "booth number", "booth numbers", "booth no", "part", "part no", "parts", "बूथ", "बूथ नंबर"],
  role: ["role", "type", "भूमिका"],
};

const TEMPLATE = 'name,mobile,booths,role\nRam Kumar,9876543210,"12, 13",volunteer\nSunita Devi,9876543211,45-47,BLA-2\n';

function normalizeTitle(value: unknown): string {
  return String(value ?? "")
    .trim()
    .toLowerCase()
    .replace(/[._:]/g, " ")
    .replace(/\s+/g, " ");
}

/** A small CSV reader: quoted fields, commas and new lines inside quotes. */
function parseCsv(text: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [];
  let field = "";
  let quoted = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (quoted) {
      if (c === '"' && text[i + 1] === '"') {
        field += '"';
        i++;
      } else if (c === '"') {
        quoted = false;
      } else {
        field += c;
      }
    } else if (c === '"') {
      quoted = true;
    } else if (c === ",") {
      row.push(field);
      field = "";
    } else if (c === "\n" || c === "\r") {
      if (c === "\r" && text[i + 1] === "\n") i++;
      row.push(field);
      rows.push(row);
      row = [];
      field = "";
    } else {
      field += c;
    }
  }
  if (field || row.length) {
    row.push(field);
    rows.push(row);
  }
  return rows.filter((r) => r.some((cell) => cell.trim() !== ""));
}

/** Rows of cells into volunteers, using the header row to find the columns. */
function toRows(table: unknown[][]): SheetRow[] {
  if (table.length === 0) throw new Error("The sheet is empty.");
  const header = table[0].map(normalizeTitle);
  const index = (key: keyof typeof COLUMNS) => header.findIndex((h) => COLUMNS[key].includes(h));
  const at = { name: index("name"), mobile: index("mobile"), booths: index("booths"), role: index("role") };
  if (at.name < 0 || at.mobile < 0) {
    throw new Error('The first row must have column titles, including "name" and "mobile" (and "booths").');
  }
  return table.slice(1).map((cells) => {
    const cell = (i: number) => (i < 0 ? "" : String(cells[i] ?? "").trim());
    let booths: string[] = [];
    let boothError: string | undefined;
    try {
      // Spreadsheets turn "12" into the number 12; "12, 13" and "45-47" stay text.
      booths = parseBooths(cell(at.booths).replace(/;/g, ",")).map(String);
    } catch (e) {
      boothError = (e as Error).message;
      booths = ["x"];
    }
    return { name: cell(at.name), mobile: cell(at.mobile), role: cell(at.role), booths, boothError };
  });
}

async function readFile(file: File): Promise<SheetRow[]> {
  const name = file.name.toLowerCase();
  if (name.endsWith(".xlsx")) {
    const { readSheet } = await import("read-excel-file/browser");
    return toRows((await readSheet(file)) as unknown[][]);
  }
  if (name.endsWith(".csv") || file.type === "text/csv" || name.endsWith(".txt")) {
    return toRows(parseCsv((await file.text()).replace(/^﻿/, "")));
  }
  throw new Error("Choose a .csv or .xlsx file. From Google Sheets: File → Download → CSV or Microsoft Excel.");
}

/**
 * "Register from a sheet": the admin picks a CSV or Excel file with name,
 * mobile, booths (and optionally role), sees every row checked, then
 * registers the good rows in one go.
 */
export default function SheetUpload({ onRegistered }: { onRegistered: () => void }) {
  const input = useRef<HTMLInputElement>(null);
  const [fileName, setFileName] = useState("");
  const [sheet, setSheet] = useState<SheetRow[] | null>(null);
  const [checked, setChecked] = useState<CheckedRow[] | null>(null);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [busy, setBusy] = useState(false);

  function reset() {
    setSheet(null);
    setChecked(null);
    setFileName("");
    if (input.current) input.current.value = "";
  }

  async function check(rows: SheetRow[], commit: boolean) {
    const { data, error } = await supabase.rpc("admin_register_volunteers", {
      p_rows: rows.map(({ name, mobile, role, booths }) => ({ name, mobile, role, booths })),
      p_commit: commit,
    });
    if (error) throw new Error("Could not check the sheet. Check your connection and try again.");
    return data as { created: number; rows: CheckedRow[] };
  }

  async function choose(file: File | undefined) {
    if (!file) return;
    setError("");
    setNotice("");
    setChecked(null);
    setFileName(file.name);
    setBusy(true);
    try {
      const rows = await readFile(file);
      if (rows.length === 0) throw new Error("The sheet has column titles but no volunteers under them.");
      if (rows.length > 2000) throw new Error("That is more than 2,000 rows. Split the sheet and upload each part.");
      setSheet(rows);
      setChecked((await check(rows, false)).rows);
    } catch (e) {
      setSheet(null);
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }

  async function register() {
    if (!sheet) return;
    setBusy(true);
    setError("");
    try {
      const result = await check(sheet, true);
      const skipped = result.rows.filter((r) => r.error).length;
      setNotice(
        `${result.created} registered.` +
          (skipped ? ` ${skipped} row${skipped > 1 ? "s were" : " was"} left out; fix and upload them again.` : "") +
          " They can now ask to sign in from the app.",
      );
      reset();
      onRegistered();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }

  function downloadTemplate() {
    const url = URL.createObjectURL(new Blob([TEMPLATE], { type: "text/csv;charset=utf-8" }));
    const a = document.createElement("a");
    a.href = url;
    a.download = "dastak-volunteers-template.csv";
    a.click();
    URL.revokeObjectURL(url);
  }

  const good = checked?.filter((r) => !r.error).length ?? 0;
  const bad = (checked?.length ?? 0) - good;

  return (
    <div className="card">
      <div className="card-head">
        <h2>Register from a sheet</h2>
        <button type="button" className="small" onClick={downloadTemplate}>
          Download template
        </button>
      </div>
      <p className="muted small-text">
        A CSV or Excel (.xlsx) file with column titles in the first row: <strong>name</strong>, <strong>mobile</strong>,{" "}
        <strong>booths</strong> (e.g. <code>12, 13</code> or <code>45-47</code>) and optionally <strong>role</strong>{" "}
        (volunteer or BLA-2; volunteer if empty). From Google Sheets use File → Download → CSV.
      </p>
      {error && <div className="notice error">{error}</div>}
      {notice && <div className="notice success">{notice}</div>}
      <div className="toolbar">
        <input
          ref={input}
          type="file"
          accept=".csv,.xlsx,text/csv,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          onChange={(e) => choose(e.target.files?.[0])}
          disabled={busy}
          aria-label="Choose a CSV or Excel file"
        />
      </div>
      {busy && !checked && <p className="muted">Reading {fileName}…</p>}

      {checked && sheet && (
        <>
          <p>
            <strong>{fileName}</strong>: {checked.length} rows · <span className="pill ok">{good} ready</span>{" "}
            {bad > 0 && <span className="pill bad">{bad} with a problem</span>}
          </p>
          <div className="table-wrap tall">
            <table>
              <thead>
                <tr>
                  <th className="num">Row</th>
                  <th>Name</th>
                  <th>Mobile</th>
                  <th>Role</th>
                  <th>Booths</th>
                  <th>Check</th>
                </tr>
              </thead>
              <tbody>
                {checked.map((r, i) => {
                  const boothError = sheet[i]?.boothError;
                  return (
                    <tr key={r.row} className={r.error ? "inactive" : ""}>
                      {/* Row numbers as in the sheet: the header is row 1. */}
                      <td className="num">{r.row + 1}</td>
                      <td>{r.name ?? <span className="muted">—</span>}</td>
                      <td>{r.mobile || <span className="muted">—</span>}</td>
                      <td>{ROLE_LABEL[r.role] ?? r.role}</td>
                      <td>{boothError ? <span className="muted">{boothError}</span> : formatBooths(r.booths) || "—"}</td>
                      <td>
                        {r.error ? (
                          <span className="pill bad">{PROBLEM[r.error] ?? r.error}</span>
                        ) : (
                          <span className="pill ok">Ready</span>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
          <div className="toolbar">
            <button type="button" className="primary" onClick={register} disabled={busy || good === 0}>
              {busy ? "Registering…" : `Register ${good} volunteer${good === 1 ? "" : "s"}`}
              {bad > 0 ? ` (leave out ${bad})` : ""}
            </button>
            <button type="button" onClick={reset} disabled={busy}>
              Cancel
            </button>
          </div>
        </>
      )}
    </div>
  );
}
