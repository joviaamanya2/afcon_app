import 'package:flutter/material.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    'Main',
    'Live',
    'Upcoming',
    'Premier League',
    'Super Leagues',
    'Global',
    'Local',
    'LaLiga',
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF16A34A),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'MATCH',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.78),
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
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F7C3A), Color(0xFF20B957)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
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
    final showSample =
        category == 'Main' ||
        category == 'Upcoming' ||
        category == 'Premier League';

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: const Color(0xFFF0F1F3),
          child: Text(
            'Today, $dateLabel',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF858B91), fontSize: 13),
          ),
        ),
        if (showSample)
          const _FixtureRow(
            competition: 'SAMPLE FIXTURE · NOT OFFICIAL AFCON DATA',
            homeTeam: 'Manchester United',
            awayTeam: 'Arsenal',
            homeInitial: 'M',
            awayInitial: 'A',
            homeColor: Color(0xFFDA291C),
            awayColor: Color(0xFFEF0107),
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
                      : Icons.sports_score_rounded,
                  color: const Color(0xFF16A34A),
                  size: 34,
                ),
                const SizedBox(height: 10),
                Text(
                  category == 'Live'
                      ? 'No live matches right now'
                      : 'No $category matches to show yet',
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
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEFF0F1))),
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
