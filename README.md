# दस्तक (Dastak)

Field tracking for the AC 371 Zafrabad claims campaign. Volunteers record every
door visit and every claim form (Form 6/8) on an Android app; the campaign
office manages the team from a website. Both share one Supabase backend.

| Folder      | What it is                                               |
| ----------- | -------------------------------------------------------- |
| `app/`      | Flutter Android app for volunteers and BLA-2s (Hindi UI) |
| `admin/`    | Next.js website for the campaign office, hosted on Vercel |
| `supabase/` | Database migrations, Edge Functions and seed data        |

## Status

Built so far: the data model, booth-scoped access rules, sign-in by admin
approval, the admin website (sign-in requests, field team, admins), and the
app's sign-in and home screens.

Not built yet: the offline database and sync, the visit form, form tracking,
the real data import, and ERO list matching.

## How sign-in works

There are no passwords or OTPs for field users.

1. An admin registers the volunteer on the website: name, mobile, role, booths.
2. The volunteer enters their mobile number in the app. The app shows a 4-digit
   code and waits.
3. The admin sees the request with the same code, confirms it with the
   volunteer, and approves.
4. The app signs in. That phone is now the volunteer's only signed-in phone;
   approving a new phone signs the old one out.

Deactivating a volunteer, or using "Sign out phone", cuts access immediately.
This is enforced in the database (row-level security), not in the app.

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

## Running things

Admin website:

```bash
cd admin && npm install && npm run dev
```

App (needs Flutter 3.50 and the Android SDK):

```bash
cd app && flutter pub get && flutter run
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

Release APKs for testing (signed with the debug key until an upload key exists):

```bash
cd app && flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

Sign-in end to end against the real backend (needs a registered test volunteer
and an admin access token):

```bash
cd app && DASTAK_TEST_MOBILE=<mobile> DASTAK_ADMIN_TOKEN=<jwt> flutter test test_live/login_live_test.dart
```

## Backend

Supabase project `dastak` (Mumbai, `ap-south-1`). Schema changes go in
`supabase/migrations/` and are applied in filename order. Edge Functions:

- `login-status`: the phone polls it; once approved it hands over a session, once.
- `admin-users`: creates admin accounts (first-time setup, and by existing admins).
