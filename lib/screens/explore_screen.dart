import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  static const _green = Color(0xFF176B46);
  static const _canvas = Color(0xFFF6F8F6);
  static const _topTabs = ['Popular', 'CAF', 'Rankings'];
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
    _dataTabController = TabController(length: 4, vsync: this);
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
        foregroundColor: const Color(0xFF19251F),
        centerTitle: false,
        title: TabBar(
          controller: _topTabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: const Color(0xFF176B46),
          indicatorWeight: 3,
          labelColor: const Color(0xFF176B46),
          unselectedLabelColor: const Color(0xFF69766F),
          tabs: _topTabs.map((tab) => Tab(text: tab)).toList(),
        ),
        bottom: PreferredSize(
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
                    foregroundColor: _green,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
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
                    iconEnabledColor: _green,
                    style: const TextStyle(
                      color: Color(0xFF19251F),
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
                      color: const Color(0xFFEAF3ED),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    labelColor: _green,
                    unselectedLabelColor: const Color(0xFF69766F),
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
                _DiscoveryContent(
                  title: 'Competitions',
                  description: 'Browse competitions by region using More, or choose one of the popular leagues above.',
                  onMore: _showMoreCompetitions,
                ),
                _DiscoveryContent(
                  title: 'World rankings',
                  description: 'Rankings and team comparisons will appear here when an approved data source is connected.',
                  onMore: _showMoreCompetitions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
            ? const Color(0xFF176B46)
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
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFFEAF3ED),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '$league · $season · SAMPLE DATA',
            style: const TextStyle(
              color: Color(0xFF19251F),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: dataTabController,
            children: [
              _StandingsTable(league: league, season: season),
              const _DataPlaceholder(
                title: 'Top players',
                message: 'Player statistics will appear here.',
              ),
              const _DataPlaceholder(
                title: 'Teams',
                message: 'Competition team profiles will appear here.',
              ),
              const _DataPlaceholder(
                title: 'Fixtures',
                message: 'Competition fixtures will appear here.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StandingsTable extends StatelessWidget {
  const _StandingsTable({required this.league, required this.season});

  final String league;
  final String season;

  static const _rows = [
    ('1', 'Uganda', '3', '3', '0', '0', '9'),
    ('2', 'Ghana', '3', '2', '1', '0', '7'),
    ('3', 'Nigeria', '3', '2', '0', '1', '6'),
    ('4', 'Morocco', '3', '1', '2', '0', '5'),
    ('5', 'Senegal', '3', '1', '1', '1', '4'),
    ('6', 'Egypt', '3', '1', '0', '2', '3'),
    ('7', 'South Africa', '3', '0', '2', '1', '2'),
  ];

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
                  style: TextStyle(color: Color(0xFF69766F), fontSize: 10),
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
        for (var index = 0; index < _rows.length; index++)
          _StandingsRow(values: _rows[index], highlighted: index < 4),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            '$league $season standings shown for layout preview only. Not official competition data.',
            style: const TextStyle(
              color: Color(0xFF69766F),
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
        style: const TextStyle(color: Color(0xFF69766F), fontSize: 9),
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
    final background = highlighted ? const Color(0xFFEAF3ED) : Colors.white;
    const textColor = Color(0xFF19251F);

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
                color: highlighted ? const Color(0xFF176B46) : textColor,
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
                color: highlighted ? const Color(0xFF176B46) : textColor,
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

class _DataPlaceholder extends StatelessWidget {
  const _DataPlaceholder({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.insights_rounded,
              color: Color(0xFF176B46),
              size: 38,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF19251F),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF69766F), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryContent extends StatelessWidget {
  const _DiscoveryContent({
    required this.title,
    required this.description,
    required this.onMore,
  });

  final String title;
  final String description;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              color: Color(0xFFD8A441),
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF19251F),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF69766F),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onMore,
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Browse all competitions'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF176B46),
                side: const BorderSide(color: Color(0xFFB7D4C4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
                  ? const Color(0xFF176B46)
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
        foregroundColor: const Color(0xFF19251F),
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
