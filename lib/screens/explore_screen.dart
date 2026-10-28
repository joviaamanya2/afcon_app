import 'dart:async';

import 'package:flutter/material.dart';

import '../data/caf_pamoja_data.dart';
import '../data/pamoja_match_data.dart';
import '../services/afcon_api.dart';
import 'teams_players_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.isActive = false});

  final bool isActive;

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
                _GroupsContent(
                  isActive:
                      widget.isActive &&
                      _topTabs[_topTabController.index] == 'Groups',
                ),
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
  const _GroupsContent({required this.isActive});

  final bool isActive;

  @override
  State<_GroupsContent> createState() => _GroupsContentState();
}

class _GroupsContentState extends State<_GroupsContent>
    with WidgetsBindingObserver {
  final _api = AfconApi();
  late Future<List<Map<String, dynamic>>> _standings;
  Timer? _refreshTimer;
  bool _appResumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _standings = _loadStandings();
    _syncRefreshTimer();
  }

  @override
  void didUpdateWidget(covariant _GroupsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _syncRefreshTimer();
      if (widget.isActive && _appResumed) _refreshStandings();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    _syncRefreshTimer();
    if (_appResumed && widget.isActive) _refreshStandings();
  }

  void _syncRefreshTimer() {
    _refreshTimer?.cancel();
    if (!widget.isActive || !_appResumed) return;
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshStandings(),
    );
  }

  void _refreshStandings() {
    if (!mounted || !widget.isActive || !_appResumed) return;
    setState(() => _standings = _loadStandings());
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _api.close();
    super.dispose();
  }
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
    final normalizedLeague = league.toLowerCase();
    final isAfcon =
        normalizedLeague == 'afcon' ||
        normalizedLeague == 'africa cup of nations';
    final hasCurrentAfconData = isAfcon && season == '2026/27';
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFFF5E6E6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            hasCurrentAfconData
                ? '$league · $season · CAF QUALIFIER DATA · updated 6 Oct 2026'
                : '$league · $season · NO VERIFIED DATA',
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
              if (hasCurrentAfconData) ...[
                const _QualifierGroupsContent(),
                const TeamsPlayersScreen(showAppBar: false, showHeader: false),
                const TeamsPlayersScreen(showAppBar: false, showHeader: false),
                const _AfconUpcomingFixturesContent(),
              ] else if (isAfcon) ...[
                const _AfconHistoricalSeasonAvailability(),
                const _AfconHistoricalSeasonAvailability(),
                const _AfconHistoricalSeasonAvailability(),
                const _AfconHistoricalSeasonAvailability(),
              ] else ...[
                _CompetitionDataUnavailable(
                  competition: league,
                  season: season,
                ),
                _CompetitionDataUnavailable(
                  competition: league,
                  season: season,
                ),
                _CompetitionDataUnavailable(
                  competition: league,
                  season: season,
                ),
                _CompetitionDataUnavailable(
                  competition: league,
                  season: season,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AfconHistoricalSeasonAvailability extends StatelessWidget {
  const _AfconHistoricalSeasonAvailability();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Verified CAF qualifier data is available for 2026/27 only. No official records for this season are included.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF666666), height: 1.5),
      ),
    ),
  );
}

class _CompetitionDataUnavailable extends StatelessWidget {
  const _CompetitionDataUnavailable({
    required this.competition,
    required this.season,
  });

  final String competition;
  final String season;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const Icon(Icons.cloud_off_rounded, color: Color(0xFF800000), size: 36),
      const SizedBox(height: 12),
      Text(
        '$competition · $season',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF1E1E1E),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Verified competition data is not connected. Standings, squads and fixtures are withheld until an official source is available.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF666666), height: 1.5),
      ),
    ],
  );
}

class _AfconUpcomingFixturesContent extends StatelessWidget {
  const _AfconUpcomingFixturesContent();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
    children: [
      const _ExploreSectionHeading(
        eyebrow: 'CAF QUALIFIER FIXTURES',
        title: 'Matchday 3',
        description: 'CAF lists these pairings for 9–17 November 2026. Exact match dates, kick-off times and stadiums have not yet been announced.',
      ),
      const SizedBox(height: 12),
      for (final fixture in cafAfcon2027UpcomingFixtures)
        _AfconFixtureCard(fixture: fixture),
      const _ExploreSourceAttribution(
        source: 'Source: CAF AFCON PAMOJA 2027 qualifier coverage.',
      ),
    ],
  );
}

class _AfconFixtureCard extends StatelessWidget {
  const _AfconFixtureCard({required this.fixture});

  final CafQualifierMatch fixture;

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
        Row(
          children: [
            Expanded(
              child: Text(
                fixture.home,
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
                fixture.away,
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
          'Group ${fixture.group} · ${fixture.dateLabel}',
          style: const TextStyle(color: Color(0xFF666666), fontSize: 10),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kick-off: To be confirmed · Stadium: To be confirmed',
          style: TextStyle(color: Color(0xFF666666), fontSize: 10),
        ),
      ],
    ),
  );
}

class _ExploreSourceAttribution extends StatelessWidget {
  const _ExploreSourceAttribution({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      source,
      style: const TextStyle(color: Color(0xFF666666), fontSize: 10),
    ),
  );
}

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
