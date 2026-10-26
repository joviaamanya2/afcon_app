import 'package:flutter/material.dart';

import '../data/pamoja_match_data.dart';
import '../services/afcon_api.dart';
import 'teams_players_screen.dart' show PlayerProfileScreen;

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  static const _brandMaroon = Color(0xFF800000);
  static const _canvas = Color(0xFFF7F7F7);
  static const _topTabs = ['Popular', 'CAF', 'Rankings', 'Groups', 'Transfers'];
  static const _leagues = [
    'AFCON',
    'CAF Champions League',
    'CAF Confederation Cup',
    'WAFCON',
  ];
  static const _regions = [
    'Popular',
    'CAF competitions',
    'National teams',
    'African clubs',
    'Women',
    'Youth',
  ];
  static const _competitionGroups = <String, List<String>>{
    'Popular': [
      'Africa Cup of Nations',
      'African Nations Championship',
      'CAF Champions League',
      'CAF Confederation Cup',
      "Women's Africa Cup of Nations",
    ],
    'CAF competitions': [
      'Africa Cup of Nations',
      'African Nations Championship',
      'CAF Champions League',
      'CAF Confederation Cup',
      'CAF Super Cup',
      'African Football League',
    ],
    'National teams': [
      'Africa Cup of Nations',
      'African Nations Championship',
      'U-23 Africa Cup of Nations',
      'U-20 Africa Cup of Nations',
      'U-17 Africa Cup of Nations',
      'Futsal Africa Cup of Nations',
      'Beach Soccer Africa Cup of Nations',
    ],
    'African clubs': [
      'CAF Champions League',
      'CAF Confederation Cup',
      'CAF Super Cup',
      'African Football League',
    ],
    'Women': ["Women's Africa Cup of Nations", "CAF Women's Champions League"],
    'Youth': [
      'U-23 Africa Cup of Nations',
      'U-20 Africa Cup of Nations',
      'U-17 Africa Cup of Nations',
      'African Schools Football Championship',
    ],
  };

  late final TabController _topTabController;
  late final TabController _dataTabController;
  String _selectedLeague = 'AFCON';
  String _selectedSeason = '2026/27';

  static const _seasons = [
    '2026/27',
    '2025/26',
    '2024/25',
    '2023/24',
    '2022/23',
    '2021/22',
  ];

  @override
  void initState() {
    super.initState();
    _topTabController = TabController(length: _topTabs.length, vsync: this);
    _topTabController.addListener(_onTopTabChanged);
    _dataTabController = TabController(length: 4, vsync: this);
  }

  void _onTopTabChanged() {
    if (!_topTabController.indexIsChanging && mounted) setState(() {});
  }

  @override
  void dispose() {
    _topTabController.dispose();
    _dataTabController.dispose();
    super.dispose();
  }

  Future<void> _showMoreCompetitions() async {
    final competition = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => const _CompetitionBrowserScreen(
          regions: _regions,
          competitionGroups: _competitionGroups,
        ),
      ),
    );
    if (competition != null && mounted) {
      setState(() => _selectedLeague = competition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E1E),
        centerTitle: false,
        title: TabBar(
          controller: _topTabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: const Color(0xFF800000),
          indicatorWeight: 3,
          labelColor: const Color(0xFF800000),
          unselectedLabelColor: const Color(0xFF666666),
          tabs: _topTabs.map((tab) => Tab(text: tab)).toList(),
        ),
        bottom: _topTabController.index < 3
            ? PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: Colors.white,
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (final league in _leagues)
                        _LeagueShortcut(
                          label: league,
                          selected: _selectedLeague == league,
                          onTap: () => setState(() => _selectedLeague = league),
                        ),
                      TextButton.icon(
                        onPressed: _showMoreCompetitions,
                        icon: const Icon(Icons.expand_more_rounded, size: 19),
                        label: const Text('More'),
                        style: TextButton.styleFrom(
                          foregroundColor: _brandMaroon,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          if (_topTabController.index < 3)
            Container(
              height: 56,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSeason,
                      dropdownColor: Colors.white,
                      iconEnabledColor: _brandMaroon,
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      items: _seasons
                          .map(
                            (season) => DropdownMenuItem(
                              value: season,
                              child: Text(season),
                            ),
                          )
                          .toList(),
                      onChanged: (season) {
                        if (season != null) {
                          setState(() => _selectedSeason = season);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TabBar(
                      controller: _dataTabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicator: BoxDecoration(
                        color: const Color(0xFFF5E6E6),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      labelColor: _brandMaroon,
                      unselectedLabelColor: const Color(0xFF666666),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Tables'),
                        Tab(text: 'Players'),
                        Tab(text: 'Teams'),
                        Tab(text: 'Fixtures'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _topTabController,
              children: [
                _CompetitionContent(
                  league: _selectedLeague,
                  season: _selectedSeason,
                  dataTabController: _dataTabController,
                ),
                _CafCompetitionsContent(onMore: _showMoreCompetitions),
                const _RankingsContent(),
                const _GroupsContent(),
                const _TransfersContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupsContent extends StatefulWidget {
  const _GroupsContent();

  @override
  State<_GroupsContent> createState() => _GroupsContentState();
}

class _GroupsContentState extends State<_GroupsContent> {
  final _api = AfconApi();
  late Future<List<Map<String, dynamic>>> _standings;

  @override
  void initState() {
    super.initState();
    _standings = _loadStandings();
  }

  Future<List<Map<String, dynamic>>> _loadStandings() async {
    final competitions = await _api.competitions();
    final afcon = competitions.where((competition) {
      final name = '${competition['name'] ?? ''}'.toLowerCase();
      return name.contains('afcon') || name.contains('africa cup of nations');
    }).toList();
    if (afcon.isEmpty) return const [];
    afcon.sort((a, b) {
      final aCurrent = '${a['season'] ?? ''}'.contains('2026');
      final bCurrent = '${b['season'] ?? ''}'.contains('2026');
      return (bCurrent ? 1 : 0).compareTo(aCurrent ? 1 : 0);
    });
    final competitionId = '${afcon.first['id'] ?? ''}';
    if (competitionId.isEmpty) return const [];
    return _api.standings(competitionId: competitionId);
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _standings,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const _QualifierGroupsContent();
          }
          final groups = <String, List<Map<String, dynamic>>>{};
          for (final row in snapshot.data ?? const <Map<String, dynamic>>[]) {
            final group = '${row['group_code'] ?? ''}'.trim();
            if (group.isEmpty) continue;
            groups.putIfAbsent(group, () => []).add(row);
          }
          if (groups.isEmpty) {
            return const _QualifierGroupsContent();
          }
          final groupNames = groups.keys.toList()..sort();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              const Text(
                'AFCON qualifying groups',
                style: TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Published standings from the AFCON backend',
                style: TextStyle(color: Color(0xFF666666), fontSize: 12),
              ),
              const SizedBox(height: 12),
              for (final group in groupNames)
                _GroupStandingsCard(
                  group: group,
                  rows: groups[group]!
                    ..sort(
                      (a, b) =>
                          _standingPosition(a).compareTo(_standingPosition(b)),
                    ),
                ),
            ],
          );
        },
      );
}

int _standingPosition(Map<String, dynamic> row) =>
    int.tryParse('${row['position'] ?? ''}') ?? 999;

class _GroupStandingsCard extends StatelessWidget {
  const _GroupStandingsCard({required this.group, required this.rows});

  final String group;
  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE6E6E6)),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 9),
          child: Row(
            children: [
              const Icon(
                Icons.groups_rounded,
                color: Color(0xFF800000),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'GROUP $group',
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
              const Spacer(),
              const Text(
                'P  PTS',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Text(
                    '${row['position'] ?? '—'}',
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${row['team_name'] ?? row['name'] ?? 'Team'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${row['played'] ?? 0}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 11,
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${row['points'] ?? 0}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Color(0xFF800000),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _QualifierGroupsContent extends StatelessWidget {
  const _QualifierGroupsContent();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
    children: [
      const _ExploreSectionHeading(
        eyebrow: 'AFCON 2027 QUALIFIERS',
        title: 'The qualifying draw',
        description: 'Teams are arranged into 12 groups. Match results and standings will appear when officially published.',
      ),
      const SizedBox(height: 12),
      for (final group in pamojaGroups) _QualifierGroupCard(group: group),
      const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'Group draw information from CAF-published material. No results are shown here.',
          style: TextStyle(color: Color(0xFF666666), fontSize: 10, height: 1.4),
        ),
      ),
    ],
  );
}

class _QualifierGroupCard extends StatelessWidget {
  const _QualifierGroupCard({required this.group});

  final PamojaGroup group;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE6E6E6)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GROUP ${group.code}',
          style: const TextStyle(
            color: Color(0xFF800000),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: group.teams
              .map(
                (team) => Chip(
                  label: Text(team),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: const Color(0xFFF5F6F5),
                  side: BorderSide.none,
                  labelStyle: const TextStyle(
                    color: Color(0xFF343A40),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
}

class _TransfersContent extends StatelessWidget {
  const _TransfersContent();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
    children: [
      const _ExploreSectionHeading(
        eyebrow: 'TRANSFER TRACKER',
        title: 'Notable past moves',
        description: 'A look back at high-profile moves involving African internationals. This is historical context, not live transfer news.',
      ),
      const SizedBox(height: 12),
      const _TransferMoveCard(
        player: 'Mohammed Kudus',
        from: 'Ajax',
        to: 'West Ham United',
        year: '2023',
      ),
      const _TransferMoveCard(
        player: 'Sadio Mané',
        from: 'Bayern Munich',
        to: 'Al-Nassr',
        year: '2023',
      ),
      const _TransferMoveCard(
        player: 'Victor Osimhen',
        from: 'Napoli',
        to: 'Galatasaray (loan)',
        year: '2024',
      ),
    ],
  );
}

class _ExploreSectionHeading extends StatelessWidget {
  const _ExploreSectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow,
        style: const TextStyle(
          color: Color(0xFF800000),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: .8,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1E1E1E),
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        description,
        style: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 12,
          height: 1.45,
        ),
      ),
    ],
  );
}

class _TransferMoveCard extends StatelessWidget {
  const _TransferMoveCard({
    required this.player,
    required this.from,
    required this.to,
    required this.year,
  });

  final String player;
  final String from;
  final String to;
  final String year;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE6E6E6)),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFFF5E6E6),
          child: Icon(Icons.swap_horiz_rounded, color: Color(0xFF800000)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$from  →  $to',
                style: const TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          year,
          style: const TextStyle(
            color: Color(0xFF800000),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _SamplePlayersContent extends StatelessWidget {
  const _SamplePlayersContent({
    required this.league,
    required this.season,
    required this.preview,
  });

  final String league;
  final String season;
  final _CompetitionPreview preview;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
    children: [
      const _ExploreSectionHeading(
        eyebrow: 'PLAYER SPOTLIGHT',
        title: 'African players to know',
        description: 'A sample of well-known internationals. This is not a confirmed squad or current-season statistics.',
      ),
      const SizedBox(height: 12),
      for (final player in preview.players)
        _ExplorePlayerCard(player: player, season: season),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '$league player list is an editorial preview, not an official roster.',
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 10,
            height: 1.4,
          ),
        ),
      ),
    ],
  );
}

class _SampleTeamsContent extends StatelessWidget {
  const _SampleTeamsContent({required this.league, required this.preview});

  final String league;
  final _CompetitionPreview preview;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
    children: [
      const _ExploreSectionHeading(
        eyebrow: 'TEAM DIRECTORY',
        title: 'National teams',
        description: 'Browse a few of the national sides featured across African football.',
      ),
      const SizedBox(height: 12),
      for (final team in preview.teams)
        _SimpleProfileCard(
          leading: team.name.substring(0, 1),
          title: team.name,
          subtitle: '${team.nickname} · ${team.region}',
        ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Showing a sample directory for $league. Team list is not competition qualification status.',
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 10,
            height: 1.4,
          ),
        ),
      ),
    ],
  );
}

class _SampleFixturesContent extends StatelessWidget {
  const _SampleFixturesContent({required this.league, required this.preview});

  final String league;
  final _CompetitionPreview preview;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
    children: [
      const _ExploreSectionHeading(
        eyebrow: 'FIXTURE PREVIEW',
        title: 'Matchday fixtures',
        description: 'These sample pairings are for layout preview only and are not confirmed matches.',
      ),
      const SizedBox(height: 12),
      for (final match in preview.fixtures)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      match.home,
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Text(
                    'VS',
                    style: TextStyle(
                      color: Color(0xFF800000),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.away,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                '$league · ${match.note}',
                style: const TextStyle(color: Color(0xFF666666), fontSize: 10),
              ),
            ],
          ),
        ),
      const Text(
        'Fixture dates, venues, and team pairings will be updated when officially published.',
        style: TextStyle(color: Color(0xFF666666), fontSize: 10, height: 1.4),
      ),
    ],
  );
}

class _SimpleProfileCard extends StatelessWidget {
  const _SimpleProfileCard({
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  final String leading;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE6E6E6)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: const Color(0xFFF5E6E6),
          child: Text(
            leading,
            style: const TextStyle(
              color: Color(0xFF800000),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF666666), fontSize: 10),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Color(0xFF999999),
          size: 13,
        ),
      ],
    ),
  );
}

class _ExplorePlayerCard extends StatelessWidget {
  const _ExplorePlayerCard({required this.player, required this.season});

  final _PreviewPlayer player;
  final String season;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PlayerProfileScreen(
            playerName: player.name,
            teamName: player.team,
            position: player.position,
            squadNumber: player.number,
            season: season,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: const Color(0xFFF5E6E6),
              child: Text(
                player.name.substring(0, 1),
                style: const TextStyle(
                  color: Color(0xFF800000),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${player.team} · ${player.position}',
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF999999),
              size: 13,
            ),
          ],
        ),
      ),
    ),
  );
}

class _CafCompetitionsContent extends StatelessWidget {
  const _CafCompetitionsContent({required this.onMore});

  final VoidCallback onMore;

  static const _competitions = [
    (
      'Africa Cup of Nations',
      'Senior men’s national teams',
      Icons.public_rounded,
    ),
    (
      'African Nations Championship',
      'Domestic-league players',
      Icons.groups_rounded,
    ),
    (
      'CAF Champions League',
      'Top-level African club football',
      Icons.emoji_events_rounded,
    ),
    (
      'CAF Confederation Cup',
      'Continental club competition',
      Icons.sports_soccer_rounded,
    ),
    (
      'Women’s Africa Cup of Nations',
      'Senior women’s national teams',
      Icons.woman_rounded,
    ),
    (
      'CAF Women’s Champions League',
      'Women’s club football',
      Icons.emoji_events_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
    children: [
      const _ExploreSectionHeading(
        eyebrow: 'CAF COMPETITIONS',
        title: 'Football across Africa',
        description: 'Follow national-team tournaments and continental club competitions.',
      ),
      const SizedBox(height: 12),
      for (final competition in _competitions)
        Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: Row(
            children: [
              Icon(competition.$3, color: const Color(0xFF800000), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      competition.$1,
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      competition.$2,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      OutlinedButton.icon(
        onPressed: onMore,
        icon: const Icon(Icons.grid_view_rounded),
        label: const Text('Browse all competitions'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF800000),
        ),
      ),
    ],
  );
}

class _RankingsContent extends StatelessWidget {
  const _RankingsContent();

  static const _champions = [
    ('2023', 'Côte d’Ivoire', 'Hosts lifted their third AFCON title.'),
    ('2021', 'Senegal', 'Claimed the nation’s first AFCON title.'),
    ('2019', 'Algeria', 'Won their second AFCON title.'),
    ('2017', 'Cameroon', 'Secured their fifth AFCON title.'),
  ];

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
    children: [
      const _ExploreSectionHeading(
        eyebrow: 'RANKINGS & HISTORY',
        title: 'Recent AFCON champions',
        description: 'A quick historical snapshot while verified live rankings are unavailable.',
      ),
      const SizedBox(height: 12),
      for (final champion in _champions)
        _SimpleProfileCard(
          leading: champion.$1.substring(2),
          title: '${champion.$2} · ${champion.$1}',
          subtitle: champion.$3,
        ),
      const Text(
        'Historical winners are shown here instead of presenting unofficial ranking positions.',
        style: TextStyle(color: Color(0xFF666666), fontSize: 10, height: 1.4),
      ),
    ],
  );
}

class _LeagueShortcut extends StatelessWidget {
  const _LeagueShortcut({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: selected
            ? const Color(0xFF800000)
            : const Color(0xFF343A40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      child: Text(label),
    );
  }
}

class _CompetitionContent extends StatelessWidget {
  const _CompetitionContent({
    required this.league,
    required this.season,
    required this.dataTabController,
  });

  final String league;
  final String season;
  final TabController dataTabController;

  @override
  Widget build(BuildContext context) {
    final preview = _previewForCompetition(league);
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFFF5E6E6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '$league · $season · SAMPLE DATA',
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: dataTabController,
            children: [
              _StandingsTable(league: league, season: season, preview: preview),
              _SamplePlayersContent(
                league: league,
                season: season,
                preview: preview,
              ),
              _SampleTeamsContent(league: league, preview: preview),
              _SampleFixturesContent(league: league, preview: preview),
            ],
          ),
        ),
      ],
    );
  }
}

class _StandingsTable extends StatelessWidget {
  const _StandingsTable({
    required this.league,
    required this.season,
    required this.preview,
  });

  final String league;
  final String season;
  final _CompetitionPreview preview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: const Color(0xFFF0F4F1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: const Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  'TEAM',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 10),
                ),
              ),
              _TableHeaderCell(label: 'P'),
              _TableHeaderCell(label: 'W'),
              _TableHeaderCell(label: 'D'),
              _TableHeaderCell(label: 'L'),
              _TableHeaderCell(label: 'PTS'),
            ],
          ),
        ),
        for (var index = 0; index < preview.table.length; index++)
          _StandingsRow(
            values: (
              '${index + 1}',
              preview.table[index].team,
              preview.table[index].played,
              preview.table[index].wins,
              preview.table[index].draws,
              preview.table[index].losses,
              preview.table[index].points,
            ),
            highlighted: index == 0,
          ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            '$league · $season: ${preview.tableNote}',
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  const _TableHeaderCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF666666), fontSize: 9),
      ),
    );
  }
}

class _StandingsRow extends StatelessWidget {
  const _StandingsRow({required this.values, required this.highlighted});

  final (String, String, String, String, String, String, String) values;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final background = highlighted ? const Color(0xFFF5E6E6) : Colors.white;
    const textColor = Color(0xFF1E1E1E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        border: const Border(bottom: BorderSide(color: Color(0xFFE9EFEB))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              values.$1,
              style: TextStyle(
                color: highlighted ? const Color(0xFF800000) : textColor,
                fontSize: 12,
                fontWeight: highlighted ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 5,
            child: Text(
              values.$2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: highlighted ? const Color(0xFF800000) : textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (final value in [
            values.$3,
            values.$4,
            values.$5,
            values.$6,
            values.$7,
          ])
            SizedBox(
              width: 34,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textColor, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

class _PreviewStanding {
  const _PreviewStanding(
    this.team,
    this.played,
    this.wins,
    this.draws,
    this.losses,
    this.points,
  );

  final String team;
  final String played;
  final String wins;
  final String draws;
  final String losses;
  final String points;
}

class _PreviewPlayer {
  const _PreviewPlayer(
    this.name,
    this.team,
    this.position, [
    this.number = '—',
  ]);

  final String name;
  final String team;
  final String position;
  final String number;
}

class _PreviewTeam {
  const _PreviewTeam(this.name, this.region, this.nickname);

  final String name;
  final String region;
  final String nickname;
}

class _PreviewFixture {
  const _PreviewFixture(this.home, this.away, this.note);

  final String home;
  final String away;
  final String note;
}

class _CompetitionPreview {
  const _CompetitionPreview({
    required this.table,
    required this.tableNote,
    required this.players,
    required this.teams,
    required this.fixtures,
  });

  final List<_PreviewStanding> table;
  final String tableNote;
  final List<_PreviewPlayer> players;
  final List<_PreviewTeam> teams;
  final List<_PreviewFixture> fixtures;
}

_CompetitionPreview _previewForCompetition(String league) {
  final name = league.toLowerCase();
  if (name.contains('wafcon') || name.contains('women')) {
    return _womenPreview;
  }
  if (name.contains('confederation')) return _confederationPreview;
  if (name.contains('champions') || name.contains('club')) {
    return _championsPreview;
  }
  return _afconPreview;
}

const _afconPreview = _CompetitionPreview(
  tableNote: 'illustrative table only; results are not official.',
  table: [
    _PreviewStanding('Morocco', '3', '2', '1', '0', '7'),
    _PreviewStanding('Gabon', '3', '1', '2', '0', '5'),
    _PreviewStanding('Niger', '3', '1', '0', '2', '3'),
    _PreviewStanding('Lesotho', '3', '0', '1', '2', '1'),
  ],
  players: [
    _PreviewPlayer('Mohammed Kudus', 'Ghana', 'Midfielder', '20'),
    _PreviewPlayer('Victor Osimhen', 'Nigeria', 'Forward', '9'),
    _PreviewPlayer('Mohamed Salah', 'Egypt', 'Forward', '10'),
    _PreviewPlayer('Achraf Hakimi', 'Morocco', 'Defender', '2'),
    _PreviewPlayer('Rogers Mato', 'Uganda', 'Forward', '17'),
  ],
  teams: [
    _PreviewTeam('Morocco', 'North Africa', 'Atlas Lions'),
    _PreviewTeam('Ghana', 'West Africa', 'Black Stars'),
    _PreviewTeam('Nigeria', 'West Africa', 'Super Eagles'),
    _PreviewTeam('Uganda', 'East Africa', 'Cranes'),
    _PreviewTeam('South Africa', 'Southern Africa', 'Bafana Bafana'),
  ],
  fixtures: [
    _PreviewFixture('Uganda', 'Ghana', 'sample pairing · date and venue TBC'),
    _PreviewFixture(
      'Morocco',
      'Nigeria',
      'sample pairing · date and venue TBC',
    ),
    _PreviewFixture('Senegal', 'Egypt', 'sample pairing · date and venue TBC'),
  ],
);

const _championsPreview = _CompetitionPreview(
  tableNote: 'illustrative club table; not live CAF standings.',
  table: [
    _PreviewStanding('Al Ahly', '4', '3', '1', '0', '10'),
    _PreviewStanding('Mamelodi Sundowns', '4', '2', '1', '1', '7'),
    _PreviewStanding('Espérance de Tunis', '4', '1', '1', '2', '4'),
    _PreviewStanding('Raja Casablanca', '4', '0', '1', '3', '1'),
  ],
  players: [
    _PreviewPlayer('Percy Tau', 'Al Ahly', 'Forward', '10'),
    _PreviewPlayer('Ronwen Williams', 'Mamelodi Sundowns', 'Goalkeeper', '1'),
    _PreviewPlayer('Teboho Mokoena', 'Mamelodi Sundowns', 'Midfielder', '4'),
    _PreviewPlayer('Peter Shalulile', 'Mamelodi Sundowns', 'Forward', '9'),
  ],
  teams: [
    _PreviewTeam('Al Ahly', 'Egypt', 'The Red Devils'),
    _PreviewTeam('Mamelodi Sundowns', 'South Africa', 'The Brazilians'),
    _PreviewTeam('Espérance de Tunis', 'Tunisia', 'Blood and Gold'),
    _PreviewTeam('Raja Casablanca', 'Morocco', 'The Greens'),
  ],
  fixtures: [
    _PreviewFixture(
      'Al Ahly',
      'Raja Casablanca',
      'sample club pairing · schedule TBC',
    ),
    _PreviewFixture(
      'Mamelodi Sundowns',
      'Espérance de Tunis',
      'sample club pairing · schedule TBC',
    ),
    _PreviewFixture(
      'Raja Casablanca',
      'Mamelodi Sundowns',
      'sample club pairing · schedule TBC',
    ),
  ],
);

const _confederationPreview = _CompetitionPreview(
  tableNote: 'illustrative club table; not live CAF standings.',
  table: [
    _PreviewStanding('RS Berkane', '4', '3', '1', '0', '10'),
    _PreviewStanding('Zamalek', '4', '2', '1', '1', '7'),
    _PreviewStanding('USM Alger', '4', '1', '1', '2', '4'),
    _PreviewStanding('Simba SC', '4', '0', '1', '3', '1'),
  ],
  players: [
    _PreviewPlayer('Youssef El Fahli', 'RS Berkane', 'Forward', '17'),
    _PreviewPlayer('Ahmed Sayed Zizo', 'Zamalek', 'Forward', '25'),
    _PreviewPlayer('Houssem Ghacha', 'USM Alger', 'Forward', '11'),
    _PreviewPlayer('Clatous Chama', 'Simba SC', 'Midfielder', '17'),
  ],
  teams: [
    _PreviewTeam('RS Berkane', 'Morocco', 'The Orange'),
    _PreviewTeam('Zamalek', 'Egypt', 'The White Knights'),
    _PreviewTeam('USM Alger', 'Algeria', 'The Reds and Blacks'),
    _PreviewTeam('Simba SC', 'Tanzania', 'The Reds'),
  ],
  fixtures: [
    _PreviewFixture(
      'RS Berkane',
      'Zamalek',
      'sample club pairing · schedule TBC',
    ),
    _PreviewFixture(
      'USM Alger',
      'Simba SC',
      'sample club pairing · schedule TBC',
    ),
    _PreviewFixture(
      'Zamalek',
      'Simba SC',
      'sample club pairing · schedule TBC',
    ),
  ],
);

const _womenPreview = _CompetitionPreview(
  tableNote: 'illustrative women’s table; not live competition standings.',
  table: [
    _PreviewStanding('Nigeria', '3', '2', '1', '0', '7'),
    _PreviewStanding('South Africa', '3', '2', '0', '1', '6'),
    _PreviewStanding('Morocco', '3', '1', '1', '1', '4'),
    _PreviewStanding('Zambia', '3', '0', '0', '3', '0'),
  ],
  players: [
    _PreviewPlayer('Asisat Oshoala', 'Nigeria', 'Forward', '8'),
    _PreviewPlayer('Barbra Banda', 'Zambia', 'Forward', '11'),
    _PreviewPlayer('Thembi Kgatlana', 'South Africa', 'Forward', '11'),
    _PreviewPlayer('Racheal Kundananji', 'Zambia', 'Forward', '9'),
  ],
  teams: [
    _PreviewTeam('Nigeria', 'West Africa', 'Super Falcons'),
    _PreviewTeam('South Africa', 'Southern Africa', 'Banyana Banyana'),
    _PreviewTeam('Morocco', 'North Africa', 'Atlas Lionesses'),
    _PreviewTeam('Zambia', 'Southern Africa', 'Copper Queens'),
  ],
  fixtures: [
    _PreviewFixture(
      'Nigeria',
      'South Africa',
      'sample women’s pairing · schedule TBC',
    ),
    _PreviewFixture(
      'Morocco',
      'Zambia',
      'sample women’s pairing · schedule TBC',
    ),
    _PreviewFixture(
      'South Africa',
      'Morocco',
      'sample women’s pairing · schedule TBC',
    ),
  ],
);

class _RegionButton extends StatelessWidget {
  const _RegionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE8F5EC) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF800000)
                  : const Color(0xFF343A40),
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompetitionBrowserScreen extends StatefulWidget {
  const _CompetitionBrowserScreen({
    required this.regions,
    required this.competitionGroups,
  });

  final List<String> regions;
  final Map<String, List<String>> competitionGroups;

  @override
  State<_CompetitionBrowserScreen> createState() =>
      _CompetitionBrowserScreenState();
}

class _CompetitionBrowserScreenState extends State<_CompetitionBrowserScreen> {
  String _selectedRegion = 'Popular';

  @override
  Widget build(BuildContext context) {
    final competitions =
        widget.competitionGroups[_selectedRegion] ?? const <String>[];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E1E),
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Explore competitions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 126,
            child: ColoredBox(
              color: const Color(0xFFF0F1F2),
              child: ListView(
                children: widget.regions
                    .map(
                      (region) => _RegionButton(
                        label: region,
                        selected: _selectedRegion == region,
                        onTap: () => setState(() => _selectedRegion = region),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const VerticalDivider(width: 1, color: Color(0xFFE5E8E9)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                Text(
                  _selectedRegion == 'Popular'
                      ? 'Popular competitions'
                      : '$_selectedRegion competitions',
                  style: const TextStyle(
                    color: Color(0xFF77838B),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 9,
                  runSpacing: 10,
                  children: competitions
                      .map(
                        (competition) => ActionChip(
                          label: Text(competition),
                          backgroundColor: const Color(0xFFF0F1F2),
                          side: BorderSide.none,
                          onPressed: () =>
                              Navigator.of(context).pop(competition),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
