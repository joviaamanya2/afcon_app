import 'dart:convert';

import 'package:afcon_app/main.dart';
import 'package:afcon_app/screens/afcon_feature_screen.dart';
import 'package:afcon_app/screens/explore_screen.dart';
import 'package:afcon_app/screens/matches_screen.dart';
import 'package:afcon_app/screens/pamoja_2027_screen.dart';
import 'package:afcon_app/screens/pamoja_qualifiers_screen.dart';
import 'package:afcon_app/screens/teams_players_screen.dart';
import 'package:afcon_app/screens/updates_screen.dart';
import 'package:afcon_app/screens/womens_champions_league_screen.dart';
import 'package:afcon_app/services/afcon_api.dart';
import 'package:afcon_app/services/fan_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets(
    'women’s Champions League content stays in app with local images',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WomensChampionsLeagueScreen()),
      );
      await tester.pump();

      expect(
        find.text('CAF Women’s Champions League Egypt 2026'),
        findsOneWidget,
      );
      expect(find.text('1–15 Nov 2026'), findsOneWidget);
      expect(find.text('The 2026 groups'), findsOneWidget);
      expect(find.text('FC Masar'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Kawempe Muslim Ladies'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Kawempe Muslim Ladies'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Full match calendar'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Full match calendar'), findsOneWidget);
      expect(
        find.byKey(const Key('wcl-fixture-1 Nov-FC Masar')),
        findsOneWidget,
      );
      expect(find.text('Suez Canal Stadium · Ismailia'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('ASEC Mimosas 1–0 FC Masar'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('ASEC Mimosas 1–0 FC Masar'), findsOneWidget);
      expect(find.text('COMPLETED'), findsWidgets);
      expect(find.text('Watch on YouTube'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('TP Mazembe 3–0 Gaborone United'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('TP Mazembe 3–0 Gaborone United'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('JKT Queens 1–4 TP Mazembe'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('JKT Queens 1–4 TP Mazembe'), findsOneWidget);
      expect(find.text('Full official fixtures and schedule'), findsNothing);
      expect(find.text('All videos'), findsNothing);
      expect(find.text('Read CAF’s official draw report'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Image && widget.image is NetworkImage,
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('home women’s football promotion opens competition page', (
    tester,
  ) async {
    final navigatorObserver = _RecordingNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [navigatorObserver],
        home: const AfconHome(),
      ),
    );

    final promotion = find.byKey(const Key('womens-promo-card'));
    await tester.scrollUntilVisible(
      promotion,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    final banner = tester.widget<Image>(
      find.byKey(const Key('home-womens-promo-image')),
    );
    expect(
      (banner.image as AssetImage).assetName,
      'assets/images/women images/home_banner.png',
    );
    await tester.tap(promotion);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(navigatorObserver.pushCount, 2);
    expect(find.byType(WomensChampionsLeagueScreen), findsOneWidget);
    expect(find.text('Women’s Champions League'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home match-centre cards open the matching in-app tabs', (
    tester,
  ) async {
    const categories = <String, (int, String)>{
      'Live': (1, 'No live AFCON qualifier matches'),
      'Fixtures': (3, 'AFCON PAMOJA 2027 · Matchday 3'),
      'Matches': (4, 'AFCON PAMOJA 2027 · Matchday 2 results'),
      'Results': (5, 'AFCON PAMOJA 2027 · Matchday 2 results'),
      'Groups': (6, 'PAMOJA 2027 qualifying groups'),
      'Venues': (8, 'Stadiums across the three host countries'),
    };

    for (final entry in categories.entries) {
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey('home-category-${entry.key}'),
          home: const AfconHome(),
        ),
      );

      final card = find.byKey(Key('home-match-category-${entry.key}'));
      expect(card, findsOneWidget, reason: 'Missing Home card ${entry.key}');
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MatchesScreen), findsOneWidget);
      final tabs = tester.widget<TabBar>(find.byType(TabBar).first);
      expect(
        tabs.controller?.index,
        entry.value.$1,
        reason: '${entry.key} should open its matching tab',
      );
      expect(find.text(entry.value.$2), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('home hero transitions between bundled AFCON images', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AfconHome()));

    expect(find.byKey(const Key('home-hero-image-carousel')), findsOneWidget);
    expect(find.byKey(const ValueKey('assets/images/cup.png')), findsOneWidget);

    final secondIndicator = find.byKey(const Key('home-hero-indicator-1'));
    await tester.ensureVisible(secondIndicator);
    await tester.tap(secondIndicator);
    await tester.pump(const Duration(milliseconds: 800));

    expect(
      find.byKey(
        const ValueKey(
          'assets/images/new images/home screen images/amad-diallo-of-cote-ivoire-is-challenged-by-darlin-yongwa-ngameni-of-cameroon.webp',
        ),
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 7));
    await tester.pump(const Duration(milliseconds: 800));
    expect(
      find.byKey(
        const ValueKey(
          'assets/images/new images/home screen images/Cafcon.webp',
        ),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('language selector is beside notifications', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AfconHome()));

    final languageButton = find.byTooltip('Choose language');
    final notificationsButton = find.byTooltip('Notifications');
    expect(languageButton, findsOneWidget);
    expect(notificationsButton, findsOneWidget);
    expect(
      tester.getTopLeft(languageButton).dx,
      lessThan(tester.getTopLeft(notificationsButton).dx),
    );

    await tester.tap(languageButton);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Luganda'), findsOneWidget);
    expect(find.text('French'), findsOneWidget);
    expect(find.text('Swahili'), findsOneWidget);
  });

  testWidgets('match tabs show in-app PAMOJA fallback content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));
    await tester.pumpAndSettle();

    final matchTabs = tester.widget<TabBar>(find.byType(TabBar).first);
    expect(matchTabs.labelColor, const Color(0xFF800000));
    expect(matchTabs.indicator, isA<BoxDecoration>());

    expect(find.byKey(const Key('match-live-video-card')), findsOneWidget);
    expect(find.text('AFCON Final Highlights'), findsOneWidget);
    expect(find.text('AFCON PAMOJA 2027 · Matchday 2 results'), findsOneWidget);
    expect(
      find.textContaining('past-match replay, not a live fixture'),
      findsOneWidget,
    );
    expect(find.text('HIGHLIGHTS'), findsOneWidget);
    expect(find.text('PAMOJA qualifying calendar'), findsOneWidget);
    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('match-live-video-card')), findsOneWidget);
    expect(find.text('AFCON Final Highlights'), findsOneWidget);
    expect(find.text('No live AFCON qualifier matches'), findsOneWidget);
    expect(find.byKey(const Key('live-lineup-preview')), findsNothing);
    expect(find.text('Mohammed Kudus'), findsNothing);
    expect(find.text('Denis Onyango'), findsNothing);
    expect(find.text('PAMOJA qualifying calendar'), findsNothing);
    expect(find.text('Matchdays 1 & 2'), findsNothing);
    expect(find.text('Akii-Bua Olympic Stadium'), findsNothing);
    expect(find.text('Benjamin Mkapa Stadium'), findsNothing);
    expect(find.text('Mandela National Stadium'), findsNothing);
    expect(find.byKey(const Key('match-date-selector')), findsOneWidget);
    expect(find.textContaining('SELECTED MATCHDAY'), findsOneWidget);

    await tester.tap(find.text('Fixtures'));
    await tester.pumpAndSettle();
    expect(find.text('AFCON PAMOJA 2027 · Matchday 3'), findsOneWidget);
    expect(find.text('Morocco'), findsOneWidget);
    expect(find.text('Niger'), findsOneWidget);
    expect(
      find.text('Kick-off: To be confirmed · Stadium: To be confirmed'),
      findsWidgets,
    );
  });

  testWidgets(
    'qualifier graphics open groups, draw pots and searchable table',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MatchesScreen(initialCategory: 'Qualifiers')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Official draw pots'), findsOneWidget);
      await tester.ensureVisible(find.text('Official draw pots'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const Key(
            'qualifier-graphic-assets/images/new images/home screen images/afcon-draw-q-potsjpg.webp',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PamojaQualifiersScreen), findsOneWidget);
      expect(find.text('POT 1'), findsOneWidget);
      await tester.tap(find.byKey(const Key('qualifiers-tab-Groups')));
      await tester.pumpAndSettle();
      expect(
        find.text('48 teams · switch views to explore the draw'),
        findsOneWidget,
      );
      expect(find.text('GROUP A'), findsOneWidget);
      expect(find.text('GROUP L'), findsOneWidget);

      await tester.tap(find.byKey(const Key('qualifiers-tab-Draw Pots')));
      await tester.pumpAndSettle();
      expect(find.text('POT 1'), findsOneWidget);
      expect(find.text('POT 4'), findsOneWidget);
      expect(find.text('Grp H'), findsNWidgets(4));

      await tester.tap(find.byKey(const Key('qualifiers-tab-Table')));
      await tester.pumpAndSettle();
      expect(find.byType(DataTable), findsOneWidget);
      expect(
        find.text('48 teams · switch views to explore the draw'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('qualifiers-search')),
        'Uganda',
      );
      await tester.pumpAndSettle();
      expect(find.text('1 of 48 teams match'), findsOneWidget);
      expect(find.text('Uganda'), findsWidgets);
      expect(find.text('GROUP A'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'match centre fixtures match Explore and mark schedule details unconfirmed',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MatchesScreen(initialCategory: 'Fixtures')),
      );
      await tester.pumpAndSettle();

      expect(find.text('AFCON PAMOJA 2027 · Matchday 3'), findsOneWidget);
      expect(find.text('Morocco'), findsOneWidget);
      expect(find.text('Niger'), findsOneWidget);
      expect(find.text('Morocco'), findsOneWidget);
      expect(find.text('Nigeria'), findsOneWidget);
      expect(
        find.textContaining(
          'Exact dates, kick-off times and stadiums have not been announced.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Kick-off: To be confirmed · Stadium: To be confirmed'),
        findsWidgets,
      );
    },
  );

  testWidgets('matches tab explains fixtures and includes all match statuses', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MatchesScreen(initialCategory: 'Matches')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Upcoming, live and completed matches'), findsOneWidget);
    expect(
      find.textContaining(
        'Matches include games that are upcoming, in progress or finished.',
      ),
      findsOneWidget,
    );
    expect(find.text('AFCON PAMOJA 2027 · Matchday 2 results'), findsOneWidget);
    expect(find.text('Angola'), findsWidgets);
    expect(find.text('Malawi'), findsWidgets);
    expect(find.text('COMPLETED'), findsWidgets);
    expect(find.text('Watch on YouTube'), findsWidgets);
    expect(find.text('Fixtures'), findsOneWidget);
    expect(find.text('View source on DAZN'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('match centre shows the CAF-published qualifier groups', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MatchesScreen(initialCategory: 'Groups')),
    );

    expect(find.text('PAMOJA 2027 qualifying groups'), findsOneWidget);
    expect(find.text('Morocco'), findsOneWidget);
    expect(find.text('Gabon'), findsOneWidget);
    expect(find.text('Côte d’Ivoire'), findsOneWidget);
    expect(find.text('Group A'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('venue tab includes East African host-country stadiums', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MatchesScreen(initialCategory: 'Venues')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Akii-Bua Olympic Stadium'), findsOneWidget);
    expect(find.text('Pitch'), findsNothing);
    expect(find.text('Lira City, Uganda'), findsOneWidget);
    expect(find.textContaining('20,000 people upon completion'), findsOneWidget);
    expect(find.text('Hoima City Stadium'), findsOneWidget);
    expect(find.text('Hoima City, Uganda'), findsOneWidget);
    expect(find.text('48,063 people (main stadium)'), findsOneWidget);
    expect(find.text('1.43556° N, 31.39389° E'), findsOneWidget);
    expect(find.text('60,000 people'), findsOneWidget);
    expect(find.text('15,000 people'), findsOneWidget);
    expect(find.text('St Mary’s Stadium (Kitende)'), findsOneWidget);
    expect(find.text('Amaan Stadium'), findsOneWidget);
    expect(
      find.text('Moi International Sports Centre (Kasarani)'),
      findsOneWidget,
    );
    expect(find.text('Nyayo National Stadium'), findsOneWidget);
    expect(
      find.text(
        'Venue reference pages: Hoima City Stadium, Amaan Stadium, Benjamin Mkapa Stadium, Mandela National Stadium, Kasarani and Nyayo. Akii-Bua planned details: PAMOJA publication. Capacities may change; venue listings do not confirm AFCON 2027 match allocations.',
      ),
      findsOneWidget,
    );
    expect(
      find.image(
        const AssetImage(
          'assets/images/new images/home screen images/benjamin-mkapa-stadium_ok.webp',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.image(
        const AssetImage('assets/images/new images/mandela stadium.PNG'),
      ),
      findsOneWidget,
    );
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets(
    'Match Center hides API errors and keeps fallback content in app',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Match data is unavailable'), findsNothing);
      expect(
        find.text('Schedule source: CAF official qualifier announcement.'),
        findsOneWidget,
      );
      expect(find.byType(OutlinedButton), findsNothing);
    },
  );

  testWidgets('All tab combines fixtures, groups, venues, and stats content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MatchesScreen(initialCategory: 'All')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('match-live-video-card')), findsOneWidget);
    expect(find.text('PAMOJA qualifying calendar'), findsOneWidget);
    expect(find.text('Groups A–L'), findsOneWidget);
    expect(find.text('Results and standings'), findsOneWidget);
    expect(find.text('Akii-Bua Olympic Stadium'), findsOneWidget);
    expect(find.text('Benjamin Mkapa Stadium'), findsOneWidget);
    expect(find.text('Mandela National Stadium'), findsOneWidget);
    expect(find.text('Stats and tournament format'), findsOneWidget);
    expect(
      find.image(
        const AssetImage(
          'assets/images/new images/home screen images/benjamin-mkapa-stadium_ok.webp',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.image(
        const AssetImage('assets/images/new images/mandela stadium.PNG'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'match details show the participating teams and lineup sections',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailsScreen(
            record: {
              'id': 'sample-match',
              'home_team': 'Ghana',
              'away_team': 'Uganda',
              'competition_name': 'PAMOJA 2027',
              'stage': 'Group H',
              'status': 'scheduled',
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Match details'), findsOneWidget);
      expect(find.text('Ghana'), findsWidgets);
      expect(find.text('Uganda'), findsWidgets);
      expect(find.text('Line-up · Ghana vs Uganda'), findsOneWidget);
      expect(
        find.text('Confirmed line-up will appear here when published.'),
        findsNWidgets(2),
      );
    },
  );

  testWidgets('PAMOJA stories stay in app without website navigation buttons', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Pamoja2027Screen()));

    await tester.drag(find.byType(ListView).first, const Offset(0, -650));
    await tester.pumpAndSettle();
    expect(find.text('PAMOJA stories'), findsOneWidget);
    expect(find.text('Visit afconpamoja.ug'), findsNothing);
    expect(find.text('Read on official site'), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('Match Center stats fallback shows tournament facts in app', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MatchesScreen(initialCategory: 'Stats')),
    );
    await tester.pumpAndSettle();

    expect(find.text('48 qualifying teams'), findsOneWidget);
    expect(find.text('24 finalists'), findsOneWidget);
    expect(find.text('Match service unavailable'), findsNothing);
  });

  testWidgets('caption control explains that live audio is not connected', (
    tester,
  ) async {
    await tester.pumpWidget(const AfconApp());

    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('Preview only · No live audio connected'), findsOneWidget);
    expect(find.text('Caption language'), findsOneWidget);
  });

  testWidgets('Home quick link opens the Teams and players section', (
    tester,
  ) async {
    final navigatorObserver = _RecordingNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [navigatorObserver],
        home: const AfconHome(),
      ),
    );

    final shortcut = find.text('Teams & players');
    await tester.scrollUntilVisible(
      shortcut,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(shortcut);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(navigatorObserver.pushCount, 2);
    expect(find.byType(TeamsPlayersScreen), findsOneWidget);
    final regionHeading = find.text('Browse by region');
    await tester.scrollUntilVisible(
      regionHeading,
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(regionHeading, findsOneWidget);
  });

  testWidgets('teams, historical seasons and player profiles are navigable', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TeamsPlayersScreen()));

    expect(find.text('Premier League'), findsOneWidget);
    expect(find.text('Manchester United'), findsWidgets);
    expect(find.text('Bruno Fernandes'), findsOneWidget);

    await tester.tap(find.byKey(const Key('player-season-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024/25').last);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('2024/25 squad archive is not connected yet'),
      findsOneWidget,
    );

    final currentYear = DateTime.now().year;
    final currentSeasonStart = DateTime.now().month >= 7
        ? currentYear
        : currentYear - 1;
    final currentSeason =
        '$currentSeasonStart/${(currentSeasonStart + 1).toString().substring(2)}';
    await tester.tap(find.byKey(const Key('player-season-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentSeason).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bruno Fernandes'));
    await tester.pumpAndSettle();

    expect(find.text('PLAYER'), findsOneWidget);
    expect(find.text('Info'), findsWidgets);
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Career statistics'), findsOneWidget);
    expect(find.text('Awaiting verified data'), findsWidgets);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Season statistics'), findsOneWidget);
  });

  testWidgets('PAMOJA card opens the page for all three host countries', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TeamsPlayersScreen()));

    expect(
      find.image(
        const AssetImage('assets/images/new images/mandela stadium.PNG'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('pamoja-tournament-card')));
    await tester.pumpAndSettle();

    expect(find.text('Three nations. One tournament.'), findsOneWidget);
    expect(find.text('Kenya'), findsOneWidget);
    expect(find.text('Tanzania'), findsOneWidget);
    expect(find.text('Uganda'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('pamoja-hero-qualifiers-graphic')),
    );
    await tester.tap(find.byKey(const Key('pamoja-hero-qualifiers-graphic')));
    await tester.pumpAndSettle();
    expect(find.byType(PamojaQualifiersScreen), findsOneWidget);
    expect(find.text('GROUP A'), findsOneWidget);
  });

  testWidgets('player list starts unranked and offers statistic sorting', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TeamsPlayersScreen()));
    await tester.drag(find.byType(ListView).first, const Offset(0, -650));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byKey(const Key('player-stat-picker')),
          )
          .initialValue,
      'All players',
    );
    expect(find.byKey(const Key('player-sort-direction')), findsNothing);

    await tester.tap(find.byKey(const Key('player-stat-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Goals').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('player-sort-direction')), findsOneWidget);
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byKey(const Key('player-stat-picker')),
          )
          .initialValue,
      'Goals',
    );
  });

  testWidgets('selected team roster shows all players before stat sorting', (
    tester,
  ) async {
    final api = AfconApi(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/teams')) {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 'uganda-id',
                  'name': 'Uganda',
                  'short_name': 'UGA',
                  'region': 'East Africa',
                },
              ],
            }),
            200,
          );
        }

        if (request.url.path.endsWith('/players')) {
          expect(request.url.queryParameters['teamId'], 'uganda-id');
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'name': 'Zed Forward',
                  'position': 'Forward',
                  'shirt_number': 9,
                  'statistics': {'goals': 2},
                },
                {
                  'name': 'Ali Striker',
                  'position': 'Forward',
                  'shirt_number': 10,
                  'statistics': {'goals': 5},
                },
              ],
            }),
            200,
          );
        }
        return http.Response('{"data":[]}', 200);
      }),
    );
    await tester.pumpWidget(MaterialApp(home: TeamsPlayersScreen(api: api)));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ranked-player-Zed Forward')), findsOneWidget);
    expect(find.byKey(const Key('ranked-player-Ali Striker')), findsOneWidget);
    expect(find.byKey(const Key('player-sort-direction')), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('player-stat-picker')));
    await tester.tap(find.byKey(const Key('player-stat-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Goals').last);
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byKey(const Key('ranked-player-Ali Striker'))).dy,
      lessThan(
        tester
            .getTopLeft(find.byKey(const Key('ranked-player-Zed Forward')))
            .dy,
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('ranked-player-Ali Striker')),
        matching: find.text('5'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('settings are opened from the top-right menu', (tester) async {
    await tester.pumpWidget(const AfconApp());

    expect(find.text('Settings'), findsNothing);
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Accessibility'), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('updates shortcut opens the tabbed news feed', (tester) async {
    await tester.pumpWidget(const AfconApp());

    await tester.tap(find.text('Updates'));
    await tester.pumpAndSettle();

    expect(find.text('News'), findsOneWidget);
    expect(find.text('Headline'), findsOneWidget);
    expect(find.text('AFCON'), findsWidgets);
    expect(find.text('Trending'), findsWidgets);
    expect(find.text('Local'), findsWidgets);
    expect(find.text('Official'), findsWidgets);

    await tester.tap(find.text('Local'));
    await tester.pumpAndSettle();

    expect(
      find.text('News and activities from host cities and regions'),
      findsOneWidget,
    );
  });

  testWidgets('CAF qualifier stories remain readable in the app', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: UpdatesScreen()));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is NetworkImage,
      ),
      findsNWidgets(3),
    );
    await tester.tap(find.text('More Headline stories'));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage,
      ),
      findsAtLeastNWidgets(1),
    );

    const storyTitle =
        'Angola defeat Malawi to complete AFCON 2027 Matchday Two';
    expect(find.text(storyTitle), findsOneWidget);
    await tester.tap(find.text(storyTitle));
    await tester.pumpAndSettle();

    expect(
      find.text('Source: CAF Online · Story content is available in this app.'),
      findsOneWidget,
    );
    expect(find.text('Read the full report on CAF'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('fans can comment on an individual news article', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: UpdatesScreen()));

    await tester.tap(
      find.text('Team and player stories from across the tournament'),
    );
    await tester.pumpAndSettle();

    expect(find.text('AFCON FAN'), findsOneWidget);
    expect(find.text('Match Report'), findsOneWidget);
    expect(find.text('Add a comment'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('article-comment-input')));
    await tester.enterText(
      find.byKey(const Key('article-comment-input')),
      'Great update!',
    );
    await tester.tap(find.byKey(const Key('post-article-comment')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Comments (1)'), findsOneWidget);
    expect(find.text('Great update!'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('media screen shows match-style highlights and playback', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: AfconFeatureScreen(feature: 'Media')),
    );

    expect(find.text('AFCON Match Center'), findsOneWidget);
    expect(find.text('Match Report'), findsOneWidget);
    expect(find.text('Match Moments'), findsOneWidget);
    expect(find.text('Highlights & Playback'), findsOneWidget);
    expect(find.text('Opening moments'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('media-playback-card')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('media-playback-card')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Official video playback will be available'),
      findsOneWidget,
    );
  });

  testWidgets('community posts can include image or video attachments', (
    tester,
  ) async {
    final backend = await _communityHarness();
    await tester.pumpWidget(
      MaterialApp(
        home: AfconFeatureScreen(
          feature: 'Community',
          api: backend.api,
          session: backend.session,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create post'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('community-add-image')), findsOneWidget);
    expect(find.byKey(const Key('community-add-video')), findsOneWidget);
    expect(
      find.text('Share a thought, photo, or video with the fans.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextField).last,
      'Matchday memories from the stands!',
    );
    await tester.tap(find.byKey(const Key('community-submit-post')));
    await tester.pumpAndSettle();

    expect(find.text('Matchday memories from the stands!'), findsOneWidget);
  });

  test(
    'fan session restores and syncs follows and notification preferences',
    () async {
      final backend = await _communityHarness();
      final token = backend.session.token!;
      final restored = FanSession(
        api: backend.api,
        tokenStore: backend.tokenStore,
      );

      expect((await restored.restore())?.displayName, 'AFCON Fan');
      expect(
        (await restored.updateDisplayName('Supporter')).displayName,
        'Supporter',
      );
      await backend.api.followTeam(
        token: token,
        teamId: 'team-1',
        follow: true,
      );
      expect((await backend.api.followedTeams(token)).single['id'], 'team-1');
      await backend.api.saveNotificationPreferences(
        token: token,
        preferences: const {
          'matchReminders': false,
          'kickoffChanges': true,
          'teamNews': true,
          'tournamentNews': false,
        },
      );
      expect((await backend.api.notificationPreferences(token))['data'], {
        'matchReminders': false,
        'kickoffChanges': true,
        'teamNews': true,
        'tournamentNews': false,
      });
      await restored.signOut();
      expect(backend.tokenStore.value, isNull);
      backend.api.close();
    },
  );

  testWidgets(
    'community users can set a name, like, comment, share and delete own posts',
    (tester) async {
      final backend = await _communityHarness();
      await tester.pumpWidget(
        MaterialApp(
          home: AfconFeatureScreen(
            feature: 'Community',
            api: backend.api,
            session: backend.session,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AFCON Fan'), findsOneWidget);
      expect(find.text('Posting as'), findsNothing);
      expect(find.byKey(const Key('community-edit-username')), findsNothing);

      await tester.tap(find.text('Create post'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'What a matchday!');
      await tester.tap(find.byKey(const Key('community-submit-post')));
      await tester.pumpAndSettle();

      expect(find.text('What a matchday!'), findsOneWidget);
      expect(find.text('AFCON Fan'), findsNWidgets(2));
      expect(find.byKey(const Key('community-share-post')), findsOneWidget);
      expect(find.text('Awaiting community review'), findsNothing);
      expect(find.text('Your post is live in the community.'), findsOneWidget);

      await tester.tap(find.byTooltip('Post options'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('community-edit-username')), findsOneWidget);
      expect(find.byKey(const Key('community-delete-post')), findsOneWidget);
      await tester.tap(find.byKey(const Key('community-edit-username')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('community-username-input')),
        'Goal Fan',
      );
      await tester.tap(find.byKey(const Key('community-username-save')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const Key('community-current-username')))
            .data,
        'Goal Fan',
      );

      final likeButton = find.byKey(const Key('community-like-post'));
      await tester.drag(find.byType(ListView).first, const Offset(0, -250));
      await tester.pumpAndSettle();
      await tester.ensureVisible(likeButton);
      await tester.tap(likeButton);
      await tester.pumpAndSettle();
      expect(find.text('Liked 1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('community-comment-post')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('community-comment-input')),
        'Great energy!',
      );
      await tester.tap(find.byKey(const Key('community-submit-comment')));
      await tester.pumpAndSettle();
      expect(find.text('Comment 1'), findsOneWidget);
      await tester.tap(find.byKey(const Key('community-comment-post')));
      await tester.pumpAndSettle();
      expect(find.text('Goal Fan: Great energy!'), findsOneWidget);
      await tester.tap(find.byTooltip('Close comments'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Post options'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('community-delete-post')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('community-confirm-delete')));
      await tester.pumpAndSettle();
      expect(find.text('What a matchday!'), findsNothing);
      expect(find.text('Start the conversation'), findsOneWidget);
    },
  );

  testWidgets('explore shows content across all tabs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExploreScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('CAF'), findsOneWidget);
    expect(find.text('Rankings'), findsOneWidget);
    expect(
      find.text('AFCON · 2026/27 · CAF QUALIFIER DATA · updated 6 Oct 2026'),
      findsOneWidget,
    );
    expect(find.text('Tables'), findsOneWidget);

    await tester.tap(find.text('Players'));
    await tester.pumpAndSettle();
    expect(find.byType(TeamsPlayersScreen), findsWidgets);
    expect(find.text('Browse by region'), findsWidgets);
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Sort by'), findsWidgets);
    expect(find.byKey(const Key('player-stat-picker')), findsWidgets);

    await tester.tap(find.text('Teams'));
    await tester.pumpAndSettle();
    expect(find.byType(TeamsPlayersScreen), findsWidgets);
    expect(find.text('Browse by region'), findsWidgets);

    await tester.tap(find.text('Fixtures'));
    await tester.pumpAndSettle();
    expect(find.text('CAF QUALIFIER FIXTURES'), findsOneWidget);
    expect(find.text('Matchday 3'), findsOneWidget);
    expect(find.text('Morocco'), findsWidgets);
    expect(find.text('Niger'), findsWidgets);
    expect(find.text('Angola'), findsWidgets);
    expect(find.text('South Sudan'), findsWidgets);

    await tester.tap(find.text('CAF'));
    await tester.pumpAndSettle();
    expect(find.text('CAF COMPETITIONS'), findsOneWidget);
    expect(find.text('CAF Champions League'), findsWidgets);

    await tester.tap(find.text('Rankings'));
    await tester.pumpAndSettle();
    expect(find.text('Recent AFCON champions'), findsOneWidget);
    expect(find.text('Côte d’Ivoire · 2023'), findsOneWidget);

    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
    expect(find.text('AFCON 2027 QUALIFIERS'), findsOneWidget);
    expect(find.text('GROUP A'), findsOneWidget);

    await tester.tap(find.text('Transfers'));
    await tester.pumpAndSettle();
    expect(find.text('Notable past moves'), findsOneWidget);
    expect(find.text('Mohammed Kudus'), findsOneWidget);

    await tester.tap(find.text('Popular'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024/25').last);
    await tester.pumpAndSettle();
    expect(find.text('AFCON · 2024/25 · NO VERIFIED DATA'), findsOneWidget);
    expect(
      find.textContaining(
        'Verified CAF qualifier data is available for 2026/27 only.',
      ),
      findsOneWidget,
    );

    final leagueShortcuts = find.byWidgetPredicate(
      (widget) =>
          widget is ListView && widget.scrollDirection == Axis.horizontal,
    );
    await tester.drag(leagueShortcuts.first, const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('Explore competitions'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    await tester.tap(find.text('African clubs'));
    await tester.pumpAndSettle();
    expect(find.text('CAF Champions League'), findsWidgets);

    await tester.tap(find.text('CAF Champions League').last);
    await tester.pumpAndSettle();
    expect(
      find.text('CAF Champions League · 2024/25 · NO VERIFIED DATA'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Verified competition data is not connected.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Players'));
    await tester.pumpAndSettle();
    expect(find.text('Percy Tau'), findsNothing);
    expect(
      find.textContaining('Verified competition data is not connected.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Teams'));
    await tester.pumpAndSettle();
    expect(find.text('The Red Devils · Egypt'), findsNothing);
    expect(
      find.textContaining('Verified competition data is not connected.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Fixtures'));
    await tester.pumpAndSettle();
    expect(find.text('Al Ahly'), findsNothing);
    expect(
      find.textContaining('Verified competition data is not connected.'),
      findsOneWidget,
    );
  });
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? lastPushedRoute;
  var pushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastPushedRoute = route;
    pushCount++;
    super.didPush(route, previousRoute);
  }
}

Future<_CommunityTestHarness> _communityHarness() async {
  const user = <String, dynamic>{
    'id': 'fan-1',
    'email': 'fan@example.test',
    'displayName': 'AFCON Fan',
  };
  final posts = <Map<String, dynamic>>[];
  final comments = <String, List<Map<String, dynamic>>>{};
  final followedTeams = <String>{};
  var displayName = 'AFCON Fan';
  var preferences = <String, dynamic>{
    'matchReminders': true,
    'kickoffChanges': true,
    'teamNews': false,
    'tournamentNews': true,
    'quietHoursStart': null,
    'quietHoursEnd': null,
  };

  http.Response respond(Object body, [int status = 200]) => http.Response(
    jsonEncode(body),
    status,
    headers: const {'content-type': 'application/json'},
  );

  final client = MockClient((request) async {
    final path = request.url.path;
    final segments = request.url.pathSegments;
    if (path == '/api/v1/auth/login') {
      return respond({
        'data': {
          'token': 'test-fan-token',
          'user': {...user, 'displayName': displayName},
        },
      });
    }
    if (path == '/api/v1/auth/me' && request.method == 'GET') {
      if (request.headers['authorization'] != 'Bearer test-fan-token') {
        return respond({'error': 'unauthorized'}, 401);
      }
      return respond({
        'data': {
          'user': {...user, 'displayName': displayName},
        },
      });
    }
    if (path == '/api/v1/auth/me' && request.method == 'PATCH') {
      if (request.headers['authorization'] != 'Bearer test-fan-token') {
        return respond({'error': 'unauthorized'}, 401);
      }
      displayName =
          (jsonDecode(request.body) as Map<String, dynamic>)['displayName']
              as String;
      return respond({
        'data': {
          'user': {...user, 'displayName': displayName},
        },
      });
    }
    if (path.startsWith('/api/v1/community/') ||
        path.startsWith('/api/v1/account/')) {
      if (request.headers['authorization'] != 'Bearer test-fan-token') {
        return respond({'error': 'unauthorized'}, 401);
      }
    }
    if (path == '/api/v1/community/posts' && request.method == 'GET') {
      return respond({'data': posts});
    }
    if (path == '/api/v1/community/posts' && request.method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final post = <String, dynamic>{
        'id': 'post-${posts.length + 1}',
        'userId': user['id'],
        'displayName': displayName,
        'content': body['content'],
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'published',
        'likesCount': 0,
        'commentsCount': 0,
        'likedByMe': false,
        'media': body['media'],
      };
      posts.insert(0, post);
      return respond({'data': post}, 201);
    }
    if (segments.length == 6 &&
        segments[2] == 'community' &&
        segments[3] == 'posts' &&
        segments[5] == 'comments' &&
        request.method == 'GET') {
      return respond({'data': comments[segments[4]] ?? []});
    }
    if (segments.length == 6 &&
        segments[2] == 'community' &&
        segments[3] == 'posts' &&
        segments[5] == 'comments' &&
        request.method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final comment = <String, dynamic>{
        'id': 'comment-${(comments[segments[4]] ?? []).length + 1}',
        'userId': user['id'],
        'displayName': displayName,
        'content': body['content'],
        'status': 'pending',
      };
      (comments[segments[4]] ??= []).add(comment);
      for (final post in posts.where((post) => post['id'] == segments[4])) {
        post['commentsCount'] = comments[segments[4]]!.length;
      }
      return respond({'data': comment}, 201);
    }
    if (segments.length == 6 &&
        segments[2] == 'community' &&
        segments[3] == 'posts' &&
        segments[5] == 'like' &&
        request.method == 'PUT') {
      final postId = segments[4];
      final post = posts.firstWhere(
        (post) => post['id'] == postId,
        orElse: () => <String, dynamic>{},
      );
      if (post.isNotEmpty) {
        post['likedByMe'] = true;
        post['likesCount'] = 1;
      }
      return respond({'data': {}});
    }
    if (path.endsWith('/like') && request.method == 'DELETE') {
      final postId = segments[4];
      final post = posts.firstWhere(
        (post) => post['id'] == postId,
        orElse: () => <String, dynamic>{},
      );
      if (post.isNotEmpty) {
        post['likedByMe'] = false;
        post['likesCount'] = 0;
      }
      return http.Response('', 204);
    }
    if (path.startsWith('/api/v1/community/posts/') &&
        request.method == 'DELETE' &&
        !path.endsWith('/like')) {
      final postId = segments[4];
      posts.removeWhere((post) => post['id'] == postId);
      return http.Response('', 204);
    }
    if (path.endsWith('/reports') && request.method == 'POST') {
      return respond({'data': {}}, 201);
    }
    if (path == '/api/v1/account/follows' && request.method == 'GET') {
      return respond({
        'data': followedTeams.map((id) => {'id': id}).toList(),
      });
    }
    if (path.startsWith('/api/v1/account/follows/') &&
        request.method == 'PUT') {
      followedTeams.add(segments.last);
      return respond({'data': {}});
    }
    if (path.startsWith('/api/v1/account/follows/') &&
        request.method == 'DELETE') {
      followedTeams.remove(segments.last);
      return http.Response('', 204);
    }
    if (path == '/api/v1/account/notification-preferences' &&
        request.method == 'GET') {
      return respond({'data': preferences});
    }
    if (path == '/api/v1/account/notification-preferences' &&
        request.method == 'PUT') {
      preferences = jsonDecode(request.body) as Map<String, dynamic>;
      return respond({'data': preferences});
    }
    return respond({
      'error': 'not_found',
      'message': 'Unexpected test request.',
    }, 404);
  });

  final api = AfconApi(client: client, baseUrl: 'http://localhost/api/v1');
  final tokenStore = _MemoryFanTokenStore();
  final session = FanSession(api: api, tokenStore: tokenStore);
  await session.signIn(
    email: user['email']!,
    password: 'a-secure-test-password',
  );
  return _CommunityTestHarness(
    api: api,
    session: session,
    tokenStore: tokenStore,
  );
}

class _CommunityTestHarness {
  const _CommunityTestHarness({
    required this.api,
    required this.session,
    required this.tokenStore,
  });

  final AfconApi api;
  final FanSession session;
  final _MemoryFanTokenStore tokenStore;
}

class _MemoryFanTokenStore implements FanTokenStore {
  String? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String token) async => value = token;
}
