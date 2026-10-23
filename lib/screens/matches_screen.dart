import 'package:flutter/material.dart';

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

class _QualifiersContent extends StatelessWidget {
  const _QualifiersContent();

  @override
  Widget build(BuildContext context) {
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
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QualifierFact(label: '12 groups'),
            _QualifierFact(label: '24 finalists'),
            _QualifierFact(label: 'Kenya · Tanzania · Uganda host'),
          ],
        ),
        const SizedBox(height: 16),
        _QualifierGraphic(
          title: 'Official draw pots',
          subtitle: 'The teams were placed into four draw pots.',
          asset: 'assets/images/new images/home screen images/afcon-draw-q-potsjpg.webp',
        ),
        _QualifierGraphic(
          title: 'Qualifying groups',
          subtitle: 'See all groups A to L and the teams in each group.',
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Key dates',
                style: TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10),
              _QualifierDateRow(
                label: 'Next qualifying window',
                date: '9–17 November 2026',
              ),
              SizedBox(height: 9),
              _QualifierDateRow(
                label: 'Final tournament',
                date: '19 June–17 July 2027',
              ),
            ],
          ),
        ),
      ],
    );
  }
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
    if (widget.category == 'Groups' || widget.category == 'Standings') {
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

  static const _details = <String, (IconData, String, String)>{
    'All': (
      Icons.sports_soccer_rounded,
      'No published matches yet',
      'Add and publish fixtures in the dashboard to show them here.',
    ),
    'Live': (
      Icons.sensors_rounded,
      'No live matches',
      'Live scores, match time, key events and statistics will appear here.',
    ),
    'Fixtures': (
      Icons.event_available_rounded,
      'No published fixtures yet',
      'Published match schedules will appear here with their kick-off and venue details.',
    ),
    'Results': (
      Icons.sports_score_rounded,
      'No results for this date',
      'Final scores, scorers, cards and match reports will appear here.',
    ),
    'Groups': (
      Icons.grid_view_rounded,
      'Group details coming soon',
      'Teams, fixtures and group progress will be available here.',
    ),
    'Standings': (
      Icons.leaderboard_rounded,
      'No published standings yet',
      'Publish a competition table from the dashboard to see group positions and points.',
    ),
    'Venues': (
      Icons.stadium_rounded,
      'No published venues yet',
      'Published stadium locations and access details will appear here.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final date = widget.date;
    final info = _details[category]!;
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
              return const _MatchStatusMessage(
                icon: Icons.cloud_off_rounded,
                title: 'Match data is unavailable',
                message:
                    'Check the API and database connection, then try again.',
              );
            }
            final records = snapshot.data ?? const <Map<String, dynamic>>[];
            if (records.isEmpty) return const SizedBox.shrink();
            if (category == 'Venues') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: records
                      .map((record) => _BackendVenueCard(record: record))
                      .toList(),
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
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE6EBE7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E6E6),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(info.$1, color: const Color(0xFF800000)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category == 'All' ? 'AFCON matchday' : category,
                          style: const TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${date.day} ${_month(date.month)} ${date.year}',
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFF666666),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 21),
              Center(
                child: Icon(info.$1, color: const Color(0xFF800000), size: 35),
              ),
              const SizedBox(height: 11),
              Center(
                child: Text(
                  info.$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  info.$3,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      color: Color(0xFF800000),
                      size: 17,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This screen displays published backend records. Add verified tournament information in the admin dashboard before publishing it to fans.',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
  const _BackendMatchCard({required this.record});
  final Map<String, dynamic> record;

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
    return Container(
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
      if (snapshot.hasError)
        return const Text(
          'Match details are unavailable. Check the API connection.',
          style: TextStyle(color: Color(0xFF666666)),
        );
      final rows = snapshot.data ?? const <Map<String, dynamic>>[];
      if (rows.isEmpty)
        return Text(
          lineups
              ? 'No published line-up data for this match.'
              : 'No published match events for this match.',
          style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
        );
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
                return const _MatchStatusMessage(
                  icon: Icons.cloud_off_rounded,
                  title: 'Match service unavailable',
                  message: 'Check that the AFCON API and database are running.',
                );
              final matches = snapshot.data ?? const <Map<String, dynamic>>[];
              if (matches.isEmpty)
                return const _MatchStatusMessage(
                  icon: Icons.sports_soccer_rounded,
                  title: 'No published matches yet',
                  message: 'Add and publish a fixture in the dashboard to see match events and line-ups here.',
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
      if (snapshot.hasError)
        return const Text(
          'Statistics are unavailable.',
          style: TextStyle(color: Color(0xFF666666), fontSize: 12),
        );
      final rows = snapshot.data ?? const <Map<String, dynamic>>[];
      if (rows.isEmpty)
        return const Text(
          'No published statistics for this match.',
          style: TextStyle(color: Color(0xFF666666), fontSize: 12),
        );
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
