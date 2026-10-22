import 'package:flutter/material.dart';

const _updatesGreen = Color(0xFF176B46);
const _updatesInk = Color(0xFF19251F);
const _updatesMuted = Color(0xFF69766F);

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

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
        backgroundColor: Colors.white,
        foregroundColor: _updatesInk,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'News',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
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

  static const _stories = [
    _Story(
      title: 'The latest AFCON headlines, all in one place',
      category: 'Headline',
      icon: Icons.newspaper_rounded,
      colors: [Color(0xFF157A50), Color(0xFF1E4771)],
    ),
    _Story(
      title: 'Team and player stories from across the tournament',
      category: 'AFCON',
      icon: Icons.groups_rounded,
      colors: [Color(0xFFB27822), Color(0xFF8C3E3B)],
    ),
    _Story(
      title: 'Stories fans are following today',
      category: 'Trending',
      icon: Icons.local_fire_department_rounded,
      colors: [Color(0xFFE07C32), Color(0xFFB84038)],
    ),
    _Story(
      title: 'News and activities from host cities and regions',
      category: 'Local',
      icon: Icons.location_city_rounded,
      colors: [Color(0xFF328D75), Color(0xFF285880)],
    ),
    _Story(
      title: 'Announcements from official AFCON channels',
      category: 'Official',
      icon: Icons.verified_rounded,
      colors: [Color(0xFF345B9A), Color(0xFF563F83)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final templates = widget.category == 'Headline'
        ? _stories.where((story) => story.category != 'Headline').toList()
        : _stories.where((story) => story.category == widget.category).toList();
    const extraHeadlines = {
      'AFCON': [
        'Players to watch as the tournament action continues',
        'National teams build momentum for upcoming games',
        'A closer look at the teams representing the continent',
      ],
      'Trending': [
        'African football stories fans are talking about',
        'The latest conversations from across African football',
        'Supporters pick their standout moments so far',
      ],
      'Local': [
        'Fans bring colour and energy to match day',
        'Local businesses prepare for visiting supporters',
        'Communities come together to celebrate the tournament',
      ],
      'Official': [
        'Tournament organisers share a new fan update',
        'Match day information from official AFCON channels',
        'Important tournament notices for fans',
      ],
    };
    final stories = <_Story>[];
    for (var storyIndex = 0; storyIndex < 4; storyIndex++) {
      for (final template in templates) {
        if (storyIndex == 0) {
          stories.add(template);
        } else {
          stories.add(
            _Story(
              title: extraHeadlines[template.category]![storyIndex - 1],
              category: template.category,
              icon: template.icon,
              colors: template.colors,
            ),
          );
        }
      }
    }
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
                foregroundColor: _updatesGreen,
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
  });

  final String title;
  final String category;
  final IconData icon;
  final List<Color> colors;

  String get id => '$category:$title';
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
                        ValueListenableBuilder<List<_ArticleComment>>(
                          valueListenable: commentStore.commentsFor(story),
                          builder: (context, comments, child) => Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: _updatesGreen,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${comments.length}',
                                style: const TextStyle(
                                  color: _updatesGreen,
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
                  style: TextButton.styleFrom(
                    foregroundColor: _updatesGreen,
                  ),
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
                  const Text(
                    '11 hours ago  /  AFCON Fan',
                    style: TextStyle(color: _updatesMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Follow the latest from African football, with tournament coverage, team updates and the moments supporters are talking about.',
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
                    child: Image.asset(
                      'assets/images/main.webp',
                      width: double.infinity,
                      height: 205,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Center(
                    child: Text(
                      'AFCON 2025  ·  AFRICAN FOOTBALL',
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
                            const Text(
                              'AFCON 2025',
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
                          color: _updatesGreen,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Match Report',
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
                  const Text(
                    'Stay with AFCON Fan for match coverage, team news and updates from across the continent. Follow your favourite national teams to keep their stories close.',
                    style: TextStyle(
                      color: Color(0xFF475467),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
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
                icon: const Icon(Icons.send_rounded, color: _updatesGreen),
              ),
              IconButton(
                tooltip: 'Share via WhatsApp',
                onPressed: _showShareMessage,
                icon: const Icon(Icons.call_rounded, color: _updatesGreen),
              ),
              IconButton(
                tooltip: 'Share article',
                onPressed: _showShareMessage,
                icon: const Icon(Icons.open_in_new_rounded),
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
          child: Icon(Icons.person_rounded, color: _updatesGreen, size: 17),
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
