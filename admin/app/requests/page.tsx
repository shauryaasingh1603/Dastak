"use client";

import { useCallback, useEffect, useState } from "react";
import Shell from "@/components/Shell";
import { ROLE_LABEL, formatTime, supabase } from "@/lib/supabase";

type LoginRequest = {
  id: string;
  match_code: string;
  status: "pending" | "approved" | "rejected" | "consumed" | "expired";
  device_model: string | null;
  auto_approved: boolean;
  created_at: string;
  decided_at: string | null;
  user: { name: string; mobile: string; role: string } | null;
};

const STATUS: Record<LoginRequest["status"], { label: string; tone: string }> = {
  pending: { label: "Waiting", tone: "warn" },
  approved: { label: "Approved, phone not yet signed in", tone: "warn" },
  consumed: { label: "Signed in", tone: "ok" },
  rejected: { label: "Rejected", tone: "bad" },
  expired: { label: "Expired", tone: "neutral" },
};

const DAY_MS = 24 * 3600 * 1000;

function Requests() {
  const [rows, setRows] = useState<LoginRequest[] | null>(null);
  const [error, setError] = useState("");
  const [busy, setBusy] = useState("");

  const load = useCallback(async () => {
    const { data, error } = await supabase
      .from("login_requests")
      .select(
        "id, match_code, status, device_model, auto_approved, created_at, decided_at, user:users!login_requests_user_id_fkey(name, mobile, role)",
      )
      .order("created_at", { ascending: false })
      .limit(60);
    if (error) {
      setError("Could not load requests. Check your connection.");
      return;
    }
    setError("");
    setRows(data as unknown as LoginRequest[]);
  }, []);

  useEffect(() => {
    load();
    const timer = setInterval(load, 5000);
    return () => clearInterval(timer);
  }, [load]);

  async function decide(request: LoginRequest, approve: boolean) {
    setBusy(request.id);
    const { data, error } = await supabase.rpc("decide_login_request", {
      p_request_id: request.id,
      p_approve: approve,
    });
    setBusy("");
    if (error || !data?.ok) {
      setError(
        data?.code === "NOT_PENDING"
          ? "That request was already decided or has expired."
          : "Could not save the decision. Try again.",
      );
    }
    load();
  }

  const now = Date.now();
  const isOpen = (r: LoginRequest) => r.status === "pending" && now - new Date(r.created_at).getTime() < DAY_MS;
  const pending = (rows ?? []).filter(isOpen);
  const recent = (rows ?? []).filter((r) => !isOpen(r)).slice(0, 25);

  return (
    <>
      <div className="page-head">
        <div>
          <h1>Sign-in requests</h1>
          <p className="muted">
            Ask the volunteer to read the 4-digit code on their phone. Approve only if it matches.
          </p>
        </div>
      </div>

      {error && <div className="notice error">{error}</div>}

      {rows === null ? (
        <p className="muted">Loading…</p>
      ) : pending.length === 0 ? (
        <div className="card empty">No one is waiting to sign in. This page refreshes on its own.</div>
      ) : (
        <div className="requests">
          {pending.map((request) => (
            <div className="request" key={request.id}>
              <div>
                <div className="code-label">Code on phone</div>
                <div className="code">{request.match_code}</div>
              </div>
              <div>
                <div className="request-name">{request.user?.name ?? "Unknown"}</div>
                <div className="muted">
                  {request.user?.mobile} · {ROLE_LABEL[request.user?.role ?? ""] ?? request.user?.role}
                </div>
                <div className="muted">
                  {request.device_model || "Unknown phone"} · asked {formatTime(request.created_at)}
                </div>
              </div>
              <div className="actions">
                <button className="approve" disabled={busy === request.id} onClick={() => decide(request, true)}>
                  Approve
                </button>
                <button className="danger" disabled={busy === request.id} onClick={() => decide(request, false)}>
                  Reject
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {recent.length > 0 && (
        <div className="card" style={{ marginTop: 28 }}>
          <h2>Recent</h2>
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Mobile</th>
                  <th>Phone</th>
                  <th>Asked</th>
                  <th>Result</th>
                </tr>
              </thead>
              <tbody>
                {recent.map((request) => {
                  const status = request.status === "pending" ? STATUS.expired : STATUS[request.status];
                  return (
                    <tr key={request.id}>
                      <td>{request.user?.name}</td>
                      <td>{request.user?.mobile}</td>
                      <td>{request.device_model || "—"}</td>
                      <td>{formatTime(request.created_at)}</td>
                      <td>
                        <span className={`pill ${status.tone}`}>{status.label}</span>
                        {request.auto_approved && (
                          <div className="hint">Automatic: same phone, approved in the last 35 days</div>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </>
  );
}

export default function Page() {
  return (
    <Shell>
      <Requests />
    </Shell>
  );
}
