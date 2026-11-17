// Creates admin accounts (email + password) for the admin website.
//
//   {action:"bootstrap", setup_code, name, email, password}
//       First admin. Works once, with the setup code, while no admin exists.
//   {action:"create_admin", name, email, password}  + admin bearer token
//       Further admins, created by an existing admin.
//
// Field users are not created here: an admin registers them in the users table
// and they sign in through device approval.
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json", "Cache-Control": "no-store" },
  });
}

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  let body: Record<string, string>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_json" }, 400);
  }

  const name = (body.name ?? "").trim();
  const email = (body.email ?? "").trim().toLowerCase();
  const password = body.password ?? "";
  if (!name || !EMAIL_RE.test(email)) return json({ error: "bad_request" }, 400);
  if (password.length < 10) return json({ error: "weak_password" }, 400);

  const admin = createClient(SUPABASE_URL, SERVICE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  let createdBy: string | null = null;
  const bootstrap = body.action === "bootstrap";

  if (bootstrap) {
    const { data: claimed, error } = await admin.rpc("bootstrap_claim", {
      p_code: body.setup_code ?? "",
    });
    if (error) {
      console.error("bootstrap claim failed", error);
      return json({ error: "server_error" }, 500);
    }
    if (!claimed) return json({ error: "setup_closed" }, 403);
  } else if (body.action === "create_admin") {
    const token = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
    const { data: caller } = await admin.auth.getUser(token);
    if (!caller?.user) return json({ error: "unauthorized" }, 401);
    const { data: profile } = await admin
      .from("users")
      .select("id")
      .eq("auth_user_id", caller.user.id)
      .eq("role", "admin")
      .eq("is_active", true)
      .maybeSingle();
    if (!profile) return json({ error: "forbidden" }, 403);
    createdBy = profile.id;
  } else {
    return json({ error: "bad_action" }, 400);
  }

  const created = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    app_metadata: { role: "admin" },
  });
  if (created.error || !created.data.user) {
    if (bootstrap) await admin.rpc("bootstrap_release");
    const exists = /already/i.test(created.error?.message ?? "");
    if (!exists) console.error("create admin failed", created.error);
    return json({ error: exists ? "email_taken" : "server_error" }, exists ? 409 : 500);
  }

  const { data: row, error: insertError } = await admin
    .from("users")
    .insert({
      auth_user_id: created.data.user.id,
      name,
      email,
      role: "admin",
      created_by: createdBy,
    })
    .select("id")
    .single();
  if (insertError) {
    console.error("insert admin profile failed", insertError);
    await admin.auth.admin.deleteUser(created.data.user.id);
    if (bootstrap) await admin.rpc("bootstrap_release");
    return json({ error: "server_error" }, 500);
  }

  return json({ ok: true, id: row.id });
});
