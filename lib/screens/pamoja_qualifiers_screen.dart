import 'package:flutter/material.dart';

import '../data/pamoja_match_data.dart';

const _qualifierCanvas = Color(0xFFF5F7F6);
const _qualifierInk = Color(0xFF202A25);
const _qualifierGreen = Color(0xFF176B46);
const _qualifierCard = Colors.white;
const _qualifierMuted = Color(0xFF68736D);
const _potColors = <int, Color>{
  1: Color(0xFF34443B),
  2: Color(0xFFC2410C),
  3: Color(0xFF0F766E),
  4: Color(0xFF6D28D9),
};

const _pots = <int, List<String>>{
  1: [
    'Morocco',
    'Senegal',
    'Nigeria',
    'Algeria',
    'Egypt',
    'Côte d’Ivoire',
    'Tunisia',
    'Cameroon',
    'DR Congo',
    'Mali',
    'South Africa',
    'Burkina Faso',
  ],
  2: [
    'Cape Verde',
    'Ghana',
    'Guinea',
    'Gabon',
    'Uganda',
    'Angola',
    'Benin',
    'Zambia',
    'Mozambique',
    'Madagascar',
    'Equatorial Guinea',
    'Comoros',
  ],
  3: [
    'Kenya',
    'Libya',
    'Tanzania',
    'Niger',
    'Mauritania',
    'The Gambia',
    'Sudan',
    'Sierra Leone',
    'Namibia',
    'Togo',
    'Malawi',
    'Rwanda',
  ],
  4: [
    'Zimbabwe',
    'Guinea-Bissau',
    'Congo',
    'Central African Republic',
    'Liberia',
    'Burundi',
    'Ethiopia',
    'Lesotho',
    'Botswana',
    'South Sudan',
    'Eritrea',
    'Somalia',
  ],
};

const _teamFlags = <String, String>{
  'Morocco': '🇲🇦',
  'Gabon': '🇬🇦',
  'Niger': '🇳🇪',
  'Lesotho': '🇱🇸',
  'Egypt': '🇪🇬',
  'Angola': '🇦🇴',
  'Malawi': '🇲🇼',
  'South Sudan': '🇸🇸',
  'Côte d’Ivoire': '🇨🇮',
  'Ghana': '🇬🇭',
  'The Gambia': '🇬🇲',
  'Somalia': '🇸🇴',
  'South Africa': '🇿🇦',
  'Guinea': '🇬🇳',
  'Kenya': '🇰🇪',
  'Eritrea': '🇪🇷',
  'DR Congo': '🇨🇩',
  'Equatorial Guinea': '🇬🇶',
  'Sierra Leone': '🇸🇱',
  'Zimbabwe': '🇿🇼',
  'Burkina Faso': '🇧🇫',
  'Benin': '🇧🇯',
  'Mauritania': '🇲🇷',
  'Central African Republic': '🇨🇫',
  'Cameroon': '🇨🇲',
  'Comoros': '🇰🇲',
  'Namibia': '🇳🇦',
  'Congo': '🇨🇬',
  'Tunisia': '🇹🇳',
  'Uganda': '🇺🇬',
  'Libya': '🇱🇾',
  'Botswana': '🇧🇼',
  'Algeria': '🇩🇿',
  'Zambia': '🇿🇲',
  'Togo': '🇹🇬',
  'Burundi': '🇧🇮',
  'Senegal': '🇸🇳',
  'Mozambique': '🇲🇿',
  'Sudan': '🇸🇩',
  'Ethiopia': '🇪🇹',
  'Mali': '🇲🇱',
  'Cape Verde': '🇨🇻',
  'Rwanda': '🇷🇼',
  'Liberia': '🇱🇷',
  'Nigeria': '🇳🇬',
  'Madagascar': '🇲🇬',
  'Tanzania': '🇹🇿',
  'Guinea-Bissau': '🇬🇼',
};

class _QualifierTeam {
  const _QualifierTeam({
    required this.name,
    required this.group,
    required this.pot,
  });

  final String name;
  final String group;
  final int pot;
}

final _qualifierTeams = [
  for (final group in pamojaGroups)
    for (final name in group.teams)
      _QualifierTeam(name: name, group: group.code, pot: _potFor(name)),
];

int _potFor(String team) {
  for (final entry in _pots.entries) {
    if (entry.value.contains(team)) return entry.key;
  }
  throw StateError('No draw pot found for $team');
}

class PamojaQualifiersScreen extends StatefulWidget {
  const PamojaQualifiersScreen({super.key, this.initialView = 'Groups'});

  final String initialView;

  @override
  State<PamojaQualifiersScreen> createState() => _PamojaQualifiersScreenState();
}

class _PamojaQualifiersScreenState extends State<PamojaQualifiersScreen> {
  static const _views = ['Groups', 'Draw Pots', 'Table'];

  late String _selectedView = widget.initialView;
  final _searchController = TextEditingController();
  String _sortColumn = 'group';
  bool _ascending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _query => _searchController.text.trim().toLowerCase();

  bool _matches(_QualifierTeam team) {
    final query = _query;
    if (query.isEmpty) return true;
    return team.name.toLowerCase().contains(query) ||
        query == team.group.toLowerCase() ||
        query == 'group ${team.group.toLowerCase()}' ||
        query == '${team.pot}' ||
        query == 'pot ${team.pot}';
  }

  List<_QualifierTeam> get _matchedTeams =>
      _qualifierTeams.where(_matches).toList();

  @override
  Widget build(BuildContext context) {
    final matched = _matchedTeams;
    return Scaffold(
      backgroundColor: _qualifierCanvas,
      appBar: AppBar(
        title: const Text('AFCON 2027 Qualifiers'),
        backgroundColor: Colors.white,
        foregroundColor: _qualifierInk,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const Text(
              'AFCON 2027\nQUALIFIERS',
              key: Key('qualifiers-page-title'),
              style: TextStyle(
                color: _qualifierInk,
                fontSize: 32,
                height: 1.04,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pamoja 2027 · Kenya, Tanzania & Uganda · 12 groups, 48 teams',
              style: TextStyle(
                color: _qualifierMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _viewSelector(),
            const SizedBox(height: 12),
            TextField(
              key: const Key('qualifiers-search'),
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Find a team, group or pot (e.g. Uganda, H, 3)',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: _qualifierCard,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFDCE3DE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: _qualifierGreen,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _potLegend(),
            const SizedBox(height: 12),
            Text(
              _query.isEmpty
                  ? '48 teams · switch views to explore the draw'
                  : '${matched.length} of 48 teams match',
              key: const Key('qualifiers-result-count'),
              style: const TextStyle(
                color: _qualifierMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedView == 'Groups')
              _groupsView()
            else if (_selectedView == 'Draw Pots')
              _potsView()
            else
              _tableView(matched),
          ],
        ),
      ),
    );
  }

  Widget _viewSelector() => Container(
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFDCE3DE)),
      borderRadius: BorderRadius.circular(12),
    ),
    clipBehavior: Clip.antiAlias,
    child: Row(
      children: [
        for (final view in _views)
          Expanded(
            child: Semantics(
              button: true,
              selected: _selectedView == view,
              child: InkWell(
                key: Key('qualifiers-tab-$view'),
                onTap: () => setState(() => _selectedView = view),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 5,
                  ),
                  color: _selectedView == view ? _qualifierGreen : null,
                  child: Text(
                    view,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedView == view
                          ? Colors.white
                          : _qualifierInk,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _potLegend() => Wrap(
    spacing: 9,
    runSpacing: 7,
    children: [
      for (final pot in _pots.keys)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: _potColors[pot],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Pot $pot',
              style: const TextStyle(
                color: _qualifierMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
    ],
  );

  Widget _groupsView() => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 760
          ? 3
          : constraints.maxWidth >= 500
          ? 2
          : 1;
      final cardWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final group in pamojaGroups)
            SizedBox(
              width: cardWidth,
              child: _groupCard(group.code, group.teams),
            ),
        ],
      );
    },
  );

  Widget _groupCard(String group, List<String> teams) {
    final visibleTeams = teams.where((name) {
      final team = _teamFor(name);
      return _matches(team);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: _qualifierCard,
        border: Border.all(color: const Color(0xFFE1E7E3)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: _qualifierGreen,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'GROUP $group',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (visibleTeams.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No matching teams',
                style: TextStyle(color: _qualifierMuted, fontSize: 12),
              ),
            )
          else
            for (final team in visibleTeams) _teamRow(_teamFor(team)),
        ],
      ),
    );
  }

  Widget _potsView() => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 760
          ? 4
          : constraints.maxWidth >= 500
          ? 2
          : 1;
      final cardWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final entry in _pots.entries)
            SizedBox(width: cardWidth, child: _potCard(entry.key, entry.value)),
        ],
      );
    },
  );

  Widget _potCard(int pot, List<String> teams) {
    final visibleTeams = teams.where((name) {
      final team = _teamFor(name);
      return _matches(team);
    }).toList();
    final color = _potColors[pot]!;

    return Container(
      decoration: BoxDecoration(
        color: _qualifierCard,
        border: Border.all(color: color.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: color,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Text(
              'POT $pot',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (visibleTeams.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No matching teams',
                style: TextStyle(color: _qualifierMuted, fontSize: 12),
              ),
            )
          else
            for (final team in visibleTeams)
              _teamRow(_teamFor(team), showGroup: true),
        ],
      ),
    );
  }

  Widget _teamRow(_QualifierTeam team, {bool showGroup = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: _qualifierInk.withValues(alpha: 0.18)),
      ),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 31,
          child: Text(
            _teamFlags[team.name] ?? '🏳️',
            style: const TextStyle(fontSize: 17),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            team.name == 'Central African Republic'
                ? 'Central African R.'
                : team.name,
            style: const TextStyle(
              color: _qualifierInk,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (showGroup)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text(
              'Grp ${team.group}',
              style: const TextStyle(
                color: _qualifierMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: _potColors[team.pot],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Pot ${team.pot}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _tableView(List<_QualifierTeam> teams) {
    final sorted = [...teams]..sort(_compareTeams);
    return Container(
      decoration: BoxDecoration(
        color: _qualifierCard,
        border: Border.all(color: const Color(0xFFDCE3DE)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: switch (_sortColumn) {
            'team' => 0,
            'group' => 1,
            _ => 2,
          },
          sortAscending: _ascending,
          headingRowColor: const WidgetStatePropertyAll(_qualifierGreen),
          dataRowMinHeight: 44,
          dataRowMaxHeight: 52,
          columns: [
            DataColumn(
              label: _tableHeading('TEAM'),
              onSort: (_, ascending) => _setSort('team', ascending),
            ),
            DataColumn(
              label: _tableHeading('GROUP'),
              onSort: (_, ascending) => _setSort('group', ascending),
            ),
            DataColumn(
              label: _tableHeading('POT'),
              onSort: (_, ascending) => _setSort('pot', ascending),
            ),
          ],
          rows: [
            for (final team in sorted)
              DataRow(
                color: WidgetStatePropertyAll(
                  _potColors[team.pot]!.withValues(alpha: 0.08),
                ),
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _teamFlags[team.name] ?? '🏳️',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(_shortTeamName(team.name)),
                      ],
                    ),
                  ),
                  DataCell(Text('Group ${team.group}')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _potColors[team.pot],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Pot ${team.pot}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Text _tableHeading(String label) => Text(
    label,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w800,
    ),
  );

  int _compareTeams(_QualifierTeam left, _QualifierTeam right) {
    final comparison = switch (_sortColumn) {
      'team' => left.name.compareTo(right.name),
      'pot' => left.pot.compareTo(right.pot),
      _ => left.group.compareTo(right.group),
    };
    return _ascending ? comparison : -comparison;
  }

  void _setSort(String column, bool ascending) {
    setState(() {
      _sortColumn = column;
      _ascending = ascending;
    });
  }

  _QualifierTeam _teamFor(String name) =>
      _qualifierTeams.firstWhere((team) => team.name == name);

  String _shortTeamName(String name) =>
      name == 'Central African Republic' ? 'Central African R.' : name;
}
