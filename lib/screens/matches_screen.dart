import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/caf_pamoja_data.dart';
import '../data/pamoja_match_data.dart';
import '../services/afcon_api.dart';
import 'pamoja_qualifiers_screen.dart';

/// Match centre for fixtures, live coverage, results, groups and venue data.
/// Match content comes from the API or a clearly attributed historical archive;
/// this screen never presents invented fixtures as official.
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({
    super.key,
    this.initialCategory = 'All',
    this.showBackButton = true,
    this.isActive = false,
  });

  final String initialCategory;
  final bool showBackButton;
  final bool isActive;

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
    'Matches',
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
                  return _MatchDataScreen(
                    feature: 'Events & stats',
                    showAppBar: false,
                    isActive:
                        widget.isActive &&
                        _tabs[_tabController.index] == category,
                  );
                }
                return _MatchList(
                  category: category,
                  date: _selectedDate,
                  isActive:
                      widget.isActive &&
                      _tabs[_tabController.index] == category,
                );
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
        builder: (_) => PamojaQualifiersScreen(
          initialView: title.toLowerCase().contains('pot')
              ? 'Draw Pots'
              : 'Groups',
        ),
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
            key: Key('qualifier-graphic-$asset'),
            onTap: () => _openImage(context),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                semanticLabel:
                    '$title. Tap to explore the groups, draw pots and table.',
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
              'Tap image to explore groups and draw pots',
              style: TextStyle(color: Color(0xFF800000), fontSize: 10),
            ),
          ],
        ),
      ],
    ),
  );
}

class _MatchList extends StatefulWidget {
  const _MatchList({
    required this.category,
    required this.date,
    required this.isActive,
  });
  final String category;
  final DateTime date;
  final bool isActive;

  @override
  State<_MatchList> createState() => _MatchListState();
}

class _MatchListState extends State<_MatchList> with WidgetsBindingObserver {
  final _api = AfconApi();
  late Future<List<Map<String, dynamic>>> _matches;
  Timer? _refreshTimer;
  bool _appResumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMatches();
    _syncRefreshTimer();
  }

  @override
  void didUpdateWidget(covariant _MatchList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category ||
        oldWidget.date != widget.date) {
      _loadMatches();
    }
    if (oldWidget.isActive != widget.isActive) {
      _syncRefreshTimer();
      if (widget.isActive && _appResumed) _refreshMatches();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    _syncRefreshTimer();
    if (_appResumed && widget.isActive) _refreshMatches();
  }

  void _syncRefreshTimer() {
    _refreshTimer?.cancel();
    if (!widget.isActive || !_appResumed) return;
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshMatches(),
    );
  }

  void _refreshMatches() {
    if (!mounted || !widget.isActive || !_appResumed) return;
    setState(_loadMatches);
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
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 12),
                  _OfficialDataPreview(category: category),
                ],
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
            if (category == 'Matches') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _MatchStatusMessage(
                      icon: Icons.sports_soccer_rounded,
                      title: 'Upcoming, live and completed matches',
                      message: 'Fixtures are games scheduled to take place. Matches include games that are upcoming, in progress or finished.',
                    ),
                    for (final record in records)
                      _BackendMatchCard(record: record),
                  ],
                ),
              );
            }
            if (category == 'Fixtures') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _MatchStatusMessage(
                      icon: Icons.event_note_rounded,
                      title: 'Published fixtures',
                      message: 'Showing fixtures from the match feed. Preview pairings appear when no published fixtures are available.',
                    ),
                    for (final record in records)
                      _BackendMatchCard(record: record),
                  ],
                ),
              );
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
        const SizedBox(height: 18),
        const _CafQualifierResults(),
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
          const _MatchStatusMessage(
            icon: Icons.sensors_off_rounded,
            title: 'No live AFCON qualifier matches',
            message: 'CAF has not published a live match for this matchday. Matchday 3 qualifiers are scheduled in the 9–17 November 2026 window.',
          ),
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
              _PublishedLineupTeam(
                name: home,
                players: homeRows,
                matchRecord: widget.record,
                opponentName: away,
                isHome: true,
              ),
              const SizedBox(height: 12),
              _PublishedLineupTeam(
                name: away,
                players: awayRows,
                matchRecord: widget.record,
                opponentName: home,
                isHome: false,
              ),
            ],
          );
        },
      );
}

int _horizontalPositionRank(String position) {
  final pos = position.toUpperCase().trim();
  switch (pos) {
    case 'LB':
    case 'LWB':
      return 10;
    case 'LM':
    case 'LAM':
      return 20;
    case 'LW':
    case 'LF':
      return 25;
    case 'LCB':
      return 35;
    case 'LDM':
    case 'LCM':
      return 40;
    case 'GK':
    case 'GOALKEEPER':
    case 'CB':
    case 'DM':
    case 'CM':
    case 'AM':
    case 'CF':
    case 'ST':
    case 'FW':
      return 50;
    case 'RCM':
    case 'RDM':
      return 60;
    case 'RCB':
      return 65;
    case 'RM':
    case 'RAM':
      return 75;
    case 'RW':
    case 'RF':
      return 80;
    case 'RB':
    case 'RWB':
      return 90;
    default:
      return 50;
  }
}

List<Map<String, dynamic>> _sortPitchLine(List<Map<String, dynamic>> linePlayers) {
  final sorted = List<Map<String, dynamic>>.from(linePlayers);
  sorted.sort((a, b) {
    final rankA = _horizontalPositionRank('${a['position'] ?? ''}');
    final rankB = _horizontalPositionRank('${b['position'] ?? ''}');
    return rankA.compareTo(rankB);
  });
  return sorted;
}

class _FootballPitchPainter extends CustomPainter {
  const _FootballPitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Alternating lawn mower stripes
    const stripeCount = 10;
    final stripeHeight = size.height / stripeCount;
    final stripePaintA = Paint()..color = const Color(0xFF1B6137);
    final stripePaintB = Paint()..color = const Color(0xFF227242);

    for (int i = 0; i < stripeCount; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
        i.isEven ? stripePaintA : stripePaintB,
      );
    }

    // 2. Stadium floodlight top glow
    final glowPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -1.0),
        radius: 0.85,
        colors: [Color(0x38FFFFFF), Color(0x001B6137)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // 3. Pitch boundary with margin
    const margin = 8.0;
    final pitchRect = Rect.fromLTWH(
      margin,
      margin,
      size.width - margin * 2,
      size.height - margin * 2,
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawRect(pitchRect, linePaint);

    // Halfway line across the top
    final halfY = pitchRect.top + 1.0;
    canvas.drawLine(
      Offset(pitchRect.left, halfY),
      Offset(pitchRect.right, halfY),
      linePaint,
    );

    // Center circle at halfway line
    final centerCircleRadius = size.width * 0.16;
    canvas.drawCircle(
      Offset(size.width / 2, halfY),
      centerCircleRadius,
      linePaint,
    );
    final spotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, halfY), 3.0, spotPaint);

    // 18-yard penalty box at bottom
    final penaltyBoxWidth = pitchRect.width * 0.64;
    final penaltyBoxHeight = pitchRect.height * 0.22;
    final penaltyBoxLeft = (size.width - penaltyBoxWidth) / 2;
    final penaltyBoxTop = pitchRect.bottom - penaltyBoxHeight;
    final penaltyRect = Rect.fromLTWH(
      penaltyBoxLeft,
      penaltyBoxTop,
      penaltyBoxWidth,
      penaltyBoxHeight,
    );
    canvas.drawRect(penaltyRect, linePaint);

    // 6-yard goal area
    final goalAreaWidth = pitchRect.width * 0.32;
    final goalAreaHeight = penaltyBoxHeight * 0.42;
    final goalAreaLeft = (size.width - goalAreaWidth) / 2;
    final goalAreaTop = pitchRect.bottom - goalAreaHeight;
    canvas.drawRect(
      Rect.fromLTWH(goalAreaLeft, goalAreaTop, goalAreaWidth, goalAreaHeight),
      linePaint,
    );

    // Penalty spot
    final penaltySpotY = pitchRect.bottom - penaltyBoxHeight * 0.65;
    canvas.drawCircle(Offset(size.width / 2, penaltySpotY), 3.0, spotPaint);

    // Penalty arc (D arc on top of 18-yard box)
    final arcRadius = size.width * 0.14;
    final arcRect = Rect.fromCircle(
      center: Offset(size.width / 2, penaltySpotY),
      radius: arcRadius,
    );
    canvas.drawArc(
      arcRect,
      3.14159 + 0.65,
      3.14159 - 1.30,
      false,
      linePaint,
    );

    // Goal mouth net line at bottom
    final goalWidth = goalAreaWidth * 0.65;
    final goalLeft = (size.width - goalWidth) / 2;
    canvas.drawLine(
      Offset(goalLeft, pitchRect.bottom),
      Offset(goalLeft + goalWidth, pitchRect.bottom),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

typedef PublishedLineupTeamView = _PublishedLineupTeam;

class _PublishedLineupTeam extends StatelessWidget {
  const _PublishedLineupTeam({
    required this.name,
    required this.players,
    this.emptyMessage = 'Confirmed line-up will appear here when published.',
    this.matchRecord,
    this.opponentName,
    this.isHome = true,
  });

  final String name;
  final List<Map<String, dynamic>> players;
  final String emptyMessage;
  final Map<String, dynamic>? matchRecord;
  final String? opponentName;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final starters = players
        .where((player) => player['is_starting'] == true)
        .toList();
    final substitutes = players
        .where((player) => player['is_starting'] != true)
        .toList();
    final formation = players.isEmpty
        ? ''
        : '${players.first['formation'] ?? ''}';

    // Group starters into tactical lines and sort left-to-right
    final attackLine = _sortPitchLine(
      starters.where((p) => _lineupPositionGroup(p, formation) == 'attack').toList(),
    );
    final advancedLine = _sortPitchLine(
      starters.where((p) => _lineupPositionGroup(p, formation) == 'advanced').toList(),
    );
    final midfieldLine = _sortPitchLine(
      starters.where((p) => _lineupPositionGroup(p, formation) == 'midfield').toList(),
    );
    final defenceLine = _sortPitchLine(
      starters.where((p) => _lineupPositionGroup(p, formation) == 'defence').toList(),
    );
    final gkLine = _sortPitchLine(
      starters.where((p) => _lineupPositionGroup(p, formation) == 'goalkeeper').toList(),
    );

    final lines = [
      attackLine,
      advancedLine,
      midfieldLine,
      defenceLine,
      gkLine,
    ].where((line) => line.isNotEmpty).toList();

    // Match info metadata
    final stage = '${matchRecord?['stage'] ?? matchRecord?['competition_name'] ?? 'AFCON QUALIFIERS'}'.toUpperCase();
    final venue = '${matchRecord?['venue_name'] ?? 'STADIUM VENUE'}'.toUpperCase();
    final kickoffRaw = '${matchRecord?['kickoff_at'] ?? ''}';
    final kickoff = _formatKickoff(kickoffRaw);

    final homeTeamName = '${matchRecord?['home_team'] ?? (isHome ? name : (opponentName ?? 'Home'))}';
    final awayTeamName = '${matchRecord?['away_team'] ?? (isHome ? (opponentName ?? 'Away') : name)}';
    final homeCrest = '${matchRecord?['home_crest_url'] ?? ''}'.trim();
    final awayCrest = '${matchRecord?['away_crest_url'] ?? ''}'.trim();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1110),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2B25)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Broadcast Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF18231E), Color(0xFF0D1512)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(
                bottom: BorderSide(color: Color(0xFF23332A), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                // Team Matchup (Crests/Badges with VS)
                Expanded(
                  child: Row(
                    children: [
                      _teamBadge(homeTeamName, homeCrest),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: Color(0xFFE63946),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      _teamBadge(awayTeamName, awayCrest),
                    ],
                  ),
                ),
                // Center Title: CONFIRMED LINEUP
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'CONFIRMED LINEUP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF9BE0B7),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // Right AFCON Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB91C1C),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text(
                    'AFCON',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Pitch or Empty Message
          if (players.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  emptyMessage,
                  style: const TextStyle(color: Color(0xFF8C9B92), fontSize: 11),
                ),
              ),
            )
          else ...[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: AspectRatio(
                  aspectRatio: 0.70,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B6137),
                    ),
                    child: Stack(
                      children: [
                        // Pitch markings background
                        const Positioned.fill(
                          child: CustomPaint(
                            painter: _FootballPitchPainter(),
                          ),
                        ),

                        // Match Info Badge on Top-Left (matching reference image)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xEE0C1012),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 2.5,
                                  width: 24,
                                  color: const Color(0xFFD3202F),
                                  margin: const EdgeInsets.only(bottom: 2),
                                ),
                                Text(
                                  stage,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 7,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Text(
                                  kickoff,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  venue,
                                  style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 7,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Formation Badge on Bottom-Left (matching reference image)
                        if (formation.isNotEmpty)
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFA81C27), Color(0xFF6D0F17)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.white30),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black87,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'FORMATION',
                                    style: TextStyle(
                                      color: Color(0xFFFEE2E2),
                                      fontSize: 7,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Text(
                                    formation,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Starting XI Players arranged on pitch
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (final line in lines)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      for (final player in line)
                                        _LineupPitchPlayer(player: player),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Substitutes Bench
            if (substitutes.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF0E1412),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(13)),
                  border: Border(
                    top: BorderSide(color: Color(0xFF1C2621), width: 1.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'SUBSTITUTES',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '(${substitutes.length} players)',
                          style: const TextStyle(
                            color: Color(0xFF84938B),
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final player in substitutes)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF19241F),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF283A31)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (player['shirt_number'] != null) ...[
                                  Text(
                                    '#${player['shirt_number']}',
                                    style: const TextStyle(
                                      color: Color(0xFFF87171),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  '${player['player_name'] ?? 'Player'}',
                                  style: const TextStyle(
                                    color: Color(0xFFD0DBD4),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (player['position'] != null && '${player['position']}'.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${player['position']})',
                                    style: const TextStyle(
                                      color: Color(0xFF8FA096),
                                      fontSize: 8.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _teamBadge(String teamName, String crestUrl) {
    if (crestUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          crestUrl,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _textBadge(teamName),
        ),
      );
    }
    return _textBadge(teamName);
  }

  Widget _textBadge(String teamName) {
    final initials = teamName.length >= 3 ? teamName.substring(0, 3).toUpperCase() : teamName.toUpperCase();
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF26382F),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFFA4F4C5),
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  static String _formatKickoff(String iso) {
    if (iso.isEmpty) return 'MATCHDAY';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return 'TODAY $hour:$minute $ampm';
    } catch (_) {
      return 'MATCHDAY';
    }
  }
}

String _lineupPositionGroup(
  Map<String, dynamic> player,
  String formation,
) {
  final position = '${player['position'] ?? ''}'.trim().toUpperCase();
  if (['GK', 'GOALKEEPER'].contains(position)) return 'goalkeeper';
  if (['RB', 'LB', 'CB', 'RWB', 'LWB', 'DEF', 'DEFENDER'].contains(position)) {
    return 'defence';
  }
  if ([
    'ST',
    'CF',
    'FW',
    'RF',
    'LF',
    'FORWARD',
    'STRIKER',
  ].contains(position)) {
    return 'attack';
  }
  if (['4-2-3-1', '4-1-4-1'].contains(formation) &&
      ['AM', 'RM', 'LM', 'RW', 'LW'].contains(position)) {
    return 'advanced';
  }
  if (formation == '3-5-2' && ['RW', 'LW', 'RM', 'LM'].contains(position)) {
    return 'midfield';
  }
  if (['RW', 'LW'].contains(position)) return 'attack';
  return 'midfield';
}

class _LineupPitchPlayer extends StatelessWidget {
  const _LineupPitchPlayer({required this.player});

  final Map<String, dynamic> player;

  @override
  Widget build(BuildContext context) {
    final imageUrl = '${player['photo_url'] ?? ''}'.trim();
    final playerName = '${player['player_name'] ?? 'Player'}'.trim();
    final shirtNumber = player['shirt_number'] == null
        ? ''
        : '${player['shirt_number']}';
    final position = '${player['position'] ?? ''}'.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player avatar/cutout
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF16251E),
                  border: Border.all(color: Colors.white, width: 1.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _playerInitialAvatar(playerName, shirtNumber),
                        )
                      : _playerInitialAvatar(playerName, shirtNumber),
                ),
              ),
              if (shirtNumber.isNotEmpty)
                Positioned(
                  right: -3,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3202F),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      shirtNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          // Broadcast name plate matching reference image
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1F23), Color(0xFF0A0D0E)],
              ),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0xFFD3202F), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              playerName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ),
          if (position.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(
              position.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
                shadows: const [
                  Shadow(color: Colors.black87, blurRadius: 3),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _playerInitialAvatar(String name, String shirtNum) {
    return Container(
      color: const Color(0xFF1E3A2F),
      child: Center(
        child: Text(
          shirtNum.isNotEmpty ? '#$shirtNum' : (name.isNotEmpty ? name[0].toUpperCase() : 'P'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
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
    if (category == 'Matches') {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MatchStatusMessage(
            icon: Icons.sports_soccer_rounded,
            title: 'Upcoming, live and completed matches',
            message: 'Fixtures are games scheduled to take place. Matches include games that are upcoming, in progress or finished. Select a date to view published match details.',
          ),
          _CafQualifierResults(),
          SizedBox(height: 12),
          _CafUpcomingFixtures(),
        ],
      );
    }
    if (category == 'Results') {
      return const _CafQualifierResults();
    }
    if (category == 'Fixtures') {
      return const _CafUpcomingFixtures();
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
    if (category != 'All') {
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

    return const _OfficialQualifyingWindowsPreview();
  }
}

class _CafUpcomingFixtures extends StatelessWidget {
  const _CafUpcomingFixtures();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _MatchCentreSectionTitle('AFCON PAMOJA 2027 · Matchday 3'),
      const SizedBox(height: 4),
      const Text(
        'CAF lists these pairings for the 9–17 November 2026 qualifier window. Exact dates, kick-off times and stadiums have not been announced.',
        style: TextStyle(color: Color(0xFF666666), fontSize: 11, height: 1.4),
      ),
      const SizedBox(height: 12),
      for (final fixture in cafAfcon2027UpcomingFixtures)
        _CafQualifierMatchCard(match: fixture),
      const _SourceAttribution(
        source: 'Source: CAF AFCON PAMOJA 2027 qualifier coverage.',
      ),
    ],
  );
}

class _CafQualifierResults extends StatelessWidget {
  const _CafQualifierResults();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _MatchCentreSectionTitle('AFCON PAMOJA 2027 · Matchday 2 results'),
      const SizedBox(height: 4),
      const Text(
        'Scores reported by CAF. The exact match dates and stadiums are not included in this results summary.',
        style: TextStyle(color: Color(0xFF666666), fontSize: 11, height: 1.4),
      ),
      const SizedBox(height: 12),
      for (final match in cafAfcon2027QualifierResults)
        _CafQualifierMatchCard(match: match),
      const _SourceAttribution(
        source:
            'Source: CAF AFCON PAMOJA 2027 Matchday 2 group-by-group report.',
      ),
    ],
  );
}

class _CafQualifierMatchCard extends StatelessWidget {
  const _CafQualifierMatchCard({required this.match});

  final CafQualifierMatch match;

  @override
  Widget build(BuildContext context) {
    final completed = match.hasScore;
    return Container(
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
              Text(
                match.hasScore
                    ? '${match.homeScore} – ${match.awayScore}'
                    : 'VS',
                style: const TextStyle(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Group ${match.group} · ${match.dateLabel}',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 11,
                  ),
                ),
              ),
              if (completed)
                const Text(
                  'COMPLETED',
                  style: TextStyle(
                    color: Color(0xFF376B4B),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          if (!completed) ...[
            const SizedBox(height: 4),
            const Text(
              'Kick-off: To be confirmed · Stadium: To be confirmed',
              style: TextStyle(color: Color(0xFF666666), fontSize: 11),
            ),
          ],
          if (completed)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                key: Key('match-watch-${match.home}-${match.away}'),
                onPressed: () =>
                    _watchMatchOnYoutube(context, match.home, match.away),
                icon: const Icon(Icons.smart_display_outlined, size: 18),
                label: const Text('Watch on YouTube'),
              ),
            ),
        ],
      ),
    );
  }
}

class _OfficialQualifyingWindowsPreview extends StatelessWidget {
  const _OfficialQualifyingWindowsPreview();

  @override
  Widget build(BuildContext context) => Column(
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
        detail: 'One of three national stadiums presented to CAF. Planned capacity: 20,000 people upon completion.',
        capacity: '20,000 people planned',
        opened: 'Under development',
        coordinates: 'Not published',
      ),
      const SizedBox(height: 10),
      const _VenueDetailsCard(
        title: 'Hoima City Stadium',
        location: 'Hoima City, Uganda',
        detail: 'A modern multi-purpose stadium in western Uganda. AFCON 2027 match allocation is not confirmed.',
        capacity: '20,000 people',
        opened: '2025',
        coordinates: '1.43556° N, 31.39389° E',
      ),
      const SizedBox(height: 10),
      const _VenueDetailsCard(
        title: 'St Mary’s Stadium (Kitende)',
        location: 'Kitende, Uganda',
        detail: 'A football stadium near Kampala. AFCON 2027 match allocation is not confirmed.',
        capacity: 'Not confirmed',
        opened: 'Not published',
        coordinates: 'Not published',
      ),
      const SizedBox(height: 10),
      const _VenueImageCard(
        title: 'Benjamin Mkapa Stadium',
        location: 'Dar es Salaam, Tanzania',
        detail: 'Stadium spotlight from a PAMOJA host country. Match allocation details are not shown.',
        asset: 'assets/images/new images/home screen images/benjamin-mkapa-stadium_ok.webp',
        imageLabel: 'Benjamin Mkapa Stadium',
        capacity: '60,000 people',
        opened: '2007',
        coordinates: '6.8536° S, 39.2738° E',
      ),
      const SizedBox(height: 10),
      const _VenueImageCard(
        title: 'Mandela National Stadium',
        location: 'Kampala, Uganda',
        detail: 'Stadium spotlight from a PAMOJA host country. Match allocation details are not shown.',
        asset: 'assets/images/new images/mandela stadium.PNG',
        imageLabel: 'Mandela National Stadium',
        capacity: '45,000 people (listed)',
        opened: '1997',
        coordinates: '0.34778° N, 32.65917° E',
      ),
      const SizedBox(height: 10),
      const _VenueDetailsCard(
        title: 'Amaan Stadium',
        location: 'Zanzibar City, Tanzania',
        detail: 'A multi-purpose stadium in Zanzibar. AFCON 2027 match allocation is not confirmed.',
        capacity: '15,000 people',
        opened: '1970',
        coordinates: '6.16600° S, 39.22386° E',
      ),
      const SizedBox(height: 10),
      const _VenueDetailsCard(
        title: 'Moi International Sports Centre (Kasarani)',
        location: 'Nairobi, Kenya',
        detail: 'A major sports complex in Nairobi. AFCON 2027 match allocation is not confirmed.',
        capacity: '48,063 people (main stadium)',
        opened: '1987',
        coordinates: '1.22806° S, 36.89056° E',
      ),
      const SizedBox(height: 10),
      const _VenueDetailsCard(
        title: 'Nyayo National Stadium',
        location: 'Nairobi, Kenya',
        detail: 'A multi-purpose stadium in Nairobi. AFCON 2027 match allocation is not confirmed.',
        capacity: '18,000 people (listed)',
        opened: '1983',
        coordinates: '1.30361° S, 36.82417° E',
      ),
      const _SourceAttribution(
        source: 'Venue reference pages: Hoima City Stadium, Amaan Stadium, Benjamin Mkapa Stadium, Mandela National Stadium, Kasarani and Nyayo. Akii-Bua planned details: PAMOJA publication. Capacities may change; venue listings do not confirm AFCON 2027 match allocations.',
      ),
    ],
  );
}

class _VenueDetailsCard extends StatelessWidget {
  const _VenueDetailsCard({
    required this.title,
    required this.location,
    required this.detail,
    required this.capacity,
    required this.opened,
    required this.coordinates,
  });

  final String title;
  final String location;
  final String detail;
  final String capacity;
  final String opened;
  final String coordinates;

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
        const SizedBox(height: 8),
        _VenueFacts(
          capacity: capacity,
          opened: opened,
          coordinates: coordinates,
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
    required this.capacity,
    required this.opened,
    required this.coordinates,
  });

  final String title;
  final String location;
  final String detail;
  final String asset;
  final String imageLabel;
  final String capacity;
  final String opened;
  final String coordinates;

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
              const SizedBox(height: 8),
              _VenueFacts(
                capacity: capacity,
                opened: opened,
                coordinates: coordinates,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _VenueFacts extends StatelessWidget {
  const _VenueFacts({
    required this.capacity,
    required this.opened,
    required this.coordinates,
  });

  final String capacity;
  final String opened;
  final String coordinates;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _VenueFactRow(label: 'Capacity', value: capacity),
      const SizedBox(height: 3),
      _VenueFactRow(label: 'Opened', value: opened),
      const SizedBox(height: 3),
      _VenueFactRow(label: 'Coordinates', value: coordinates),
    ],
  );
}

class _VenueFactRow extends StatelessWidget {
  const _VenueFactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 82,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF66716B),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(color: Color(0xFF66716B), fontSize: 10),
        ),
      ),
    ],
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
  Widget build(BuildContext context) {
    final imageUrl = record['image_url']?.toString().trim();
    final name = '${record['name'] ?? 'Stadium'}';
    final location =
        '${record['city'] ?? ''}${record['country'] == null ? '' : ', ${record['country']}'}';
    final capacity = record['capacity'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    semanticLabel: name,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: Color(0xFFF5E6E6),
                      child: Center(
                        child: Icon(
                          Icons.stadium_rounded,
                          color: Color(0xFF800000),
                          size: 42,
                        ),
                      ),
                    ),
                  )
                : const ColoredBox(
                    color: Color(0xFFF5E6E6),
                    child: Center(
                      child: Icon(
                        Icons.stadium_rounded,
                        color: Color(0xFF800000),
                        size: 42,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(
                      color: Color(0xFF176B46),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (capacity != null) ...[
                  const SizedBox(height: 7),
                  Text(
                    'Capacity: $capacity people',
                    style: const TextStyle(
                      color: Color(0xFF66716B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
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
    final normalizedStatus = status.toLowerCase().trim();
    final completed = const {
      'finished',
      'completed',
      'played',
      'full time',
      'ft',
    }.contains(normalizedStatus);
    final dateOnly = record['date_only'] == true;
    final homeScore = record['home_score'];
    final awayScore = record['away_score'];
    final hasScore = homeScore != null && awayScore != null;
    final kickoffLabel = kickoff == null
        ? 'To be confirmed'
        : dateOnly
        ? '${_weekday(kickoff.weekday)}, ${kickoff.day} ${_month(kickoff.month)} ${kickoff.year}'
        : '${_weekday(kickoff.weekday)}, ${kickoff.day} ${_month(kickoff.month)} · ${kickoff.hour.toString().padLeft(2, '0')}:${kickoff.minute.toString().padLeft(2, '0')}';
    final venue = '${record['venue_name'] ?? ''}'.trim();
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
                    completed ? 'COMPLETED' : status.toUpperCase(),
                    style: TextStyle(
                      color: completed
                          ? const Color(0xFF376B4B)
                          : status == 'live'
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
                'Date: $kickoffLabel${dateOnly || kickoff == null ? '' : ' · Kick-off: ${kickoff.hour.toString().padLeft(2, '0')}:${kickoff.minute.toString().padLeft(2, '0')}'}',
                style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                'Stadium: ${venue.isEmpty ? 'To be confirmed' : venue}',
                style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
              ),
              if (completed)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: Key('match-watch-${record['id']}'),
                    onPressed: () => _watchMatchOnYoutube(
                      context,
                      '${record['home_team'] ?? 'Home'}',
                      '${record['away_team'] ?? 'Away'}',
                    ),
                    icon: const Icon(Icons.smart_display_outlined, size: 18),
                    label: const Text('Watch on YouTube'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _watchMatchOnYoutube(
  BuildContext context,
  String home,
  String away,
) async {
  final uri = Uri.https('www.youtube.com', '/results', {
    'search_query': '$home vs $away AFCON highlights',
  });
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
      context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Could not open YouTube.')));
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
                    matchRecord: widget.record,
                    opponentName: away,
                    isHome: true,
                    emptyMessage:
                        snapshot.connectionState == ConnectionState.waiting
                        ? 'Loading confirmed line-up…'
                        : 'Confirmed line-up will appear here when published.',
                  ),
                  const SizedBox(height: 12),
                  _PublishedLineupTeam(
                    name: away,
                    players: awayRows,
                    matchRecord: widget.record,
                    opponentName: home,
                    isHome: false,
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
      const _MatchDataScreen(feature: 'Events & stats', isActive: true);
}

class _MatchDataScreen extends StatefulWidget {
  const _MatchDataScreen({
    required this.feature,
    this.showAppBar = true,
    this.isActive = false,
  });
  final String feature;
  final bool showAppBar;
  final bool isActive;

  @override
  State<_MatchDataScreen> createState() => _MatchDataScreenState();
}

class _MatchDataScreenState extends State<_MatchDataScreen>
    with WidgetsBindingObserver {
  final _api = AfconApi();
  late Future<List<Map<String, dynamic>>> _matches = _api.matches();
  String? _selectedMatchId;
  Timer? _refreshTimer;
  bool _appResumed = true;

  bool get _isLineup => feature == 'Line-ups';

  String get feature => widget.feature;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncRefreshTimer();
  }

  @override
  void didUpdateWidget(covariant _MatchDataScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _syncRefreshTimer();
      if (widget.isActive && _appResumed) _refreshMatchData();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    _syncRefreshTimer();
    if (_appResumed && widget.isActive) _refreshMatchData();
  }

  void _syncRefreshTimer() {
    _refreshTimer?.cancel();
    if (!widget.isActive || !_appResumed) return;
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshMatchData(),
    );
  }

  void _refreshMatchData() {
    if (!mounted || !widget.isActive || !_appResumed) return;
    setState(() => _matches = _api.matches());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
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
