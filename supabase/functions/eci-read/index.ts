// Reads ECI screenshots with Claude.
//
// When a volunteer files Form 6 in the ECI app, they attach a screenshot of
// its "Track application status" page (or the "Thank you" page with the
// Reference ID) to the visit. Once that screenshot is in storage, the phone
// (and the admin Forms page) calls this function. For each screenshot
// waiting to be read it asks Claude for the reference number, name, form
// type, status and date, and whether the name matches the person on our
// list, then records the reading: a readable reference number fills the
// form's receipt and marks it submitted.
//
// Needs the Edge Function secret ANTHROPIC_API_KEY. Without it nothing is
// read and the screenshots stay waiting.
import Anthropic from "npm:@anthropic-ai/sdk@1.7.0";
import { zodOutputFormat } from "npm:@anthropic-ai/sdk@1.7.0/helpers/zod";
import * as z from "npm:zod@4.6.7/v4";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const API_KEY = Deno.env.get("ANTHROPIC_API_KEY");

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;
const noStore = { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false };

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

/** Only signed-in volunteers and admins may ask (not the public key). */
function isSignedIn(req: Request): boolean {
  const token = (req.headers.get("authorization") ?? "").replace(/^Bearer\s+/i, "");
  try {
    const payload = JSON.parse(atob(token.split(".")[1].replace(/-/g, "+").replace(/_/g, "/")));
    return payload.role === "authenticated";
  } catch {
    return false;
  }
}

const Reading = z.object({
  is_eci_screen: z.boolean(),
  reference_number: z.string().nullable(),
  applicant_name: z.string().nullable(),
  form_type: z.string().nullable(),
  tracking_status: z.string().nullable(),
  status_date: z.string().nullable(),
  state: z.string().nullable(),
  assembly_constituency: z.string().nullable(),
  name_matches: z.boolean().nullable(),
  note: z.string(),
});
type Reading = z.infer<typeof Reading>;

const SYSTEM = `You read screenshots from the Election Commission of India (ECI) app or website, taken by campaign volunteers after filing a voter registration form (Form 6) for someone.

Two kinds of screen count as ECI screens:
- "Track application status": shows "Reference Number", "Tracking status as on <date> is: <STATUS>", and a box with First Name, State, AC and Form Type.
- The confirmation after submitting: "Your application has been submitted successfully on date: <date>" and "Your Reference ID: <id>".

Fill in the fields from what the screenshot shows:
- is_eci_screen: true only for one of the two screens above.
- reference_number: copy it exactly, character for character (letters and digits, no spaces). Null if not visible or not legible.
- applicant_name: the First Name shown, as written. Null if the screen has no name.
- form_type: as shown, e.g. "FORM6".
- tracking_status: as shown, e.g. "SUBMITTED". For the confirmation screen use "SUBMITTED".
- status_date: the tracking or submission date as YYYY-MM-DD (screens show DD/MM/YYYY or DD-MM-YYYY).
- state and assembly_constituency: as shown, else null.
- name_matches: compare applicant_name with the expected person given below (whose name is in Hindi): true if it is plausibly the same name written in English letters (allow spelling and transliteration differences), false if it is clearly someone else, null if the screen shows no name.
- note: one short sentence in English, only if something needs a person's attention (illegible digits, a different form type, a different constituency, not an ECI screen); otherwise an empty string.

Never guess characters you cannot read.`;

function toBase64(bytes: Uint8Array): string {
  let binary = "";
  for (let i = 0; i < bytes.length; i += 0x8000) {
    binary += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
  }
  return btoa(binary);
}

function mediaType(bytes: Uint8Array): "image/jpeg" | "image/png" | "image/webp" {
  if (bytes[0] === 0x89 && bytes[1] === 0x50) return "image/png";
  if (bytes[0] === 0x52 && bytes[1] === 0x49 && bytes[8] === 0x57 && bytes[9] === 0x45) return "image/webp";
  return "image/jpeg";
}

type Pending = {
  form_id: string;
  eci_path: string;
  form_type: string;
  name: string;
  relative: string | null;
  age: number | null;
  gender: string | null;
};

async function read(client: Anthropic, image: Uint8Array, p: Pending): Promise<Record<string, unknown>> {
  const expected =
    `Expected person (from our list): name "${p.name}"` +
    (p.relative ? `, relative "${p.relative}"` : "") +
    (p.age ? `, age ${p.age}` : "") +
    (p.gender ? `, gender ${p.gender}` : "") +
    `. The volunteer filed Form ${p.form_type}.`;

  const response = await client.messages.parse({
    model: "claude-opus-5-5",
    max_tokens: 16000,
    output_config: { effort: "low", format: zodOutputFormat(Reading) },
    system: SYSTEM,
    messages: [
      {
        role: "user",
        content: [
          { type: "image", source: { type: "base64", media_type: mediaType(image), data: toBase64(image) } },
          { type: "text", text: expected },
        ],
      },
    ],
  });

  if (response.stop_reason === "refusal") {
    return { status: "FAILED", note: "The screenshot could not be read automatically; please check it by hand." };
  }
  const r: Reading | null = response.parsed_output;
  if (!r) {
    return { status: "FAILED", note: "The screenshot could not be read automatically; please check it by hand." };
  }
  const status = !r.is_eci_screen ? "NOT_ECI" : r.reference_number ? "READ" : "FAILED";
  return {
    status,
    reference_number: r.reference_number,
    applicant_name: r.applicant_name,
    form_type: r.form_type,
    tracking_status: r.tracking_status,
    status_date:
      r.status_date && DATE_RE.test(r.status_date) && !Number.isNaN(Date.parse(r.status_date)) ? r.status_date : null,
    state: r.state,
    assembly_constituency: r.assembly_constituency,
    name_matches: r.name_matches,
    note:
      r.note ||
      (status === "NOT_ECI"
        ? "This is not an ECI application screenshot."
        : status === "FAILED"
          ? "No reference number could be read."
          : ""),
  };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  if (!isSignedIn(req)) return json({ error: "not_signed_in" }, 401);

  let body: { form_id?: string } = {};
  try {
    body = await req.json();
  } catch {
    // An empty body reads whatever is waiting.
  }
  const formId = body.form_id && UUID_RE.test(body.form_id) ? body.form_id : null;

  if (!API_KEY) return json({ read: 0, waiting: "no_api_key" });

  const db = createClient(SUPABASE_URL, SERVICE_KEY, { auth: noStore });
  const { data: pending, error } = await db.rpc("eci_pending", { p_form: formId, p_limit: 5 });
  if (error) return json({ error: "pending_failed" }, 500);

  const client = new Anthropic({ apiKey: API_KEY });
  const results: { form_id: string; status: string }[] = [];
  for (const p of (pending ?? []) as Pending[]) {
    const { data: file, error: fileError } = await db.storage.from("form-photos").download(p.eci_path);
    if (fileError || !file) {
      results.push({ form_id: p.form_id, status: "image_missing" });
      continue;
    }
    let reading: Record<string, unknown>;
    try {
      reading = await read(client, new Uint8Array(await file.arrayBuffer()), p);
    } catch (e) {
      // Rate limits, overload, network: leave it waiting for the next call.
      const status = e instanceof Anthropic.APIError ? `api_error_${e.status}` : "error";
      results.push({ form_id: p.form_id, status });
      continue;
    }
    const { error: recordError } = await db.rpc("eci_record", { p_form: p.form_id, p_reading: reading });
    results.push({ form_id: p.form_id, status: recordError ? "record_failed" : String(reading.status) });
  }
  return json({ read: results.length, results });
});
