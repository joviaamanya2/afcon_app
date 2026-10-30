import 'package:afcon_app/screens/matches_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders confirmed lineup broadcast graphic matching reference image', (tester) async {
    final samplePlayers = <Map<String, dynamic>>[
      // Starters 4-3-3
      {'player_id': 'p1', 'player_name': 'David Raya', 'position': 'GK', 'shirt_number': 22, 'is_starting': true, 'formation': '4-3-3'},
      {'player_id': 'p2', 'player_name': 'Calafiori', 'position': 'LB', 'shirt_number': 33, 'is_starting': true, 'formation': '4-3-3'},
      {'player_id': 'p3', 'player_name': 'Gabriel', 'position': 'CB', 'shirt_number': 6, 'is_starting': true, 'formation': '4-3-3'},
      {'player_id': 'p4', 'player_name': 'Mosquera', 'position': 'CB', 'shirt_number': 4, 'is_starting': true, 'formation': '4-3-3'},
      {'player_id': 'p5', 'player_name': 'Ben White', 'position': 'RB', 'shirt_number': 2, 'is_starting': true, 'formation': '4-3-3'},
      {'player_id': 'p6', 'player_name': 'Lewis Skelly', 'position': 'CM', 'shirt_number': 49, 'is_starting': true, 'formation': '4-3-3'},
      {'player_id': 'p7', 'player_name': 'Declan Rice', 'position': 'DM', 'shirt_number': 41, 'is_starting': true, 'formation': '4-3-3'},
      {'player_id': 'p8', 'player_name': 'Odegaard', 'position': 'CM', 'shirt_number': 8, 'is_starting': true, 'formation': '4-3-3'},
      {'player_id': 'p9', 'player_name': 'Tzolis', 'position': 'LW', 'shirt_number': 11, 'is_starting': true, 'formation': '4-3-3'},
      {'player_id': 'p10', 'player_name': 'Kai Havertz', 'position': 'ST', 'shirt_number': 29, 'is_starting': true, 'formation': '4-3-3'},
      {'player_id': 'p11', 'player_name': 'Saka', 'position': 'RW', 'shirt_number': 7, 'is_starting': true, 'formation': '4-3-3'},
      // Substitutes
      {'player_id': 'p12', 'player_name': 'Trossard', 'position': 'LW', 'shirt_number': 19, 'is_starting': false, 'formation': '4-3-3'},
      {'player_id': 'p13', 'player_name': 'Jorginho', 'position': 'CM', 'shirt_number': 20, 'is_starting': false, 'formation': '4-3-3'},
    ];

    final sampleMatch = <String, dynamic>{
      'id': 'match-101',
      'home_team': 'Arsenal',
      'away_team': 'Aston Villa',
      'stage': 'Matchday 2 of 38',
      'venue_name': 'Villa Park',
      'kickoff_at': '2026-11-12T19:00:00Z',
    };

    // Test direct widget rendering with sample lineup
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PublishedLineupTeamView(
              name: 'Arsenal',
              players: samplePlayers,
              matchRecord: sampleMatch,
              opponentName: 'Aston Villa',
              isHome: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify broadcast header
    expect(find.text('CONFIRMED LINEUP'), findsOneWidget);
    expect(find.text('ARSENAL'), findsWidgets);
    expect(find.text('AFCON'), findsOneWidget);

    // Verify match info badge
    expect(find.text('MATCHDAY 2 OF 38'), findsOneWidget);
    expect(find.text('VILLA PARK'), findsOneWidget);

    // Verify formation badge
    expect(find.text('FORMATION'), findsOneWidget);
    expect(find.text('4-3-3'), findsOneWidget);

    // Verify starting players on pitch with nameplate
    expect(find.text('DAVID RAYA'), findsOneWidget);
    expect(find.text('CALAFIORI'), findsOneWidget);
    expect(find.text('GABRIEL'), findsOneWidget);
    expect(find.text('BEN WHITE'), findsOneWidget);
    expect(find.text('DECLAN RICE'), findsOneWidget);
    expect(find.text('KAI HAVERTZ'), findsOneWidget);
    expect(find.text('SAKA'), findsOneWidget);

    // Verify substitutes
    expect(find.text('SUBSTITUTES'), findsOneWidget);
    expect(find.text('Trossard'), findsOneWidget);
    expect(find.text('Jorginho'), findsOneWidget);
  });
}
