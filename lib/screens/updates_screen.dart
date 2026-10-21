import 'package:flutter/material.dart';

const _updatesGreen = Color(0xFF16A34A);
const _updatesInk = Color(0xFF202124);
const _updatesMuted = Color(0xFF858B91);

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = ['Headline', 'AFCON', 'Trending', 'Local', 'Official'];

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _updatesGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'NEWS',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'Search updates',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search will be available soon.')),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: _updatesGreen,
          unselectedLabelColor: _updatesMuted,
          indicatorColor: _updatesGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) => _UpdatesFeed(category: tab)).toList(),
      ),
    );
  }
}

class _UpdatesFeed extends StatelessWidget {
  const _UpdatesFeed({required this.category});

  final String category;

  static const _stories = [
    _Story(
      title: 'The latest AFCON headlines, all in one place',
      category: 'Headline',
      comments: '—',
      icon: Icons.newspaper_rounded,
      colors: [Color(0xFF157A50), Color(0xFF1E4771)],
    ),
    _Story(
      title: 'Team and player stories from across the tournament',
      category: 'AFCON',
      comments: '—',
      icon: Icons.groups_rounded,
      colors: [Color(0xFFB27822), Color(0xFF8C3E3B)],
    ),
    _Story(
      title: 'Stories fans are following today',
      category: 'Trending',
      comments: '—',
      icon: Icons.local_fire_department_rounded,
      colors: [Color(0xFFE07C32), Color(0xFFB84038)],
    ),
    _Story(
      title: 'News and activities from host cities and regions',
      category: 'Local',
      comments: '—',
      icon: Icons.location_city_rounded,
      colors: [Color(0xFF328D75), Color(0xFF285880)],
    ),
    _Story(
      title: 'Announcements from official AFCON channels',
      category: 'Official',
      comments: '—',
      icon: Icons.verified_rounded,
      colors: [Color(0xFF345B9A), Color(0xFF563F83)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final stories = category == 'Headline'
        ? _stories
        : _stories.where((story) => story.category == category).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFFF8A26),
              size: 25,
            ),
            const SizedBox(width: 7),
            Text(
              category == 'Headline' ? 'Trending' : category,
              style: const TextStyle(
                color: _updatesInk,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'AFCON updates',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _updatesMuted, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFE9ECEF)),
        for (final story in stories) _StoryTile(story: story),
      ],
    );
  }
}

class _Story {
  const _Story({
    required this.title,
    required this.category,
    required this.comments,
    required this.icon,
    required this.colors,
  });

  final String title;
  final String category;
  final String comments;
  final IconData icon;
  final List<Color> colors;
}

class _StoryTile extends StatelessWidget {
  const _StoryTile({required this.story});

  final _Story story;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F1F2))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 112,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: story.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(story.icon, color: Colors.white, size: 38),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      story.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _updatesInk,
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        story.category.toUpperCase(),
                        style: const TextStyle(
                          color: _updatesGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: _updatesGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        story.comments,
                        style: const TextStyle(
                          color: _updatesGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
