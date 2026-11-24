"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import PersonPanel from "@/components/PersonPanel";
import Shell from "@/components/Shell";
import { istTime } from "@/lib/labels";
import { supabase } from "@/lib/supabase";

type Flag = {
  id: string;
  user_id: string;
  volunteer: string;
  volunteer_mobile: string | null;
  kind: string;
  severity: "HIGH" | "MEDIUM" | "LOW";
  count: number;
  summary: string;
  detail: {
    people?: { id: string; name: string; part_no: number; house_no: string | null }[];
    mobile?: string;
    reference?: string;
    volunteers?: string[];
    text?: string;
  };
  status: "OPEN" | "OK" | "PROBLEM";
  note: string | null;
  reviewed_by: string | null;
  reviewed_at: string | null;
  first_seen: string;
  last_seen: string;
};

type VolunteerCount = { user_id: string; name: string; open: number; high: number; problem: number; ok: number };

/** What each check means, and what to look at. */
const FLAG_KIND: Record<string, { title: string; check: string }> = {
  SAME_MOBILE: {
    title: "Same phone number, many households",
    check: "Call the number. One real person rarely belongs to three unrelated houses.",
  },
  OWN_NUMBER: {
    title: "Volunteer's own number used",
    check: "The volunteer entered their own number instead of the voter's.",
  },
  TEAM_NUMBER: {
    title: "Another team member's number used",
    check: "A team member's number was entered for voters.",
  },
  DUPLICATE_NEW_VOTER: {
    title: "Same new voter added twice",
    check: "Check whether this is one person entered twice.",
  },
  ECI_REF_REUSED: {
    title: "ECI reference on several forms",
    check: "One ECI application can only belong to one person.",
  },
  SCREENSHOT_REUSED: {
    title: "Same ECI screenshot reused",
    check: "The identical screenshot file was attached to different people.",
  },
  PHOTO_REUSED: {
    title: "Same face photo reused",
    check: "The identical photo file was attached to different people.",
  },
  ECI_NOT_ECI: { title: "Not an ECI screenshot", check: "Open the person's form and look at the image." },
  ECI_NAME_MISMATCH: {
    title: "Name on ECI doesn't match",
    check: "The ECI application may be for someone else.",
  },
  ECI_OTHER_AC: { title: "ECI application for another constituency", check: "Should be 371 Zafrabad." },
  ECI_UNREADABLE: { title: "ECI screenshot unreadable", check: "Open the screenshot and read it by hand." },
  ONE_SPOT: {
    title: "Many houses from one spot",
    check: "Many households recorded standing in one place. Call a few to confirm the visit.",
  },
  TOO_FAST: { title: "Too many houses too quickly", check: "Call a few households to confirm the visit." },
  FAR_FROM_BOOTH: {
    title: "Recorded far from the booth",
    check: "The phone was far from where the booth's other visits were recorded.",
  },
  NO_LOCATION: { title: "Visits without location", check: "Location may have been switched off." },
  ODD_HOURS: { title: "Visits late at night or early morning", check: "Check these were real door visits." },
  MOSTLY_NOT_MET: {
    title: "Almost everyone 'nobody met'",
    check: "Many 'nobody met' in one day can mean doors were not knocked.",
  },
  NUMBERS_DECLINED: {
    title: "Few phone numbers taken",
    check: "Most people met gave no number. Remind the volunteer to ask.",
  },
  REPEATED_TEXT: { title: "Same remark copied", check: "The same note was typed for many households." },
};

const SEVERITY: Record<string, { label: string; tone: string }> = {
  HIGH: { label: "Serious", tone: "bad" },
  MEDIUM: { label: "Check", tone: "warn" },
  LOW: { label: "Minor", tone: "neutral" },
};

const STATUS_TABS: [string, string][] = [
  ["OPEN", "To review"],
  ["PROBLEM", "Problems"],
  ["OK", "Fine"],
  ["ALL", "All"],
];

function FlagCard({ flag, onPerson, onChanged }: { flag: Flag; onPerson: (id: string) => void; onChanged: () => void }) {
  const [note, setNote] = useState(flag.note ?? "");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const kind = FLAG_KIND[flag.kind] ?? { title: flag.kind, check: "" };
  const sev = SEVERITY[flag.severity];

  const review = async (status: Flag["status"]) => {
    setBusy(true);
    setError("");
    const { error } = await supabase.rpc("admin_review_flag", { p_flag: flag.id, p_status: status, p_note: note });
    setBusy(false);
    if (error) {
      setError("Could not save. Check your connection.");
      return;
    }
    onChanged();
  };

  return (
    <div className={`flag-card sev-${flag.severity.toLowerCase()}`}>
      <div className="flag-head">
        <span className={`pill ${sev.tone}`}>{sev.label}</span>
        <strong>{kind.title}</strong>
        {flag.status !== "OPEN" && (
          <span className={`pill ${flag.status === "PROBLEM" ? "bad" : "ok"}`}>
            {flag.status === "PROBLEM" ? "Problem" : "Fine"}
          </span>
        )}
      </div>
      <p className="flag-summary">{flag.summary}</p>
      {kind.check && <p className="muted small-text">{kind.check}</p>}
      <div className="muted small-text">
        {flag.volunteer}
        {flag.volunteer_mobile && ` · ${flag.volunteer_mobile}`} · first seen {istTime(flag.first_seen)}
        {flag.last_seen !== flag.first_seen && ` · latest ${istTime(flag.last_seen)}`}
      </div>
      {flag.detail.volunteers && flag.detail.volunteers.length > 1 && (
        <div className="small-text">Volunteers involved: {flag.detail.volunteers.join(", ")}</div>
      )}
      {flag.detail.people && flag.detail.people.length > 0 && (
        <div className="pill-row flag-people">
          {flag.detail.people.map((p) => (
            <button key={p.id} className="chip" onClick={() => onPerson(p.id)}>
              {p.name}
              <span className="muted">
                {" "}
                · booth {p.part_no}
                {p.house_no && `, house ${p.house_no}`}
              </span>
            </button>
          ))}
        </div>
      )}
      <div className="flag-actions">
        <input
          placeholder="Note (what you found)"
          value={note}
          onChange={(e) => setNote(e.target.value)}
          aria-label="Note"
        />
        {flag.status === "OPEN" ? (
          <>
            <button className="small" disabled={busy} onClick={() => review("OK")}>
              Looks fine
            </button>
            <button className="small danger" disabled={busy} onClick={() => review("PROBLEM")}>
              Problem
            </button>
          </>
        ) : (
          <>
            <button className="small" disabled={busy} onClick={() => review(flag.status)}>
              Save note
            </button>
            <button className="small" disabled={busy} onClick={() => review("OPEN")}>
              Reopen
            </button>
          </>
        )}
      </div>
      {flag.reviewed_by && flag.reviewed_at && (
        <div className="muted small-text">
          Reviewed by {flag.reviewed_by} · {istTime(flag.reviewed_at)}
        </div>
      )}
      {error && <div className="notice error">{error}</div>}
    </div>
  );
}

function Flags() {
  const [status, setStatus] = useState("OPEN");
  const [flags, setFlags] = useState<Flag[] | null>(null);
  const [volunteers, setVolunteers] = useState<VolunteerCount[]>([]);
  const [selected, setSelected] = useState("");
  const [kind, setKind] = useState("");
  const [error, setError] = useState("");
  const [scanning, setScanning] = useState(false);
  const [person, setPerson] = useState<string | null>(null);

  const load = useCallback(async () => {
    const { data, error } = await supabase.rpc("admin_flags", { p_status: status });
    if (error) {
      setError("Could not load the flags. Check your connection.");
      setFlags([]);
      return;
    }
    setError("");
    const d = data as { flags: Flag[]; volunteers: VolunteerCount[] };
    setFlags(d.flags);
    setVolunteers(d.volunteers);
  }, [status]);

  useEffect(() => {
    load();
    const timer = setInterval(load, 60_000);
    return () => clearInterval(timer);
  }, [load]);

  const scan = async () => {
    setScanning(true);
    await supabase.rpc("admin_scan_quality");
    setScanning(false);
    load();
  };

  const shown = useMemo(
    () => (flags ?? []).filter((f) => (!selected || f.user_id === selected) && (!kind || f.kind === kind)),
    [flags, selected, kind],
  );
  const kinds = useMemo(() => [...new Set((flags ?? []).map((f) => f.kind))], [flags]);

  return (
    <>
      <div className="page-head dash-head">
        <div>
          <h1>Flags</h1>
          <p className="muted">
            Patterns that suggest shortcuts or made-up entries, raised as soon as a volunteer&apos;s phone sends its
            work. Look into each one, then mark it fine or a problem. A flag marked fine opens again if more of the same
            turns up.
          </p>
        </div>
        <button className="small" onClick={scan} disabled={scanning}>
          {scanning ? "Checking…" : "Check everyone now"}
        </button>
      </div>

      {error && <div className="notice error">{error}</div>}

      <div className="activity">
        <aside className="card volunteer-list">
          <button className={`volunteer-item ${selected === "" ? "on" : ""}`} onClick={() => setSelected("")}>
            <strong>Everyone</strong>
            <span className="muted small-text">{volunteers.reduce((a, v) => a + v.open, 0)} to review</span>
          </button>
          {volunteers.map((v) => (
            <button
              key={v.user_id}
              className={`volunteer-item ${selected === v.user_id ? "on" : ""}`}
              onClick={() => setSelected(v.user_id)}
            >
              <strong>{v.name}</strong>
              <span className="muted small-text">
                {v.open} to review
                {v.high > 0 && ` · ${v.high} serious`}
                {v.problem > 0 && ` · ${v.problem} problem${v.problem > 1 ? "s" : ""}`}
              </span>
            </button>
          ))}
        </aside>

        <section className="activity-main">
          <div className="card">
            <div className="toolbar">
              {STATUS_TABS.map(([s, text]) => (
                <button key={s} className={`small ${status === s ? "selected" : ""}`} onClick={() => setStatus(s)}>
                  {text}
                </button>
              ))}
              <select value={kind} onChange={(e) => setKind(e.target.value)} aria-label="Kind">
                <option value="">Every kind</option>
                {kinds.map((k) => (
                  <option key={k} value={k}>
                    {FLAG_KIND[k]?.title ?? k}
                  </option>
                ))}
              </select>
            </div>
            {flags === null ? (
              <p className="muted">Loading…</p>
            ) : shown.length === 0 ? (
              <p className="empty">{status === "OPEN" ? "Nothing to review." : "No flags here."}</p>
            ) : (
              shown.map((f) => <FlagCard key={`${f.id}${f.status}`} flag={f} onPerson={setPerson} onChanged={load} />)
            )}
          </div>
        </section>
      </div>

      {person && <PersonPanel voterId={person} onClose={() => setPerson(null)} />}
    </>
  );
}

export default function Page() {
  return (
    <Shell>
      <Flags />
    </Shell>
  );
}
