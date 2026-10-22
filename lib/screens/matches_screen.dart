import 'package:flutter/material.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    'All',
    'Live',
    'Fixtures',
    'Results',
    'Groups',
    'Standings',
    'Venues',
  ];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF19251F),
        centerTitle: true,
        title: const Text(
          'MATCH CENTRE',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: const [SizedBox(width: 48)],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: const Color(0xFF176B46),
          unselectedLabelColor: const Color(0xFF69766F),
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
            color: const Color(0xFFEAF3ED),
            borderRadius: BorderRadius.circular(10),
          ),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs
            .map(
              (category) =>
                  _MatchList(category: category, dateLabel: _formatDate(today)),
            )
            .toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList({required this.category, required this.dateLabel});

  final String category;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final showSample = category == 'All' || category == 'Fixtures';

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.white,
          child: Text(
            'Today, $dateLabel',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF69766F),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (showSample)
          const _FixtureRow(
            competition: 'SAMPLE FIXTURE · NOT OFFICIAL AFCON DATA',
            homeTeam: 'Uganda',
            awayTeam: 'Ghana',
            homeInitial: 'U',
            awayInitial: 'G',
            homeColor: Color(0xFF176B46),
            awayColor: Color(0xFFD84343),
            time: '19:45',
          )
        else
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Icon(
                  category == 'Live'
                      ? Icons.sensors_rounded
                      : category == 'Venues'
                          ? Icons.stadium_rounded
                          : category == 'Groups' || category == 'Standings'
                              ? Icons.table_chart_rounded
                              : Icons.sports_score_rounded,
                  color: const Color(0xFF176B46),
                  size: 34,
                ),
                const SizedBox(height: 10),
                Text(
                  category == 'Live'
                      ? 'No live matches right now'
                      : category == 'Results'
                          ? 'Results will appear here'
                          : category == 'Groups'
                              ? 'Group information is coming soon'
                              : category == 'Standings'
                                  ? 'Tournament standings are coming soon'
                                  : category == 'Venues'
                                      ? 'Confirmed match venues are coming soon'
                                      : 'No matches to show yet',
                  style: const TextStyle(
                    color: Color(0xFF40464B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Official AFCON match data has not been connected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF858B91), fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FixtureRow extends StatelessWidget {
  const _FixtureRow({
    required this.competition,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeInitial,
    required this.awayInitial,
    required this.homeColor,
    required this.awayColor,
    required this.time,
  });

  final String competition;
  final String homeTeam;
  final String awayTeam;
  final String homeInitial;
  final String awayInitial;
  final Color homeColor;
  final Color awayColor;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 2),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EBE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            competition,
            style: const TextStyle(
              color: Color(0xFF91979C),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FixtureTeam(
                  name: homeTeam,
                  initial: homeInitial,
                  color: homeColor,
                  alignEnd: true,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F2F4),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'VS',
                      style: TextStyle(
                        color: Color(0xFF40464B),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF777D82),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FixtureTeam(
                  name: awayTeam,
                  initial: awayInitial,
                  color: awayColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FixtureTeam extends StatelessWidget {
  const _FixtureTeam({
    required this.name,
    required this.initial,
    required this.color,
    this.alignEnd = false,
  });

  final String name;
  final String initial;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignEnd
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (alignEnd) ...[
          Flexible(
            child: Text(
              name,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF24282C),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 7),
        ],
        _TeamBadge(initial: initial, color: color, size: 34),
        if (!alignEnd) ...[
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF24282C),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TeamBadge extends StatelessWidget {
  const _TeamBadge({
    required this.initial,
    required this.color,
    this.size = 28,
  });

  final String initial;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
