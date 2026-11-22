"use client";

import Link from "next/link";
import { useCallback, useEffect, useMemo, useState } from "react";
import Shell from "@/components/Shell";
import { BarList, DailyBars, Legend, Meter, type Series } from "@/components/charts";
import { ROLE_LABEL, formatTime, supabase } from "@/lib/supabase";

type Counts = Record<string, number>;
type Share = { people: number; attempted: number; reached: number };

type Dashboard = {
  generated_at: string;
  today: string;
  settings: {
    visits_open_from: string;
    claims_close_at: string;
    status_close_at: string;
    daily_people_target: number;
  };
  totals: {
    people: number;
    attempted: number;
    reached: number;
    visits: number;
    visits_today: number;
    people_today: number;
    new_voters: number;
    contacts_given: number;
    contacts_refused: number;
    member_mobiles: number;
    revisits_due_today: number;
    revisits_overdue: number;
    field_users: number;
    signed_in: number;
    active_today: number;
    pending_sign_ins: number;
  };
  forms: { by_type: Counts; by_status: Counts; by_route: Counts };
  daily: {
    day: string;
    people: number;
    visits: number;
    volunteers: number;
    form6: number;
    form7: number;
    form8: number;
    submitted: number;
  }[];
  outcomes: Counts;
  by_priority: (Share & { priority: number })[];
  by_source: (Share & { source: string })[];
  flags: Counts;
  booths: Booth[];
  volunteers: Volunteer[];
  recent: {
    id: string;
    visited_at: string;
    received_at: string;
    volunteer: string;
    part_no: number;
    outcome: string;
    people: number;
    flags: string[];
    gps: boolean;
    contact: "GIVEN" | "REFUSED" | null;
  }[];
};

type Booth = Share & {
  part_no: number;
  name: string;
  top_priority_left: number;
  forms: number;
  submitted: number;
  visits_today: number;
  last_visit_at: string | null;
  volunteers: string[];
};

type Volunteer = {
  id: string;
  name: string;
  role: string;
  is_active: boolean;
  signed_in: boolean;
  last_login_at: string | null;
  booths: number[];
  people_today: number;
  people_total: number;
  visits_total: number;
  days_worked: number;
  forms: number;
  submitted: number;
  flagged_visits: number;
  last_visit_at: string | null;
  last_received_at: string | null;
};

// Chart colours (validated as a set against the white card surface).
const BLUE = "#2a78d6";
const ORANGE = "#eb6834";

const OUTCOME: Record<string, string> = {
  ELIGIBLE: "Eligible, needs Form 6",
  MOVED_IN: "Moved in, needs Form 8",
  CORRECTION: "Needs a correction",
  ALREADY_ON_ROLL: "Already on the roll",
  SHIFTED: "Shifted away",
  DEAD: "Dead",
  NOT_MET: "Not met yet",
};

const FORM_STATUS: [string, string][] = [
  ["FILLED", "Filled, not yet submitted"],
  ["SUBMITTED", "Submitted"],
  ["IN_ERO_LIST", "In the ERO list"],
  ["HEARING", "Hearing"],
  ["ACCEPTED", "Accepted"],
  ["REJECTED", "Rejected"],
];

const FLAG: Record<string, string> = {
  GPS_OFF: "Location was off",
  GPS_DENIED: "Location permission refused",
  GPS_TIMEOUT: "No location fix in time",
  GPS_INACCURATE: "Location rough (over 100 m)",
  GPS_APPROXIMATE: "Only approximate location",
  CLOCK_SKEW: "Phone clock was wrong",
};

const ROUTE: Record<string, string> = { BLA2: "Through BLA-2", SELF: "By the voter", ONLINE: "Online", NONE: "Route not set" };

const n = (v: number) => v.toLocaleString("en-IN");
const pct = (a: number, b: number) => {
  if (b <= 0) return "—";
  const p = (a / b) * 100;
  // Early on, shares are tiny: show 0.4%, not 0%.
  return `${p > 0 && p < 10 ? p.toFixed(1) : Math.round(p)}%`;
};

function dayLabel(iso: string) {
  return new Date(`${iso}T00:00:00+05:30`).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    timeZone: "Asia/Kolkata",
  });
}

function sinceLabel(iso: string | null, now: number) {
  if (!iso) return "never";
  const minutes = Math.round((now - new Date(iso).getTime()) / 60000);
  if (minutes < 1) return "just now";
  if (minutes < 60) return `${minutes} min ago`;
  const hours = Math.round(minutes / 60);
  if (hours < 24) return `${hours} h ago`;
  return formatTime(iso);
}

function downloadCsv(name: string, header: string[], rows: (string | number)[][]) {
  const cell = (v: string | number) => {
    const s = String(v ?? "");
    return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
  };
  const text = "﻿" + [header, ...rows].map((r) => r.map(cell).join(",")).join("\n");
  const url = URL.createObjectURL(new Blob([text], { type: "text/csv;charset=utf-8" }));
  const a = document.createElement("a");
  a.href = url;
  a.download = name;
  a.click();
  URL.revokeObjectURL(url);
}

function Tile({ label, value, sub, children }: { label: string; value: string; sub?: React.ReactNode; children?: React.ReactNode }) {
  return (
    <div className="tile card">
      <div className="tile-label">{label}</div>
      <div className="tile-value">{value}</div>
      {children}
      {sub && <div className="tile-sub">{sub}</div>}
    </div>
  );
}

function DashboardView() {
  const [data, setData] = useState<Dashboard | null>(null);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [now, setNow] = useState(() => Date.now());

  const load = useCallback(async () => {
    setLoading(true);
    const { data, error } = await supabase.rpc("admin_dashboard");
    setLoading(false);
    if (error) {
      setError("Could not load the numbers. Check your connection; this page retries every minute.");
      return;
    }
    setError("");
    setData(data as Dashboard);
    setNow(Date.now());
  }, []);

  useEffect(() => {
    load();
    const timer = setInterval(load, 60_000);
    return () => clearInterval(timer);
  }, [load]);

  if (!data) {
    return (
      <>
        <div className="page-head">
          <h1>Dashboard</h1>
        </div>
        {error ? <div className="notice error">{error}</div> : <p className="muted">Loading…</p>}
      </>
    );
  }

  const t = data.totals;
  const closeAt = new Date(data.settings.claims_close_at).getTime();
  const daysLeft = Math.max(0, Math.ceil((closeAt - now) / 86_400_000));
  const left = t.people - t.reached;
  const neededPerDay = daysLeft > 0 ? Math.ceil(left / daysLeft) : left;
  const teamTarget = t.field_users * data.settings.daily_people_target;
  const formsTotal = Object.values(data.forms.by_type).reduce((a, b) => a + b, 0);
  const formsSubmitted = formsTotal - (data.forms.by_status.FILLED ?? 0);
  const outcomesTotal = Object.values(data.outcomes).reduce((a, b) => a + b, 0);
  const flagged = Object.entries(data.flags).sort((a, b) => b[1] - a[1]);

  const formSeries: Series[] = [
    { key: "form6", label: "Form 6 (new voter)", color: BLUE },
    { key: "form8", label: "Form 8 (shift / correction)", color: ORANGE },
  ];

  return (
    <div className={loading ? "dash refreshing" : "dash"}>
      <div className="page-head dash-head">
        <div>
          <h1>Dashboard</h1>
          <p className="muted">
            Updated {sinceLabel(data.generated_at, now)} · refreshes every minute · India time
          </p>
        </div>
        <button className="small" onClick={load} disabled={loading}>
          {loading ? "Refreshing…" : "Refresh now"}
        </button>
      </div>

      {error && <div className="notice error">{error}</div>}
      {t.pending_sign_ins > 0 && (
        <div className="notice info">
          {t.pending_sign_ins} sign-in request{t.pending_sign_ins > 1 ? "s are" : " is"} waiting.{" "}
          <Link href="/requests">Open sign-in requests</Link>
        </div>
      )}

      <section className="tiles">
        <Tile
          label="People reached"
          value={`${n(t.reached)} / ${n(t.people)}`}
          sub={`${pct(t.reached, t.people)} reached · ${n(t.attempted)} visited at least once`}
        >
          <Meter value={t.reached} total={t.people} />
        </Tile>
        <Tile
          label="Today"
          value={`${n(t.people_today)} people`}
          sub={`${n(t.visits_today)} visits · ${t.active_today} of ${t.field_users} volunteers out · team target ${n(teamTarget)}`}
        >
          <Meter value={t.people_today} total={teamTarget} />
        </Tile>
        <Tile
          label="Claim forms"
          value={n(formsTotal)}
          sub={`${n(formsSubmitted)} submitted · Form 6: ${n(data.forms.by_type["6"] ?? 0)} · Form 8: ${n(data.forms.by_type["8"] ?? 0)}`}
        >
          <Meter value={formsSubmitted} total={formsTotal} tone="ok" />
        </Tile>
        <Tile
          label="Days left for claims"
          value={String(daysLeft)}
          sub={`Closes 16 Dec · ${n(neededPerDay)} people a day needed to reach everyone`}
        />
      </section>

      <section className="dash-row two">
        <div className="card">
          <h2>People visited per day</h2>
          <DailyBars
            rows={data.daily}
            series={[{ key: "people", label: "People", color: BLUE }]}
            xLabel={(r) => dayLabel(r.day)}
            reference={teamTarget > 0 ? { value: teamTarget, label: `Team target ${n(teamTarget)}` } : undefined}
            emptyText="No visits yet"
            tooltip={(r) => ({
              title: dayLabel(r.day),
              rows: [
                { label: "people", value: n(r.people), color: BLUE },
                { label: "visits", value: n(r.visits) },
                { label: "volunteers out", value: n(r.volunteers) },
              ],
            })}
          />
        </div>
        <div className="card">
          <h2>Forms filled per day</h2>
          <Legend series={formSeries} />
          <DailyBars
            rows={data.daily}
            series={formSeries}
            xLabel={(r) => dayLabel(r.day)}
            emptyText="No forms yet"
            tooltip={(r) => ({
              title: dayLabel(r.day),
              rows: [
                { label: "Form 6", value: n(r.form6), color: BLUE },
                { label: "Form 8", value: n(r.form8), color: ORANGE },
                { label: "submitted that day", value: n(r.submitted) },
              ],
            })}
          />
        </div>
      </section>

      <section className="dash-row three">
        <div className="card">
          <h2>What volunteers found</h2>
          <p className="muted small-text">Latest result for each person visited.</p>
          {outcomesTotal === 0 ? (
            <p className="empty">No visits yet.</p>
          ) : (
            <BarList
              color={BLUE}
              total={outcomesTotal}
              items={Object.entries(data.outcomes)
                .map(([k, v]) => ({ label: OUTCOME[k] ?? k, value: v }))
                .sort((a, b) => b.value - a.value)}
            />
          )}
        </div>
        <div className="card">
          <h2>Forms by stage</h2>
          {formsTotal === 0 ? (
            <p className="empty">No forms yet.</p>
          ) : (
            <>
              <BarList
                color={BLUE}
                total={formsTotal}
                items={FORM_STATUS.map(([k, label]) => ({ label, value: data.forms.by_status[k] ?? 0 })).filter(
                  (i) => i.value > 0 || i.label === "Submitted",
                )}
              />
              <p className="muted small-text">
                {Object.entries(data.forms.by_route)
                  .map(([k, v]) => `${ROUTE[k] ?? k}: ${n(v)}`)
                  .join(" · ")}
              </p>
            </>
          )}
        </div>
        <div className="card">
          <h2>Progress by priority</h2>
          <table className="mini">
            <tbody>
              {data.by_priority.map((p) => (
                <tr key={p.priority}>
                  <td>Priority {p.priority}</td>
                  <td className="grow">
                    <Meter value={p.reached} total={p.people} />
                  </td>
                  <td className="num">
                    {n(p.reached)} / {n(p.people)}
                  </td>
                </tr>
              ))}
              {data.by_source.map((s) => (
                <tr key={s.source}>
                  <td>{s.source === "ASDD" ? "ASDD list" : s.source === "POSS_DEL" ? "Possibly deleted" : "Added in field"}</td>
                  <td className="grow">
                    <Meter value={s.reached} total={s.people} />
                  </td>
                  <td className="num">
                    {n(s.reached)} / {n(s.people)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <section className="card">
        <h2>Needs attention</h2>
        <div className="attention">
          <Attention count={t.revisits_overdue} tone="bad" label="Revisits overdue" hint="Nobody was home and the revisit date has passed." />
          <Attention count={t.revisits_due_today} tone="warn" label="Revisits due today" />
          {flagged.map(([flag, count]) => (
            <Attention key={flag} count={count} tone="warn" label={FLAG[flag] ?? flag} hint="Visits saved with this location or clock problem." />
          ))}
          <Attention count={t.field_users - t.signed_in} tone="warn" label="Volunteers not signed in" />
          <Attention count={t.contacts_refused} tone="neutral" label="Households refused a phone number" />
        </div>
        <p className="muted small-text">
          Phone numbers collected: {n(t.contacts_given)} household contacts, {n(t.member_mobiles)} family members ·
          New voters added in the field: {n(t.new_voters)}
        </p>
      </section>

      <VolunteersTable volunteers={data.volunteers} target={data.settings.daily_people_target} now={now} />
      <BoothsTable booths={data.booths} now={now} />
      <RecentVisits recent={data.recent} now={now} />
    </div>
  );
}

function Attention({ count, tone, label, hint }: { count: number; tone: string; label: string; hint?: string }) {
  return (
    <div className={`attention-item ${count > 0 ? tone : "clear"}`} title={hint}>
      <span className="attention-icon" aria-hidden>
        {count > 0 ? "!" : "✓"}
      </span>
      <strong>{n(count)}</strong>
      <span>{label}</span>
    </div>
  );
}

function VolunteersTable({ volunteers, target, now }: { volunteers: Volunteer[]; target: number; now: number }) {
  const rows = useMemo(
    () =>
      [...volunteers]
        .filter((v) => v.is_active)
        .sort((a, b) => b.people_today - a.people_today || b.people_total - a.people_total || a.name.localeCompare(b.name)),
    [volunteers],
  );

  function csv() {
    downloadCsv(
      "dastak-volunteers.csv",
      ["Name", "Role", "Booths", "People today", "People total", "Visits", "Days worked", "Forms", "Submitted", "Flagged visits", "Last visit", "Last sent", "Signed in"],
      rows.map((v) => [
        v.name,
        ROLE_LABEL[v.role] ?? v.role,
        v.booths.join(" "),
        v.people_today,
        v.people_total,
        v.visits_total,
        v.days_worked,
        v.forms,
        v.submitted,
        v.flagged_visits,
        v.last_visit_at ?? "",
        v.last_received_at ?? "",
        v.signed_in ? "yes" : "no",
      ]),
    );
  }

  return (
    <section className="card">
      <div className="card-head">
        <h2>Volunteers</h2>
        <button className="small" onClick={csv}>
          Download CSV
        </button>
      </div>
      {rows.length === 0 ? (
        <p className="empty">No volunteers registered yet.</p>
      ) : (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Booths</th>
                <th>Today (target {target})</th>
                <th className="num">People total</th>
                <th className="num">Forms</th>
                <th>Last visit</th>
                <th>Last sent</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((v) => (
                <tr key={v.id}>
                  <td>
                    {v.name}
                    <div className="muted small-text">{ROLE_LABEL[v.role] ?? v.role}</div>
                  </td>
                  <td>{v.booths.length ? v.booths.join(", ") : <span className="muted">none</span>}</td>
                  <td>
                    <div className="today-cell">
                      <Meter value={v.people_today} total={target} tone={v.people_today >= target ? "ok" : undefined} />
                      <span>{v.people_today}</span>
                    </div>
                  </td>
                  <td className="num">{n(v.people_total)}</td>
                  <td className="num">
                    {v.forms}
                    {v.forms > 0 && <span className="muted"> ({v.submitted} sent)</span>}
                  </td>
                  <td>{sinceLabel(v.last_visit_at, now)}</td>
                  <td>{sinceLabel(v.last_received_at, now)}</td>
                  <td>
                    {!v.signed_in ? (
                      <span className="pill warn">Not signed in</span>
                    ) : v.flagged_visits > 0 ? (
                      <span className="pill warn" title="Visits saved with a location or clock problem">
                        {v.flagged_visits} flagged
                      </span>
                    ) : (
                      <span className="pill ok">OK</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </section>
  );
}

type BoothFilter = "all" | "untouched" | "progress" | "unassigned" | "today";
type BoothSort = "part" | "done" | "left" | "p1";

function BoothsTable({ booths, now }: { booths: Booth[]; now: number }) {
  const [query, setQuery] = useState("");
  const [filter, setFilter] = useState<BoothFilter>("all");
  const [sort, setSort] = useState<BoothSort>("part");

  const rows = useMemo(() => {
    const q = query.trim().toLowerCase();
    const list = booths.filter((b) => {
      if (q && !String(b.part_no).startsWith(q) && !b.name.toLowerCase().includes(q) && !b.volunteers.some((v) => v.toLowerCase().includes(q))) {
        return false;
      }
      switch (filter) {
        case "untouched":
          return b.attempted === 0;
        case "progress":
          return b.attempted > 0 && b.reached < b.people;
        case "unassigned":
          return b.volunteers.length === 0;
        case "today":
          return b.visits_today > 0;
        default:
          return true;
      }
    });
    const share = (b: Booth) => (b.people ? b.reached / b.people : 0);
    return list.sort((a, b) => {
      switch (sort) {
        case "done":
          return share(b) - share(a) || a.part_no - b.part_no;
        case "left":
          return b.people - b.reached - (a.people - a.reached) || a.part_no - b.part_no;
        case "p1":
          return b.top_priority_left - a.top_priority_left || a.part_no - b.part_no;
        default:
          return a.part_no - b.part_no;
      }
    });
  }, [booths, query, filter, sort]);

  const unassigned = booths.filter((b) => b.volunteers.length === 0).length;
  const untouched = booths.filter((b) => b.attempted === 0).length;

  function csv() {
    downloadCsv(
      "dastak-booths.csv",
      ["Booth", "Name", "Volunteers", "People", "Visited", "Reached", "Priority 1 left", "Forms", "Submitted", "Visits today", "Last visit"],
      rows.map((b) => [
        b.part_no,
        b.name,
        b.volunteers.join("; "),
        b.people,
        b.attempted,
        b.reached,
        b.top_priority_left,
        b.forms,
        b.submitted,
        b.visits_today,
        b.last_visit_at ?? "",
      ]),
    );
  }

  return (
    <section className="card">
      <div className="card-head">
        <h2>Booths</h2>
        <button className="small" onClick={csv}>
          Download CSV
        </button>
      </div>
      <p className="muted small-text">
        {booths.length} booths · {untouched} not visited yet · {unassigned} with no volunteer
      </p>
      <div className="toolbar">
        <input placeholder="Booth number, name or volunteer" value={query} onChange={(e) => setQuery(e.target.value)} />
        <select value={filter} onChange={(e) => setFilter(e.target.value as BoothFilter)} aria-label="Show">
          <option value="all">All booths</option>
          <option value="today">Visited today</option>
          <option value="progress">In progress</option>
          <option value="untouched">Not visited yet</option>
          <option value="unassigned">No volunteer</option>
        </select>
        <select value={sort} onChange={(e) => setSort(e.target.value as BoothSort)} aria-label="Sort">
          <option value="part">Sort: booth number</option>
          <option value="left">Sort: most people left</option>
          <option value="p1">Sort: most priority 1 left</option>
          <option value="done">Sort: most done</option>
        </select>
      </div>
      <div className="table-wrap tall">
        <table>
          <thead>
            <tr>
              <th>Booth</th>
              <th>Volunteers</th>
              <th>Reached</th>
              <th className="num">P1 left</th>
              <th className="num">Forms</th>
              <th className="num">Today</th>
              <th>Last visit</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((b) => (
              <tr key={b.part_no}>
                <td>
                  <strong>{b.part_no}</strong> <span className="booth-name">{b.name}</span>
                </td>
                <td>{b.volunteers.length ? b.volunteers.join(", ") : <span className="pill warn">none</span>}</td>
                <td>
                  <div className="today-cell">
                    <Meter value={b.reached} total={b.people} />
                    <span>
                      {n(b.reached)}/{n(b.people)}
                    </span>
                  </div>
                </td>
                <td className="num">{b.top_priority_left}</td>
                <td className="num">{b.forms}</td>
                <td className="num">{b.visits_today || ""}</td>
                <td>{b.last_visit_at ? sinceLabel(b.last_visit_at, now) : <span className="muted">—</span>}</td>
              </tr>
            ))}
            {rows.length === 0 && (
              <tr>
                <td colSpan={7} className="empty">
                  No booths match.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </section>
  );
}

function RecentVisits({ recent, now }: { recent: Dashboard["recent"]; now: number }) {
  return (
    <section className="card">
      <h2>Latest visits</h2>
      {recent.length === 0 ? (
        <p className="empty">No visits yet. They appear here as phones send them.</p>
      ) : (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>When</th>
                <th>Volunteer</th>
                <th>Booth</th>
                <th>Result</th>
                <th className="num">People</th>
                <th>Contact number</th>
                <th>Checks</th>
              </tr>
            </thead>
            <tbody>
              {recent.map((r) => (
                <tr key={r.id}>
                  <td>
                    {formatTime(r.visited_at)}
                    {new Date(r.received_at).getTime() - new Date(r.visited_at).getTime() > 3_600_000 && (
                      <div className="muted small-text">sent {sinceLabel(r.received_at, now)}</div>
                    )}
                  </td>
                  <td>{r.volunteer}</td>
                  <td>{r.part_no}</td>
                  <td>{OUTCOME[r.outcome] ?? r.outcome}</td>
                  <td className="num">{r.people}</td>
                  <td>{r.contact === "GIVEN" ? "given" : r.contact === "REFUSED" ? <span className="muted">refused</span> : "—"}</td>
                  <td>
                    {r.flags.length === 0 ? (
                      <span className="pill ok">OK</span>
                    ) : (
                      r.flags.map((f) => (
                        <span key={f} className="pill warn">
                          {FLAG[f] ?? f}
                        </span>
                      ))
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </section>
  );
}

export default function Page() {
  return (
    <Shell>
      <DashboardView />
    </Shell>
  );
}
