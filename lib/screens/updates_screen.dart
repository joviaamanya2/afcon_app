import 'package:flutter/material.dart';

import '../data/caf_pamoja_data.dart';
import '../services/afcon_api.dart';

const _updatesMaroon = Color(0xFF800000);
const _updatesInk = Color(0xFF1E1E1E);
const _updatesMuted = Color(0xFF666666);
const _defaultNewsImage =
    'assets/images/new images/news images/b26i3fr0265.webp';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = ['Headline', 'AFCON', 'Trending', 'Local', 'Official'];

  late final TabController _tabController;
  final _commentStore = _ArticleCommentStore();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        backgroundColor: Colors.white,
        foregroundColor: _updatesInk,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'News',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        leading: widget.showBackButton
            ? IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
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
          labelColor: _updatesMaroon,
          unselectedLabelColor: _updatesMuted,
          indicatorColor: _updatesMaroon,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs
            .map(
              (tab) => _UpdatesFeed(category: tab, commentStore: _commentStore),
            )
            .toList(),
      ),
    );
  }
}

class _UpdatesFeed extends StatefulWidget {
  const _UpdatesFeed({required this.category, required this.commentStore});

  final String category;
  final _ArticleCommentStore commentStore;

  @override
  State<_UpdatesFeed> createState() => _UpdatesFeedState();
}

class _UpdatesFeedState extends State<_UpdatesFeed> {
  bool _showAll = false;
  final _api = AfconApi();
  List<Map<String, dynamic>> _backendArticles = [];
  bool _articleLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      final category = widget.category == 'Headline' ? null : widget.category;
      final articles = await _api.news(category: category);
      if (mounted) setState(() => _backendArticles = articles);
    } catch (_) {
      if (mounted) setState(() => _articleLoadFailed = true);
    }
  }

  @override
  void didUpdateWidget(covariant _UpdatesFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _backendArticles = [];
      _articleLoadFailed = false;
      _loadArticles();
    }
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backendStories = _backendArticles
        .map(
          (article) => _Story(
            title: '${article['title'] ?? 'AFCON update'}',
            category: '${article['category'] ?? 'AFCON'}',
            icon: Icons.newspaper_rounded,
            colors: const [Color(0xFF157A50), Color(0xFF1E4771)],
            summary: '${article['summary'] ?? ''}',
            body: '${article['body'] ?? ''}',
            imageUrl: article['image_url']?.toString(),
            fallbackImageAsset: _fallbackNewsImage(article),
            source: article['source']?.toString(),
            sourceUrl: article['source_url']?.toString(),
            publishedAt: article['published_at']?.toString(),
          ),
        )
        .toList();
    final backendTitles = backendStories
        .map((story) => story.title.toLowerCase().trim())
        .toSet();
    final curatedStories = _storiesForCategory(widget.category)
        .where((story) => !backendTitles.contains(story.title.toLowerCase()))
        .toList();
    // CAF's locally bundled stories keep the News screen useful before the
    // admin dashboard has published records or while the API is offline.
    final stories = [...backendStories, ...curatedStories];
    final visibleStories = _showAll ? stories : stories.take(3).toList();

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
              widget.category == 'Headline' ? 'Latest' : widget.category,
              style: const TextStyle(
                color: _updatesInk,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Latest AFCON updates',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _updatesMuted, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFE9ECEF)),
        if (visibleStories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 20),
            child: Column(
              children: [
                Icon(
                  _articleLoadFailed
                      ? Icons.cloud_off_rounded
                      : Icons.newspaper_rounded,
                  color: _updatesMaroon,
                  size: 34,
                ),
                const SizedBox(height: 10),
                Text(
                  _articleLoadFailed
                      ? 'News service unavailable'
                      : 'No published stories yet',
                  style: const TextStyle(
                    color: _updatesInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _articleLoadFailed
                      ? 'Check the backend connection and try again.'
                      : 'Published articles added in the dashboard will appear here.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _updatesMuted, fontSize: 12),
                ),
              ],
            ),
          )
        else
          for (final story in visibleStories)
            _StoryTile(story: story, commentStore: widget.commentStore),
        if (stories.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showAll = !_showAll),
              icon: Icon(
                _showAll
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
              ),
              label: Text(
                _showAll ? 'Show less' : 'More ${widget.category} stories',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _updatesMaroon,
                side: const BorderSide(color: Color(0xFFD7E7DD)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
      ],
    );
  }
}

class _Story {
  const _Story({
    required this.title,
    required this.category,
    required this.icon,
    required this.colors,
    this.summary = '',
    this.body = '',
    this.imageUrl,
    this.imageAsset,
    this.fallbackImageAsset,
    this.source,
    this.sourceUrl,
    this.publishedAt,
  });

  final String title;
  final String category;
  final IconData icon;
  final List<Color> colors;
  final String summary;
  final String body;
  final String? imageUrl;
  final String? imageAsset;
  final String? fallbackImageAsset;
  final String? source;
  final String? sourceUrl;
  final String? publishedAt;

  String get id => '$category:$title';
}

String _fallbackNewsImage(Map<String, dynamic> article) {
  final imageAsset = article['image_asset']?.toString().trim();
  return imageAsset != null && imageAsset.isNotEmpty
      ? imageAsset
      : _defaultNewsImage;
}

class _StoryImage extends StatelessWidget {
  const _StoryImage({
    required this.story,
    required this.width,
    required this.height,
  });

  final _Story story;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fallbackAsset =
        story.fallbackImageAsset ?? story.imageAsset ?? _defaultNewsImage;
    final imageAsset = story.imageAsset;
    if (imageAsset != null && imageAsset.isNotEmpty) {
      return Image.asset(
        imageAsset,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    }

    final imageUrl = story.imageUrl?.trim();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}

const _cafStaticStories = <_Story>[
  _Story(
    title: 'Angola defeat Malawi to complete AFCON 2027 Matchday Two',
    category: 'AFCON',
    icon: Icons.sports_soccer_rounded,
    colors: [Color(0xFF157A50), Color(0xFF1E4771)],
    summary: 'Angola beat Malawi 3–1 in Luanda on 6 October, finishing the second round of PAMOJA 2027 qualifiers.',
    body: 'CAF reports that Milson, Mabululu and Miro scored for Angola. The result left Angola unbeaten after two matches and level on four points with Egypt in Group B.',
    imageUrl:
        'https://www.cafonline.com/media/vknjc3fe/b26ixfr0185.jpg?width=600',
    fallbackImageAsset: 'assets/images/new images/news images/b26ixfr0185.webp',
    source: 'CAF Online',
    sourceUrl: cafAngolaMalawiSource,
    publishedAt: '6 Oct 2026',
  ),
  _Story(
    title: 'CAF reviews the AFCON 2027 qualifier groups after Matchday Two',
    category: 'AFCON',
    icon: Icons.table_chart_rounded,
    colors: [Color(0xFF157A50), Color(0xFF1E4771)],
    summary: 'CAF’s group review reports second-round results across the 12 PAMOJA qualifier groups and identifies the teams that began with two wins.',
    body: 'The CAF report highlights perfect starts for Morocco, Côte d’Ivoire, The Gambia, South Africa, DR Congo, Rwanda, Mali and Guinea-Bissau. It also notes Egypt, Senegal and Algeria remained unbeaten after two rounds.',
    imageUrl: 'https://www.cafonline.com/media/g4sp3jfu/brahim-abdelkader-diaz-of-morocco-celebrates-goal-during-the-2027-africa-cup-of-nations-qualifiers-match-between-lesotho-and-morocco-at-free-state-stadium.jpg?width=600',
    fallbackImageAsset:
        'assets/images/new images/news images/ismael-saibari-of-morocco.webp',
    source: 'CAF Online',
    sourceUrl: cafAfcon2027ResultsSource,
    publishedAt: '2 Oct 2026',
  ),
  _Story(
    title: 'Guinea edge co-hosts Kenya in AFCON 2027 qualifier',
    category: 'AFCON',
    icon: Icons.sports_soccer_rounded,
    colors: [Color(0xFF157A50), Color(0xFF1E4771)],
    summary: 'Serhou Guirassy scored the only goal as Guinea beat Kenya 1–0 in Conakry on 1 October.',
    body: 'CAF reports the goal came in the 32nd minute at the 28 September Stadium. The result gave Guinea their first points in Group D; South Africa led the group after two rounds.',
    imageUrl: 'https://www.cafonline.com/media/33eknmcv/serhou-guirassy-of-guinea-l-celebrates-goal-with-teammates-during-the-2025-africa-cup-of-nations-qualifiers-match-between-ethiopia-and-guinea.jpg?width=600',
    fallbackImageAsset: 'assets/images/new images/news images/b26i3fr0265.webp',
    source: 'CAF Online',
    sourceUrl: cafGuineaKenyaSource,
    publishedAt: '1 Oct 2026',
  ),
  _Story(
    title: 'Benin hold off Mauritania as Mali, Côte d’Ivoire collect wins',
    category: 'AFCON',
    icon: Icons.sports_soccer_rounded,
    colors: [Color(0xFF157A50), Color(0xFF1E4771)],
    summary: 'Benin beat Mauritania 2–1, Mali edged Liberia 1–0 and Côte d’Ivoire scored twice late to defeat Somalia. Congo and Cameroon shared a 1–1 draw in the AFCON 2027 qualifiers.',
    body: 'Benin held on for a 2–1 win after a late Mauritanian penalty made the closing stages tense. Mali found the only goal against Liberia in the 79th minute, while Côte d’Ivoire broke Somalia’s resistance with goals in the 89th minute and stoppage time. Congo and Cameroon drew 1–1.',
    imageAsset: 'assets/images/new images/news images/b26i3fr0265.webp',
    source: 'CAF Online',
    publishedAt: '29 Sep 2026',
  ),
  _Story(
    title: '10 young players to watch in the AFCON PAMOJA 2027 qualifiers',
    category: 'AFCON',
    icon: Icons.groups_rounded,
    colors: [Color(0xFF157A50), Color(0xFF1E4771)],
    summary: 'CAF highlighted emerging talent ahead of the qualifying campaign, including Ghana midfielder Caleb Yirenkyi, who joined Coventry City in August 2026.',
    body: 'The AFCON PAMOJA 2027 group qualifiers bring 48 countries into the race for a place at the finals. CAF’s players to watch include young internationals from across the continent. Ghana’s Caleb Yirenkyi, a versatile 20-year-old midfielder, was named Danish Superliga Young Player of the Year for 2025/26 before moving to Coventry City.',
    imageAsset: 'assets/images/new images/news images/caleb-yirenkyi.webp',
    source: 'CAF Online',
    publishedAt: '23 Sep 2026',
  ),
  _Story(
    title: 'Morocco hold Brazil as Atlas Lions begin World Cup journey',
    category: 'World Cup',
    icon: Icons.public_rounded,
    colors: [Color(0xFF157A50), Color(0xFF1E4771)],
    summary: 'Morocco opened their 2026 FIFA World Cup campaign with a 1–1 draw against Brazil. Ismael Saibari scored for the Atlas Lions before Brazil equalised.',
    body: 'Ismael Saibari put Morocco ahead in the 21st minute after a through ball from Brahim Diaz. Brazil responded through Vinicius Junior eleven minutes later. Both sides had chances after the break, but the match finished 1–1 in Group C.',
    imageAsset: 'assets/images/new images/news images/morocco-s-midfielder-ismael-saibari-scores-goal-against-brazil.webp',
    source: 'CAF Online',
    publishedAt: '14 Jun 2026',
  ),
];

List<_Story> _storiesForCategory(String category) {
  switch (category) {
    case 'AFCON':
      return _cafStaticStories
          .where((story) => story.category == 'AFCON')
          .toList();
    case 'Local':
      // No locally sourced Uganda story is bundled with these assets yet.
      return const [];
    case 'Headline':
    case 'Trending':
    case 'Official':
    default:
      return _cafStaticStories;
  }
}

class _ArticleComment {
  const _ArticleComment({required this.text});

  final String text;
}

class _ArticleCommentStore {
  final Map<String, ValueNotifier<List<_ArticleComment>>> _comments = {};

  ValueNotifier<List<_ArticleComment>> commentsFor(_Story story) =>
      _comments.putIfAbsent(
        story.id,
        () => ValueNotifier<List<_ArticleComment>>(const []),
      );

  void dispose() {
    for (final comments in _comments.values) {
      comments.dispose();
    }
  }

  void add(_Story story, String text) {
    final comments = commentsFor(story);
    comments.value = List.unmodifiable([
      ...comments.value,
      _ArticleComment(text: text),
    ]);
  }
}

class _StoryTile extends StatelessWidget {
  const _StoryTile({required this.story, required this.commentStore});

  final _Story story;
  final _ArticleCommentStore commentStore;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              _ArticleScreen(story: story, commentStore: commentStore),
        ),
      ),
      child: Container(
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: _StoryImage(story: story, width: 112, height: 88),
              ),
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
                            color: _updatesMaroon,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        ValueListenableBuilder<List<_ArticleComment>>(
                          valueListenable: commentStore.commentsFor(story),
                          builder: (context, comments, child) => Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: _updatesMaroon,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${comments.length}',
                                style: const TextStyle(
                                  color: _updatesMaroon,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}

class _ArticleScreen extends StatefulWidget {
  const _ArticleScreen({required this.story, required this.commentStore});

  final _Story story;
  final _ArticleCommentStore commentStore;

  @override
  State<_ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<_ArticleScreen> {
  bool _saved = false;
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  final _commentsKey = GlobalKey();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write a comment before posting.')),
      );
      return;
    }

    widget.commentStore.add(widget.story, text);
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  void _scrollToComments() {
    final commentsContext = _commentsKey.currentContext;
    if (commentsContext != null) {
      Scrollable.ensureVisible(
        commentsContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  void _showShareMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing will be available soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 52,
            backgroundColor: Colors.white,
            foregroundColor: _updatesInk,
            surfaceTintColor: Colors.white,
            centerTitle: true,
            title: const Text(
              'AFCON FAN',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            actions: [
              ValueListenableBuilder<List<_ArticleComment>>(
                valueListenable: widget.commentStore.commentsFor(story),
                builder: (context, comments, child) => TextButton.icon(
                  onPressed: _scrollToComments,
                  style: TextButton.styleFrom(foregroundColor: _updatesMaroon),
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: Text('${comments.length}'),
                ),
              ),
              IconButton(
                tooltip: _saved ? 'Remove bookmark' : 'Save article',
                onPressed: () => setState(() => _saved = !_saved),
                icon: Icon(
                  _saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: const TextStyle(
                      color: _updatesInk,
                      fontSize: 19,
                      height: 1.28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    [
                      story.category,
                      if (story.source != null && story.source!.isNotEmpty)
                        story.source!,
                      if (story.publishedAt != null &&
                          story.publishedAt!.isNotEmpty)
                        story.publishedAt!,
                    ].join('  ·  '),
                    style: const TextStyle(color: _updatesMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    story.summary.isEmpty
                        ? 'Published AFCON news and tournament updates.'
                        : story.summary,
                    style: TextStyle(
                      color: Color(0xFF30343B),
                      fontSize: 14,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: _StoryImage(
                      story: story,
                      width: double.infinity,
                      height: 205,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Center(
                    child: Text(
                      'CAF ONLINE  ·  AFRICAN FOOTBALL',
                      style: TextStyle(color: _updatesMuted, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F2F5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFB58A27),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Text(
                              story.category.toUpperCase(),
                              style: const TextStyle(
                                color: _updatesMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              story.category == 'AFCON'
                                  ? 'AFCON PAMOJA 2027'
                                  : story.category.toUpperCase(),
                              style: TextStyle(
                                color: _updatesInk,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.sports_soccer_rounded,
                          color: _updatesMaroon,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Story',
                    style: TextStyle(
                      color: _updatesInk,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    story.title,
                    style: const TextStyle(
                      color: Color(0xFF344054),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    story.body.isEmpty ? story.summary : story.body,
                    style: TextStyle(
                      color: Color(0xFF475467),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  if (story.source?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Source: ${story.source} · Story content is available in this app.',
                      style: const TextStyle(
                        color: _updatesMuted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const Text(
                        'Related:',
                        style: TextStyle(color: _updatesMuted, fontSize: 12),
                      ),
                      _relatedChip(story.category),
                      _relatedChip('AFCON'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Color(0xFFE6E8EC)),
                  const SizedBox(height: 14),
                  const Text(
                    'Share to others',
                    style: TextStyle(
                      color: _updatesInk,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _shareAction(
                        icon: Icons.call_rounded,
                        label: 'WhatsApp',
                        color: const Color(0xFF25A65A),
                      ),
                      _shareAction(
                        icon: Icons.facebook_rounded,
                        label: 'Facebook',
                        color: const Color(0xFF4267B2),
                      ),
                      _shareAction(
                        icon: Icons.send_rounded,
                        label: 'Telegram',
                        color: const Color(0xFF36AEE2),
                      ),
                      _shareAction(
                        icon: Icons.more_horiz_rounded,
                        label: 'More',
                        color: _updatesMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Color(0xFFE6E8EC)),
                  const SizedBox(height: 16),
                  Container(
                    key: _commentsKey,
                    child: ValueListenableBuilder<List<_ArticleComment>>(
                      valueListenable: widget.commentStore.commentsFor(story),
                      builder: (context, comments, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🔥 Hot comments',
                            style: TextStyle(
                              color: _updatesInk,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              'Popular comments from supporters will appear here.',
                              style: TextStyle(
                                color: _updatesMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Latest comments  ·  Comments (${comments.length})',
                            style: const TextStyle(
                              color: _updatesInk,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (comments.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Text(
                                'No comments yet. Be the first to join the conversation.',
                                style: TextStyle(
                                  color: _updatesMuted,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          else
                            for (final comment in comments.reversed)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: _commentTile(comment),
                              ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Copyright Declaration',
                    style: TextStyle(color: _updatesMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE6E8EC))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('article-comment-input'),
                  controller: _commentController,
                  minLines: 1,
                  maxLines: 3,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                  decoration: InputDecoration(
                    hintText: 'Add a comment',
                    prefixIcon: const Icon(Icons.edit_rounded, size: 17),
                    filled: true,
                    fillColor: const Color(0xFFF0F1F5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                key: const Key('post-article-comment'),
                tooltip: 'Post comment',
                onPressed: _submitComment,
                icon: const Icon(Icons.send_rounded, color: _updatesMaroon),
              ),
              IconButton(
                tooltip: 'Share via WhatsApp',
                onPressed: _showShareMessage,
                icon: const Icon(Icons.call_rounded, color: _updatesMaroon),
              ),
              IconButton(
                tooltip: 'Share article',
                onPressed: _showShareMessage,
                icon: const Icon(Icons.share_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _relatedChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: _updatesInk, fontSize: 11),
      ),
    );
  }

  Widget _shareAction({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: _showShareMessage,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(color: _updatesMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentTile(_ArticleComment comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 15,
          backgroundColor: Color(0xFFE6F1E9),
          child: Icon(Icons.person_rounded, color: _updatesMaroon, size: 17),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You  ·  just now',
                style: TextStyle(
                  color: _updatesMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                comment.text,
                style: const TextStyle(
                  color: _updatesInk,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.thumb_up_alt_outlined, size: 15, color: _updatesMuted),
      ],
    );
  }
}
