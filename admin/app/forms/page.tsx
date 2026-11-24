"use client";

import { useCallback, useEffect, useState } from "react";
import ExportDialog, { EMPTY_FILTERS } from "@/components/ExportDialog";
import PersonPanel from "@/components/PersonPanel";
import Shell from "@/components/Shell";
import { formatTime, supabase } from "@/lib/supabase";

type FormRow = {
  id: string;
  form_type: string;
  route: string | null;
  reference_no: string | null;
  filed_on: string | null;
  current_status: string;
  created_at: string;
  photo_path: string | null;
  photo_at: string | null;
  filer: { name: string } | null;
  voter: {
    id: string;
    name_hi: string;
    age: number | null;
    gender: string | null;
    epic: string | null;
    category: string;
    new_reason: string | null;
    new_reason_note: string | null;
    family: { part_no: number; house_no: string | null };
  };
};

const STATUS: Record<string, string> = {
  FILLED: "Filled, not submitted",
  SUBMITTED: "Submitted",
  IN_ERO_LIST: "In ERO list",
  HEARING: "Hearing",
  ACCEPTED: "Accepted",
  REJECTED: "Rejected",
};

const ROUTE: Record<string, string> = { BLA2: "BLA-2", SELF: "By the voter", ONLINE: "Online" };

const REASON: Record<string, string> = { TURNED_18_THIS_YEAR: "Turned 18 this year", OTHER: "New voter" };

const LIMIT = 300;

function downloadCsv(rows: FormRow[]) {
  const header = ["Form", "Applicant", "Age", "EPIC", "Booth", "House", "New voter", "Status", "Route", "Receipt", "Filed on", "Volunteer", "Photo"];
  const cell = (v: unknown) => {
    const s = String(v ?? "");
    return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
  };
  const lines = rows.map((f) =>
    [
      `Form ${f.form_type}`,
      f.voter.name_hi,
      f.voter.age,
      f.voter.epic,
      f.voter.family.part_no,
      f.voter.family.house_no,
      f.voter.new_reason ? REASON[f.voter.new_reason] : "",
      STATUS[f.current_status] ?? f.current_status,
      f.route ? ROUTE[f.route] : "",
      f.reference_no,
      f.filed_on,
      f.filer?.name,
      f.photo_path ? "yes" : "no",
    ]
      .map(cell)
      .join(","),
  );
  const url = URL.createObjectURL(new Blob(["﻿" + [header.join(","), ...lines].join("\n")], { type: "text/csv;charset=utf-8" }));
  const a = document.createElement("a");
  a.href = url;
  a.download = "dastak-forms.csv";
  a.click();
  URL.revokeObjectURL(url);
}

function Forms() {
  const [rows, setRows] = useState<FormRow[] | null>(null);
  const [photos, setPhotos] = useState<Record<string, string>>({});
  const [counts, setCounts] = useState<{ forms: number; photos: number; turned18: number } | null>(null);
  const [error, setError] = useState("");
  const [booth, setBooth] = useState("");
  const [type, setType] = useState("");
  const [status, setStatus] = useState("");
  const [photo, setPhoto] = useState("");
  const [query, setQuery] = useState("");
  const [large, setLarge] = useState<string | null>(null);
  const [person, setPerson] = useState<string | null>(null);
  const [exporting, setExporting] = useState(false);
  const [team, setTeam] = useState<{ id: string; name: string }[]>([]);

  useEffect(() => {
    supabase
      .from("users")
      .select("id, name")
      .in("role", ["volunteer", "bla2"])
      .order("name")
      .then(({ data }) => setTeam((data ?? []) as { id: string; name: string }[]));
  }, []);

  const load = useCallback(async () => {
    let request = supabase
      .from("forms")
      .select(
        "id, form_type, route, reference_no, filed_on, current_status, created_at, photo_path, photo_at, " +
          "filer:users!forms_filed_by_user_id_fkey(name), " +
          "voter:voters!inner(id, name_hi, age, gender, epic, category, new_reason, new_reason_note, family:families!inner(part_no, house_no))",
      )
      .order("created_at", { ascending: false })
      .limit(LIMIT);
    if (/^\d+$/.test(booth.trim())) request = request.eq("voter.family.part_no", Number(booth.trim()));
    if (type) request = request.eq("form_type", type);
    if (status) request = request.eq("current_status", status);
    if (photo === "yes") request = request.not("photo_path", "is", null);
    if (photo === "no") request = request.is("photo_path", null);
    const { data, error } = await request;
    if (error) {
      setError("Could not load the forms. Check your connection.");
      return;
    }
    setError("");
    const list = data as unknown as FormRow[];
    setRows(list);

    // Short-lived links to the photos on this page.
    const paths = list.map((f) => f.photo_path).filter((p): p is string => !!p);
    if (paths.length) {
      const { data: signed } = await supabase.storage.from("form-photos").createSignedUrls(paths, 3600);
      setPhotos(Object.fromEntries((signed ?? []).filter((s) => s.signedUrl).map((s) => [s.path, s.signedUrl])));
    } else {
      setPhotos({});
    }
  }, [booth, type, status, photo]);

  useEffect(() => {
    load();
  }, [load]);

  useEffect(() => {
    (async () => {
      const [all, withPhoto, turned18] = await Promise.all([
        supabase.from("forms").select("id", { count: "exact", head: true }),
        supabase.from("forms").select("id", { count: "exact", head: true }).not("photo_path", "is", null),
        supabase.from("voters").select("id", { count: "exact", head: true }).eq("new_reason", "TURNED_18_THIS_YEAR"),
      ]);
      setCounts({ forms: all.count ?? 0, photos: withPhoto.count ?? 0, turned18: turned18.count ?? 0 });
    })();
  }, []);

  const needle = query.trim().toLowerCase();
  const shown = (rows ?? []).filter(
    (f) =>
      !needle ||
      f.voter.name_hi.toLowerCase().includes(needle) ||
      (f.reference_no ?? "").toLowerCase().includes(needle) ||
      (f.voter.epic ?? "").toLowerCase().includes(needle) ||
      (f.filer?.name ?? "").toLowerCase().includes(needle),
  );

  return (
    <>
      <div className="page-head dash-head">
        <div>
          <h1>Forms</h1>
          <p className="muted">
            Claim forms filled in the field, newest first, with the applicant&apos;s face photo.
            {counts &&
              ` ${counts.forms.toLocaleString("en-IN")} forms · ${counts.photos.toLocaleString("en-IN")} with a photo · ${counts.turned18.toLocaleString("en-IN")} new voters who turned 18 this year`}
          </p>
        </div>
        <div className="toolbar" style={{ margin: 0 }}>
          <button className="small" onClick={() => rows && downloadCsv(shown)} disabled={!rows?.length}>
            CSV of this page
          </button>
          <button className="small primary" onClick={() => setExporting(true)}>
            Export…
          </button>
        </div>
      </div>

      {error && <div className="notice error">{error}</div>}

      <div className="card">
        <div className="toolbar">
          <input placeholder="Name, receipt, EPIC or volunteer" value={query} onChange={(e) => setQuery(e.target.value)} />
          <input
            placeholder="Booth"
            value={booth}
            onChange={(e) => setBooth(e.target.value)}
            inputMode="numeric"
            style={{ flex: "0 1 110px" }}
            aria-label="Booth number"
          />
          <select value={type} onChange={(e) => setType(e.target.value)} aria-label="Form type">
            <option value="">All forms</option>
            <option value="6">Form 6</option>
            <option value="8">Form 8</option>
          </select>
          <select value={status} onChange={(e) => setStatus(e.target.value)} aria-label="Status">
            <option value="">Any status</option>
            {Object.entries(STATUS).map(([k, v]) => (
              <option key={k} value={k}>
                {v}
              </option>
            ))}
          </select>
          <select value={photo} onChange={(e) => setPhoto(e.target.value)} aria-label="Photo">
            <option value="">With or without photo</option>
            <option value="yes">With photo</option>
            <option value="no">No photo yet</option>
          </select>
        </div>

        {rows === null ? (
          <p className="muted">Loading…</p>
        ) : shown.length === 0 ? (
          <p className="empty">No forms match.</p>
        ) : (
          <>
            {rows.length === LIMIT && (
              <p className="muted small-text">Showing the newest {LIMIT}. Pick a booth to see older ones.</p>
            )}
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Photo</th>
                    <th>Applicant</th>
                    <th>Form</th>
                    <th>Booth</th>
                    <th>Status</th>
                    <th>Receipt</th>
                    <th>Volunteer</th>
                  </tr>
                </thead>
                <tbody>
                  {shown.map((f) => {
                    const url = f.photo_path ? photos[f.photo_path] : undefined;
                    return (
                      <tr key={f.id}>
                        <td>
                          {url ? (
                            <button className="photo-thumb" onClick={() => setLarge(url)} aria-label="Show photo larger">
                              {/* eslint-disable-next-line @next/next/no-img-element */}
                              <img src={url} alt="" width={56} height={56} />
                            </button>
                          ) : (
                            <span className="pill warn">No photo</span>
                          )}
                        </td>
                        <td>
                          <button className="link" onClick={() => setPerson(f.voter.id)}>
                            {f.voter.name_hi}
                          </button>
                          <div className="muted small-text">
                            {[f.voter.age && `${f.voter.age} yrs`, f.voter.epic].filter(Boolean).join(" · ")}
                            {f.voter.new_reason && (
                              <>
                                {" · "}
                                <strong>{REASON[f.voter.new_reason]}</strong>
                                {f.voter.new_reason_note && `: ${f.voter.new_reason_note}`}
                              </>
                            )}
                          </div>
                        </td>
                        <td>Form {f.form_type}</td>
                        <td>
                          {f.voter.family.part_no}
                          {f.voter.family.house_no && <div className="muted small-text">House {f.voter.family.house_no}</div>}
                        </td>
                        <td>
                          {STATUS[f.current_status] ?? f.current_status}
                          {f.route && <div className="muted small-text">{ROUTE[f.route]}</div>}
                        </td>
                        <td>
                          {f.reference_no ?? <span className="muted">—</span>}
                          {f.filed_on && <div className="muted small-text">{f.filed_on}</div>}
                        </td>
                        <td>
                          {f.filer?.name ?? "—"}
                          <div className="muted small-text">{formatTime(f.created_at)}</div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </>
        )}
      </div>

      {person && <PersonPanel voterId={person} onClose={() => setPerson(null)} />}
      {exporting && (
        <ExportDialog
          initial={{ ...EMPTY_FILTERS, kind: "forms", booths: booth, form_type: type, status }}
          volunteers={team}
          onClose={() => setExporting(false)}
        />
      )}

      {large && (
        <div className="photo-overlay" role="dialog" aria-label="Photo" onClick={() => setLarge(null)}>
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src={large} alt="Applicant's face photo" />
          <button className="small">Close</button>
        </div>
      )}
    </>
  );
}

export default function Page() {
  return (
    <Shell>
      <Forms />
    </Shell>
  );
}
