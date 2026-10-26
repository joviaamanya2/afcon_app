import 'package:afcon_app/main.dart';
import 'package:afcon_app/screens/afcon_feature_screen.dart';
import 'package:afcon_app/screens/explore_screen.dart';
import 'package:afcon_app/screens/matches_screen.dart';
import 'package:afcon_app/screens/pamoja_2027_screen.dart';
import 'package:afcon_app/screens/teams_players_screen.dart';
import 'package:afcon_app/screens/updates_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home shows badge-style sample fixture and opens match screen', (
    tester,
  ) async {
    await tester.pumpWidget(const AfconApp());

    expect(find.text('AFCON FAN'), findsOneWidget);
    expect(find.text("Today's matches"), findsOneWidget);
    expect(find.text('Manchester United'), findsWidgets);
    expect(find.text('Arsenal'), findsOneWidget);
    expect(find.textContaining('19:45'), findsOneWidget);
    expect(find.text('VS'), findsOneWidget);
    expect(
      find.text(
        'Preview app · Official match and event data is not connected yet.',
      ),
      findsNothing,
    );
    await tester.tap(find.text('Matches'));
    await tester.pumpAndSettle();

    expect(find.text('MATCH'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Premier League'), findsOneWidget);
    expect(find.text('Super Leagues'), findsOneWidget);
    expect(find.text('Global'), findsOneWidget);
    expect(find.text('Local'), findsOneWidget);
    expect(find.text('LaLiga'), findsOneWidget);
    expect(find.text('Manchester United'), findsOneWidget);
    expect(find.text('Arsenal'), findsOneWidget);
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

  testWidgets('match tabs show in-app PAMOJA fallback content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));
    await tester.pumpAndSettle();

    final matchTabs = tester.widget<TabBar>(find.byType(TabBar).first);
    expect(matchTabs.labelColor, const Color(0xFF800000));
    expect(matchTabs.indicator, isA<BoxDecoration>());

    expect(find.byKey(const Key('match-live-video-card')), findsOneWidget);
    expect(find.text('AFCON Final Highlights'), findsOneWidget);
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
    expect(find.byKey(const Key('live-lineup-preview')), findsOneWidget);
    expect(
      find.text(
        'Ghana vs Uganda · Sample player preview only; this is not a confirmed fixture or official starting line-up.',
      ),
      findsOneWidget,
    );
    expect(find.text('Mohammed Kudus'), findsOneWidget);
    expect(find.text('Denis Onyango'), findsOneWidget);
    expect(find.text('PAMOJA qualifying calendar'), findsNothing);
    expect(find.text('Matchdays 1 & 2'), findsNothing);
    expect(find.text('Akii-Bua Olympic Stadium'), findsNothing);
    expect(find.text('Benjamin Mkapa Stadium'), findsNothing);
    expect(find.text('Mandela National Stadium'), findsNothing);
    expect(find.byKey(const Key('match-date-selector')), findsOneWidget);
    expect(find.textContaining('SELECTED MATCHDAY'), findsOneWidget);

    await tester.tap(find.text('Fixtures'));
    await tester.pumpAndSettle();
    expect(find.text('Official qualifying windows'), findsOneWidget);
    expect(find.text('Matchdays 1 & 2'), findsOneWidget);
    expect(find.text('Matchdays 3 & 4'), findsOneWidget);
  });

  testWidgets(
    'match centre shows CAF qualifying windows instead of fake fixtures',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MatchesScreen(initialCategory: 'Fixtures')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Official qualifying windows'), findsOneWidget);
      expect(find.text('Matchdays 1 & 2'), findsOneWidget);
      expect(find.text('Matchdays 3 & 4'), findsOneWidget);
      expect(find.text('Matchdays 5 & 6'), findsOneWidget);
      expect(
        find.textContaining('not confirmed individual fixtures'),
        findsOneWidget,
      );
      expect(find.text('Kenya'), findsNothing);
    },
  );

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

  testWidgets('venue tab presents the attributed Akii-Bua source details', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MatchesScreen(initialCategory: 'Venues')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Akii-Bua Olympic Stadium'), findsOneWidget);
    expect(find.text('Lira City, Uganda'), findsOneWidget);
    expect(find.textContaining('20,000 upon completion'), findsOneWidget);
    expect(
      find.text(
        'Akii-Bua profile: PAMOJA publication. Other photos are host-country stadium spotlights.',
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

  testWidgets('shortcuts appear at the top and open their section', (
    tester,
  ) async {
    await tester.pumpWidget(const AfconApp());

    expect(find.text('Teams & players'), findsOneWidget);
    await tester.tap(find.text('Teams & players'));
    await tester.pumpAndSettle();

    expect(find.byType(TeamsPlayersScreen), findsOneWidget);
    expect(find.text('Browse by league'), findsOneWidget);
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
  });

  testWidgets('player rankings sort selected statistics highest to lowest', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TeamsPlayersScreen()));
    await tester.drag(find.byType(ListView).first, const Offset(0, -650));
    await tester.pumpAndSettle();

    expect(find.text('Goals'), findsWidgets);
    expect(find.text('8'), findsWidgets);
    final bruno = tester.getTopLeft(
      find.byKey(const Key('ranked-player-Bruno Fernandes')),
    );
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(const Key('rank-badge-Bruno Fernandes')),
              matching: find.byType(Text),
            ),
          )
          .data,
      '1',
    );
    final rashford = tester.getTopLeft(
      find.byKey(const Key('ranked-player-Marcus Rashford')),
    );
    expect(bruno.dy, lessThan(rashford.dy));
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(const Key('rank-badge-Marcus Rashford')),
              matching: find.byType(Text),
            ),
          )
          .data,
      '2',
    );

    await tester.tap(find.byKey(const Key('player-stat-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assists').last);
    await tester.pumpAndSettle();

    final brunoByAssists = tester.getTopLeft(
      find.byKey(const Key('ranked-player-Bruno Fernandes')),
    );
    final rashfordByAssists = tester.getTopLeft(
      find.byKey(const Key('ranked-player-Marcus Rashford')),
    );
    expect(brunoByAssists.dy, lessThan(rashfordByAssists.dy));

    await tester.tap(find.byKey(const Key('player-sort-direction')));
    await tester.pumpAndSettle();
    final mainooAscending = tester.getTopLeft(
      find.byKey(const Key('ranked-player-Kobbie Mainoo')),
    );
    final brunoAscending = tester.getTopLeft(
      find.byKey(const Key('ranked-player-Bruno Fernandes')),
    );
    expect(mainooAscending.dy, lessThan(brunoAscending.dy));
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
    await tester.pumpWidget(
      const MaterialApp(home: AfconFeatureScreen(feature: 'Community')),
    );

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

  testWidgets(
    'community users can set a name, like, comment, share and delete own posts',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AfconFeatureScreen(feature: 'Community')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('community-edit-username')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('community-username-input')),
        'Goal Fan',
      );
      await tester.tap(find.byKey(const Key('community-username-save')));
      await tester.pumpAndSettle();
      expect(find.text('Goal Fan'), findsWidgets);

      await tester.tap(find.text('Create post'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'What a matchday!');
      await tester.tap(find.byKey(const Key('community-submit-post')));
      await tester.pumpAndSettle();

      expect(find.text('What a matchday!'), findsOneWidget);
      expect(find.text('Goal Fan'), findsWidgets);
      expect(find.byKey(const Key('community-share-post')), findsOneWidget);

      await tester.tap(find.byKey(const Key('community-like-post')));
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
    expect(find.text('AFCON · 2026/27 · SAMPLE DATA'), findsOneWidget);
    expect(find.text('Tables'), findsOneWidget);

    await tester.tap(find.text('Players'));
    await tester.pumpAndSettle();
    expect(find.text('Mohammed Kudus'), findsOneWidget);
    expect(find.text('PLAYER SPOTLIGHT'), findsOneWidget);
    await tester.tap(find.text('Mohammed Kudus'));
    await tester.pumpAndSettle();
    expect(find.text('PLAYER'), findsOneWidget);
    expect(find.text('Follow'), findsOneWidget);
    expect(find.text('News'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Rating'), findsOneWidget);
    expect(find.text('Match'), findsOneWidget);
    expect(find.text('Info'), findsWidgets);
    expect(find.text('Ghana'), findsOneWidget);
    expect(find.textContaining('example'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('PLAYER SPOTLIGHT'), findsOneWidget);

    await tester.tap(find.text('Teams'));
    await tester.pumpAndSettle();
    expect(find.text('TEAM DIRECTORY'), findsOneWidget);
    expect(find.text('Atlas Lions · North Africa'), findsOneWidget);

    await tester.tap(find.text('Fixtures'));
    await tester.pumpAndSettle();
    expect(find.text('FIXTURE PREVIEW'), findsOneWidget);
    expect(
      find.textContaining('sample pairing · date and venue TBC'),
      findsWidgets,
    );

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
    expect(find.text('AFCON · 2024/25 · SAMPLE DATA'), findsOneWidget);

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
      find.text('CAF Champions League · 2024/25 · SAMPLE DATA'),
      findsOneWidget,
    );
    expect(find.text('Al Ahly'), findsWidgets);

    await tester.tap(find.text('Players'));
    await tester.pumpAndSettle();
    expect(find.text('Percy Tau'), findsOneWidget);
    expect(find.text('Victor Osimhen'), findsNothing);

    await tester.tap(find.text('Teams'));
    await tester.pumpAndSettle();
    expect(find.text('The Red Devils · Egypt'), findsOneWidget);
    expect(find.text('Atlas Lions · North Africa'), findsNothing);

    await tester.tap(find.text('Fixtures'));
    await tester.pumpAndSettle();
    expect(find.text('Al Ahly'), findsOneWidget);
    expect(find.text('Raja Casablanca'), findsWidgets);
  });
}
