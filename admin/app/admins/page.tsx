"use client";

import { useCallback, useEffect, useState } from "react";
import Shell, { useAdmin } from "@/components/Shell";
import { formatTime, supabase } from "@/lib/supabase";

type AdminRow = { id: string; name: string; email: string; is_active: boolean; created_at: string };

const CREATE_ERRORS: Record<string, string> = {
  email_taken: "That email already has an account.",
  weak_password: "The password must be at least 10 characters.",
  bad_request: "Enter a name and a valid email address.",
  forbidden: "Only an active admin can add admins.",
};

function Admins() {
  const me = useAdmin();
  const [rows, setRows] = useState<AdminRow[] | null>(null);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [saving, setSaving] = useState(false);

  const load = useCallback(async () => {
    const { data, error } = await supabase
      .from("users")
      .select("id, name, email, is_active, created_at")
      .eq("role", "admin")
      .order("created_at");
    if (error) setError("Could not load admins.");
    else setRows(data as AdminRow[]);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  async function create(event: React.FormEvent) {
    event.preventDefault();
    setError("");
    setNotice("");
    setSaving(true);
    const { data: session } = await supabase.auth.getSession();
    const response = await fetch(`${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/admin-users`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        apikey: process.env.NEXT_PUBLIC_SUPABASE_KEY!,
        Authorization: `Bearer ${session.session?.access_token ?? ""}`,
      },
      body: JSON.stringify({ action: "create_admin", name, email, password }),
    }).catch(() => null);
    const result = response ? await response.json().catch(() => ({})) : {};
    setSaving(false);
    if (!response?.ok) {
      setError(CREATE_ERRORS[result.error] ?? "Could not add the admin. Try again.");
      return;
    }
    setNotice(`${name.trim()} can now sign in with that email and password.`);
    setName("");
    setEmail("");
    setPassword("");
    load();
  }

  async function setActive(row: AdminRow, is_active: boolean) {
    if (!is_active && !confirm(`Deactivate ${row.name}? They will no longer be able to use this site.`)) return;
    setError("");
    const { error } = await supabase.from("users").update({ is_active }).eq("id", row.id);
    if (error) setError("Could not update the admin.");
    load();
  }

  return (
    <>
      <div className="page-head">
        <div>
          <h1>Admins</h1>
          <p className="muted">Admins see the whole constituency. Keep this list short.</p>
        </div>
      </div>

      {error && <div className="notice error">{error}</div>}
      {notice && <div className="notice success">{notice}</div>}

      <form className="card" onSubmit={create}>
        <h2>Add an admin</h2>
        <div className="form-row" style={{ gridTemplateColumns: "1fr 1.2fr 1fr auto" }}>
          <div>
            <label htmlFor="admin-name">Name</label>
            <input id="admin-name" value={name} onChange={(e) => setName(e.target.value)} autoComplete="off" required />
          </div>
          <div>
            <label htmlFor="admin-email">Email</label>
            <input
              id="admin-email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              autoComplete="off"
              required
            />
          </div>
          <div>
            <label htmlFor="admin-password">Starting password</label>
            <input
              id="admin-password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete="new-password"
              minLength={10}
              required
            />
          </div>
          <button className="primary" disabled={saving}>
            Add admin
          </button>
        </div>
        <div className="hint">At least 10 characters. Give it to them in person or by phone, not in a group chat.</div>
      </form>

      <div className="card">
        {rows === null ? (
          <p className="muted">Loading…</p>
        ) : (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Added</th>
                  <th>Status</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {rows.map((row) => (
                  <tr key={row.id} className={row.is_active ? "" : "inactive"}>
                    <td>
                      {row.name} {row.id === me.id && <span className="muted">(you)</span>}
                    </td>
                    <td>{row.email}</td>
                    <td>{formatTime(row.created_at)}</td>
                    <td>
                      <span className={`pill ${row.is_active ? "ok" : "neutral"}`}>
                        {row.is_active ? "Active" : "Deactivated"}
                      </span>
                    </td>
                    <td>
                      {row.id !== me.id &&
                        (row.is_active ? (
                          <button className="small danger" onClick={() => setActive(row, false)}>
                            Deactivate
                          </button>
                        ) : (
                          <button className="small" onClick={() => setActive(row, true)}>
                            Reactivate
                          </button>
                        ))}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </>
  );
}

export default function Page() {
  return (
    <Shell>
      <Admins />
    </Shell>
  );
}
