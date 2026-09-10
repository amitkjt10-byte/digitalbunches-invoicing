# Digital Bunches — Invoicing

A branded invoicing app: real email/password accounts, clients, invoices with
line items/tax/discount, a dashboard with a revenue chart, printable invoice
sheets, and dark mode. Built with React + Vite, backed by Supabase (Postgres
+ Auth) so every account's data is private and persists for real.

This doc takes you from these files to a live URL you can hand to your team.
Budget about 20–30 minutes the first time.

---

## 1. Create a Supabase project (free tier is fine)

1. Go to [supabase.com](https://supabase.com) → **New project**.
2. Pick a name (e.g. `digitalbunches-invoicing`), a database password (save
   it somewhere), and a region close to your users.
3. Once the project finishes provisioning, open **SQL Editor** → **New
   query**, paste in the contents of [`supabase/schema.sql`](./supabase/schema.sql),
   and click **Run**. This creates the `app_data` table and locks it down so
   each user can only ever read/write their own row.
4. Open **Project Settings → API**. You'll need two values from this page in
   the next step:
   - **Project URL**
   - **anon / public key** (not the `service_role` key — never put that in
     frontend code)
5. Optional but recommended for a real client rollout: **Authentication →
   Providers → Email** — decide whether to require email confirmation
   before login. It's on by default. If you'd rather people get in
   immediately after signing up (simplest for an internal tool), turn
   **Confirm email** off in **Authentication → Settings**.

## 2. Configure the app

```bash
cp .env.example .env
```

Open `.env` and fill in the two values from step 1.4:

```
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-public-key
```

## 3. Run it locally (to check everything works)

```bash
npm install
npm run dev
```

Visit the URL it prints (usually `http://localhost:5173`), create an
account, and confirm you can create a client, draft an invoice, and see it
on the dashboard.

## 4. Deploy it for real

The easiest path is **Vercel** (Netlify works the same way):

1. Push this folder to a GitHub repo.
2. Go to [vercel.com](https://vercel.com) → **Add New → Project** → import
   the repo.
3. Vercel auto-detects Vite. Before deploying, add the two environment
   variables from your `.env` under **Settings → Environment Variables**
   (same names, `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`).
4. Click **Deploy**. You'll get a live `*.vercel.app` URL in about a minute.
5. Optional: **Settings → Domains** to point a domain you own (e.g.
   `invoices.digitalbunches.com`) at it — add a CNAME record with your DNS
   provider as instructed there.

That URL is what you hand to your client or team — no separate server to
run or maintain; Supabase hosts the database and auth.

## How data is stored

Each signed-up user gets one row in the `app_data` table containing their
whole workspace (business profile, clients, invoices) as JSON. Row Level
Security (set up by `schema.sql`) means a user can only ever see their own
row — enforced by the database itself, not just the app's code. This keeps
the schema simple while still being a real, durable, private backend.

If you outgrow this later — e.g. you want cross-invoice reporting in SQL,
or multiple people on one team sharing the same client list — the natural
next step is splitting `clients` and `invoices` into their own Postgres
tables with a `team_id`. Worth revisiting once there's a concrete need for
it; not necessary to launch.

## Notes for whoever maintains this

- Auth is handled entirely by Supabase (`supabase-js`) — there's no custom
  password logic in the app to worry about or audit.
- The Supabase **anon key** is meant to be public/embedded in frontend code;
  it only grants what your Row Level Security policies allow. Never expose
  the `service_role` key here.
- The logo is embedded directly in `src/App.jsx` as a base64 data URI, so
  there's no separate image asset to lose track of or that can 404.
- Styling is plain CSS-in-JS (one big stylesheet string in `App.jsx`) — no
  Tailwind/build-step dependency, easy to hand-edit colors, spacing, or type
  in one place.
