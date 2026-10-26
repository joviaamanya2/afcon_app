# AFCON Fan API

Fastify and PostgreSQL API for the Flutter app and admin dashboard. Public endpoints return only records marked `published = true`. The app can start without PostgreSQL: collection endpoints return empty lists and qualifier content uses the bundled fallback.

## Run locally (PowerShell)

```powershell
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
npm.cmd install
```

Set `DATABASE_URL` in `.env`. Create the database, then apply all migrations in order:

```powershell
psql $env:DATABASE_URL -f db/migrations/001_initial.sql
psql $env:DATABASE_URL -f db/migrations/002_seed_pamoja_qualifiers.sql
psql $env:DATABASE_URL -f db/migrations/003_dashboard_auth.sql
psql $env:DATABASE_URL -f db/migrations/004_refresh_pamoja_official_data.sql
npm.cmd run dev
```

The API listens on port `8080` by default. Check `http://localhost:8080/health`. For Android emulator use `--dart-define=AFCON_API_URL=http://10.0.2.2:8080/api/v1`; for a physical device use the computer's LAN address.

Run the Vite dashboard from the `dashboard` folder with `npm.cmd install` and `npm.cmd run dev`, then open `http://localhost:5173`. Set `ALLOWED_ORIGINS=http://localhost:5173` in the backend `.env` if needed. Full dashboard steps are in [dashboard/README.md](../dashboard/README.md).

## App endpoints

- `GET /api/v1/competitions`
- `GET /api/v1/matches?date=&status=&competitionId=&teamId=`
- `GET /api/v1/teams`, `players`, `standings`, `venues`
- `GET /api/v1/news`, `events`, `media`
- `GET /api/v1/match-events?matchId=`, `lineups?matchId=`, `match-statistics?matchId=`
- `GET /api/v1/qualifiers` for AFCON PAMOJA 2027 groups, hosts, key dates and bundled image asset paths
- `POST /api/v1/assistant/ask` and `POST /api/v1/translation/sessions` return a clear not-configured response until provider adapters are added

The Flutter Qualifiers tab reads facts and dates from `/api/v1/qualifiers`; bundled draw graphics remain available offline.

PAMOJA qualifying groups, international match windows and qualification rules are curated from the [CAF qualifier draw announcement](https://www.cafonline.com/caf-africa-cup-of-nations/news/the-road-to-east-africa-mapped-out-the-qualifier-draw-for-the-totalenergies-caf-africa-cup-of-nations-pamoja-2027-concluded/). The Akii-Bua stadium profile is attributed to the [official PAMOJA article](https://afconpamoja.ug/akii-bua-stadium-is-befitting-of-ugandas-first-olympic-gold-medalist/). These pages do not provide a live-score feed or match-by-match fixture/results/statistics data; publish those records only after they are verified from an official source.

## Admin API

Admin writes require a signed-in dashboard account. On first use, the registration page creates the initial owner account. Registration closes after the first account is created. Passwords are stored as scrypt hashes, and the dashboard receives a random seven-day session token stored only in browser session storage. This session is not used by the Flutter app.

- `GET /api/v1/admin/:resource`
- `POST /api/v1/admin/:resource`
- `PATCH /api/v1/admin/:resource/:id`
- `DELETE /api/v1/admin/:resource/:id`

Supported resources: `competitions`, `teams`, `players`, `matches`, `standings`, `venues`, `news`, `events`, `media`, `match-events`, `lineups`, `match-statistics`, and `qualifiers`. Writes are restricted to allowlisted fields. Set `ALLOWED_ORIGINS` for browser dashboard origins.

Authentication endpoints: `GET /api/v1/auth/status`, `POST /api/v1/auth/register` (initial owner only), `POST /api/v1/auth/login`, `GET /api/v1/auth/me`, and `POST /api/v1/auth/logout`.

News images and media require valid publication and territory rights before setting `published` to true. Confirm dates and group data against CAF before publishing; the seed qualifier data is an editable starting point.
