import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _cafPurple = Color(0xFF3921AA);
const _cafPink = Color(0xFFBD4F6C);
const _ink = Color(0xFF1E1E1E);
const _muted = Color(0xFF666666);
const _womenImagePath = 'assets/images/women images/';

const _womenChampionsLeagueFixtures = <_WomenFixture>[
  _WomenFixture(
    date: '1 Nov',
    group: 'Group A',
    home: 'FUS Rabat',
    away: 'Lekié Football Filles',
    kickoff: '14:00',
    venue: 'Ismailia Stadium',
  ),
  _WomenFixture(
    date: '1 Nov',
    group: 'Group B',
    home: 'AS FAR',
    away: 'Kawempe Muslim Ladies',
    kickoff: '14:00',
    venue: 'Suez Canal Stadium',
  ),
  _WomenFixture(
    date: '1 Nov',
    group: 'Group B',
    home: 'USFAS Bamako',
    away: 'WAFU Zone B qualifier',
    kickoff: '17:00',
    venue: 'Ismailia Stadium',
  ),
  _WomenFixture(
    date: '1 Nov',
    group: 'Group A',
    home: 'FC Masar',
    away: 'Mamelodi Sundowns',
    kickoff: '17:00',
    venue: 'Suez Canal Stadium',
  ),
  _WomenFixture(
    date: '4 Nov',
    group: 'Group A',
    home: 'Lekié Football Filles',
    away: 'Mamelodi Sundowns',
    kickoff: '14:00',
    venue: 'Ismailia Stadium',
  ),
  _WomenFixture(
    date: '4 Nov',
    group: 'Group A',
    home: 'FC Masar',
    away: 'FUS Rabat',
    kickoff: '17:00',
    venue: 'Suez Canal Stadium',
  ),
  _WomenFixture(
    date: '5 Nov',
    group: 'Group B',
    home: 'AS FAR',
    away: 'USFAS Bamako',
    kickoff: '14:00',
    venue: 'Suez Canal Stadium',
  ),
  _WomenFixture(
    date: '5 Nov',
    group: 'Group B',
    home: 'WAFU Zone B qualifier',
    away: 'Kawempe Muslim Ladies',
    kickoff: '17:00',
    venue: 'Ismailia Stadium',
  ),
  _WomenFixture(
    date: '7 Nov',
    group: 'Group A',
    home: 'Lekié Football Filles',
    away: 'FC Masar',
    kickoff: '14:00',
    venue: 'Suez Canal Stadium',
  ),
  _WomenFixture(
    date: '7 Nov',
    group: 'Group A',
    home: 'Mamelodi Sundowns',
    away: 'FUS Rabat',
    kickoff: '14:00',
    venue: 'Ismailia Stadium',
  ),
  _WomenFixture(
    date: '8 Nov',
    group: 'Group B',
    home: 'WAFU Zone B qualifier',
    away: 'AS FAR',
    kickoff: '14:00',
    venue: 'Suez Canal Stadium',
  ),
  _WomenFixture(
    date: '8 Nov',
    group: 'Group B',
    home: 'Kawempe Muslim Ladies',
    away: 'USFAS Bamako',
    kickoff: '14:00',
    venue: 'Ismailia Stadium',
  ),
  _WomenFixture(
    date: '11 Nov',
    group: 'Semi-final 1',
    home: '1st Group A',
    away: '2nd Group B',
    kickoff: '17:00',
    venue: 'Suez Canal Stadium',
  ),
  _WomenFixture(
    date: '11 Nov',
    group: 'Semi-final 2',
    home: '1st Group B',
    away: '2nd Group A',
    kickoff: '14:00',
    venue: 'Ismailia Stadium',
  ),
  _WomenFixture(
    date: '14 Nov',
    group: 'Third-place match',
    home: 'Semi-final loser 1',
    away: 'Semi-final loser 2',
    kickoff: '14:00',
    venue: 'Ismailia Stadium',
  ),
  _WomenFixture(
    date: '15 Nov',
    group: 'Final',
    home: 'Semi-final winner 1',
    away: 'Semi-final winner 2',
    kickoff: '17:00',
    venue: 'Suez Canal Stadium',
  ),
];

class _WomenFixture {
  const _WomenFixture({
    required this.date,
    required this.group,
    required this.home,
    required this.away,
    required this.kickoff,
    required this.venue,
  });

  final String date;
  final String group;
  final String home;
  final String away;
  final String kickoff;
  final String venue;
}

class WomensChampionsLeagueScreen extends StatefulWidget {
  const WomensChampionsLeagueScreen({super.key});

  @override
  State<WomensChampionsLeagueScreen> createState() =>
      _WomensChampionsLeagueScreenState();
}

class _WomensChampionsLeagueScreenState
    extends State<WomensChampionsLeagueScreen> {
  Future<void> _openYoutubeSearch(String query) async {
    final uri = Uri.https('www.youtube.com', '/results', {
      'search_query': query,
    });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open YouTube.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F7F7),
    appBar: AppBar(
      title: const Text('Women’s Champions League'),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      foregroundColor: _ink,
      elevation: 0,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            '${_womenImagePath}seven.PNG',
            height: 190,
            width: double.infinity,
            fit: BoxFit.cover,
            semanticLabel: 'Women footballers together on the pitch',
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'CAF Women’s Champions League Egypt 2026',
          style: TextStyle(
            color: _ink,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Africa’s leading women’s club competition returns to Egypt for two weeks of continental football.',
          style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Icons.calendar_month_rounded,
              label: '1–15 Nov 2026',
            ),
            _InfoChip(icon: Icons.location_on_outlined, label: 'Egypt'),
            _InfoChip(icon: Icons.groups_rounded, label: '8 clubs'),
          ],
        ),
        const SizedBox(height: 22),
        const _SectionHeading(title: 'The 2026 groups'),
        const SizedBox(height: 10),
        const _GroupCard(
          group: 'A',
          clubs: [
            ('FC Masar', 'Egypt'),
            ('Mamelodi Sundowns', 'South Africa'),
            ('FUS Rabat', 'Morocco'),
            ('Lekié Football Filles', 'Cameroon'),
          ],
        ),
        const SizedBox(height: 10),
        const _GroupCard(
          group: 'B',
          clubs: [
            ('AS FAR', 'Morocco · defending champions'),
            ('Kawempe Muslim Ladies', 'Uganda'),
            ('USFAS Bamako', 'Mali'),
            ('WAFU Zone B representative', 'Qualification pending'),
          ],
        ),
        const SizedBox(height: 22),
        const _SectionHeading(title: 'Tournament format'),
        const SizedBox(height: 10),
        const _InfoPanel(
          icon: Icons.account_tree_outlined,
          text: 'Eight clubs compete in two groups of four. The top two teams in each group advance to the semi-finals.',
        ),
        const SizedBox(height: 8),
        const _InfoPanel(
          icon: Icons.account_balance_outlined,
          text: 'Matches are scheduled at Suez Canal Stadium and Ismailia Stadium in Ismailia. The WAFU Zone B qualifying club is shown as a placeholder until confirmed.',
        ),
        const SizedBox(height: 22),
        const _SectionHeading(title: 'Full match calendar'),
        const SizedBox(height: 10),
        const Text(
          'All published group matches and knock-out fixtures, with kick-off times and venues.',
          style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            '${_womenImagePath}main picture.PNG',
            width: double.infinity,
            fit: BoxFit.contain,
            semanticLabel:
                'CAF Women’s Champions League Egypt 2026 match calendar',
          ),
        ),
        const SizedBox(height: 10),
        for (final fixture in _womenChampionsLeagueFixtures)
          _WomenFixtureCard(fixture: fixture),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(
              child: _SectionHeading(title: 'From the CAF archive'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Highlights from the 2025 edition. The 2026 match video schedule has not been published here yet.',
          style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
        ),
        const SizedBox(height: 10),
        _ArchiveVideoCard(
          title: 'ASEC Mimosas 1–0 FC Masar',
          detail: '2025 semi-final highlights',
          imageAsset: '${_womenImagePath}one.PNG',
          youtubeSearchQuery:
              'ASEC Mimosas 1-0 FC Masar CAF WCL 2025 semi-final highlights',
          onTap: _openYoutubeSearch,
        ),
        const SizedBox(height: 10),
        _ArchiveVideoCard(
          title: 'TP Mazembe 0–1 ASEC Mimosas',
          detail: '2025 group stage · Matchday 1 highlights',
          imageAsset: '${_womenImagePath}two.PNG',
          youtubeSearchQuery:
              'TP Mazembe 0-1 ASEC Mimosas CAF WCL 2025 highlights',
          onTap: _openYoutubeSearch,
        ),
        const SizedBox(height: 10),
        _ArchiveVideoCard(
          title: 'TP Mazembe 3–0 Gaborone United',
          detail: '2025 group stage · Matchday 2 highlights',
          imageAsset: '${_womenImagePath}three.PNG',
          youtubeSearchQuery:
              'TP Mazembe 3-0 Gaborone United CAF WCL 2025 highlights',
          onTap: _openYoutubeSearch,
        ),
        const SizedBox(height: 10),
        _ArchiveVideoCard(
          title: 'JKT Queens 1–4 TP Mazembe',
          detail: '2025 group stage · Matchday 3 highlights',
          imageAsset: '${_womenImagePath}four.PNG',
          youtubeSearchQuery:
              'JKT Queens 1-4 TP Mazembe CAF WCL 2025 highlights',
          onTap: _openYoutubeSearch,
        ),
        const SizedBox(height: 20),
        const _SectionHeading(title: 'Women’s football gallery'),
        const SizedBox(height: 10),
        SizedBox(
          height: 176,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _WomenGalleryCard(
                image: '${_womenImagePath}five.PNG',
                title: 'Tournament voices',
                detail: 'A moment from the competition',
              ),
              SizedBox(width: 10),
              _WomenGalleryCard(
                image: '${_womenImagePath}six.PNG',
                title: 'Morocco 2024',
                detail: 'CAF Women’s Champions League',
              ),
              SizedBox(width: 10),
              _WomenGalleryCard(
                image: '${_womenImagePath}eight.PNG',
                title: 'Women’s football',
                detail: 'Players across the continent',
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: _ink,
      fontSize: 17,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE6E6E6)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: _cafPink),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: _ink,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.clubs});

  final String group;
  final List<(String, String)> clubs;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE6E6E6)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GROUP $group',
          style: const TextStyle(
            color: _cafPurple,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
        ),
        const SizedBox(height: 7),
        for (final (club, country) in clubs)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: const Color(0xFFF8E9EE),
                  child: Text(
                    club.substring(0, 1),
                    style: const TextStyle(
                      color: _cafPink,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        country,
                        style: const TextStyle(color: _muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFFE6E6E6)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: _cafPurple),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: _muted, fontSize: 12, height: 1.45),
          ),
        ),
      ],
    ),
  );
}

class _WomenFixtureCard extends StatelessWidget {
  const _WomenFixtureCard({required this.fixture});

  final _WomenFixture fixture;

  @override
  Widget build(BuildContext context) => Container(
    key: Key('wcl-fixture-${fixture.date}-${fixture.home}'),
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE6E6E6)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${fixture.date} · ${fixture.group}',
                style: const TextStyle(
                  color: _cafPurple,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              fixture.kickoff,
              style: const TextStyle(
                color: _ink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                fixture.home,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Text(
              'VS',
              style: TextStyle(
                color: _cafPink,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            Expanded(
              child: Text(
                fixture.away,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            const Icon(Icons.stadium_outlined, color: _muted, size: 14),
            const SizedBox(width: 5),
            Text(
              '${fixture.venue} · Ismailia',
              style: const TextStyle(color: _muted, fontSize: 10),
            ),
          ],
        ),
      ],
    ),
  );
}

class _WomenGalleryCard extends StatelessWidget {
  const _WomenGalleryCard({
    required this.image,
    required this.title,
    required this.detail,
  });

  final String image;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(image, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ArchiveVideoCard extends StatelessWidget {
  const _ArchiveVideoCard({
    required this.title,
    required this.detail,
    required this.imageAsset,
    required this.youtubeSearchQuery,
    required this.onTap,
  });

  final String title;
  final String detail;
  final String imageAsset;
  final String youtubeSearchQuery;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => onTap(youtubeSearchQuery),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                imageAsset,
                height: 165,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const Icon(
                Icons.play_circle_fill_rounded,
                size: 52,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Color(0xFF376B4B),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => onTap(youtubeSearchQuery),
                      icon: const Icon(Icons.smart_display_outlined, size: 18),
                      label: const Text('Watch on YouTube'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
