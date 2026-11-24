"use client";

import { useState } from "react";
import { supabase } from "@/lib/supabase";
import { ECI_STATUS, label } from "@/lib/labels";

export type EciFields = {
  eci_path?: string | null;
  eci_status?: string | null;
  eci_reference_no?: string | null;
  eci_name?: string | null;
  eci_form_type?: string | null;
  eci_tracking_status?: string | null;
  eci_status_date?: string | null;
  eci_name_matches?: boolean | null;
  eci_note?: string | null;
};

const TONE: Record<string, string> = { READ: "ok", PENDING: "neutral", FAILED: "warn", NOT_ECI: "bad" };

/** Asks the server to read waiting ECI screenshots now (one form, or the next few). */
export async function readEciNow(formId?: string): Promise<string> {
  const { data, error } = await supabase.functions.invoke("eci-read", { body: formId ? { form_id: formId } : {} });
  if (error) return "Could not reach the reader. Try again.";
  const d = data as { read?: number; waiting?: string; results?: { status: string }[] };
  if (d.waiting === "no_api_key") return "Reading is not switched on yet (the Claude API key is missing).";
  if (!d.read) return "Nothing was waiting to be read.";
  const done = (d.results ?? []).filter((r) => ["READ", "FAILED", "NOT_ECI"].includes(r.status)).length;
  return done === d.read ? `Read ${done} screenshot${done === 1 ? "" : "s"}.` : `Read ${done} of ${d.read}; try again for the rest.`;
}

/** What was read from a form's ECI screenshot. */
export default function EciReading({ f, formId, onRead }: { f: EciFields; formId: string; onRead?: () => void }) {
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");

  if (!f.eci_path) return <span className="pill warn">No ECI screenshot</span>;

  const readNow = async () => {
    setBusy(true);
    setMessage(await readEciNow(formId));
    setBusy(false);
    onRead?.();
  };

  return (
    <div className="eci-reading">
      <span className={`pill ${TONE[f.eci_status ?? ""] ?? "neutral"}`}>ECI: {label(ECI_STATUS, f.eci_status)}</span>
      {f.eci_reference_no && (
        <div>
          <span className="muted small-text">Reference </span>
          <strong className="mono">{f.eci_reference_no}</strong>
        </div>
      )}
      {f.eci_name && (
        <div>
          <span className="muted small-text">Name on ECI </span>
          {f.eci_name}{" "}
          {f.eci_name_matches === true && <span className="pill ok">matches</span>}
          {f.eci_name_matches === false && <span className="pill bad">different person?</span>}
        </div>
      )}
      {(f.eci_tracking_status || f.eci_status_date || f.eci_form_type) && (
        <div className="muted small-text">
          {[f.eci_form_type, f.eci_tracking_status, f.eci_status_date].filter(Boolean).join(" · ")}
        </div>
      )}
      {f.eci_note && <div className="small-text warn-text">{f.eci_note}</div>}
      {f.eci_status === "PENDING" && (
        <button className="small" onClick={readNow} disabled={busy}>
          {busy ? "Reading…" : "Read now"}
        </button>
      )}
      {message && <div className="muted small-text">{message}</div>}
    </div>
  );
}
