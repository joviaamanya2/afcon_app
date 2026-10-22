import 'dart:async';

import 'package:flutter/material.dart';

import 'screens/explore_screen.dart';
import 'screens/afcon_feature_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/teams_players_screen.dart';
import 'screens/updates_screen.dart';
import './screens/afcon_theme.dart';

void main() {
  runApp(const AfconApp());
}

const _navy = Color(0xFF172B27);
const _green = Color(0xFF176B46);
const _gold = Color(0xFFD8A441);
const _ink = Color(0xFF19251F);
const _muted = Color(0xFF69766F);
const _canvas = Color(0xFFF6F8F6);

class AfconApp extends StatelessWidget {
  const AfconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AFCON Fan',
      debugShowCheckedModeBanner: false,
      theme: buildAfconTheme(),
      home: const AfconHome(),
    );
  }
}

class AfconHome extends StatefulWidget {
  const AfconHome({super.key});

  @override
  State<AfconHome> createState() => _AfconHomeState();
}

class _AfconHomeState extends State<AfconHome> {
  int _selectedIndex = 0;
  String _selectedLanguage = 'English';

  void _openMatches() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const MatchesScreen()),
    );
  }

  void _openShortcut(String title) {
    if (title == 'Teams & players') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const TeamsPlayersScreen(),
        ),
      );
      return;
    }

    if (title == 'Updates') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (context) => const UpdatesScreen()),
      );
      return;
    }

    if ([
      'Media',
      'Events',
      'Venues',
      'Ask AFCON',
      'Follow teams',
      'Notifications',
    ].contains(title)) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => AfconFeatureScreen(feature: title),
        ),
      );
      return;
    }

    final details = switch (title) {
      _ => 'Official AFCON content will appear here when it is available.',
    };

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _SurfaceCard(
                child: Text(
                  details,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: const _SettingsPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: const _BrandMark(),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _openShortcut('Notifications'),
            style: IconButton.styleFrom(
              foregroundColor: _green,
              backgroundColor: const Color(0xFFEAF3ED),
              shape: const CircleBorder(),
            ),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 22),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD84343),
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Open menu',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              style: IconButton.styleFrom(
                foregroundColor: _green,
                backgroundColor: const Color(0xFFEAF3ED),
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.menu_rounded),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'AFCON FAN',
                style: TextStyle(
                  color: _ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your tournament, your language',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
              const SizedBox(height: 24),
              const Text(
                'APP LANGUAGE',
                style: TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: _LanguagePicker(
                  selectedLanguage: _selectedLanguage,
                  onChanged: (language) =>
                      setState(() => _selectedLanguage = language),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.tune_rounded, color: _green),
                title: const Text('Settings'),
                subtitle: const Text('Accessibility, data use and privacy'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openSettings();
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _HomePage(
                  onOpenMatches: _openMatches,
                  onOpenShortcut: _openShortcut,
                  language: _selectedLanguage,
                ),
                const _InfoPage(
                  icon: Icons.sports_soccer_rounded,
                  title: 'Matches',
                  subtitle: 'Fixtures, results, standings, line-ups and match venues will appear here.',
                  detail: 'Official match information has not been connected yet. Dates, scores and venues will be shown here once an approved source is available.',
                ),
                const ExploreScreen(),
                const AfconFeatureScreen(
                  feature: 'Community',
                  showAppBar: false,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            _openMatches();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer_rounded),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum_rounded),
            label: 'Community',
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.sports_soccer_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AFCON FAN',
              style: TextStyle(
                color: _ink,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              'TOGETHER IN FOOTBALL',
              style: TextStyle(
                color: _muted,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({
    required this.selectedLanguage,
    required this.onChanged,
  });

  final String selectedLanguage;
  final ValueChanged<String> onChanged;

  static const _languages = ['English', 'Luganda', 'French', 'Swahili'];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Choose app language',
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 6),
        decoration: BoxDecoration(
          color: _canvas,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedLanguage,
            borderRadius: BorderRadius.circular(12),
            icon: const Icon(Icons.expand_more_rounded, size: 19),
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            items: _languages
                .map(
                  (language) =>
                      DropdownMenuItem(value: language, child: Text(language)),
                )
                .toList(),
            onChanged: (language) {
              if (language != null) onChanged(language);
            },
          ),
        ),
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({
    required this.onOpenMatches,
    required this.onOpenShortcut,
    required this.language,
  });

  final VoidCallback onOpenMatches;
  final ValueChanged<String> onOpenShortcut;
  final String language;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        _QuickLinks(onSelected: onOpenShortcut),
        const SizedBox(height: 2),
        _TodaysMatches(onOpenMatches: onOpenMatches),
        const SizedBox(height: 14),
        _WelcomeBanner(language: language),
        const SizedBox(height: 24),
        _SectionHeading(
          title: 'Happening around you',
          actionLabel: 'Explore events',
          onAction: () => onOpenShortcut('Events'),
        ),
        const SizedBox(height: 12),
        const _EventsPlaceholder(),
        const SizedBox(height: 24),
        const _TranslationCard(),
      ],
    );
  }
}

class _TodaysMatches extends StatelessWidget {
  const _TodaysMatches({required this.onOpenMatches});

  final VoidCallback onOpenMatches;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = const [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ][now.month - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: "Today's matches",
          actionLabel: 'All matches',
          onAction: onOpenMatches,
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _TodayMatchCard(
                dateLabel: '${now.day} $month',
                homeTeam: 'Uganda',
                awayTeam: 'Ghana',
                time: '19:45',
                onTap: onOpenMatches,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WelcomeBanner extends StatefulWidget {
  const _WelcomeBanner({required this.language});

  final String language;

  @override
  State<_WelcomeBanner> createState() => _WelcomeBannerState();
}

class _WelcomeBannerState extends State<_WelcomeBanner> {
  static const _images = ['assets/images/main.webp', 'assets/images/cup.png'];

  final _pageController = PageController();
  Timer? _rotationTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _rotationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % _images.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: _navy,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A102A43),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            child: PageView.builder(
              key: const Key('home-hero-image-carousel'),
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) => Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _images[index],
                    key: ValueKey(_images[index]),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.03),
                          _navy.withValues(alpha: 0.88),
                        ],
                        stops: const [0.2, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 14,
                    child: Text(
                      index == 0
                          ? 'THE ROAD TO AFCON 2025'
                          : 'ONE TROPHY. ONE CONTINENT.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'YOUR TOURNAMENT, YOUR LANGUAGE',
                        style: TextStyle(
                          color: Color(0xFFFFD978),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(
                        _images.length,
                        (index) => Semantics(
                          button: true,
                          selected: _currentPage == index,
                          label: 'Show AFCON image ${index + 1}',
                          child: GestureDetector(
                            key: Key('home-hero-indicator-$index'),
                            onTap: () => _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeInOutCubic,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: _currentPage == index ? 18 : 7,
                              height: 7,
                              margin: const EdgeInsets.only(left: 5),
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? _gold
                                    : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'The beautiful game,\ncloser to everyone.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your experience is set to ${widget.language}. Follow matches, explore events and enjoy the conversation.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Icon(Icons.translate_rounded, color: _gold, size: 18),
                    SizedBox(width: 7),
                    Text(
                      'Football for every language',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: _green,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            actionLabel,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _TodayMatchCard extends StatelessWidget {
  const _TodayMatchCard({
    required this.dateLabel,
    required this.homeTeam,
    required this.awayTeam,
    required this.time,
    required this.onTap,
  });

  final String dateLabel;
  final String homeTeam;
  final String awayTeam;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 310,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8EEF0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080B2D36),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'TODAY · $dateLabel · $time',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const Text(
                      'SAMPLE',
                      style: TextStyle(
                        color: Color(0xFF9A6B10),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _HomeFixtureTeam(
                        name: homeTeam,
                        initial: 'U',
                        color: _green,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _HomeFixtureTeam(
                        name: awayTeam,
                        initial: 'G',
                        color: const Color(0xFFD84343),
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeFixtureTeam extends StatelessWidget {
  const _HomeFixtureTeam({
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: _ink,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 5),
        ],
        _HomeTeamBadge(initial: initial, color: color),
        if (!alignEnd) ...[
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HomeTeamBadge extends StatelessWidget {
  const _HomeTeamBadge({required this.initial, required this.color});

  final String initial;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
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
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EventsPlaceholder extends StatelessWidget {
  const _EventsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.location_city_rounded, color: _green),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover regional events',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Official activities and locations will be listed here.',
                  style: TextStyle(color: _muted, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _muted),
        ],
      ),
    );
  }
}

class _TranslationCard extends StatefulWidget {
  const _TranslationCard();

  @override
  State<_TranslationCard> createState() => _TranslationCardState();
}

class _TranslationCardState extends State<_TranslationCard> {
  bool _captionsEnabled = false;
  String _captionLanguage = 'Luganda';

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.graphic_eq_rounded, color: _green),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live language captions',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Follow spoken content in your language',
                      style: TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _captionsEnabled,
                activeTrackColor: _green,
                onChanged: (value) => setState(() => _captionsEnabled = value),
              ),
            ],
          ),
          if (_captionsEnabled) ...[
            const SizedBox(height: 14),
            const _StatusPill(
              label: 'Preview only · No live audio connected',
              color: Color(0xFFFFF5DD),
              textColor: Color(0xFF805700),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _captionLanguage,
              decoration: InputDecoration(
                labelText: 'Caption language',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Luganda', child: Text('Luganda')),
                DropdownMenuItem(value: 'Swahili', child: Text('Swahili')),
                DropdownMenuItem(value: 'French', child: Text('French')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _captionLanguage = value);
              },
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Sample caption in $_captionLanguage will appear here when an approved audio feed is connected.',
                style: const TextStyle(color: _ink, fontSize: 12, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickLink(
            icon: Icons.groups_rounded,
            label: 'Teams & players',
            onTap: () => onSelected('Teams & players'),
          ),
          const SizedBox(width: 9),
          _QuickLink(
            icon: Icons.play_circle_outline,
            label: 'Media',
            onTap: () => onSelected('Media'),
          ),
          const SizedBox(width: 9),
          _QuickLink(
            icon: Icons.notifications_none,
            label: 'Updates',
            onTap: () => onSelected('Updates'),
          ),
          const SizedBox(width: 9),
          _QuickLink(
            icon: Icons.star_outline_rounded,
            label: 'Follow teams',
            onTap: () => onSelected('Follow teams'),
          ),
          const SizedBox(width: 9),
          _QuickLink(
            icon: Icons.auto_awesome_rounded,
            label: 'Ask AFCON',
            onTap: () => onSelected('Ask AFCON'),
          ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE5ECEE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: _green),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPage extends StatelessWidget {
  const _InfoPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: _muted, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 20),
        _SurfaceCard(
          child: Column(
            children: [
              _EmptyIcon(icon: icon),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            color: _ink,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Make the app work better for you.',
          style: TextStyle(color: _muted, fontSize: 14),
        ),
        const SizedBox(height: 20),
        _SurfaceCard(
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.translate_rounded,
                title: 'Language',
                subtitle: 'Choose your preferred app language above',
              ),
              const Divider(height: 24),
              const _SettingsRow(
                icon: Icons.accessibility_new_rounded,
                title: 'Accessibility',
                subtitle: 'Readable text and assistive technology support',
              ),
              const Divider(height: 24),
              const _SettingsRow(
                icon: Icons.data_saver_on_rounded,
                title: 'Data saving',
                subtitle: 'Options for slower or limited connections',
              ),
              const Divider(height: 24),
              const _SettingsRow(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                subtitle: 'Privacy information will be provided before launch',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _green, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: _muted, size: 20),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EEF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B2D36),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EmptyIcon extends StatelessWidget {
  const _EmptyIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: _green, size: 26),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
