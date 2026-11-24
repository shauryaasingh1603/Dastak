"use client";

import { useCallback, useEffect, useState } from "react";
import Shell from "@/components/Shell";
import SheetUpload from "@/components/SheetUpload";
import { formatBooths, parseBooths } from "@/lib/booths";
import { ROLE_LABEL, formatTime, supabase } from "@/lib/supabase";

type Assignment = { id: string; part_no: number; section_no: number | null; from_date: string; to_date: string | null };

type FieldUser = {
  id: string;
  name: string;
  mobile: string;
  role: "volunteer" | "bla2";
  is_active: boolean;
  device_model: string | null;
  active_session_id: string | null;
  last_login_at: string | null;
  trusted_until: string | null;
  assignments: Assignment[];
};

/** Today's date in India, as YYYY-MM-DD. The database uses the same day boundary. */
function todayIST(offsetDays = 0): string {
  return new Date(Date.now() + 5.5 * 3600 * 1000 + offsetDays * 86400 * 1000).toISOString().slice(0, 10);
}

function activeParts(user: FieldUser): Assignment[] {
  const today = todayIST();
  return user.assignments.filter((a) => a.from_date <= today && (!a.to_date || a.to_date >= today));
}

function Team() {
  const [users, setUsers] = useState<FieldUser[] | null>(null);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [saving, setSaving] = useState(false);

  const [name, setName] = useState("");
  const [mobile, setMobile] = useState("");
  const [role, setRole] = useState<"volunteer" | "bla2">("volunteer");
  const [booths, setBooths] = useState("");

  const [editing, setEditing] = useState<string | null>(null);
  const [editValue, setEditValue] = useState("");
  const [filter, setFilter] = useState("");

  const load = useCallback(async () => {
    const { data, error } = await supabase
      .from("users")
      .select(
        "id, name, mobile, role, is_active, device_model, active_session_id, last_login_at, trusted_until, assignments!assignments_user_id_fkey(id, part_no, section_no, from_date, to_date)",
      )
      .neq("role", "admin")
      .order("name");
    if (error) {
      setError("Could not load the field team.");
      return;
    }
    setUsers(data as unknown as FieldUser[]);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  function fail(message: string) {
    setNotice("");
    setError(message);
  }

  async function register(event: React.FormEvent) {
    event.preventDefault();
    setError("");
    setNotice("");

    const cleanName = name.trim();
    const cleanMobile = mobile.replace(/\D/g, "").slice(-10);
    if (!cleanName) return fail("Enter the volunteer's name.");
    if (!/^[6-9]\d{9}$/.test(cleanMobile)) return fail("Enter a 10-digit mobile number starting with 6–9.");
    let parts: number[];
    try {
      parts = parseBooths(booths);
    } catch (e) {
      return fail((e as Error).message);
    }

    setSaving(true);
    const { data: created, error: insertError } = await supabase
      .from("users")
      .insert({ name: cleanName, mobile: cleanMobile, role })
      .select("id")
      .single();
    if (insertError) {
      setSaving(false);
      return fail(
        insertError.code === "23505"
          ? "That mobile number is already registered."
          : "Could not register the volunteer. Try again.",
      );
    }
    if (parts.length > 0) {
      const { error: assignError } = await supabase
        .from("assignments")
        .insert(parts.map((part_no) => ({ user_id: created.id, part_no })));
      if (assignError) {
        setSaving(false);
        await load();
        return fail("Registered, but the booths were not saved. Use “Edit booths” on their row.");
      }
    }
    setSaving(false);
    setName("");
    setMobile("");
    setBooths("");
    setNotice(`${cleanName} is registered. They can now ask to sign in from the app.`);
    load();
  }

  async function saveBooths(user: FieldUser) {
    setError("");
    setNotice("");
    let wanted: number[];
    try {
      wanted = parseBooths(editValue);
    } catch (e) {
      return fail((e as Error).message);
    }
    const current = activeParts(user).filter((a) => a.section_no === null);
    const toAdd = wanted.filter((p) => !current.some((a) => a.part_no === p));
    const toEnd = current.filter((a) => !wanted.includes(a.part_no));
    const today = todayIST();

    setSaving(true);
    const results = await Promise.all([
      toAdd.length
        ? supabase.from("assignments").insert(toAdd.map((part_no) => ({ user_id: user.id, part_no })))
        : null,
      // An assignment that began today never covered a full day: remove it.
      // Older ones are closed as of yesterday so the history is kept.
      ...toEnd.map((a) =>
        a.from_date >= today
          ? supabase.from("assignments").delete().eq("id", a.id)
          : supabase.from("assignments").update({ to_date: todayIST(-1) }).eq("id", a.id),
      ),
    ]);
    setSaving(false);
    if (results.some((r) => r?.error)) return fail("Some booth changes were not saved. Check the row and try again.");
    setEditing(null);
    load();
  }

  async function setActive(user: FieldUser, is_active: boolean) {
    if (!is_active && !confirm(`Deactivate ${user.name}? Their phone loses access immediately.`)) return;
    setError("");
    const { error } = await supabase.from("users").update({ is_active }).eq("id", user.id);
    if (error) return fail("Could not update the volunteer.");
    load();
  }

  async function signOutPhone(user: FieldUser) {
    if (!confirm(`Sign ${user.name} out of their phone? They will need a new approval to sign in again.`)) return;
    setError("");
    const { error } = await supabase.from("users").update({ active_session_id: null }).eq("id", user.id);
    if (error) return fail("Could not sign the phone out.");
    load();
  }

  const needle = filter.trim().toLowerCase();
  const shown = (users ?? []).filter(
    (u) =>
      !needle ||
      u.name.toLowerCase().includes(needle) ||
      u.mobile.includes(needle) ||
      activeParts(u).some((a) => String(a.part_no) === needle),
  );

  return (
    <>
      <div className="page-head">
        <div>
          <h1>Field team</h1>
          <p className="muted">Register volunteers and BLA-2s here, then approve their phones under Sign-in requests.</p>
        </div>
      </div>

      {error && <div className="notice error">{error}</div>}
      {notice && <div className="notice success">{notice}</div>}

      <form className="card" onSubmit={register}>
        <h2>Register a volunteer</h2>
        <div className="form-row">
          <div>
            <label htmlFor="name">Name</label>
            <input id="name" value={name} onChange={(e) => setName(e.target.value)} autoComplete="off" />
          </div>
          <div>
            <label htmlFor="mobile">Mobile number</label>
            <input
              id="mobile"
              value={mobile}
              onChange={(e) => setMobile(e.target.value)}
              inputMode="numeric"
              autoComplete="off"
              placeholder="10 digits"
            />
          </div>
          <div>
            <label htmlFor="role">Role</label>
            <select id="role" value={role} onChange={(e) => setRole(e.target.value as "volunteer" | "bla2")}>
              <option value="volunteer">Volunteer</option>
              <option value="bla2">BLA-2</option>
            </select>
          </div>
          <div>
            <label htmlFor="booths">Booths</label>
            <input
              id="booths"
              value={booths}
              onChange={(e) => setBooths(e.target.value)}
              autoComplete="off"
              placeholder="e.g. 45, 46, 50-52"
            />
          </div>
          <button className="primary" disabled={saving}>
            Register
          </button>
        </div>
        <div className="hint">Booths are part numbers 1–443. You can leave them empty and add them later.</div>
      </form>

      <SheetUpload onRegistered={load} />

      <div className="card">
        <div className="page-head" style={{ marginBottom: 12 }}>
          <h2 style={{ margin: 0 }}>
            Registered <span className="muted">({users?.length ?? 0})</span>
          </h2>
          <input
            style={{ maxWidth: 260 }}
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            placeholder="Search name, mobile or booth"
            aria-label="Search the field team"
          />
        </div>

        {users === null ? (
          <p className="muted">Loading…</p>
        ) : shown.length === 0 ? (
          <div className="empty">{users.length === 0 ? "No one is registered yet." : "No one matches that search."}</div>
        ) : (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Mobile</th>
                  <th>Role</th>
                  <th>Booths</th>
                  <th>Phone</th>
                  <th>Status</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {shown.map((user) => {
                  const parts = activeParts(user);
                  const signedIn = user.is_active && !!user.active_session_id;
                  return (
                    <tr key={user.id} className={user.is_active ? "" : "inactive"}>
                      <td>{user.name}</td>
                      <td>{user.mobile}</td>
                      <td>{ROLE_LABEL[user.role]}</td>
                      <td>
                        {editing === user.id ? (
                          <div className="inline-edit">
                            <input
                              value={editValue}
                              onChange={(e) => setEditValue(e.target.value)}
                              aria-label={`Booths for ${user.name}`}
                              autoFocus
                            />
                            <button className="small primary" disabled={saving} onClick={() => saveBooths(user)}>
                              Save
                            </button>
                            <button className="small" onClick={() => setEditing(null)}>
                              Cancel
                            </button>
                          </div>
                        ) : (
                          <>
                            {parts.length ? (
                              formatBooths(parts.map((a) => a.part_no))
                            ) : (
                              <span className="pill warn">None</span>
                            )}{" "}
                            <button
                              className="link"
                              onClick={() => {
                                setEditing(user.id);
                                setEditValue(formatBooths(parts.filter((a) => a.section_no === null).map((a) => a.part_no)));
                              }}
                            >
                              Edit
                            </button>
                          </>
                        )}
                      </td>
                      <td>
                        {signedIn ? (
                          <>
                            {user.device_model || "Signed in"}
                            <div className="hint">since {formatTime(user.last_login_at)}</div>
                            {user.trusted_until && new Date(user.trusted_until) > new Date() && (
                              <div className="hint">
                                Signs back in without approval until {formatTime(user.trusted_until)}
                              </div>
                            )}
                          </>
                        ) : (
                          <span className="muted">Not signed in</span>
                        )}
                      </td>
                      <td>
                        <span className={`pill ${user.is_active ? "ok" : "neutral"}`}>
                          {user.is_active ? "Active" : "Deactivated"}
                        </span>
                      </td>
                      <td>
                        <div className="actions">
                          {signedIn && (
                            <button className="small" onClick={() => signOutPhone(user)}>
                              Sign out phone
                            </button>
                          )}
                          {user.is_active ? (
                            <button className="small danger" onClick={() => setActive(user, false)}>
                              Deactivate
                            </button>
                          ) : (
                            <button className="small" onClick={() => setActive(user, true)}>
                              Reactivate
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })}
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
      <Team />
    </Shell>
  );
}
