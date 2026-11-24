# दस्तक (Dastak)

Field tracking for the AC 371 Zafrabad claims campaign. Volunteers record every
door visit and every claim form (Form 6/8) on a website that works on their
phones, also without network; the campaign office manages the team from a
separate admin website. Both share one Supabase backend.

| Folder      | What it is                                               |
| ----------- | -------------------------------------------------------- |
| `app/`      | Flutter app for volunteers and BLA-2s (Hindi UI), served as a website |
| `admin/`    | Next.js website for the campaign office, hosted on Vercel |
| `supabase/` | Database migrations, Edge Functions and seed data        |

## Status

Built: the data model, booth-scoped access rules, sign-in by admin approval,
the admin website (sign-in requests, field team, admins), the volunteers' app
(booths, people, visit form with precise location, new voters, form
tracking, offline storage and sync), offline opening of the website, and the
real visit list.

Not built yet: admin progress pages, bulk volunteer registration, receipt
photos, and ERO list matching.

## Working without network

The volunteers' website keeps itself on the phone after the first visit
(`app/tool/sw_template.js`, turned into `sw.js` by `app/tool/make_sw.dart` on
every build), so the link opens with no network. Visits and forms are saved in
the browser's own database and sent when the phone is back online. A new
version installs in the background; the volunteer sees
"नया संस्करण उपलब्ध है · खोलें" and it switches when they tap it.

Unsent work lives only in that browser on that phone. Volunteers should keep
using the same browser, not clear its data, and not use private/incognito
tabs. The home screen warns while anything is unsent, and signing out is
blocked until it has been sent.

## How sign-in works

There are no passwords or OTPs for field users.

1. An admin registers the volunteer on the admin website: name, mobile, role, booths.
2. The volunteer enters their mobile number on the volunteers' website. The app shows a 4-digit
   code and waits.
3. The admin sees the request with the same code, confirms it with the
   volunteer, and approves.
4. The app signs in. That phone is now the volunteer's only signed-in phone;
   approving a new phone signs the old one out.

Once approved, that phone can sign back in on its own for 35 days from the
approval (it proves itself with a device key that never leaves it), so
admins are not asked again each time. A different phone or browser still
needs an admin. Approving a new phone moves the 35 days to it.

Deactivating a volunteer, or using "Sign out phone", cuts access immediately
and ends the 35 days. This is enforced in the database (row-level security
and a trigger on users), not in the app.

Admins sign in to the website with email and password. The first admin is
created once at `/setup` with a setup code; further admins are added from the
Admins page.

## Data rules

- Real voter data must never be committed. `.gitignore` blocks spreadsheets and
  CSVs; only the generated mock list in `supabase/seed/mock_data.sql` belongs here.
- Every mock EPIC starts with `MOCK`. Run `supabase/seed/clear_field_data.sql`
  before loading the real list.
- The Supabase URL and publishable key in `admin/.env` and `app/lib/config.dart`
  are public values. No secret key belongs in this repository.

## Where things run

- Admin website: https://dastak-admin-green.vercel.app (Vercel project
  `dastak-admin`, root directory `admin`).
- Volunteers' website: https://dastak-app-preview.vercel.app (Vercel project
  `dastak-app-preview`, root directory `app`, built by `app/tool/vercel_build.sh`).
- Both redeploy on every push to this branch.
- Backend: Supabase project `dastak`, Mumbai.

## Running things

Admin website:

```bash
cd admin && npm install && npm run dev
```

Volunteers' app in a browser (needs Flutter 3.50):

```bash
cd app && flutter pub get && flutter run -d chrome
```

The same build Vercel makes, with the offline helper:

```bash
cd app && flutter build web --release --no-web-resources-cdn --web-content-hash && dart run tool/make_sw.dart build/web
```

App unit tests:

```bash
cd app && flutter test
```

Render the main screens to images (written to `app/test_live/previews/`), to
check the Hindi layout without a phone:

```bash
cd app && flutter test --update-goldens test_live/screens_preview_test.dart
```

Sign-in end to end against the real backend (needs a registered test volunteer
and an admin access token):

```bash
cd app && DASTAK_TEST_MOBILE=<mobile> DASTAK_ADMIN_TOKEN=<jwt> flutter test test_live/login_live_test.dart
```

## Loading the visit list

The real list was loaded on 18 Nov 2026 from the campaign workbook:

```bash
python3 -I tools/import/import_visit_list.py AC371_Zafrabad_Visit_List_before_16Dec.xlsx
```

This writes a reconciliation report and the rows (as SQL and JSON) to
`tools/import/out/`, which git ignores. The rows were sent in batches to
`import_booths` / `import_people`, which only work with a one-time import
token (see `supabase/migrations/20261118113000_import_functions.sql`); the
token was expired and the functions closed to the public afterwards.
Every listed person is their own record; households are confirmed in the
field. Never commit the workbook or anything in `tools/import/out/`.

Version 2 of the workbook (re-checked against the draft roll of 17 Nov
2026) was applied on 24 Nov 2026 without touching anyone's visits:

```bash
python3 -I tools/import/update_v2.py AC371_Zafrabad_Visit_List_v2_DraftRoll_aligned.xlsx
DASTAK_IMPORT_TOKEN_FILE=<token file> python3 -I tools/import/send.py --v2
```

It added 3,369 newly found possibly deleted people, moved 3,106 people
found on the draft roll to the category ON_DRAFT_ROLL (no visit; the
matched draft entry is kept to check), re-graded the possibly deleted, and
stored everyone's 2027 draft part and section. 82,343 people in all.

## Backend

Supabase project `dastak` (Mumbai, `ap-south-1`). Schema changes go in
`supabase/migrations/` and are applied in filename order. Edge Functions:

- `login-status`: the phone polls it; once approved it hands over a session, once.
- `admin-users`: creates admin accounts (first-time setup, and by existing admins).
