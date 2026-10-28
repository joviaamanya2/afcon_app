# AFCON Fan

A Flutter football companion app focused on African national team football. The interface is organised around the features fans expect from a football app: match centre, teams and players, competition tables, news, media, venues, events, notifications and community.

## Current app areas

- **Home:** tournament highlights, match-centre entry point, local events and language support.
- **Match centre:** date navigation, match search, live matches, fixtures, results, groups, standings and venue guide.
- The venue guide includes Hoima City Stadium and selected stadiums in Uganda, Kenya and Tanzania, with capacity, pitch, opening year and coordinates where available. Listing a venue does not confirm that it will host an AFCON 2027 match; venue capacities and planned details may change.
- The Matches > Fixtures screen and Explore show the same CAF-published AFCON PAMOJA 2027 Matchday 3 pairings. Exact match dates, kick-off times and stadiums stay marked as unconfirmed until CAF publishes them; published API fixtures take precedence.
- AFCON PAMOJA 2027 qualifier groups, Matchday 2 results, and Matchday 3 pairings are bundled from CAF reports. This verified snapshot is not a live feed; exact fixture dates, kick-off times, stadiums, and full squads are shown as unavailable until CAF publishes them.
- Tapping the AFCON qualifier graphics opens an interactive Groups, Draw Pots and Table view with team search and sortable records.
- **Teams & players:** regional national-team browsing; profiles and rankings use published backend records only.
- **Explore:** CAF competition discovery, AFCON qualifier groups and fixtures, verified tournament history, and unavailable states where no verified competition feed is connected.
- **Updates and media:** news categories, match reports, highlights and playback entry points.
- **Fan tools:** followed teams, notification preferences, multilingual help, community and accessibility settings.

## Data needed for a production release

The app includes a CAF-sourced AFCON PAMOJA 2027 qualifier snapshot, last checked against CAF reports published through 6 October 2026. Other competition standings, fixtures, squads, player stats and live match data depend on the configured API/CMS and remain unavailable until verified records are published. The bundled snapshot is not refreshed automatically. Connect a verified, licensed data provider or editorial CMS before presenting live facts.

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

The TypeScript API scaffold, PostgreSQL schema, Flutter API client, and local setup steps are in [backend/README.md](../backend/README.md). Configure `AFCON_API_URL` with a Dart define for the phone or emulator. Ask AFCON is powered by DeepSeek when `AI_PROVIDER_API_KEY` is configured in the backend; voice translation remains unavailable until its speech and translation providers are connected.

The app reads published matches, standings, venues, team rosters, articles, events, media and AFCON PAMOJA qualifier details from the backend. Open data screens refresh every 10 seconds while visible and refresh again when the app returns to the foreground. Venue records can include an optional public image URL. Ask AFCON answers from published records and shows source labels. The browser control room at `../dashboard/` uses the initial owner account and session login to manage content through protected API endpoints. See [backend/README.md](../backend/README.md) and [dashboard/README.md](../dashboard/README.md) to run both. On an Android emulator, the app defaults to the host API at `10.0.2.2:8080`; for a physical phone, pass the computer's LAN address with `--dart-define=AFCON_API_URL=http://YOUR_COMPUTER_IP:8080/api/v1`.

## Run

```sh
flutter pub get
flutter run
```
