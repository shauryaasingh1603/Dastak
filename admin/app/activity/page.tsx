"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import ExportDialog, { EMPTY_FILTERS } from "@/components/ExportDialog";
import PersonPanel from "@/components/PersonPanel";
import Shell from "@/components/Shell";
import { ROLE_LABEL, supabase } from "@/lib/supabase";
import { CATEGORY, CONTACT_RELATION, FLAG, FORM_STATUS, OUTCOME, istDate, istTime, label } from "@/lib/labels";

type Volunteer = {
  id: string;
  name: string;
  role: string;
  is_active: boolean;
  booths: number[];
  people_today: number;
  last_visit_at: string | null;
};

type VisitRow = {
  visit_id: string;
  voter_id: string;
  visited_at: string;
  volunteer: string;
  part_no: number;
  house_no: string | null;
  name: string;
  age: number | null;
  category: string;
  outcome: string;
  person_mobile: string | null;
  contact_name: string | null;
  contact_relation: string | null;
  contact_mobile: string | null;
  contact_refused: boolean;
  remarks: string | null;
  revisit_on: string | null;
  flags: string;
  form_type: string | null;
  form_status: string | null;
  has_photo: boolean;
  has_eci: boolean;
  eci_status: string | null;
};

type Range = "today" | "yesterday" | "week" | "custom";

function rangeDates(range: Range, from: string, to: string): [string, string] {
  if (range === "today") return [istDate(), istDate()];
  if (range === "yesterday") return [istDate(-1), istDate(-1)];
  if (range === "week") return [istDate(-6), istDate()];
  return [from, to];
}

function Activity() {
  const [volunteers, setVolunteers] = useState<Volunteer[]>([]);
  const [selected, setSelected] = useState<string>(""); // "" = everyone
  const [query, setQuery] = useState("");
  const [range, setRange] = useState<Range>("today");
  const [from, setFrom] = useState(istDate());
  const [to, setTo] = useState(istDate());
  const [rows, setRows] = useState<VisitRow[] | null>(null);
  const [met, setMet] = useState<"all" | "met" | "not">("all");
  const [search, setSearch] = useState("");
  const [error, setError] = useState("");
  const [person, setPerson] = useState<string | null>(null);
  const [exporting, setExporting] = useState(false);

  useEffect(() => {
    (async () => {
      const { data } = await supabase.rpc("admin_dashboard");
      const list = ((data as { volunteers?: Volunteer[] } | null)?.volunteers ?? []).filter((v) => v.is_active);
      setVolunteers(list.sort((a, b) => b.people_today - a.people_today || a.name.localeCompare(b.name)));
    })();
  }, []);

  const [dFrom, dTo] = rangeDates(range, from, to);

  const load = useCallback(async () => {
    setRows(null);
    const { data, error } = await supabase.rpc("admin_rows", {
      p_kind: "visits",
      p_filters: { from: dFrom, to: dTo, user_id: selected },
    });
    if (error) {
      setError("Could not load the visits. Check your connection.");
      setRows([]);
      return;
    }
    setError("");
    setRows((data ?? []) as VisitRow[]);
  }, [dFrom, dTo, selected]);

  useEffect(() => {
    load();
  }, [load]);

  const needle = search.trim().toLowerCase();
  const shownRows = useMemo(
    () =>
      (rows ?? []).filter(
        (r) =>
          (met === "all" || (met === "met") === (r.outcome !== "NOT_MET")) &&
          (!needle || r.name.toLowerCase().includes(needle) || String(r.part_no) === needle),
      ),
    [rows, met, needle],
  );

  // Visits with the people they covered, newest first.
  const visits = useMemo(() => {
    const byVisit = new Map<string, VisitRow[]>();
    for (const r of shownRows) byVisit.set(r.visit_id, [...(byVisit.get(r.visit_id) ?? []), r]);
    return [...byVisit.values()];
  }, [shownRows]);

  const all = rows ?? [];
  const people = new Set(all.map((r) => r.voter_id)).size;
  const metPeople = new Set(all.filter((r) => r.outcome !== "NOT_MET").map((r) => r.voter_id)).size;
  const forms = new Set(all.filter((r) => r.form_type).map((r) => r.voter_id)).size;
  const outcomes = Object.entries(
    all.reduce<Record<string, number>>((acc, r) => ({ ...acc, [r.outcome]: (acc[r.outcome] ?? 0) + 1 }), {}),
  ).sort((a, b) => b[1] - a[1]);

  const current = volunteers.find((v) => v.id === selected);
  const list = volunteers.filter((v) => !query.trim() || v.name.toLowerCase().includes(query.trim().toLowerCase()));

  return (
    <>
      <div className="page-head dash-head">
        <div>
          <h1>Activity</h1>
          <p className="muted">Who each volunteer visited, and what they found. Click a name for the full record.</p>
        </div>
        <button className="small" onClick={() => setExporting(true)}>
          Export…
        </button>
      </div>

      <div className="activity">
        <aside className="card volunteer-list">
          <input placeholder="Find a volunteer" value={query} onChange={(e) => setQuery(e.target.value)} />
          <button className={`volunteer-item ${selected === "" ? "on" : ""}`} onClick={() => setSelected("")}>
            <strong>Everyone</strong>
            <span className="muted small-text">{volunteers.reduce((a, v) => a + v.people_today, 0)} people today</span>
          </button>
          {list.map((v) => (
            <button key={v.id} className={`volunteer-item ${selected === v.id ? "on" : ""}`} onClick={() => setSelected(v.id)}>
              <strong>{v.name}</strong>
              <span className="muted small-text">
                {v.people_today} today · booths {v.booths.join(", ") || "none"}
              </span>
            </button>
          ))}
        </aside>

        <section className="activity-main">
          <div className="card">
            <div className="card-head">
              <h2>
                {current ? current.name : "Everyone"}
                {current && <span className="muted small-text"> · {ROLE_LABEL[current.role] ?? current.role}</span>}
              </h2>
            </div>
            <div className="toolbar">
              {(
                [
                  ["today", "Today"],
                  ["yesterday", "Yesterday"],
                  ["week", "Last 7 days"],
                  ["custom", "Dates…"],
                ] as [Range, string][]
              ).map(([r, text]) => (
                <button key={r} className={`small ${range === r ? "selected" : ""}`} onClick={() => setRange(r)}>
                  {text}
                </button>
              ))}
              {range === "custom" && (
                <>
                  <input type="date" value={from} onChange={(e) => setFrom(e.target.value)} aria-label="From" />
                  <input type="date" value={to} onChange={(e) => setTo(e.target.value)} aria-label="To" />
                </>
              )}
            </div>

            <div className="mini-tiles">
              <div>
                <strong>{people}</strong>
                <span>people visited</span>
              </div>
              <div>
                <strong>{metPeople}</strong>
                <span>met</span>
              </div>
              <div>
                <strong>{people - metPeople}</strong>
                <span>not met</span>
              </div>
              <div>
                <strong>{forms}</strong>
                <span>with a form</span>
              </div>
            </div>
            {outcomes.length > 0 && (
              <div className="pill-row">
                {outcomes.map(([o, count]) => (
                  <span key={o} className="pill neutral">
                    {label(OUTCOME, o)}: {count}
                  </span>
                ))}
              </div>
            )}
          </div>

          <div className="card">
            <div className="toolbar">
              <input placeholder="Search a name or booth" value={search} onChange={(e) => setSearch(e.target.value)} />
              <select value={met} onChange={(e) => setMet(e.target.value as typeof met)} aria-label="Met">
                <option value="all">Met and not met</option>
                <option value="met">Met only</option>
                <option value="not">Not met only</option>
              </select>
            </div>
            {error && <div className="notice error">{error}</div>}
            {rows === null ? (
              <p className="muted">Loading…</p>
            ) : visits.length === 0 ? (
              <p className="empty">No visits for these dates.</p>
            ) : (
              visits.map((group) => {
                const v = group[0];
                return (
                  <div className="visit-group" key={v.visit_id}>
                    <div className="visit-head">
                      <strong>{istTime(v.visited_at)}</strong>
                      <span className="muted">
                        Booth {v.part_no}
                        {v.house_no && ` · House ${v.house_no}`}
                        {!selected && ` · ${v.volunteer}`}
                      </span>
                      {v.flags &&
                        v.flags.split(", ").map((f) => (
                          <span key={f} className="pill warn">
                            {label(FLAG, f)}
                          </span>
                        ))}
                    </div>
                    {(v.contact_name || v.contact_mobile || v.contact_refused) && (
                      <div className="muted small-text">
                        Spoke to {v.contact_name ?? "—"}
                        {v.contact_relation && ` (${label(CONTACT_RELATION, v.contact_relation)})`} ·{" "}
                        {v.contact_mobile ?? (v.contact_refused ? "refused to give a number" : "no number")}
                        {v.revisit_on && ` · revisit ${v.revisit_on}`}
                        {v.remarks && ` · “${v.remarks}”`}
                      </div>
                    )}
                    {group.map((r) => (
                      <button key={r.voter_id} className="person-row" onClick={() => setPerson(r.voter_id)}>
                        <span className="person-name">
                          {r.name}
                          <span className="muted small-text">
                            {" "}
                            {[r.age && `${r.age} yrs`, label(CATEGORY, r.category), r.person_mobile].filter(Boolean).join(" · ")}
                          </span>
                        </span>
                        <span className={`pill ${r.outcome === "NOT_MET" ? "warn" : "ok"}`}>{label(OUTCOME, r.outcome)}</span>
                        {r.form_type && (
                          <span className="pill neutral">
                            Form {r.form_type}: {label(FORM_STATUS, r.form_status)}
                            {r.has_eci ? (r.eci_status === "READ" ? " · ECI ✓" : " · ECI") : " · no ECI"}
                            {r.has_photo ? " · photo" : ""}
                          </span>
                        )}
                      </button>
                    ))}
                  </div>
                );
              })
            )}
          </div>
        </section>
      </div>

      {person && <PersonPanel voterId={person} onClose={() => setPerson(null)} />}
      {exporting && (
        <ExportDialog
          initial={{ ...EMPTY_FILTERS, kind: "visits", from: dFrom, to: dTo, user_id: selected }}
          volunteers={volunteers.map((v) => ({ id: v.id, name: v.name }))}
          onClose={() => setExporting(false)}
        />
      )}
    </>
  );
}

export default function Page() {
  return (
    <Shell>
      <Activity />
    </Shell>
  );
}
