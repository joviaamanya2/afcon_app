import 'dart:async';

import 'package:flutter/material.dart';

import 'screens/explore_screen.dart';
import 'screens/afcon_feature_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/teams_players_screen.dart';
import 'screens/updates_screen.dart';
import './screens/afcon_theme.dart';
import 'services/afcon_api.dart';

void main() {
  runApp(const AfconApp());
}

const _brandMaroon = Color.fromARGB(255, 136, 2, 9);
const _ink = Color(0xFF1E1E1E);
const _muted = Color(0xFF666666);
const _canvas = Color(0xFFF7F7F7);

class AfconApp extends StatelessWidget {
  const AfconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AFCON Fan',
      debugShowCheckedModeBanner: false,
      theme: buildAfconTheme(),
      home: const AfconSplashScreen(),
    );
  }
}

class AfconSplashScreen extends StatefulWidget {
  const AfconSplashScreen({super.key});

  @override
  State<AfconSplashScreen> createState() => _AfconSplashScreenState();
}

class _AfconSplashScreenState extends State<AfconSplashScreen> {
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, _, _) => const AfconHome(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.92, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  child: Image.asset(
                    'assets/images/afcon_logo_clean.png',
                    width: 270,
                    height: 270,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.sports_soccer_rounded,
                      color: _brandMaroon,
                      size: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'AFCON FAN',
                  style: TextStyle(
                    color: _brandMaroon,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'TOGETHER IN FOOTBALL',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE9E9E9))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Official Title Sponsor',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                'assets/images/official_partner_clean.png',
                width: 86,
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Text(
                  'TotalEnergies',
                  style: TextStyle(
                    color: _ink,
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

class AfconHome extends StatefulWidget {
  const AfconHome({super.key});

  @override
  State<AfconHome> createState() => _AfconHomeState();
}

class _AfconHomeState extends State<AfconHome> {
  int _selectedIndex = 0;
  String _selectedLanguage = 'English';
  String _selectedMatchCategory = 'All';
  int _matchScreenVersion = 0;

  void _openMatchCategory(String category) {
    if (category == 'Stats') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const MatchStatsScreen()));
      return;
    }
    setState(() {
      _selectedMatchCategory = category;
      _selectedIndex = 2;
      _matchScreenVersion++;
    });
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
              foregroundColor: _brandMaroon,
              backgroundColor: const Color(0xFFF5E6E6),
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
                foregroundColor: _brandMaroon,
                backgroundColor: const Color(0xFFF5E6E6),
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
                leading: const Icon(Icons.tune_rounded, color: _brandMaroon),
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
                  onOpenMatchCategory: _openMatchCategory,
                  onOpenShortcut: _openShortcut,
                  language: _selectedLanguage,
                ),
                const UpdatesScreen(showBackButton: false),
                MatchesScreen(
                  key: ValueKey('$_selectedMatchCategory-$_matchScreenVersion'),
                  initialCategory: _selectedMatchCategory,
                  showBackButton: false,
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
        onDestinationSelected: (index) => setState(() {
          _selectedIndex = index;
          if (index == 2) {
            _selectedMatchCategory = 'All';
            _matchScreenVersion++;
          }
        }),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article_rounded),
            label: 'News',
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E2D2)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/afcon_logo_clean.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.sports_soccer_rounded,
              color: _brandMaroon,
              size: 23,
            ),
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
    required this.onOpenMatchCategory,
    required this.onOpenShortcut,
    required this.language,
  });

  final ValueChanged<String> onOpenMatchCategory;
  final ValueChanged<String> onOpenShortcut;
  final String language;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        _QuickLinks(onSelected: onOpenShortcut),
        const SizedBox(height: 14),
        _WelcomeBanner(language: language),
        const SizedBox(height: 24),
        _SectionHeading(
          title: 'The road to PAMOJA 2027',
          actionLabel: 'View groups',
          onAction: () => onOpenMatchCategory('Groups'),
        ),
        const SizedBox(height: 12),
        _Pamoja2027Card(
          onOpenQualifiers: () => onOpenMatchCategory('Qualifiers'),
        ),
        const SizedBox(height: 24),
        const _TranslationCard(),
        const SizedBox(height: 24),
        _MatchCenterCards(onOpenCategory: onOpenMatchCategory),
        const SizedBox(height: 14),
        _WomensFootballAdvert(onTap: () => onOpenShortcut('Events')),
      ],
    );
  }
}

class _WomensFootballAdvert extends StatelessWidget {
  const _WomensFootballAdvert({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0D9E4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.campaign_rounded,
                  color: Color(0xFF800000),
                  size: 17,
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'FEATURED TOURNAMENT',
                    style: TextStyle(
                      color: Color(0xFF800000),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.black.withValues(alpha: .45),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 7,
                child: Image.asset(
                  'assets/images/new images/media/women.PNG',
                  width: double.infinity,
                  fit: BoxFit.fill,
                  semanticLabel: 'CAF Women’s Champions League Egypt 2026, 1–15 November 2026',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Explore women’s football',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Text(
                  'Discover',
                  style: TextStyle(
                    color: Color(0xFF800000),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF800000),
                  size: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _MatchCenterCards extends StatelessWidget {
  const _MatchCenterCards({required this.onOpenCategory});

  final ValueChanged<String> onOpenCategory;

  static const _items = <(String, String, IconData)>[
    ('Live', 'Live', Icons.wifi_tethering_rounded),
    ('Fixtures', 'Fixtures', Icons.calendar_month_rounded),
    ('Results', 'Results', Icons.flag_rounded),
    ('Groups', 'Groups', Icons.table_chart_rounded),
    ('Venues', 'Venues', Icons.stadium_rounded),
    ('Events & stats', 'Stats', Icons.bar_chart_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Match centre',
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Fixtures, scores, groups and venues',
          style: TextStyle(color: _muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720 ? 6 : 3;
            final spacing = 8.0;
            final width =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _items.map((item) {
                return SizedBox(
                  width: width,
                  child: _MatchCenterCard(
                    title: item.$1,
                    icon: item.$3,
                    onTap: () => onOpenCategory(item.$2),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _MatchCenterCard extends StatelessWidget {
  const _MatchCenterCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6E6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _brandMaroon, size: 16),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _WelcomeBanner extends StatefulWidget {
  const _WelcomeBanner({required this.language});

  final String language;

  @override
  State<_WelcomeBanner> createState() => _WelcomeBannerState();
}

class _WelcomeBannerState extends State<_WelcomeBanner> {
  static const _images = [
    'assets/images/cup.png',
    'assets/images/new images/home screen images/amad-diallo-of-cote-ivoire-is-challenged-by-darlin-yongwa-ngameni-of-cameroon.webp',
    'assets/images/new images/home screen images/Cafcon.webp',
    'assets/images/new images/home screen images/benjamin-mkapa-stadium_ok.webp',
  ];
  static const _headlines = [
    'The AFCON trophy',
    'African football, live',
    'The stage for Africa’s best',
    'A continent united',
  ];

  Timer? _rotationTimer;
  int _currentPage = 0;

  String get _todayLabel {
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} '
        '${months[now.month - 1]} ${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _rotationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      _showSlide((_currentPage + 1) % _images.length);
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  void _showSlide(int slide) =>
      setState(() => _currentPage = slide % _images.length);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 250,
        child: GestureDetector(
          key: const Key('home-hero-image-carousel'),
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity.abs() < 100) return;
            final next =
                (_currentPage + (velocity < 0 ? 1 : -1)) % _images.length;
            _showSlide(next < 0 ? next + _images.length : next);
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.025, end: 1).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            ),
            child: Stack(
              key: ValueKey(_images[_currentPage]),
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _images[_currentPage],
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0x08000000),
                        Color(0xC9000000),
                      ],
                      stops: [0.35, 0.57, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'AFCON  •  ${widget.language.toUpperCase()}',
                      style: const TextStyle(
                        color: Color(0xFF800000),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _headlines[_currentPage],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          height: 1.12,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(height: 1, color: Colors.white54),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _todayLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            children: List.generate(
                              _images.length,
                              (dotIndex) => Semantics(
                                button: true,
                                selected: _currentPage == dotIndex,
                                label: 'Show AFCON image ${dotIndex + 1}',
                                child: GestureDetector(
                                  key: Key('home-hero-indicator-$dotIndex'),
                                  onTap: () => _showSlide(dotIndex),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: _currentPage == dotIndex ? 16 : 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(left: 4),
                                    decoration: BoxDecoration(
                                      color: _currentPage == dotIndex
                                          ? Colors.white
                                          : Colors.white54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
            foregroundColor: _brandMaroon,
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

class _Pamoja2027Card extends StatelessWidget {
  const _Pamoja2027Card({required this.onOpenQualifiers});

  final VoidCallback onOpenQualifiers;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpenQualifiers,
        borderRadius: BorderRadius.circular(18),
        child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.3,
            child: Image.asset(
              'assets/images/new images/home screen images/afcon_pamoja_q.webp',
              fit: BoxFit.fill,
              semanticLabel: 'CAF AFCON PAMOJA 2027 qualifier groups graphic',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'CAF UPDATE  •  19 MAY 2026',
            style: TextStyle(
              color: _brandMaroon,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'The road to East Africa is mapped out',
            style: TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Forty-eight nations are chasing 21 places at the finals. Hosts Kenya, Tanzania and Uganda qualify automatically.',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: const [
              _PamojaFactChip(label: '12 groups'),
              _PamojaFactChip(label: '24 finalists'),
              _PamojaFactChip(label: '19 Jun – 17 Jul 2027'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F0F0),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: _brandMaroon,
                  size: 16,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Next qualifiers: 9–17 November 2026',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onOpenQualifiers,
              icon: const Icon(Icons.table_chart_rounded, size: 15),
              label: const Text('View qualifiers'),
              style: TextButton.styleFrom(
                foregroundColor: _brandMaroon,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                visualDensity: VisualDensity.compact,
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

class _PamojaFactChip extends StatelessWidget {
  const _PamojaFactChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: _ink,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _TranslationCard extends StatefulWidget {
  const _TranslationCard();

  @override
  State<_TranslationCard> createState() => _TranslationCardState();
}

class _TranslationCardState extends State<_TranslationCard> {
  final _api = AfconApi();
  bool _captionsEnabled = false;
  String _captionLanguage = 'Luganda';
  bool _startingTranslation = false;
  String? _translationStatus;

  Future<void> _setCaptionsEnabled(bool enabled) async {
    setState(() {
      _captionsEnabled = enabled;
      _translationStatus = enabled ? 'Connecting to live translation…' : null;
      _startingTranslation = enabled;
    });
    if (!enabled) return;
    final languageCode = switch (_captionLanguage) {
      'Luganda' => 'lg',
      'Swahili' => 'sw',
      'French' => 'fr',
      _ => 'lg',
    };
    try {
      await _api.createTranslationSession(targetLanguage: languageCode);
      if (!mounted) return;
      setState(() => _translationStatus = 'Translation session ready.');
    } on AfconApiException catch (error) {
      if (!mounted) return;
      setState(() => _translationStatus = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _translationStatus = 'Could not reach the AFCON backend.');
    } finally {
      if (mounted) setState(() => _startingTranslation = false);
    }
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

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
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: _brandMaroon,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live voice translation',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Listen to English speech in your language',
                      style: TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _captionsEnabled,
                activeTrackColor: _brandMaroon,
                onChanged: _setCaptionsEnabled,
              ),
            ],
          ),
          if (_captionsEnabled) ...[
            const SizedBox(height: 14),
            _StatusPill(
              label: _startingTranslation
                  ? 'Connecting to translation service'
                  : _translationStatus ??
                        'Live audio translation is not connected',
              color: const Color(0xFFFFF5DD),
              textColor: const Color(0xFF805700),
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
                if (value != null) {
                  setState(() => _captionLanguage = value);
                  if (_captionsEnabled) _setCaptionsEnabled(true);
                }
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
                'Translated transcript and spoken $_captionLanguage audio will appear here when speech services are connected.',
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
              Icon(icon, size: 18, color: _brandMaroon),
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
        Icon(icon, color: _brandMaroon, size: 21),
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
