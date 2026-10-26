# AFCON Fan

A Flutter football companion app focused on African national team football. The interface is organised around the features fans expect from a football app: match centre, teams and players, competition tables, news, media, venues, events, notifications and community.

## Current app areas

- **Home:** tournament highlights, match-centre entry point, local events and language support.
- **Match centre:** date navigation, match search, live matches, fixtures, results, groups, standings and venue guide.
- **Teams & players:** team browsing, player profiles, season selection and statistical rankings.
- **Explore:** competitions, tables, rankings and regional discovery.
- **Updates and media:** news categories, match reports, highlights and playback entry points.
- **Fan tools:** followed teams, notification preferences, multilingual help, community and accessibility settings.

## Data needed for a production release

The app currently has preview content and does not connect to an official match or news source. Do not treat sample content as current competition information. Connect a verified data provider or an editorial CMS before publishing live facts.

### Match centre

- Competition, season, stage, group and match identifier.
- Home and away team identifiers, crests, names and country codes.
- Kick-off timestamp with source timezone, stadium and match status.
- Score, half-time score, extra-time and penalty shootout scores.
- Match events with minute, added time, player, event type and team (goals, assists, cards, substitutions, VAR).
- Starting line-ups, substitutes, formations, coaches and player availability.
- Live statistics such as possession, shots, shots on target, corners and fouls.
- Provenance, last-updated timestamp and correction status for each match.

### Tournament, teams and players

- Competition seasons, qualification format, rounds, groups and advancement rules.
- Official group tables and tie-break order; played, wins, draws, losses, goals for/against, goal difference and points.
- National team profile, federation, coach, squad, kit/crest assets and recent form.
- Player profile, position, shirt number, date of birth, club, caps and tournament statistics.
- Stat definitions, units, season/competition scope and source attribution.

### Matchday and fan features

- Venue coordinates, address, capacity, entry guidance, accessibility, transport and local timezone.
- News articles with author, publication time, region, category, source and image rights.
- Video/audio assets with rights window, territory, captions, language and playback URL.
- Host-city event schedule, venue, booking link and organizer contact.
- Followed teams, favourite matches, reminder lead times, quiet hours and device push token.
- App locale, notification consent, privacy choices and accessibility preferences.
- Community account, post/comment moderation, reporting workflow and retention policy.

## Data and release checklist

1. Choose an approved football data provider and confirm its AFCON coverage, update frequency and licensing.
2. Define stable IDs and API contracts for competitions, seasons, teams, players, matches, standings, venues and articles.
3. Store timestamps in UTC and render them in the fan's selected timezone; clearly show the timezone on match details.
4. Keep source and `last_updated` metadata so stale or corrected data can be identified.
5. Add loading, offline, delayed-feed and empty states before enabling live scores or reminders.
6. Verify media and team assets are licensed for the intended territories and dates.
7. Configure authentication, push delivery and moderation before enabling account-backed fan features.

## Backend

The TypeScript API scaffold, PostgreSQL schema, Flutter API client, and local setup steps are in [backend/README.md](backend/README.md). Configure `AFCON_API_URL` with a Dart define for the phone or emulator. The assistant and voice translation controls now call the API and show its actual setup status; they remain unavailable until provider adapters and credentials are configured.

The app reads published matches, standings, venues, team rosters, articles, events, media and AFCON PAMOJA qualifier details from the backend. The browser control room at `dashboard/` uses the initial owner account and session login to manage content through protected API endpoints. See [backend/README.md](backend/README.md) and [dashboard/README.md](dashboard/README.md) to run both. On an Android emulator, the app defaults to the host API at `10.0.2.2:8080`; for a physical phone, pass the computer's LAN address with `--dart-define=AFCON_API_URL=http://YOUR_COMPUTER_IP:8080/api/v1`.

## Run

```sh
flutter pub get
flutter run
```
