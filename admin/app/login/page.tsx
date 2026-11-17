"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabase";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (new URLSearchParams(window.location.search).has("denied")) {
      setError("That account is not an active admin.");
    }
  }, []);

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    setError("");
    setBusy(true);
    const { error } = await supabase.auth.signInWithPassword({ email: email.trim(), password });
    setBusy(false);
    if (error) {
      setError(
        error.status === 400 ? "Wrong email or password." : "Could not sign in. Check your connection and try again.",
      );
      return;
    }
    router.replace("/");
  }

  return (
    <div className="center">
      <form className="card" onSubmit={submit}>
        <h1>
          दस्तक <span style={{ color: "var(--accent)" }}>Admin</span>
        </h1>
        <p className="muted">Campaign office sign-in.</p>
        {error && <div className="notice error">{error}</div>}
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
            autoComplete="current-password"
            required
          />
        </div>
        <button className="primary" style={{ width: "100%" }} disabled={busy}>
          {busy ? "Signing in…" : "Sign in"}
        </button>
        <p className="hint" style={{ marginTop: 14 }}>
          Setting up for the first time? <Link href="/setup">Create the first admin</Link>.
        </p>
      </form>
    </div>
  );
}
