"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { supabase } from "@/lib/supabase";

const ERRORS: Record<string, string> = {
  setup_closed: "Setup is closed: the code is wrong, or the first admin already exists.",
  weak_password: "The password must be at least 10 characters.",
  bad_request: "Enter your name and a valid email address.",
  email_taken: "That email already has an account.",
};

/** One-time page that creates the first admin, guarded by the setup code. */
export default function SetupPage() {
  const router = useRouter();
  const [code, setCode] = useState("");
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    setError("");
    setBusy(true);
    const response = await fetch(`${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/admin-users`, {
      method: "POST",
      headers: { "Content-Type": "application/json", apikey: process.env.NEXT_PUBLIC_SUPABASE_KEY! },
      body: JSON.stringify({ action: "bootstrap", setup_code: code.trim(), name, email, password }),
    }).catch(() => null);
    const result = response ? await response.json().catch(() => ({})) : {};
    if (!response?.ok) {
      setBusy(false);
      setError(ERRORS[result.error] ?? "Could not finish setup. Check your connection and try again.");
      return;
    }
    const { error: signInError } = await supabase.auth.signInWithPassword({ email: email.trim(), password });
    setBusy(false);
    router.replace(signInError ? "/login" : "/");
  }

  return (
    <div className="center">
      <form className="card" onSubmit={submit}>
        <h1>First-time setup</h1>
        <p className="muted">Creates the first admin account. This works once.</p>
        {error && <div className="notice error">{error}</div>}
        <div className="field">
          <label htmlFor="code">Setup code</label>
          <input id="code" value={code} onChange={(e) => setCode(e.target.value)} autoComplete="off" required />
        </div>
        <div className="field">
          <label htmlFor="name">Your name</label>
          <input id="name" value={name} onChange={(e) => setName(e.target.value)} autoComplete="name" required />
        </div>
        <div className="field">
          <label htmlFor="email">Email</label>
          <input
            id="email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            autoComplete="username"
            required
          />
        </div>
        <div className="field">
          <label htmlFor="password">Password</label>
          <input
            id="password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            autoComplete="new-password"
            minLength={10}
            required
          />
          <div className="hint">At least 10 characters.</div>
        </div>
        <button className="primary" style={{ width: "100%" }} disabled={busy}>
          {busy ? "Creating…" : "Create admin"}
        </button>
        <p className="hint" style={{ marginTop: 14 }}>
          Already set up? <Link href="/login">Sign in</Link>.
        </p>
      </form>
    </div>
  );
}
