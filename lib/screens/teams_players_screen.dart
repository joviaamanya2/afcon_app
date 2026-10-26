import 'package:flutter/material.dart';

import '../services/afcon_api.dart';
import 'pamoja_2027_screen.dart';
import 'pamoja_tournament_card.dart';

class TeamsPlayersScreen extends StatefulWidget {
  const TeamsPlayersScreen({super.key, this.initialTeam});

  final String? initialTeam;

  @override
  State<TeamsPlayersScreen> createState() => _TeamsPlayersScreenState();
}

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({
    super.key,
    required this.playerName,
    required this.teamName,
    required this.position,
    required this.squadNumber,
    required this.season,
  });

  final String playerName;
  final String teamName;
  final String position;
  final String squadNumber;
  final String season;

  @override
  Widget build(BuildContext context) => _PlayerProfileScreen(
    player: _Player(playerName, position, squadNumber),
    club: _Club(
      teamName,
      season.split('/').first,
      teamName.isEmpty ? '?' : teamName[0].toUpperCase(),
      const Color(0xFF800000),
    ),
    season: season,
  );
}

class _TeamsPlayersScreenState extends State<TeamsPlayersScreen> {
  static const _brandMaroon = Color(0xFF800000);
  static const _ink = Color(0xFF1E1E1E);
  static const _muted = Color(0xFF666666);
  static const _leagues = [
    'East Africa',
    'West Africa',
    'North Africa',
    'Central Africa',
    'Southern Africa',
  ];
  static const _clubs = <String, List<_Club>>{
    'East Africa': [
      _Club('Uganda', '2020', 'U', Color(0xFF126B45)),
      _Club('Kenya', '2020', 'K', Color(0xFFD84343)),
      _Club('Tanzania', '2020', 'T', Color(0xFF25845C)),
      _Club('Rwanda', '2020', 'R', Color(0xFF3976B8)),
      _Club('Burundi', '2020', 'B', Color(0xFFB84043)),
      _Club('Sudan', '2020', 'S', Color(0xFF25845C)),
      _Club('Ethiopia', '2020', 'E', Color(0xFF25845C)),
      _Club('South Sudan', '2020', 'S', Color(0xFF3976B8)),
      _Club('Eritrea', '2020', 'E', Color(0xFFB84043)),
      _Club('Djibouti', '2020', 'D', Color(0xFF3976B8)),
      _Club('Somalia', '2020', 'S', Color(0xFF3976B8)),
    ],
    'West Africa': [
      _Club('Senegal', '2020', 'S', Color(0xFF16834B)),
      _Club('Ivory Coast', '2020', 'C', Color(0xFFE98232)),
      _Club('Ghana', '2020', 'G', Color(0xFFD84343)),
      _Club('Nigeria', '2020', 'N', Color(0xFF16834B)),
      _Club('Mali', '2020', 'M', Color(0xFF16834B)),
      _Club('Burkina Faso', '2020', 'B', Color(0xFFD84343)),
      _Club('Guinea', '2020', 'G', Color(0xFFD84343)),
      _Club('The Gambia', '2020', 'G', Color(0xFFB84043)),
      _Club('Togo', '2020', 'T', Color(0xFF16834B)),
      _Club('Benin', '2020', 'B', Color(0xFF16834B)),
      _Club('Niger', '2020', 'N', Color(0xFFE98232)),
      _Club('Liberia', '2020', 'L', Color(0xFFD84343)),
      _Club('Sierra Leone', '2020', 'S', Color(0xFF25845C)),
      _Club('Mauritania', '2020', 'M', Color(0xFF16834B)),
      _Club('Guinea-Bissau', '2020', 'G', Color(0xFFD84343)),
      _Club('Cabo Verde', '2020', 'C', Color(0xFF3976B8)),
    ],
    'North Africa': [
      _Club('Morocco', '2020', 'M', Color(0xFFD84343)),
      _Club('Egypt', '2020', 'E', Color(0xFFD84343)),
      _Club('Algeria', '2020', 'A', Color(0xFF16834B)),
      _Club('Tunisia', '2020', 'T', Color(0xFFD84343)),
      _Club('Libya', '2020', 'L', Color(0xFF16834B)),
    ],
    'Central Africa': [
      _Club('Cameroon', '2020', 'C', Color(0xFFD84343)),
      _Club('DR Congo', '2020', 'D', Color(0xFF3976B8)),
      _Club('Congo', '2020', 'C', Color(0xFF16834B)),
      _Club('Gabon', '2020', 'G', Color(0xFF25845C)),
      _Club('Equatorial Guinea', '2020', 'E', Color(0xFFD84343)),
      _Club('Chad', '2020', 'C', Color(0xFFE98232)),
      _Club('Central African Republic', '2020', 'C', Color(0xFF3976B8)),
      _Club('Sao Tome and Principe', '2020', 'S', Color(0xFF16834B)),
    ],
    'Southern Africa': [
      _Club('South Africa', '2020', 'S', Color(0xFF16834B)),
      _Club('Zambia', '2020', 'Z', Color(0xFF16834B)),
      _Club('Angola', '2020', 'A', Color(0xFFD84343)),
      _Club('Zimbabwe', '2020', 'Z', Color(0xFF16834B)),
      _Club('Botswana', '2020', 'B', Color(0xFF3976B8)),
      _Club('Namibia', '2020', 'N', Color(0xFF3976B8)),
      _Club('Mozambique', '2020', 'M', Color(0xFF16834B)),
      _Club('Malawi', '2020', 'M', Color(0xFFD84343)),
      _Club('Madagascar', '2020', 'M', Color(0xFFD84343)),
      _Club('Lesotho', '2020', 'L', Color(0xFF3976B8)),
      _Club('Eswatini', '2020', 'E', Color(0xFF25845C)),
      _Club('Comoros', '2020', 'C', Color(0xFF16834B)),
      _Club('Mauritius', '2020', 'M', Color(0xFFD84343)),
      _Club('Seychelles', '2020', 'S', Color(0xFF3976B8)),
    ],
  };
  static const _samplePlayers = <String, List<_Player>>{
    'Uganda': [
      _Player('Denis Onyango', 'Goalkeeper', '18'),
      _Player('Khalid Aucho', 'Midfielder', '8'),
      _Player('Rogers Mato', 'Forward', '17', {
        'Goals': 4,
        'Assists': 2,
        'Yellow cards': 1,
      }),
    ],
    'Ghana': [
      _Player('Mohammed Kudus', 'Midfielder', '20', {
        'Goals': 5,
        'Assists': 3,
        'Yellow cards': 2,
      }),
      _Player('Thomas Partey', 'Midfielder', '5'),
      _Player('Jordan Ayew', 'Forward', '9'),
    ],
    'Nigeria': [
      _Player('Victor Osimhen', 'Forward', '9', {
        'Goals': 6,
        'Assists': 1,
        'Yellow cards': 1,
      }),
      _Player('Alex Iwobi', 'Midfielder', '17'),
      _Player('Ademola Lookman', 'Forward', '7'),
    ],
    'Morocco': [
      _Player('Achraf Hakimi', 'Defender', '2'),
      _Player('Brahim Diaz', 'Forward', '10'),
      _Player('Youssef En-Nesyri', 'Forward', '19'),
    ],
    'Senegal': [
      _Player('Sadio Mane', 'Forward', '10'),
      _Player('Kalidou Koulibaly', 'Defender', '3'),
      _Player('Nicolas Jackson', 'Forward', '11'),
    ],
    'Egypt': [
      _Player('Mohamed Salah', 'Forward', '10'),
      _Player('Omar Marmoush', 'Forward', '7'),
    ],
    'South Africa': [
      _Player('Ronwen Williams', 'Goalkeeper', '1'),
      _Player('Percy Tau', 'Forward', '10'),
      _Player('Lyle Foster', 'Forward', '9'),
    ],
    'Ivory Coast': [
      _Player('Franck Kessie', 'Midfielder', '8'),
      _Player('Simon Adingra', 'Forward', '10'),
      _Player('Sebastien Haller', 'Forward', '22'),
    ],
  };
  String _selectedLeague = _leagues.first;
  _Club? _selectedClub;
  String? _selectedSeason;
  String _selectedPlayerStat = 'Goals';
  bool _descendingPlayerStats = true;
  final _playersSectionKey = GlobalKey();
  final _api = AfconApi();
  List<Map<String, dynamic>> _backendTeams = [];
  List<Map<String, dynamic>> _backendPlayers = [];

  Future<void> _loadBackendTeams() async {
    try {
      final teams = await _api.teams();
      if (!mounted) return;
      setState(() => _backendTeams = teams);
      if (teams.isNotEmpty) {
        final regions = teams.map((team) {
          final region = '${team['region'] ?? ''}'.trim();
          return region.isEmpty ? 'Unassigned' : region;
        }).toSet();
        if (regions.isNotEmpty && !regions.contains(_selectedLeague)) {
          setState(() => _selectedLeague = regions.first);
        }
        final intendedTeam = widget.initialTeam ?? _selectedClub?.name;
        final selected = teams
            .where((team) => '${team['name']}' == intendedTeam)
            .toList();
        final firstTeam = selected.isNotEmpty ? selected.first : teams.first;
        final teamRegion = '${firstTeam['region'] ?? ''}'.trim();
        final teamName = '${firstTeam['name'] ?? 'Team'}';
        final teamId = '${firstTeam['id'] ?? ''}';
        if (intendedTeam != null && selected.isNotEmpty) {
          setState(() {
            _selectedLeague = teamRegion.isEmpty ? 'Unassigned' : teamRegion;
            _selectedClub = _Club(
              teamName,
              DateTime.now().year.toString(),
              teamName.substring(0, 1).toUpperCase(),
              _brandMaroon,
              id: teamId,
            );
          });
        }
        if (teamId.isNotEmpty) _loadBackendPlayers(teamId);
      }
    } catch (_) {
      // Preview teams remain available when the API is offline.
    }
  }

  Future<void> _loadBackendPlayers(String teamId) async {
    try {
      final players = await _api.players(teamId: teamId);
      if (mounted) setState(() => _backendPlayers = players);
    } catch (_) {
      if (mounted) setState(() => _backendPlayers = []);
    }
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadBackendTeams();
    final team = widget.initialTeam;
    if (team == null) return;
    for (final league in _leagues) {
      final matchingTeam = _clubs[league]!.where((club) => club.name == team);
      if (matchingTeam.isNotEmpty) {
        _selectedLeague = league;
        _selectedClub = matchingTeam.first;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final targetContext = _playersSectionKey.currentContext;
          if (targetContext != null) {
            Scrollable.ensureVisible(
              targetContext,
              duration: const Duration(milliseconds: 450),
              alignment: 0.08,
            );
          }
        });
        return;
      }
    }
  }

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

  String _playerStatLabel(String key) {
    final label = key.replaceAll('_', ' ');
    return label.isEmpty
        ? label
        : '${label[0].toUpperCase()}${label.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final backendRegions = _backendTeams.map((team) {
      final region = '${team['region'] ?? ''}'.trim();
      return region.isEmpty ? 'Unassigned' : region;
    }).toSet();
    final leagues = _backendTeams.isEmpty ? _leagues : backendRegions.toList();
    final activeLeague = leagues.contains(_selectedLeague)
        ? _selectedLeague
        : leagues.first;
    final backendRegionTeams = _backendTeams.where((team) {
      final region = '${team['region'] ?? ''}'.trim();
      return (region.isEmpty ? 'Unassigned' : region) == activeLeague;
    }).toList();
    final clubs = backendRegionTeams.isNotEmpty
        ? backendRegionTeams
              .map(
                (team) => _Club(
                  '${team['name'] ?? 'Team'}',
                  DateTime.now().year.toString(),
                  (('${team['short_name'] ?? team['name'] ?? 'T'}')
                              .trim()
                              .isEmpty
                          ? 'T'
                          : '${team['short_name'] ?? team['name'] ?? 'T'}'
                                .trim()
                                .substring(0, 1))
                      .toUpperCase(),
                  _brandMaroon,
                  id: '${team['id'] ?? ''}',
                ),
              )
              .toList()
        : _clubs[activeLeague] ?? _clubs[_leagues.first]!;
    final matchingClubs = clubs.where(
      (club) => club.name == _selectedClub?.name,
    );
    final selectedClub = matchingClubs.isNotEmpty
        ? matchingClubs.first
        : clubs.first;
    final seasons = _seasonsFor(selectedClub);
    final selectedSeason = seasons.contains(_selectedSeason)
        ? _selectedSeason!
        : seasons.first;
    final players = selectedClub.id != null
        ? _backendPlayers.map((record) {
            final stats = record['stats'] is Map
                ? (record['stats'] as Map).map(
                    (key, value) => MapEntry(
                      _playerStatLabel('$key'),
                      value is num
                          ? value.toInt()
                          : int.tryParse('$value') ?? 0,
                    ),
                  )
                : <String, int>{};
            return _Player(
              '${record['name'] ?? 'Player'}',
              '${record['position'] ?? 'Player'}',
              '${record['shirt_number'] ?? '—'}',
              stats,
            );
          }).toList()
        : _samplePlayers[selectedClub.name] ?? const <_Player>[];
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
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Teams & players'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        foregroundColor: _ink,
        titleTextStyle: const TextStyle(
          color: _ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          PamojaTournamentCard(
            onOpenTournament: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const Pamoja2027Screen()),
            ),
          ),
          const Text(
            'National teams across Africa',
            style: TextStyle(
              color: _ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Browse national sides by region, then explore available squad previews.',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 18),
          const Text(
            'Browse by region',
            style: TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: leagues.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final league = leagues[index];
                final selected = league == _selectedLeague;
                return ChoiceChip(
                  label: Text(league),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: const Color(0xFF176B46),
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
          Text(
            'Teams · ${clubs.length}',
            style: const TextStyle(
              color: _ink,
              fontSize: 16,
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
                  onTap: () {
                    setState(() {
                      _selectedClub = club;
                      _selectedSeason = null;
                      _backendPlayers = [];
                    });
                    if (club.id != null) _loadBackendPlayers(club.id!);
                  },
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
            key: _playersSectionKey,
            children: [
              Expanded(
                child: Text(
                  '${selectedClub.name} squad',
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
                  color: _brandMaroon,
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
    final firstSeason = int.parse(club.sampleStartYear);
    return [
      for (var year = currentSeasonStart; year >= firstSeason; year--)
        '$year/${(year + 1).toString().substring(2)}',
    ];
  }
}

class _Club {
  const _Club(
    this.name,
    this.sampleStartYear,
    this.badgeLetter,
    this.color, {
    this.id,
  });

  final String name;
  final String sampleStartYear;
  final String badgeLetter;
  final Color color;
  final String? id;

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
                    color: Color(0xFF1E1E1E),
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
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5ECEE)),
        borderRadius: BorderRadius.circular(12),
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
                    color: Color(0xFF1E1E1E),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'National team · sample season archive',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: const Key('player-season-picker'),
              value: selectedSeason,
              dropdownColor: Colors.white,
              iconEnabledColor: const Color(0xFF1E1E1E),
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
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
              color: Color(0xFF800000),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${club.name} · ${player.position}',
          style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${player.stats[statLabel] ?? '—'}',
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              statLabel,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 9),
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
          const Icon(Icons.history_rounded, color: Color(0xFF800000)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'The $season squad archive is not connected yet. Historical players will appear here when verified records are available.',
              style: const TextStyle(
                color: Color(0xFF666666),
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
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E1E),
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text('PLAYER'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            color: const Color(0xFF800000),
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
                              color: Color(0xFF800000),
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
              labelColor: const Color(0xFF800000),
              unselectedLabelColor: const Color(0xFF858B91),
              indicatorColor: const Color(0xFF800000),
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
              color: Color(0xFF800000),
              size: 38,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF666666),
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
