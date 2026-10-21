import 'package:flutter/material.dart';

class TeamsPlayersScreen extends StatefulWidget {
  const TeamsPlayersScreen({super.key});

  @override
  State<TeamsPlayersScreen> createState() => _TeamsPlayersScreenState();
}

class _TeamsPlayersScreenState extends State<TeamsPlayersScreen> {
  static const _green = Color(0xFF147D55);
  static const _ink = Color(0xFF172B4D);
  static const _muted = Color(0xFF627D98);
  static const _leagues = [
    'Premier League',
    'La Liga',
    'Serie A',
    'Bundesliga',
  ];
  static const _clubs = <String, List<_Club>>{
    'Premier League': [
      _Club('Manchester United', '1878', 'M', Color(0xFFDA291C)),
      _Club('Arsenal', '1886', 'A', Color(0xFFEF0107)),
      _Club('Liverpool', '1892', 'L', Color(0xFFC8102E)),
      _Club('Manchester City', '1880', 'C', Color(0xFF6CABDD)),
    ],
    'La Liga': [
      _Club('Real Madrid', '1902', 'R', Color(0xFF8B7BB8)),
      _Club('Barcelona', '1899', 'B', Color(0xFF004D98)),
      _Club('Atlético Madrid', '1903', 'A', Color(0xFFCB3524)),
    ],
    'Serie A': [
      _Club('Juventus', '1897', 'J', Color(0xFF303030)),
      _Club('Inter Milan', '1908', 'I', Color(0xFF00529F)),
      _Club('AC Milan', '1899', 'M', Color(0xFFCC0000)),
    ],
    'Bundesliga': [
      _Club('Bayern Munich', '1900', 'B', Color(0xFFDC052D)),
      _Club('Borussia Dortmund', '1909', 'D', Color(0xFFFDE100)),
    ],
  };

  static const _samplePlayers = <String, List<_Player>>{
    'Manchester United': [
      _Player('Bruno Fernandes', 'Midfielder', '8', {
        'Goals': 8,
        'Assists': 7,
        'Yellow cards': 4,
        'Red cards': 0,
        'Penalty goals': 2,
        'Shots': 41,
        'Shots on target': 19,
        'Dribbles attempted': 38,
        'Successful dribbles': 21,
        'Times fouled': 24,
        'Big chances created': 11,
        'Big chances missed': 5,
        'Distance covered (km)': 112,
        'Sprints': 186,
      }),
      _Player('Marcus Rashford', 'Forward', '10', {
        'Goals': 6,
        'Assists': 3,
        'Yellow cards': 2,
        'Red cards': 0,
        'Penalty goals': 0,
        'Shots': 35,
        'Shots on target': 15,
        'Dribbles attempted': 47,
        'Successful dribbles': 25,
        'Times fouled': 18,
        'Big chances created': 7,
        'Big chances missed': 6,
        'Distance covered (km)': 98,
        'Sprints': 204,
      }),
      _Player('Kobbie Mainoo', 'Midfielder', '37', {
        'Goals': 2,
        'Assists': 2,
        'Yellow cards': 3,
        'Red cards': 0,
        'Penalty goals': 0,
        'Shots': 16,
        'Shots on target': 7,
        'Dribbles attempted': 22,
        'Successful dribbles': 16,
        'Times fouled': 14,
        'Big chances created': 4,
        'Big chances missed': 2,
        'Distance covered (km)': 105,
        'Sprints': 132,
      }),
    ],
    'Arsenal': [
      _Player('Bukayo Saka', 'Forward', '7'),
      _Player('Martin Ødegaard', 'Midfielder', '8'),
      _Player('Declan Rice', 'Midfielder', '41'),
    ],
    'Liverpool': [
      _Player('Mohamed Salah', 'Forward', '11'),
      _Player('Virgil van Dijk', 'Defender', '4'),
      _Player('Alisson Becker', 'Goalkeeper', '1'),
    ],
    'Manchester City': [
      _Player('Erling Haaland', 'Forward', '9'),
      _Player('Phil Foden', 'Midfielder', '47'),
      _Player('Rodri', 'Midfielder', '16'),
    ],
    'Real Madrid': [
      _Player('Jude Bellingham', 'Midfielder', '5'),
      _Player('Vinícius Júnior', 'Forward', '7'),
      _Player('Thibaut Courtois', 'Goalkeeper', '1'),
    ],
    'Barcelona': [
      _Player('Lamine Yamal', 'Forward', '19'),
      _Player('Pedri', 'Midfielder', '8'),
      _Player('Robert Lewandowski', 'Forward', '9'),
    ],
    'Atlético Madrid': [
      _Player('Antoine Griezmann', 'Forward', '7'),
      _Player('Koke', 'Midfielder', '6'),
    ],
    'Juventus': [
      _Player('Dušan Vlahović', 'Forward', '9'),
      _Player('Kenan Yıldız', 'Forward', '10'),
    ],
    'Inter Milan': [
      _Player('Lautaro Martínez', 'Forward', '10'),
      _Player('Nicolò Barella', 'Midfielder', '23'),
    ],
    'AC Milan': [
      _Player('Rafael Leão', 'Forward', '10'),
      _Player('Christian Pulisic', 'Forward', '11'),
    ],
    'Bayern Munich': [
      _Player('Harry Kane', 'Forward', '9'),
      _Player('Jamal Musiala', 'Midfielder', '42'),
    ],
    'Borussia Dortmund': [
      _Player('Julian Brandt', 'Midfielder', '10'),
      _Player('Karim Adeyemi', 'Forward', '27'),
    ],
  };

  String _selectedLeague = _leagues.first;
  _Club? _selectedClub;
  String? _selectedSeason;
  String _selectedPlayerStat = 'Goals';
  bool _descendingPlayerStats = true;

  static const _playerStats = [
    'Goals',
    'Assists',
    'Yellow cards',
    'Red cards',
    'Penalty goals',
    'Shots',
    'Shots on target',
    'Dribbles attempted',
    'Successful dribbles',
    'Times fouled',
    'Big chances created',
    'Big chances missed',
    'Distance covered (km)',
    'Sprints',
  ];

  @override
  Widget build(BuildContext context) {
    final clubs = _clubs[_selectedLeague]!;
    final selectedClub = _selectedClub != null && clubs.contains(_selectedClub)
        ? _selectedClub!
        : clubs.first;
    final seasons = _seasonsFor(selectedClub);
    final selectedSeason = seasons.contains(_selectedSeason)
        ? _selectedSeason!
        : seasons.first;
    final players = _samplePlayers[selectedClub.name] ?? const <_Player>[];
    final rankedPlayers = players.toList()
      ..sort((first, second) {
        final firstValue = first.stats[_selectedPlayerStat];
        final secondValue = second.stats[_selectedPlayerStat];
        if (firstValue == null) return secondValue == null ? 0 : 1;
        if (secondValue == null) return -1;
        return _descendingPlayerStats
            ? secondValue.compareTo(firstValue)
            : firstValue.compareTo(secondValue);
      });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        title: const Text('Teams & players'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const Text(
            'Browse by league',
            style: TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _leagues.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final league = _leagues[index];
                final selected = league == _selectedLeague;
                return ChoiceChip(
                  label: Text(league),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: _green,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => setState(() {
                    _selectedLeague = league;
                    _selectedClub = null;
                    _selectedSeason = null;
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Teams',
            style: TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: clubs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final club = clubs[index];
                final selected = club == selectedClub;
                return _ClubCard(
                  club: club,
                  selected: selected,
                  onTap: () => setState(() {
                    _selectedClub = club;
                    _selectedSeason = null;
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          _HistoryPanel(
            club: selectedClub,
            seasons: seasons,
            selectedSeason: selectedSeason,
            onSeasonChanged: (season) {
              if (season != null) setState(() => _selectedSeason = season);
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${selectedClub.name} player rankings',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                selectedSeason,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Rank by',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: const Key('player-stat-picker'),
                  initialValue: _selectedPlayerStat,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _playerStats
                      .map(
                        (stat) =>
                            DropdownMenuItem(value: stat, child: Text(stat)),
                      )
                      .toList(),
                  onChanged: (stat) {
                    if (stat != null) {
                      setState(() => _selectedPlayerStat = stat);
                    }
                  },
                ),
              ),
              IconButton(
                key: const Key('player-sort-direction'),
                tooltip: _descendingPlayerStats
                    ? 'Highest to lowest'
                    : 'Lowest to highest',
                onPressed: () => setState(
                  () => _descendingPlayerStats = !_descendingPlayerStats,
                ),
                icon: Icon(
                  _descendingPlayerStats
                      ? Icons.south_rounded
                      : Icons.north_rounded,
                  color: _green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Illustrative sample stats · sorted by selected stat',
            style: TextStyle(color: _muted, fontSize: 10),
          ),
          const SizedBox(height: 8),
          if (selectedSeason != seasons.first)
            _HistoricalSeasonNotice(season: selectedSeason)
          else if (rankedPlayers.isEmpty)
            const _NoPlayersNotice()
          else
            for (var index = 0; index < rankedPlayers.length; index++)
              _PlayerCard(
                player: rankedPlayers[index],
                club: selectedClub,
                season: selectedSeason,
                rank: index + 1,
                statLabel: _selectedPlayerStat,
              ),
          const SizedBox(height: 10),
          const Text(
            'Roster previews are illustrative. Historical squads and player career records require a verified football data source.',
            style: TextStyle(color: _muted, fontSize: 11, height: 1.45),
          ),
        ],
      ),
    );
  }

  List<String> _seasonsFor(_Club club) {
    final currentYear = DateTime.now().year;
    final currentSeasonStart = DateTime.now().month >= 7
        ? currentYear
        : currentYear - 1;
    final firstSeason = int.parse(club.foundedYear);
    return [
      for (var year = currentSeasonStart; year >= firstSeason; year--)
        '$year/${(year + 1).toString().substring(2)}',
    ];
  }
}

class _Club {
  const _Club(this.name, this.foundedYear, this.badgeLetter, this.color);

  final String name;
  final String foundedYear;
  final String badgeLetter;
  final Color color;

  @override
  bool operator ==(Object other) => other is _Club && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

class _Player {
  const _Player(this.name, this.position, this.number, [this.stats = const {}]);

  final String name;
  final String position;
  final String number;
  final Map<String, int> stats;
}

class _ClubCard extends StatelessWidget {
  const _ClubCard({
    required this.club,
    required this.selected,
    required this.onTap,
  });

  final _Club club;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE6F3EB) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 126,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFF90C8A5)
                  : const Color(0xFFE5ECEE),
            ),
          ),
          child: Row(
            children: [
              _Badge(club: club, size: 36),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  club.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF172B4D),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({
    required this.club,
    required this.seasons,
    required this.selectedSeason,
    required this.onSeasonChanged,
  });

  final _Club club;
  final List<String> seasons;
  final String selectedSeason;
  final ValueChanged<String?> onSeasonChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF25333D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _Badge(club: club, size: 42),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Founded ${club.foundedYear} · season archive',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: const Key('player-season-picker'),
              value: selectedSeason,
              dropdownColor: const Color(0xFF25333D),
              iconEnabledColor: Colors.white,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              items: seasons
                  .map(
                    (season) =>
                        DropdownMenuItem(value: season, child: Text(season)),
                  )
                  .toList(),
              onChanged: onSeasonChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.club, required this.size});

  final _Club club;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: club.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        club.badgeLetter,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.48,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.club,
    required this.season,
    required this.rank,
    required this.statLabel,
  });

  final _Player player;
  final _Club club;
  final String season;
  final int rank;
  final String statLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5ECEE)),
      ),
      child: ListTile(
        key: Key('ranked-player-${player.name}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => _PlayerProfileScreen(
              player: player,
              club: club,
              season: season,
            ),
          ),
        ),
        leading: CircleAvatar(
          key: Key('rank-badge-${player.name}'),
          radius: 20,
          backgroundColor: const Color(0xFFEAF5EF),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Color(0xFF147D55),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(
            color: Color(0xFF172B4D),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${club.name} · ${player.position}',
          style: const TextStyle(color: Color(0xFF627D98), fontSize: 11),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${player.stats[statLabel] ?? '—'}',
              style: const TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              statLabel,
              style: const TextStyle(color: Color(0xFF627D98), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoricalSeasonNotice extends StatelessWidget {
  const _HistoricalSeasonNotice({required this.season});

  final String season;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5ECEE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: Color(0xFF147D55)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'The $season squad archive is not connected yet. Historical players will appear here when verified records are available.',
              style: const TextStyle(
                color: Color(0xFF627D98),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoPlayersNotice extends StatelessWidget {
  const _NoPlayersNotice();

  @override
  Widget build(BuildContext context) {
    return const _HistoricalSeasonNotice(season: 'This team');
  }
}

class _PlayerProfileScreen extends StatefulWidget {
  const _PlayerProfileScreen({
    required this.player,
    required this.club,
    required this.season,
  });

  final _Player player;
  final _Club club;
  final String season;

  @override
  State<_PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<_PlayerProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 4);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final club = widget.club;
    final season = widget.season;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF167CB5),
        foregroundColor: Colors.white,
        title: const Text('PLAYER'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            color: const Color(0xFF167CB5),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 43,
                          backgroundColor: Colors.white,
                          child: Text(
                            player.number,
                            style: const TextStyle(
                              color: Color(0xFF167CB5),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -3,
                          bottom: -2,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: _Badge(club: club, size: 25),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () =>
                              setState(() => _isFollowing = !_isFollowing),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: Text(_isFollowing ? 'Following' : 'Follow'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Text(
                  _shortName(player.name),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  player.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${player.position} / ${club.name} / $season',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                const Text(
                  'SAMPLE PROFILE · VERIFY DATA BEFORE PUBLISHING',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: const Color(0xFF148B4D),
              unselectedLabelColor: const Color(0xFF858B91),
              indicatorColor: const Color(0xFF148B4D),
              tabs: const [
                Tab(text: 'News'),
                Tab(text: 'Stats'),
                Tab(text: 'Rating'),
                Tab(text: 'Match'),
                Tab(text: 'Info'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ProfilePlaceholder(
                  title: 'Player news',
                  description:
                      'Verified news about this player will appear here.',
                ),
                _ProfilePlaceholder(
                  title: 'Season statistics',
                  description: 'Appearances, goals, assists and other verified statistics will appear here.',
                ),
                _ProfilePlaceholder(
                  title: 'Player rating',
                  description: 'Ratings will appear when an approved match-data source is connected.',
                ),
                _ProfilePlaceholder(
                  title: 'Match history',
                  description:
                      'Past and upcoming match appearances will appear here.',
                ),
                _PlayerInfoContent(player: player, club: club, season: season),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortName(String name) {
    final parts = name.split(' ');
    return parts.length > 1 ? parts.last : name;
  }
}

class _PlayerInfoContent extends StatelessWidget {
  const _PlayerInfoContent({
    required this.player,
    required this.club,
    required this.season,
  });

  final _Player player;
  final _Club club;
  final String season;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const _ProfileSectionHeader(title: 'Info'),
        _ProfileInfoRow(label: 'Name', value: player.name),
        _ProfileInfoRow(label: 'Full name', value: player.name),
        _ProfileInfoRow(label: 'Team', value: club.name),
        _ProfileInfoRow(label: 'Position', value: player.position),
        _ProfileInfoRow(label: 'Squad number', value: player.number),
        const _ProfileInfoRow(
          label: 'Nationality',
          value: 'Awaiting verified data',
        ),
        const _ProfileInfoRow(
          label: 'Birth date',
          value: 'Awaiting verified data',
        ),
        const _ProfileInfoRow(
          label: 'Career statistics',
          value: 'Awaiting verified data',
        ),
        const _ProfileSectionHeader(title: 'Market values'),
        const SizedBox(height: 14),
        const _MarketValuePlaceholder(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Text(
            'Season: $season · Verified market-value history is not connected.',
            style: const TextStyle(
              color: Color(0xFF858B91),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSectionHeader extends StatelessWidget {
  const _ProfileSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F1F2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF40464B),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 51),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F1F2))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF9AA0A5), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF343A40),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder({required this.title, required this.description});

  final String title;
  final String description;

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
              color: Color(0xFF167CB5),
              size: 38,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF627D98),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketValuePlaceholder extends StatelessWidget {
  const _MarketValuePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        border: Border.all(color: const Color(0xFFE8ECEE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            'Market value history will appear here when verified data is available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF858B91),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }
}
