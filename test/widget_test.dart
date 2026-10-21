import 'package:afcon_app/main.dart';
import 'package:afcon_app/screens/explore_screen.dart';
import 'package:afcon_app/screens/matches_screen.dart';
import 'package:afcon_app/screens/teams_players_screen.dart';
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

  testWidgets('match tabs filter the sample match list', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

    final matchTabs = tester.widget<TabBar>(find.byType(TabBar).first);
    expect(matchTabs.labelColor, Colors.white);
    expect(matchTabs.indicator, isA<BoxDecoration>());

    expect(find.text('Manchester United'), findsOneWidget);
    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();
    expect(find.text('No live matches right now'), findsOneWidget);

    await tester.tap(find.text('Upcoming'));
    await tester.pumpAndSettle();
    expect(find.text('Manchester United'), findsOneWidget);
    expect(find.text('Arsenal'), findsOneWidget);

    await tester.tap(find.text('Premier League'));
    await tester.pumpAndSettle();
    expect(find.text('Manchester United'), findsOneWidget);

    await tester.ensureVisible(find.text('LaLiga'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LaLiga'));
    await tester.pumpAndSettle();
    expect(find.text('No LaLiga matches to show yet'), findsOneWidget);
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

    expect(find.text('NEWS'), findsOneWidget);
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

  testWidgets('explore has competition tabs and more region selector', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExploreScreen()));

    expect(find.text('Hot'), findsOneWidget);
    expect(find.text('Competitions'), findsOneWidget);
    expect(find.text('Ranking'), findsOneWidget);
    expect(find.text('EPL'), findsOneWidget);
    expect(find.text('Tables'), findsOneWidget);
    expect(find.text('North City'), findsOneWidget);
    expect(find.text('EPL · 2026/27 · SAMPLE DATA'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024/25').last);
    await tester.pumpAndSettle();
    expect(find.text('EPL · 2024/25 · SAMPLE DATA'), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('Explore competitions'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    await tester.tap(find.text('African'));
    await tester.pumpAndSettle();
    expect(find.text('Africa Cup of Nations'), findsOneWidget);

    await tester.tap(find.text('Africa Cup of Nations'));
    await tester.pumpAndSettle();
    expect(
      find.text('Africa Cup of Nations · 2024/25 · SAMPLE DATA'),
      findsOneWidget,
    );
  });
}
