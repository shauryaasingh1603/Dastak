"use client";

import { useEffect, useState } from "react";
import EciReading, { type EciFields } from "@/components/EciReading";
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
  istTime,
  label,
} from "@/lib/labels";

type Person = {
  voter: {
    id: string;
    name: string;
    relation: string | null;
    relative: string | null;
    age: number | null;
    gender: string | null;
    epic: string | null;
    category: string;
    source: string;
    confidence: string | null;
    closest: string | null;
    draft_part: number | null;
    draft_section: string | null;
    old_part: number | null;
    old_serial: number | null;
    new_reason: string | null;
    new_reason_note: string | null;
    mobile: string | null;
    added_by: string | null;
    added_at: string | null;
  };
  household: {
    code: string;
    part_no: number;
    house_no: string | null;
    hidden: boolean;
    needs_review: boolean;
    priority: number;
    polling_station: string | null;
  };
  visits: {
    id: string;
    visited_at: string;
    received_at: string;
    volunteer: string;
    volunteer_mobile: string | null;
    outcome: string;
    docs: string[] | null;
    mobile: string | null;
    met_person: string | null;
    contact_name: string | null;
    contact_relation: string | null;
    contact_mobile: string | null;
    contact_refused: boolean;
    remarks: string | null;
    revisit_on: string | null;
    gps_lat: number | null;
    gps_lng: number | null;
    gps_accuracy_m: number | null;
    flags: string[] | null;
    members: { id: string; name: string; outcome: string }[] | null;
  }[];
  forms: (EciFields & {
    id: string;
    type: string;
    status: string;
    route: string | null;
    reference_no: string | null;
    filed_on: string | null;
    created_at: string;
    filed_by: string | null;
    photo_path: string | null;
    photo_at: string | null;
    events: { status: string; at: string; note: string | null; by: string | null }[] | null;
  })[];
  same_record: { id: string; name: string; age: number | null; relation: string | null; relative: string | null }[];
};

function Row({ name, children }: { name: string; children: React.ReactNode }) {
  if (children === null || children === undefined || children === "" || children === false) return null;
  return (
    <div className="kv">
      <div className="kv-name">{name}</div>
      <div className="kv-value">{children}</div>
    </div>
  );
}

/**
 * One person's full record, opened from any list on the admin site:
 * details, booth and house, forms (with photo and history), every visit
 * (who, when, where, phones, documents, notes) and the household.
 */
export default function PersonPanel({ voterId, onClose }: { voterId: string; onClose: () => void }) {
  const [shown, setShown] = useState(voterId);
  const [person, setPerson] = useState<Person | null>(null);
  const [photos, setPhotos] = useState<Record<string, string>>({});
  const [error, setError] = useState("");
  const [reload, setReload] = useState(0);

  useEffect(() => setShown(voterId), [voterId]);
  useEffect(() => {
    setPerson(null);
    setPhotos({});
  }, [shown]);

  useEffect(() => {
    let active = true;
    setError("");
    (async () => {
      const { data, error } = await supabase.rpc("admin_person", { p_voter: shown });
      if (!active) return;
      if (error || !data) {
        setError("Could not load this person. Check your connection.");
        return;
      }
      const p = data as Person;
      setPerson(p);
      const paths = p.forms.flatMap((f) => [f.photo_path, f.eci_path]).filter((x): x is string => !!x);
      if (paths.length) {
        const { data: signed } = await supabase.storage.from("form-photos").createSignedUrls(paths, 3600);
        if (active) setPhotos(Object.fromEntries((signed ?? []).filter((s) => s.signedUrl).map((s) => [s.path, s.signedUrl])));
      }
    })();
    return () => {
      active = false;
    };
  }, [shown, reload]);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [onClose]);

  const v = person?.voter;
  const h = person?.household;

  return (
    <div className="panel-backdrop" onClick={onClose}>
      <aside className="panel" role="dialog" aria-label="Person" onClick={(e) => e.stopPropagation()}>
        <div className="panel-head">
          <div>
            <h2>{v?.name ?? "Loading…"}</h2>
            {v && (
              <div className="muted small-text">
                {[
                  v.relative && `${label(RELATION, v.relation) || "Relative"}: ${v.relative}`,
                  v.age && `${v.age} yrs`,
                  label(GENDER, v.gender),
                ]
                  .filter(Boolean)
                  .join(" · ")}
              </div>
            )}
          </div>
          <button className="small" onClick={onClose}>
            Close
          </button>
        </div>

        {error && <div className="notice error">{error}</div>}

        {v && h && (
          <div className="panel-body">
            <div className="pill-row">
              <span className="pill neutral">{label(CATEGORY, v.category)}</span>
              {h.needs_review && <span className="pill warn">Needs review</span>}
              {h.hidden && <span className="pill neutral">Not on the current list</span>}
              {h.priority === 1 && <span className="pill bad">Priority 1</span>}
            </div>

            <section>
              <h3>Details</h3>
              <Row name="EPIC">{v.epic ?? <span className="muted">none</span>}</Row>
              <Row name="Booth">
                {h.part_no}
                {h.polling_station && <span className="muted"> · {h.polling_station}</span>}
              </Row>
              <Row name="House">{h.house_no}</Row>
              <Row name="2027 draft roll">
                {v.draft_part && `Part ${v.draft_part}${v.draft_section ? `, section ${v.draft_section}` : ""}`}
              </Row>
              <Row name="2025 roll">
                {v.old_part && `Part ${v.old_part}${v.old_serial ? `, serial ${v.old_serial}` : ""}`}
              </Row>
              <Row name="Mobile">{v.mobile}</Row>
              <Row name="Entry to check">{v.closest}</Row>
              <Row name="Record">{h.code}</Row>
            </section>

            {v.new_reason && (
              <section>
                <h3>New voter</h3>
                <Row name="Why added">
                  {label(NEW_REASON, v.new_reason)}
                  {v.new_reason_note && `: ${v.new_reason_note}`}
                </Row>
                <Row name="Added by">
                  {v.added_by} {v.added_at && <span className="muted">· {istTime(v.added_at)}</span>}
                </Row>
              </section>
            )}

            <section>
              <h3>Forms</h3>
              {person.forms.length === 0 && <p className="muted small-text">No form.</p>}
              {person.forms.map((f) => (
                <div className="sub-card" key={f.id}>
                  <div className="sub-card-head">
                    <strong>Form {f.type}</strong>
                    <span className="pill neutral">{label(FORM_STATUS, f.status)}</span>
                  </div>
                  <div className="sub-card-body">
                    <div className="thumbs">
                      {f.eci_path && photos[f.eci_path] && (
                        <div>
                          <a href={photos[f.eci_path]} target="_blank" rel="noreferrer" className="photo-thumb eci">
                            {/* eslint-disable-next-line @next/next/no-img-element */}
                            <img src={photos[f.eci_path]} alt="ECI screenshot" width={96} height={96} />
                          </a>
                          <span className="thumb-label">ECI</span>
                        </div>
                      )}
                      {f.photo_path && photos[f.photo_path] && (
                        <div>
                          <a href={photos[f.photo_path]} target="_blank" rel="noreferrer" className="photo-thumb">
                            {/* eslint-disable-next-line @next/next/no-img-element */}
                            <img src={photos[f.photo_path]} alt="Face photo" width={96} height={96} />
                          </a>
                          <span className="thumb-label">Photo</span>
                        </div>
                      )}
                    </div>
                    <div className="grow">
                      <EciReading f={f} formId={f.id} onRead={() => setReload((n) => n + 1)} />
                      <Row name="Receipt">{f.reference_no}</Row>
                      <Row name="Route">{label(ROUTE, f.route)}</Row>
                      <Row name="Filed on">{f.filed_on}</Row>
                      <Row name="Filled by">
                        {f.filed_by} <span className="muted">· {istTime(f.created_at)}</span>
                      </Row>
                    </div>
                  </div>
                  {f.events && f.events.length > 0 && (
                    <ol className="timeline">
                      {f.events.map((e, i) => (
                        <li key={i}>
                          <strong>{label(FORM_STATUS, e.status)}</strong>{" "}
                          <span className="muted">
                            {istTime(e.at)}
                            {e.by && ` · ${e.by}`}
                          </span>
                          {e.note && <div className="small-text">{e.note}</div>}
                        </li>
                      ))}
                    </ol>
                  )}
                </div>
              ))}
            </section>

            <section>
              <h3>Visits</h3>
              {person.visits.length === 0 && <p className="muted small-text">Not visited yet.</p>}
              {person.visits.map((vi) => (
                <div className="sub-card" key={vi.id}>
                  <div className="sub-card-head">
                    <strong>{istTime(vi.visited_at)}</strong>
                    <span className={`pill ${vi.outcome === "NOT_MET" ? "warn" : "ok"}`}>{label(OUTCOME, vi.outcome)}</span>
                  </div>
                  <Row name="Volunteer">
                    {vi.volunteer} {vi.volunteer_mobile && <span className="muted">· {vi.volunteer_mobile}</span>}
                  </Row>
                  <Row name="Person's mobile">{vi.mobile}</Row>
                  <Row name="Documents seen">{(vi.docs ?? []).map((d) => label(DOC, d)).join(", ")}</Row>
                  <Row name="Spoke to">
                    {vi.contact_name}
                    {vi.contact_relation && ` (${label(CONTACT_RELATION, vi.contact_relation)})`}
                  </Row>
                  <Row name="Their mobile">
                    {vi.contact_mobile ?? (vi.contact_refused ? <span className="muted">refused to give</span> : null)}
                  </Row>
                  <Row name="Revisit on">{vi.revisit_on}</Row>
                  <Row name="Remarks">{vi.remarks}</Row>
                  <Row name="Location">
                    {vi.gps_lat != null && vi.gps_lng != null ? (
                      <a
                        href={`https://www.google.com/maps?q=${vi.gps_lat},${vi.gps_lng}`}
                        target="_blank"
                        rel="noreferrer"
                      >
                        Open map
                        {vi.gps_accuracy_m != null && ` (±${Math.round(vi.gps_accuracy_m)} m)`}
                      </a>
                    ) : (
                      <span className="muted">not recorded</span>
                    )}
                  </Row>
                  <Row name="Checks">
                    {(vi.flags ?? []).length > 0 &&
                      (vi.flags ?? []).map((f) => (
                        <span key={f} className="pill warn">
                          {label(FLAG, f)}
                        </span>
                      ))}
                  </Row>
                  <Row name="Sent">{vi.received_at && istTime(vi.received_at)}</Row>
                  {vi.members && vi.members.length > 0 && (
                    <Row name="Same household">
                      {vi.members.map((m) => (
                        <button key={m.id} className="link" onClick={() => setShown(m.id)}>
                          {m.name} <span className="muted">({label(OUTCOME, m.outcome)})</span>
                        </button>
                      ))}
                    </Row>
                  )}
                </div>
              ))}
            </section>

            {person.same_record.length > 0 && (
              <section>
                <h3>Others on the same record</h3>
                {person.same_record.map((o) => (
                  <button key={o.id} className="link block" onClick={() => setShown(o.id)}>
                    {o.name}
                    <span className="muted">
                      {" "}
                      {[o.relative && `${label(RELATION, o.relation)}: ${o.relative}`, o.age && `${o.age} yrs`]
                        .filter(Boolean)
                        .join(" · ")}
                    </span>
                  </button>
                ))}
              </section>
            )}
          </div>
        )}
      </aside>
    </div>
  );
}
