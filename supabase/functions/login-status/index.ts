// Step 3 of device-approval login.
//
// The phone polls this with the request id and the secret it generated when it
// asked to sign in. While the admin has not decided, it gets {status:"pending"}.
// Once approved it gets a session exactly once, and the user is bound to that
// session: row-level security rejects every other session for the same user.
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const noStore = { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false };

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", "Cache-Control": "no-store" },
  });
}

function sessionIdOf(accessToken: string): string | null {
  try {
    const payload = accessToken.split(".")[1].replace(/-/g, "+").replace(/_/g, "/");
    return JSON.parse(atob(payload)).session_id ?? null;
  } catch {
    return null;
  }
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  let body: { request_id?: string; device_secret?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_json" }, 400);
  }
  const requestId = body.request_id ?? "";
  const deviceSecret = body.device_secret ?? "";
  if (!UUID_RE.test(requestId) || deviceSecret.length < 32) {
    return json({ error: "bad_request" }, 400);
  }

  const admin = createClient(SUPABASE_URL, SERVICE_KEY, { auth: noStore });

  const { data: peek, error: peekError } = await admin.rpc("login_request_peek", {
    p_request_id: requestId,
    p_device_secret: deviceSecret,
  });
  if (peekError) {
    console.error("peek failed", peekError);
    return json({ error: "server_error" }, 500);
  }
  if (peek.status !== "approved") return json({ status: peek.status });

  // Field users have no password. Their auth account exists only so that an
  // approved phone can hold a session; the address is never mailed.
  const email = `u-${peek.user.id}@field.dastak.invalid`;

  // Create the auth account on first sign-in. generateLink would create it too,
  // but as an unconfirmed sign-up whose token is not a sign-in token.
  if (!peek.user.auth_user_id) {
    const created = await admin.auth.admin.createUser({
      email,
      email_confirm: true,
      app_metadata: { dastak_user_id: peek.user.id, role: peek.user.role },
    });
    if (created.error && !/already/i.test(created.error.message)) {
      console.error("create auth user failed", created.error);
      return json({ error: "server_error" }, 500);
    }
  }

  const link = await admin.auth.admin.generateLink({ type: "magiclink", email });
  if (link.error || !link.data?.properties?.hashed_token) {
    console.error("generate link failed", link.error);
    return json({ error: "server_error" }, 500);
  }

  const anon = createClient(SUPABASE_URL, ANON_KEY, { auth: noStore });
  const verified = await anon.auth.verifyOtp({
    token_hash: link.data.properties.hashed_token,
    // deno-lint-ignore no-explicit-any
    type: (link.data.properties.verification_type ?? "magiclink") as any,
  });
  const session = verified.data?.session;
  const sessionId = session ? sessionIdOf(session.access_token) : null;
  if (verified.error || !session || !sessionId) {
    console.error("mint session failed", verified.error);
    return json({ error: "server_error" }, 500);
  }

  const { data: consumed, error: consumeError } = await admin.rpc("login_request_consume", {
    p_request_id: requestId,
    p_device_secret: deviceSecret,
    p_auth_user_id: session.user.id,
    p_session_id: sessionId,
  });
  if (consumeError || !consumed?.ok) {
    // Another poll won the race, or the request changed state. Drop this session.
    await admin.auth.admin.signOut(session.access_token).catch(() => {});
    if (consumeError) {
      console.error("consume failed", consumeError);
      return json({ error: "server_error" }, 500);
    }
    return json({ status: "consumed" });
  }

  return json({
    status: "approved",
    session: {
      access_token: session.access_token,
      refresh_token: session.refresh_token,
      expires_at: session.expires_at,
    },
    user: {
      id: peek.user.id,
      name: peek.user.name,
      role: peek.user.role,
      mobile: peek.user.mobile,
    },
  });
});
