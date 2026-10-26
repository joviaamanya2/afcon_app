import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/pamoja_match_data.dart';
import '../services/afcon_api.dart';

/// Match centre for fixtures, live coverage, results, groups and venue data.
/// Match content is intentionally sourced from an API/CMS before being shown;
/// this screen never presents invented fixtures as official.
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({
    super.key,
    this.initialCategory = 'All',
    this.showBackButton = true,
  });

  final String initialCategory;
  final bool showBackButton;

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    'All',
    'Live',
    'Qualifiers',
    'Fixtures',
    'Results',
    'Groups',
    'Standings',
    'Venues',
    'Stats',
  ];
  late final TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  bool _searching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final requestedIndex = _tabs.indexOf(widget.initialCategory);
    _tabController = TabController(
      length: _tabs.length,
      initialIndex: requestedIndex < 0 ? 0 : requestedIndex,
      vsync: this,
    );
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _shiftDate(int days) =>
      setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search teams, matches or venues',
                  border: InputBorder.none,
                ),
              )
            : const Text('Match centre'),
        leading: widget.showBackButton
            ? IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        actions: [
          IconButton(
            tooltip: _searching ? 'Close search' : 'Search matches',
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) _searchController.clear();
            }),
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
          ),
          const SizedBox(width: 6),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: const Color(0xFF800000),
          unselectedLabelColor: const Color(0xFF666666),
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
          indicator: BoxDecoration(
            color: const Color(0xFFF5E6E6),
            borderRadius: BorderRadius.circular(10),
          ),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: Column(
        children: [
          if (_tabs[_tabController.index] != 'Qualifiers')
            _DateSelector(
              key: const Key('match-date-selector'),
              date: _selectedDate,
              onPrevious: () => _shiftDate(-1),
              onNext: () => _shiftDate(1),
              onToday: () => setState(() => _selectedDate = DateTime.now()),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((category) {
                if (category == 'Qualifiers') {
                  return const _QualifiersContent();
                }
                if (category == 'Groups') {
                  return const _OfficialGroupsContent();
                }
                if (category == 'Stats') {
                  return const _MatchDataScreen(
                    feature: 'Events & stats',
                    showAppBar: false,
                  );
                }
                return _MatchList(category: category, date: _selectedDate);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    super.key,
    required this.date,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });
  final DateTime date;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final label =
        '${_weekday(date.weekday)}, ${date.day} ${_month(date.month)}';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous day',
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${date.year} · SELECTED MATCHDAY',
                  style: const TextStyle(
                    color: Color(0xFF89938D),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .7,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onToday, child: const Text('Today')),
          IconButton(
            tooltip: 'Next day',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _QualifiersContent extends StatefulWidget {
  const _QualifiersContent();

  @override
  State<_QualifiersContent> createState() => _QualifiersContentState();
}

class _QualifiersContentState extends State<_QualifiersContent> {
  final _api = AfconApi();
  late final Future<Map<String, dynamic>> _qualifiers = _api.qualifiers();

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
    future: _qualifiers,
    builder: (context, snapshot) {
      final data = snapshot.data ?? const <String, dynamic>{};
      final tournament = data['tournament'] is Map
          ? (data['tournament'] as Map)['label']?.toString()
          : null;
      final hosts = data['hostCountries'] is List
          ? (data['hostCountries'] as List).join(' / ')
          : 'Kenya / Tanzania / Uganda';

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          const Text(
            'AFCON PAMOJA 2027 qualifiers',
            style: TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Explore the draw pots, qualifying groups and key dates on the road to East Africa.',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QualifierFact(label: '${data['groupCount'] ?? 12} groups'),
              _QualifierFact(label: '${data['finalistCount'] ?? 24} finalists'),
              _QualifierFact(label: '$hosts host'),
            ],
          ),
          const SizedBox(height: 16),
          const _QualifierGraphic(
            title: 'Official draw pots',
            subtitle: 'The teams were placed into four draw pots.',
            asset: 'assets/images/new images/home screen images/afcon-draw-q-potsjpg.webp',
          ),
          const _QualifierGraphic(
            title: 'Qualifying groups',
            subtitle: 'The official draw places 48 teams into 12 groups.',
            asset: 'assets/images/new images/home screen images/afcon_pamoja_q.webp',
          ),
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE6E8EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CAF qualifying windows',
                  style: TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                for (final window in pamojaQualifierWindows) ...[
                  _QualifierDateRow(
                    label: window.matchdays,
                    date: window.dates,
                  ),
                  if (window != pamojaQualifierWindows.last)
                    const SizedBox(height: 9),
                ],
                const SizedBox(height: 9),
                _QualifierDateRow(
                  label: 'Final tournament',
                  date: tournament ?? '19 June-17 July 2027',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _QualificationRulesCard(),
          const SizedBox(height: 10),
          const _SourceAttribution(
            source: 'Source: CAF official qualifying draw and schedule.',
          ),
        ],
      );
    },
  );
}

class _QualifierFact extends StatelessWidget {
  const _QualifierFact({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF5EAEA),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Color(0xFF800000),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _QualifierDateRow extends StatelessWidget {
  const _QualifierDateRow({required this.label, required this.date});

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(
        Icons.calendar_month_rounded,
        size: 17,
        color: Color(0xFF800000),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
        ),
      ),
      Text(
        date,
        style: const TextStyle(
          color: Color(0xFF1E1E1E),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _QualifierGraphic extends StatelessWidget {
  const _QualifierGraphic({
    required this.title,
    required this.subtitle,
    required this.asset,
  });

  final String title;
  final String subtitle;
  final String asset;

  void _openImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _QualifierImageViewer(title: title, asset: asset),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE6E8EB)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
        ),
        const SizedBox(height: 10),
        Material(
          color: const Color(0xFFFFF8DE),
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openImage(context),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Color(0xFF800000),
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.zoom_in_rounded, size: 15, color: Color(0xFF800000)),
            SizedBox(width: 4),
            Text(
              'Tap image to expand',
              style: TextStyle(color: Color(0xFF800000), fontSize: 10),
            ),
          ],
        ),
      ],
    ),
  );
}

class _QualifierImageViewer extends StatelessWidget {
  const _QualifierImageViewer({required this.title, required this.asset});

  final String title;
  final String asset;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1E1E1E),
      title: Text(title),
    ),
    body: Center(
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    ),
  );
}

class _MatchList extends StatefulWidget {
  const _MatchList({required this.category, required this.date});
  final String category;
  final DateTime date;

  @override
  State<_MatchList> createState() => _MatchListState();
}

class _MatchListState extends State<_MatchList> {
  final _api = AfconApi();
  late Future<List<Map<String, dynamic>>> _matches;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  @override
  void didUpdateWidget(covariant _MatchList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category || oldWidget.date != widget.date)
      _loadMatches();
  }

  void _loadMatches() {
    if (widget.category == 'Venues') {
      _matches = _api.venues();
      return;
    }
    if (widget.category == 'Standings') {
      _matches = _loadStandings();
      return;
    }
    final status = switch (widget.category) {
      'Live' => 'live',
      'Fixtures' => 'scheduled',
      'Results' => 'finished',
      _ => null,
    };
    final date = widget.date;
    _matches = _api.matches(
      date:
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      status: status,
    );
  }

  Future<List<Map<String, dynamic>>> _loadStandings() async {
    final competitions = await _api.competitions();
    if (competitions.isEmpty) return const [];
    return _api.standings(competitionId: '${competitions.first['id']}');
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _matches,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              if (category == 'Live') return const _LiveMatchContent();
              if (category == 'All') return const _AllMatchCentreContent();
              return _OfficialDataPreview(category: category);
            }
            final records = snapshot.data ?? const <Map<String, dynamic>>[];
            if (category == 'Live') {
              return _LiveMatchContent(records: records);
            }
            if (category == 'All') {
              return _AllMatchCentreContent(records: records);
            }
            if (records.isEmpty) {
              return _OfficialDataPreview(category: category);
            }
            if (category == 'Venues') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    const _OfficialVenuePreview(),
                    const SizedBox(height: 10),
                    for (final record in records)
                      _BackendVenueCard(record: record),
                  ],
                ),
              );
            }
            if (category == 'Groups' || category == 'Standings') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: records
                      .map((record) => _BackendStandingCard(record: record))
                      .toList(),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: records
                    .map((record) => _BackendMatchCard(record: record))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _OfficialGroupsContent extends StatelessWidget {
  const _OfficialGroupsContent();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
    children: [
      const Text(
        'PAMOJA 2027 qualifying groups',
        style: TextStyle(
          color: Color(0xFF1E1E1E),
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 5),
      const Text(
        'CAF’s published draw: 48 teams across 12 groups. Host nations Kenya, Uganda and Tanzania are already qualified.',
        style: TextStyle(color: Color(0xFF666666), fontSize: 13, height: 1.45),
      ),
      const SizedBox(height: 14),
      for (final group in pamojaGroups) _OfficialGroupCard(group: group),
      const SizedBox(height: 4),
      const _QualificationRulesCard(),
      const SizedBox(height: 10),
      const _SourceAttribution(
        source: 'Source: CAF official PAMOJA 2027 qualifier draw.',
      ),
    ],
  );
}

class _AllMatchCentreContent extends StatelessWidget {
  const _AllMatchCentreContent({this.records = const []});

  final List<Map<String, dynamic>> records;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _MatchCentreSectionTitle('Live video'),
        const SizedBox(height: 9),
        const _LiveVideoCard(),
        if (records.isNotEmpty) ...[
          const SizedBox(height: 18),
          const _MatchCentreSectionTitle('Fixtures and results'),
          const SizedBox(height: 9),
          for (final record in records) _BackendMatchCard(record: record),
        ],
        const SizedBox(height: 20),
        const _MatchCentreSectionTitle('PAMOJA qualifying calendar'),
        const SizedBox(height: 9),
        for (final window in pamojaQualifierWindows)
          _QualifierWindowCard(window: window),
        const _SourceAttribution(
          source: 'Qualifying schedule: CAF official announcement.',
        ),
        const SizedBox(height: 14),
        const _MatchCentreSectionTitle('Qualifiers'),
        const SizedBox(height: 3),
        const _QualifierGraphic(
          title: 'Official draw pots',
          subtitle: 'The 48 teams were placed into four draw pots.',
          asset: 'assets/images/new images/home screen images/afcon-draw-q-potsjpg.webp',
        ),
        const _QualifierGraphic(
          title: 'Qualifying groups',
          subtitle: 'All 12 groups on the road to PAMOJA 2027.',
          asset:
              'assets/images/new images/home screen images/afcon_pamoja_q.webp',
        ),
        const SizedBox(height: 4),
        const _MatchCentreSectionTitle('Groups A–L'),
        const SizedBox(height: 9),
        for (final group in pamojaGroups) _OfficialGroupCard(group: group),
        const SizedBox(height: 4),
        const _MatchCentreSectionTitle('Results and standings'),
        const SizedBox(height: 9),
        const _QualificationRulesCard(),
        const SizedBox(height: 18),
        const _MatchCentreSectionTitle('Host stadiums'),
        const SizedBox(height: 9),
        const _OfficialVenuePreview(),
        const SizedBox(height: 18),
        const _MatchCentreSectionTitle('Stats and tournament format'),
        const SizedBox(height: 9),
        const _TournamentOverview(),
      ],
    ),
  );
}

class _MatchCentreSectionTitle extends StatelessWidget {
  const _MatchCentreSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: Color(0xFF1E1E1E),
      fontSize: 17,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _LiveMatchContent extends StatelessWidget {
  const _LiveMatchContent({this.records = const []});

  final List<Map<String, dynamic>> records;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _LiveVideoCard(),
        const SizedBox(height: 18),
        if (records.isEmpty) ...[
          const _SampleLineupPreview(),
        ] else ...[
          const Text(
            'Live match line-ups',
            style: TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (final record in records) ...[
            _BackendMatchCard(record: record),
            _MatchLineupPanel(record: record),
            const SizedBox(height: 12),
          ],
        ],
      ],
    ),
  );
}

class _LineupPlayer {
  const _LineupPlayer(this.name, this.position, this.number);

  final String name;
  final String position;
  final String number;
}

class _SampleLineupPreview extends StatelessWidget {
  const _SampleLineupPreview();

  static const _ghana = [
    _LineupPlayer('Mohammed Kudus', 'Midfielder', '20'),
    _LineupPlayer('Thomas Partey', 'Midfielder', '5'),
    _LineupPlayer('Jordan Ayew', 'Forward', '9'),
  ];
  static const _uganda = [
    _LineupPlayer('Denis Onyango', 'Goalkeeper', '18'),
    _LineupPlayer('Khalid Aucho', 'Midfielder', '8'),
    _LineupPlayer('Rogers Mato', 'Forward', '17'),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Line-up preview',
        key: Key('live-lineup-preview'),
        style: TextStyle(
          color: Color(0xFF1E1E1E),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Ghana vs Uganda · Sample player preview only; this is not a confirmed fixture or official starting line-up.',
        style: TextStyle(color: Color(0xFF66716B), fontSize: 11, height: 1.45),
      ),
      const SizedBox(height: 10),
      _LineupTeamCard(team: 'Ghana', players: _ghana),
      const SizedBox(height: 8),
      _LineupTeamCard(team: 'Uganda', players: _uganda),
    ],
  );
}

class _LineupTeamCard extends StatelessWidget {
  const _LineupTeamCard({required this.team, required this.players});

  final String team;
  final List<_LineupPlayer> players;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE6EBE7)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          team,
          style: const TextStyle(
            color: Color(0xFF176B46),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        for (final player in players)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    player.number,
                    style: const TextStyle(
                      color: Color(0xFF66716B),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    player.name,
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  player.position,
                  style: const TextStyle(
                    color: Color(0xFF66716B),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _MatchLineupPanel extends StatefulWidget {
  const _MatchLineupPanel({required this.record});

  final Map<String, dynamic> record;

  @override
  State<_MatchLineupPanel> createState() => _MatchLineupPanelState();
}

class _MatchLineupPanelState extends State<_MatchLineupPanel> {
  final _api = AfconApi();
  late final Future<List<Map<String, dynamic>>> _lineups = _api.lineups(
    matchId: '${widget.record['id']}',
  );

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _lineups,
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Map<String, dynamic>>[];
          if (rows.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                'Confirmed line-ups will appear here when available.',
                style: TextStyle(color: Color(0xFF66716B), fontSize: 11),
              ),
            );
          }

          final home = '${widget.record['home_team'] ?? 'Home'}';
          final away = '${widget.record['away_team'] ?? 'Away'}';
          final homeId = '${widget.record['home_team_id'] ?? ''}';
          final awayId = '${widget.record['away_team_id'] ?? ''}';
          final homeRows = rows
              .where(
                (row) =>
                    row['team_name'] == home ||
                    (homeId.isNotEmpty && '${row['team_id']}' == homeId),
              )
              .toList();
          final awayRows = rows
              .where(
                (row) =>
                    row['team_name'] == away ||
                    (awayId.isNotEmpty && '${row['team_id']}' == awayId),
              )
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Line-up · $home vs $away',
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              _PublishedLineupTeam(name: home, players: homeRows),
              const SizedBox(height: 8),
              _PublishedLineupTeam(name: away, players: awayRows),
            ],
          );
        },
      );
}

class _PublishedLineupTeam extends StatelessWidget {
  const _PublishedLineupTeam({
    required this.name,
    required this.players,
    this.emptyMessage = 'Confirmed line-up will appear here when published.',
  });

  final String name;
  final List<Map<String, dynamic>> players;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE6EBE7)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: Color(0xFF176B46),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        if (players.isEmpty)
          Text(
            emptyMessage,
            style: const TextStyle(color: Color(0xFF66716B), fontSize: 11),
          )
        else
          for (final player in players)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      '${player['shirt_number'] ?? '—'}',
                      style: const TextStyle(
                        color: Color(0xFF66716B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${player['player_name'] ?? 'Player'}',
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${player['position'] ?? 'Position TBC'}',
                    style: const TextStyle(
                      color: Color(0xFF66716B),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
      ],
    ),
  );
}

class _LiveVideoCard extends StatelessWidget {
  const _LiveVideoCard();

  static const _videoUrl = 'https://www.youtube.com/watch?v=chuhAI45g70';

  Future<void> _playVideo(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(_videoUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this video.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Material(
    key: const Key('match-live-video-card'),
    color: const Color(0xFF18231D),
    borderRadius: BorderRadius.circular(14),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => _playVideo(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/new images/home screen images/Cafcon.webp',
                  fit: BoxFit.cover,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x22000000), Color(0xAA000000)],
                    ),
                  ),
                ),
                const Center(
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF176B46),
                      size: 38,
                    ),
                  ),
                ),
                const Positioned(left: 12, top: 12, child: _VideoBadge()),
                const Positioned(
                  right: 12,
                  bottom: 11,
                  child: Text(
                    'CAF TV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AFCON Final Highlights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Senegal vs Morocco · AFCON 2025 final',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                SizedBox(height: 7),
                Text(
                  'Watch the key moments from the final. This is a past-match replay, not a live fixture.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _VideoBadge extends StatelessWidget {
  const _VideoBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFF176B46),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
      'HIGHLIGHTS',
      style: TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.7,
      ),
    ),
  );
}

class _OfficialGroupCard extends StatelessWidget {
  const _OfficialGroupCard({required this.group});

  final PamojaGroup group;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE6EBE7)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3ED),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Group ${group.code}',
            style: const TextStyle(
              color: Color(0xFF176B46),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final team in group.teams)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    team,
                    style: const TextStyle(
                      color: Color(0xFF303A34),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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

class _QualificationRulesCard extends StatelessWidget {
  const _QualificationRulesCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE6EBE7)),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qualification format',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Teams play home and away across six matchdays. Normally, the top two in each group qualify. In Groups D, H and L, only the highest-ranked non-host qualifies because Kenya, Uganda and Tanzania qualify automatically as hosts.',
          style: TextStyle(color: Color(0xFF5D6962), fontSize: 12, height: 1.5),
        ),
      ],
    ),
  );
}

class _SourceAttribution extends StatelessWidget {
  const _SourceAttribution({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      source,
      style: const TextStyle(color: Color(0xFF66716B), fontSize: 11),
    ),
  );
}

class _OfficialDataPreview extends StatelessWidget {
  const _OfficialDataPreview({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    if (category == 'Live') {
      return const _LiveMatchContent();
    }
    if (category == 'Results') {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QualificationRulesCard(),
          _SourceAttribution(
            source:
                'Competition format: CAF PAMOJA 2027 qualifier announcement.',
          ),
        ],
      );
    }
    if (category == 'Standings') {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QualificationRulesCard(),
          _SourceAttribution(
            source: 'Group structure and qualification rules: CAF.',
          ),
        ],
      );
    }
    if (category == 'Venues') {
      return const _OfficialVenuePreview();
    }
    if (category != 'All' && category != 'Fixtures') {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TournamentOverview(),
          _SourceAttribution(
            source:
                'Tournament format: CAF PAMOJA 2027 qualifier announcement.',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _MatchStatusMessage(
          icon: Icons.event_note_rounded,
          title: 'Official qualifying windows',
          message: 'CAF has published the international windows. These are date ranges, not confirmed individual fixtures.',
        ),
        for (final window in pamojaQualifierWindows)
          _QualifierWindowCard(window: window),
        const _SourceAttribution(
          source: 'Schedule source: CAF official qualifier announcement.',
        ),
      ],
    );
  }
}

class _QualifierWindowCard extends StatelessWidget {
  const _QualifierWindowCard({required this.window});

  final PamojaQualifierWindow window;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE6EBE7)),
    ),
    child: Row(
      children: [
        const Icon(Icons.calendar_month_rounded, color: Color(0xFF176B46)),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                window.matchdays,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                window.dates,
                style: const TextStyle(color: Color(0xFF66716B), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _OfficialVenuePreview extends StatelessWidget {
  const _OfficialVenuePreview();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Stadiums across the three host countries',
        style: TextStyle(color: Color(0xFF66716B), fontSize: 12, height: 1.4),
      ),
      const SizedBox(height: 10),
      const _VenueDetailsCard(
        title: 'Akii-Bua Olympic Stadium',
        location: 'Lira City, Uganda',
        detail: 'One of three national stadiums presented to CAF. Planned capacity: 20,000 upon completion.',
      ),
      const SizedBox(height: 10),
      const _VenueImageCard(
        title: 'Benjamin Mkapa Stadium',
        location: 'Dar es Salaam, Tanzania',
        detail: 'Stadium spotlight from a PAMOJA host country. Match allocation details are not shown.',
        asset: 'assets/images/new images/home screen images/benjamin-mkapa-stadium_ok.webp',
        imageLabel: 'Benjamin Mkapa Stadium',
      ),
      const SizedBox(height: 10),
      const _VenueImageCard(
        title: 'Mandela National Stadium',
        location: 'Kampala, Uganda',
        detail: 'Stadium spotlight from a PAMOJA host country. Match allocation details are not shown.',
        asset: 'assets/images/new images/mandela stadium.PNG',
        imageLabel: 'Mandela National Stadium',
      ),
      const _SourceAttribution(
        source: 'Akii-Bua profile: PAMOJA publication. Other photos are host-country stadium spotlights.',
      ),
    ],
  );
}

class _VenueDetailsCard extends StatelessWidget {
  const _VenueDetailsCard({
    required this.title,
    required this.location,
    required this.detail,
  });

  final String title;
  final String location;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE6EBE7)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          location,
          style: const TextStyle(
            color: Color(0xFF176B46),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          detail,
          style: const TextStyle(
            color: Color(0xFF66716B),
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

class _VenueImageCard extends StatelessWidget {
  const _VenueImageCard({
    required this.title,
    required this.location,
    required this.detail,
    required this.asset,
    required this.imageLabel,
  });

  final String title;
  final String location;
  final String detail;
  final String asset;
  final String imageLabel;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE6EBE7)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 8,
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            semanticLabel: imageLabel,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: const TextStyle(
                  color: Color(0xFF176B46),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                detail,
                style: const TextStyle(
                  color: Color(0xFF66716B),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TournamentOverview extends StatelessWidget {
  const _TournamentOverview();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE6EBE7)),
    ),
    child: const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _QualifierFact(label: '48 qualifying teams'),
        _QualifierFact(label: '12 groups'),
        _QualifierFact(label: '6 matchdays'),
        _QualifierFact(label: '24 finalists'),
        _QualifierFact(label: '3 co-hosts'),
      ],
    ),
  );
}

class _BackendStandingCard extends StatelessWidget {
  const _BackendStandingCard({required this.record});
  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE6EBE7)),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '${record['position'] ?? '—'}',
            style: const TextStyle(
              color: Color(0xFF800000),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${record['team_name'] ?? record['team_id'] ?? 'Team'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Group ${record['group_code'] ?? '—'} · P ${record['played'] ?? 0} · W ${record['won'] ?? 0} · D ${record['drawn'] ?? 0} · L ${record['lost'] ?? 0}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
        Text(
          '${record['points'] ?? 0} pts',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF800000),
          ),
        ),
      ],
    ),
  );
}

class _BackendVenueCard extends StatelessWidget {
  const _BackendVenueCard({required this.record});
  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE6EBE7)),
    ),
    child: Row(
      children: [
        const Icon(Icons.stadium_rounded, color: Color(0xFF800000)),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${record['name'] ?? 'Stadium'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${record['city'] ?? ''}${record['country'] == null ? '' : ', ${record['country']}'}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
        if (record['capacity'] != null)
          Text(
            '${record['capacity']}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
      ],
    ),
  );
}

class _MatchStatusMessage extends StatelessWidget {
  const _MatchStatusMessage({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF800000)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(
                message,
                style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BackendMatchCard extends StatelessWidget {
  const _BackendMatchCard({required this.record, this.interactive = true});

  final Map<String, dynamic> record;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final kickoff = DateTime.tryParse('${record['kickoff_at'] ?? ''}')
        ?.toLocal();
    final status = '${record['status'] ?? 'scheduled'}'.replaceAll('_', ' ');
    final homeScore = record['home_score'];
    final awayScore = record['away_score'];
    final hasScore = homeScore != null && awayScore != null;
    final kickoffLabel = kickoff == null
        ? 'Kick-off time TBC'
        : '${_weekday(kickoff.weekday)}, ${kickoff.day} ${_month(kickoff.month)} · ${kickoff.hour.toString().padLeft(2, '0')}:${kickoff.minute.toString().padLeft(2, '0')}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('match-card-${record['id']}'),
        onTap: interactive
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MatchDetailsScreen(record: record),
                ),
              )
            : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE6EBE7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${record['competition_name'] ?? 'AFCON'} · ${record['stage'] ?? record['group_code'] ?? ''}',
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: status == 'live'
                          ? const Color(0xFFCC3E32)
                          : const Color(0xFF800000),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${record['home_team'] ?? 'Home'}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    hasScore ? '$homeScore  -  $awayScore' : 'VS',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF800000),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${record['away_team'] ?? 'Away'}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                '$kickoffLabel${record['venue_name'] == null ? '' : ' · ${record['venue_name']}'}',
                style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchDetailsScreen extends StatefulWidget {
  const MatchDetailsScreen({super.key, required this.record});

  final Map<String, dynamic> record;

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final _api = AfconApi();
  late final Future<List<Map<String, dynamic>>> _lineups = _api.lineups(
    matchId: '${widget.record['id']}',
  );

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final home = '${record['home_team'] ?? 'Home'}';
    final away = '${record['away_team'] ?? 'Away'}';
    final kickoff = DateTime.tryParse('${record['kickoff_at'] ?? ''}')
        ?.toLocal();
    final kickoffLabel = kickoff == null
        ? 'Kick-off time to be confirmed'
        : '${_weekday(kickoff.weekday)}, ${kickoff.day} ${_month(kickoff.month)} · ${kickoff.hour.toString().padLeft(2, '0')}:${kickoff.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Match details'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BackendMatchCard(record: record, interactive: false),
          const SizedBox(height: 8),
          Text(
            '${record['competition_name'] ?? 'AFCON'} · ${record['stage'] ?? record['group_code'] ?? 'Match'}',
            style: const TextStyle(
              color: Color(0xFF66716B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$kickoffLabel${record['venue_name'] == null ? '' : ' · ${record['venue_name']}'}',
            style: const TextStyle(color: Color(0xFF66716B), fontSize: 11),
          ),
          const SizedBox(height: 22),
          Text(
            'Line-up · $home vs $away',
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _lineups,
            builder: (context, snapshot) {
              final rows = snapshot.data ?? const <Map<String, dynamic>>[];
              final homeId = '${record['home_team_id'] ?? ''}';
              final awayId = '${record['away_team_id'] ?? ''}';
              final homeRows = rows
                  .where(
                    (row) =>
                        row['team_name'] == home ||
                        (homeId.isNotEmpty && '${row['team_id']}' == homeId),
                  )
                  .toList();
              final awayRows = rows
                  .where(
                    (row) =>
                        row['team_name'] == away ||
                        (awayId.isNotEmpty && '${row['team_id']}' == awayId),
                  )
                  .toList();
              return Column(
                children: [
                  _PublishedLineupTeam(
                    name: home,
                    players: homeRows,
                    emptyMessage:
                        snapshot.connectionState == ConnectionState.waiting
                        ? 'Loading confirmed line-up…'
                        : 'Confirmed line-up will appear here when published.',
                  ),
                  const SizedBox(height: 10),
                  _PublishedLineupTeam(
                    name: away,
                    players: awayRows,
                    emptyMessage:
                        snapshot.connectionState == ConnectionState.waiting
                        ? 'Loading confirmed line-up…'
                        : 'Confirmed line-up will appear here when published.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Opens published match events and statistics from the Home match centre.
class MatchStatsScreen extends StatelessWidget {
  const MatchStatsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const _MatchDataScreen(feature: 'Events & stats');
}

class _MatchDataScreen extends StatefulWidget {
  const _MatchDataScreen({required this.feature, this.showAppBar = true});
  final String feature;
  final bool showAppBar;

  @override
  State<_MatchDataScreen> createState() => _MatchDataScreenState();
}

class _MatchDataScreenState extends State<_MatchDataScreen> {
  final _api = AfconApi();
  late final Future<List<Map<String, dynamic>>> _matches = _api.matches();
  String? _selectedMatchId;

  bool get _isLineup => feature == 'Line-ups';

  String get feature => widget.feature;

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Widget _matchRecords(
    String matchId, {
    required bool lineups,
  }) => FutureBuilder<List<Map<String, dynamic>>>(
    future: lineups
        ? _api.lineups(matchId: matchId)
        : _api.matchEvents(matchId: matchId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting)
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );
      if (snapshot.hasError) return const _TournamentOverview();
      final rows = snapshot.data ?? const <Map<String, dynamic>>[];
      if (rows.isEmpty) return const _TournamentOverview();
      return Column(
        children: rows.map((row) {
          final title = lineups
              ? '${row['player_name'] ?? row['player_id'] ?? 'Player'}'
              : '${row['event_type'] ?? 'Event'} · ${row['minute'] ?? 0}\'';
          final subtitle = lineups
              ? '${row['position'] ?? 'Position TBC'} · ${row['is_starting'] == true ? 'Starting XI' : 'Substitute'} · #${row['shirt_number'] ?? '—'}'
              : '${row['team_name'] ?? 'Match event'}${row['player_name'] == null ? '' : ' · ${row['player_name']}'}${row['detail'] == null ? '' : ' · ${row['detail']}'}';
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF5E6E6),
              child: Icon(
                lineups ? Icons.person_rounded : Icons.sports_soccer_rounded,
                color: const Color(0xFF800000),
                size: 19,
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          );
        }).toList(),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: widget.showAppBar ? AppBar(title: Text(feature)) : null,
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _matches,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: CircularProgressIndicator(),
                  ),
                );
              if (snapshot.hasError)
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TournamentOverview(),
                    SizedBox(height: 8),
                    _QualificationRulesCard(),
                    _SourceAttribution(
                      source:
                          'Tournament format: CAF PAMOJA 2027 announcement.',
                    ),
                  ],
                );
              final matches = snapshot.data ?? const <Map<String, dynamic>>[];
              if (matches.isEmpty)
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TournamentOverview(),
                    SizedBox(height: 8),
                    _QualificationRulesCard(),
                    _SourceAttribution(
                      source:
                          'Tournament format: CAF PAMOJA 2027 announcement.',
                    ),
                  ],
                );
              final matchId = _selectedMatchId ?? '${matches.first['id']}';
              final selected = matches
                  .where((match) => '${match['id']}' == matchId)
                  .toList();
              final match = selected.isNotEmpty
                  ? selected.first
                  : matches.first;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: '${match['id']}',
                    decoration: const InputDecoration(
                      labelText: 'Select a published match',
                      border: OutlineInputBorder(),
                    ),
                    items: matches
                        .map(
                          (item) => DropdownMenuItem(
                            value: '${item['id']}',
                            child: Text(
                              '${item['home_team'] ?? 'Home'} vs ${item['away_team'] ?? 'Away'}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedMatchId = value),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isLineup ? 'PUBLISHED LINE-UP' : 'PUBLISHED MATCH EVENTS',
                    style: const TextStyle(
                      color: Color(0xFF89938D),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .9,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _matchRecords('${match['id']}', lineups: _isLineup),
                  ),
                  if (!_isLineup) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'MATCH STATISTICS',
                      style: TextStyle(
                        color: Color(0xFF89938D),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .9,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _matchStatistics('${match['id']}'),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _matchStatistics(
    String matchId,
  ) => FutureBuilder<List<Map<String, dynamic>>>(
    future: _api.matchStatistics(matchId: matchId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting)
        return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return const _TournamentOverview();
      final rows = snapshot.data ?? const <Map<String, dynamic>>[];
      if (rows.isEmpty) return const _TournamentOverview();
      return Column(
        children: rows
            .map(
              (row) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${row['statistic'] ?? 'Statistic'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: Text(
                  '${row['home_value'] ?? '—'}  :  ${row['away_value'] ?? '—'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF800000),
                  ),
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

String _weekday(int day) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];
String _month(int month) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month - 1];
