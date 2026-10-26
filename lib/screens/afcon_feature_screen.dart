import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'teams_players_screen.dart';

import 'community_video_controller_native.dart'
    if (dart.library.html) 'community_video_controller_web.dart'
    as community_video;
import '../services/afcon_api.dart';

const _cafMaroon = Color(0xFF800000);
const _cafMaroonDeep = Color(0xFF5C0000);
const _ink = Color(0xFF1E1E1E);
const _muted = Color(0xFF666666);
const _canvas = Color(0xFFF7F7F7);

const _officialAfconVideos = [
  (
    title: 'Senegal vs Morocco',
    round: 'AFCON 2025 Final highlights',
    date: '18 January 2026',
    youtubeId: 'chuhAI45g70',
    category: 'Highlights',
    source: 'CAF TV',
  ),
  (
    title: 'Egypt vs Nigeria',
    round: 'Third-place highlights',
    date: '17 January 2026',
    youtubeId: 'SFrZtXJAThY',
    category: 'Highlights',
    source: 'CAF TV',
  ),
  (
    title: 'Nigeria vs Morocco',
    round: 'Semi-final highlights',
    date: '14 January 2026',
    youtubeId: '8rVYcW0-oh0',
    category: 'Highlights',
    source: 'CAF TV',
  ),
  (
    title: 'Senegal vs Egypt',
    round: 'Semi-final highlights',
    date: '14 January 2026',
    youtubeId: 'Kd1CQx0Fu7M',
    category: 'Highlights',
    source: 'CAF TV',
  ),
  (
    title: 'Sadio Mane interview: Winning with Senegal',
    round: 'Player interview',
    date: '8 January 2026',
    youtubeId: 'QUk0olaIf8o',
    category: 'Interviews',
    source: 'beIN SPORTS',
  ),
  (
    title: 'AFCON 2025 is on the doors',
    round: 'Tournament build-up',
    date: '20 December 2025',
    youtubeId: '2c_0qo4Mz2w',
    category: 'Road to AFCON',
    source: 'CAF TV',
  ),
];

/// Polished feature surfaces for AFCON features that are not yet backed by an
/// approved live data or content provider.
class AfconFeatureScreen extends StatefulWidget {
  const AfconFeatureScreen({
    super.key,
    required this.feature,
    this.showAppBar = true,
  });

  final String feature;
  final bool showAppBar;

  @override
  State<AfconFeatureScreen> createState() => _AfconFeatureScreenState();
}

class _AfconFeatureScreenState extends State<AfconFeatureScreen> {
  final _api = AfconApi();
  final Map<String, Future<List<Map<String, dynamic>>>> _contentRequests = {};
  String _selectedVideoCategory = 'Highlights';
  final Set<String> _followedTeams = {};
  final Map<String, bool> _notificationPreferences = {
    'Match reminders': true,
    'Kick-off changes': true,
    'Team news': false,
    'Tournament announcements': true,
  };
  final TextEditingController _questionController = TextEditingController();
  String? _submittedQuestion;
  String? _assistantResponse;
  bool _assistantLoading = false;
  final List<_CommunityPost> _communityPosts = [];
  final Set<DateTime> _likedCommunityPosts = {};
  String _communityUsername = 'AFCON Fan';

  @override
  void dispose() {
    _questionController.dispose();
    _api.close();
    super.dispose();
  }

  Future<void> _askAssistant(String question) async {
    final cleanedQuestion = question.trim();
    if (cleanedQuestion.isEmpty) return;
    setState(() {
      _submittedQuestion = cleanedQuestion;
      _assistantResponse = null;
      _assistantLoading = true;
      _questionController.text = cleanedQuestion;
    });
    try {
      final result = await _api.askAssistant(question: cleanedQuestion);
      if (!mounted) return;
      setState(
        () => _assistantResponse =
            result['answer']?.toString() ?? 'No answer was returned.',
      );
    } on AfconApiException catch (error) {
      if (!mounted) return;
      setState(() => _assistantResponse = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _assistantResponse = 'Could not reach the AFCON backend.');
    } finally {
      if (mounted) setState(() => _assistantLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _content(String resource) =>
      _contentRequests.putIfAbsent(
        resource,
        () => switch (resource) {
          'teams' => _api.teams(),
          'events' => _api.events(),
          'venues' => _api.venues(),
          'media' => _api.media(),
          _ => Future.value(const <Map<String, dynamic>>[]),
        },
      );

  Widget _backendContentList({
    required String resource,
    required String title,
    required IconData icon,
  }) => FutureBuilder<List<Map<String, dynamic>>>(
    future: _content(resource),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (snapshot.hasError) {
        return _EventCard(
          title: '$title unavailable',
          detail: 'The backend could not be reached. Check your connection and try again.',
          icon: Icons.cloud_off_rounded,
        );
      }
      final records = snapshot.data ?? const <Map<String, dynamic>>[];
      if (records.isEmpty) {
        return _EventCard(
          title: 'No published $title yet',
          detail: 'Published $title added in the dashboard will appear here.',
          icon: icon,
        );
      }
      return Column(
        children: records.map((record) {
          final recordTitle = '${record['title'] ?? record['name'] ?? 'AFCON'}';
          final details = resource == 'events'
              ? '${record['city'] ?? ''}${record['starts_at'] == null ? '' : ' · ${record['starts_at']}'}'
              : resource == 'venues'
              ? '${record['city'] ?? ''}${record['capacity'] == null ? '' : ' · Capacity ${record['capacity']}'}'
              : '${record['description'] ?? record['media_type'] ?? ''}';
          if (resource == 'teams') {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TeamsPlayersScreen(initialTeam: recordTitle),
                ),
              ),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFF5E6E6),
                child: Text(
                  recordTitle.isEmpty ? 'T' : recordTitle[0],
                  style: const TextStyle(
                    color: _cafMaroon,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              title: Text(
                recordTitle,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                '${record['region'] ?? 'African team'} · ${record['coach'] ?? 'Team profile'}',
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
              trailing: IconButton(
                tooltip: _followedTeams.contains(recordTitle)
                    ? 'Unfollow $recordTitle'
                    : 'Follow $recordTitle',
                onPressed: () => setState(
                  () => _followedTeams.contains(recordTitle)
                      ? _followedTeams.remove(recordTitle)
                      : _followedTeams.add(recordTitle),
                ),
                icon: Icon(
                  _followedTeams.contains(recordTitle)
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: _followedTeams.contains(recordTitle)
                      ? const Color(0xFFB17A00)
                      : _muted,
                ),
              ),
            );
          }
          return ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: resource == 'media'
                ? () {
                    final mediaUrl =
                        record['playback_url'] ??
                        record['url'] ??
                        record['source_url'];
                    if (mediaUrl is String && mediaUrl.isNotEmpty) {
                      _openExternalVideo(mediaUrl);
                    }
                  }
                : null,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF5E6E6),
              child: Icon(icon, color: _cafMaroon, size: 19),
            ),
            title: Text(
              recordTitle,
              style: const TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              details.isEmpty ? title : details,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
          );
        }).toList(),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final feature = widget.feature;
    return Scaffold(
      backgroundColor: _canvas,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              foregroundColor: _ink,
              surfaceTintColor: Colors.white,
              elevation: 0,
              title: Text(
                feature == 'Media' ? 'AFCON Media' : feature,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          : null,
      floatingActionButton: feature == 'Community'
          ? FloatingActionButton.extended(
              onPressed: _composeCommunityPost,
              backgroundColor: _cafMaroon,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Create post'),
            )
          : null,
      body: feature == 'Media'
          ? ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                _backendMediaContent(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: _SourceNote(),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
              children: [
                _FeatureHero(feature: feature),
                const SizedBox(height: 18),
                if (feature == 'Ask AFCON') _assistantContent(),
                if (feature == 'Follow teams') _followContent(),
                if (feature == 'Notifications') _notificationContent(),
                if (feature == 'Events') _eventContent(),
                if (feature == 'Venues') _venueContent(),
                if (feature == 'Community') _communityContent(),
                const SizedBox(height: 18),
                if (feature != 'Community') const _SourceNote(),
              ],
            ),
    );
  }

  Widget _assistantContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Ask about the tournament'),
      const SizedBox(height: 10),
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Try a question',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                        'When is the next match?',
                        'Where is my team playing?',
                        'Show the group standings',
                      ]
                      .map(
                        (question) => ActionChip(
                          label: Text(question),
                          onPressed: () => _askAssistant(question),
                          backgroundColor: const Color(0xFFF5E6E6),
                          side: BorderSide.none,
                          labelStyle: const TextStyle(
                            color: _cafMaroon,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _questionController,
              textInputAction: TextInputAction.send,
              onSubmitted: _askAssistant,
              decoration: InputDecoration(
                hintText: 'Ask in your language…',
                suffixIcon: IconButton(
                  tooltip: 'Send question',
                  onPressed: () => _askAssistant(_questionController.text),
                  icon: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(backgroundColor: _cafMaroon),
                ),
                filled: true,
                fillColor: _canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_submittedQuestion case final question?
                when question.isNotEmpty) ...[
              const SizedBox(height: 14),
              _AssistantReply(
                question: question,
                response: _assistantResponse,
                loading: _assistantLoading,
              ),
            ],
          ],
        ),
      ),
    ],
  );

  Widget _followContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Choose your teams'),
      const SizedBox(height: 10),
      _Panel(
        child: _backendContentList(
          resource: 'teams',
          title: 'teams',
          icon: Icons.flag_rounded,
        ),
      ),
    ],
  );

  Widget _notificationContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Choose what you hear about'),
      const SizedBox(height: 10),
      _Panel(
        child: Column(
          children: _notificationPreferences.keys
              .map(
                (label) => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: _cafMaroon,
                  title: Text(
                    label,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'For teams and matches you follow',
                    style: TextStyle(color: _muted, fontSize: 11),
                  ),
                  value: _notificationPreferences[label]!,
                  onChanged: (value) =>
                      setState(() => _notificationPreferences[label] = value),
                ),
              )
              .toList(),
        ),
      ),
    ],
  );

  Widget _eventContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Around the tournament'),
      const SizedBox(height: 10),
      _Panel(
        child: _backendContentList(
          resource: 'events',
          title: 'fan events',
          icon: Icons.event_available_rounded,
        ),
      ),
    ],
  );

  Widget _venueContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Matchday locations'),
      const SizedBox(height: 10),
      _Panel(
        child: _backendContentList(
          resource: 'venues',
          title: 'venues',
          icon: Icons.stadium_rounded,
        ),
      ),
    ],
  );

  Widget _backendMediaContent() {
    final featured = _officialAfconVideos.first;
    final categoryVideos = _officialAfconVideos
        .where((video) => video.category == _selectedVideoCategory)
        .where((video) => video.youtubeId != featured.youtubeId)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _OfficialVideoCard(
            title: featured.title,
            round: featured.round,
            date: featured.date,
            youtubeId: featured.youtubeId,
            source: featured.source,
            onTap: () => _openExternalVideo(
              'https://www.youtube.com/watch?v=${featured.youtubeId}',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Explore AFCON videos'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Highlights', 'Interviews', 'Road to AFCON']
                    .map(
                      (category) => ChoiceChip(
                        label: Text(category),
                        selected: category == _selectedVideoCategory,
                        onSelected: (_) =>
                            setState(() => _selectedVideoCategory = category),
                        selectedColor: _cafMaroon,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: category == _selectedVideoCategory
                              ? _cafMaroon
                              : const Color(0xFFE6E8E5),
                        ),
                        labelStyle: TextStyle(
                          color: category == _selectedVideoCategory
                              ? Colors.white
                              : _ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedVideoCategory,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (categoryVideos.isEmpty)
                const _EventCard(
                  title: 'More videos coming soon',
                  detail: 'Browse the CAF archive for more official coverage.',
                  icon: Icons.video_library_rounded,
                )
              else
                for (final video in categoryVideos) ...[
                  _OfficialVideoCard(
                    title: video.title,
                    round: video.round,
                    date: video.date,
                    youtubeId: video.youtubeId,
                    source: video.source,
                    onTap: () => _openExternalVideo(
                      'https://www.youtube.com/watch?v=${video.youtubeId}',
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              OutlinedButton.icon(
                onPressed: () => _openExternalVideo(
                  'https://www.cafonline.com/afcon2025/videos/',
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 17),
                label: const Text('More videos on CAF Online'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _cafMaroon,
                  side: const BorderSide(color: Color(0xFFE3D1D1)),
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openExternalVideo(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this video link.')),
      );
    }
  }

  Future<void> _composeCommunityPost() async {
    final draft = await showModalBottomSheet<_CommunityPostDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ComposeCommunityPostSheet(),
    );
    if (!mounted || draft == null) return;
    setState(() {
      _communityPosts.insert(
        0,
        _CommunityPost(
          author: _communityUsername,
          content: draft.content,
          media: draft.media,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  Widget _communityContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Community feed'),
      const SizedBox(height: 10),
      _CommunityIdentityCard(
        username: _communityUsername,
        onEdit: _editCommunityUsername,
      ),
      const SizedBox(height: 10),
      _CommunityComposer(
        username: _communityUsername,
        onTap: _composeCommunityPost,
      ),
      const SizedBox(height: 14),
      if (_communityPosts.isEmpty)
        const _CommunityEmptyState()
      else
        for (var index = 0; index < _communityPosts.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CommunityPostCard(
              post: _communityPosts[index],
              isOwnPost: _communityPosts[index].isOwnPost,
              liked: _likedCommunityPosts.contains(
                _communityPosts[index].createdAt,
              ),
              onLike: () => setState(() {
                final postKey = _communityPosts[index].createdAt;
                if (!_likedCommunityPosts.add(postKey)) {
                  _likedCommunityPosts.remove(postKey);
                }
              }),
              onComment: () => _showCommunityComments(_communityPosts[index]),
              onShare: () => _shareCommunityPost(_communityPosts[index]),
              onDelete: () => _deleteCommunityPost(_communityPosts[index]),
              onReport: _reportCommunityPost,
            ),
          ),
      const SizedBox(height: 6),
      const _CommunitySafetyNote(),
    ],
  );

  Future<void> _editCommunityUsername() async {
    final username = await showDialog<String>(
      context: context,
      builder: (context) =>
          _CommunityUsernameDialog(initialUsername: _communityUsername),
    );
    final cleanedUsername = username?.trim() ?? '';
    if (!mounted || cleanedUsername.isEmpty) return;
    setState(() => _communityUsername = cleanedUsername);
  }

  Future<void> _showCommunityComments(_CommunityPost post) async {
    final comment = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _CommunityCommentsSheet(comments: List.unmodifiable(post.comments)),
    );
    final cleanedComment = comment?.trim() ?? '';
    if (!mounted || cleanedComment.isEmpty) return;
    setState(() => post.comments.add('$_communityUsername: $cleanedComment'));
  }

  Future<void> _shareCommunityPost(_CommunityPost post) async {
    final text = [
      '${post.author} on AFCON Community',
      if (post.content.isNotEmpty) post.content,
      if (post.media.isNotEmpty) '${post.media.length} media attachment(s)',
    ].join('\n\n');
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: post.media.isEmpty
              ? null
              : post.media
                    .map((media) => XFile(media.file.path))
                    .toList(growable: false),
        ),
      );
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Could not share this post.')),
      );
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sharing is unavailable on this device.')),
      );
    }
  }

  Future<void> _deleteCommunityPost(_CommunityPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This will remove your post from this feed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('community-confirm-delete'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() {
      _communityPosts.remove(post);
      _likedCommunityPosts.remove(post.createdAt);
    });
  }

  void _reportCommunityPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thanks. This post has been flagged for review.'),
      ),
    );
  }
}

class _CommunityPost {
  _CommunityPost({
    required this.author,
    required this.content,
    required this.media,
    required this.createdAt,
  });

  final String author;
  final String content;
  final List<_CommunityMedia> media;
  final DateTime createdAt;
  final bool isOwnPost = true;
  final int likes = 0;
  final List<String> comments = [];
}

class _CommunityMedia {
  const _CommunityMedia({required this.file, required this.isVideo});

  final XFile file;
  final bool isVideo;
}

class _CommunityPostDraft {
  const _CommunityPostDraft({required this.content, required this.media});

  final String content;
  final List<_CommunityMedia> media;
}

class _ComposeCommunityPostSheet extends StatefulWidget {
  const _ComposeCommunityPostSheet();

  @override
  State<_ComposeCommunityPostSheet> createState() =>
      _ComposeCommunityPostSheetState();
}

class _ComposeCommunityPostSheetState
    extends State<_ComposeCommunityPostSheet> {
  final _controller = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<_CommunityMedia> _media = [];
  bool _isPickingMedia = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickMedia({required bool video}) async {
    if (_isPickingMedia) return;
    if (_media.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can attach up to 4 items per post.')),
      );
      return;
    }

    setState(() => _isPickingMedia = true);
    try {
      final file = video
          ? await _imagePicker.pickVideo(source: ImageSource.gallery)
          : await _imagePicker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 90,
            );
      if (file != null && mounted) {
        setState(() {
          _media.add(_CommunityMedia(file: file, isVideo: video));
        });
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ??
                'Could not open the media picker. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPickingMedia = false);
    }
  }

  void _removeMedia(int index) {
    setState(() => _media.removeAt(index));
  }

  void _submitPost() {
    final text = _controller.text.trim();
    if (text.isEmpty && _media.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write something or attach a photo or video to post.'),
        ),
      );
      return;
    }

    Navigator.of(
      context,
    ).pop(_CommunityPostDraft(content: text, media: List.unmodifiable(_media)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7E0DA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Create a post',
                style: TextStyle(
                  color: _ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Share a thought, photo, or video with the fans.',
                style: TextStyle(color: _muted, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 4,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Write something for the fans…',
                  filled: true,
                  fillColor: _canvas,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    key: const Key('community-add-image'),
                    onPressed: _isPickingMedia
                        ? null
                        : () => _pickMedia(video: false),
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: const Text('Photo'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    key: const Key('community-add-video'),
                    onPressed: _isPickingMedia
                        ? null
                        : () => _pickMedia(video: true),
                    icon: const Icon(Icons.videocam_outlined, size: 18),
                    label: const Text('Video'),
                  ),
                  if (_isPickingMedia) ...[
                    const SizedBox(width: 12),
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
              if (_media.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 86,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _media.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) => _SelectedMediaThumbnail(
                      media: _media[index],
                      onRemove: () => _removeMedia(index),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('community-submit-post'),
                  onPressed: _submitPost,
                  style: FilledButton.styleFrom(
                    backgroundColor: _cafMaroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'Post to community',
                    style: TextStyle(fontWeight: FontWeight.w800),
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

class _CommunityComposer extends StatelessWidget {
  const _CommunityComposer({required this.username, required this.onTap});

  final String username;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _Panel(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFF5E6E6),
            child: Text(
              username.isEmpty ? 'A' : username[0].toUpperCase(),
              style: const TextStyle(
                color: _cafMaroon,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Text(
              'Share something with the fans…',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_rounded, color: _cafMaroon),
          ),
        ],
      ),
    ),
  );
}

class _CommunityIdentityCard extends StatelessWidget {
  const _CommunityIdentityCard({required this.username, required this.onEdit});

  final String username;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFF5E6E6),
          child: Text(
            username.isEmpty ? 'A' : username[0].toUpperCase(),
            style: const TextStyle(
              color: _cafMaroon,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Posting as',
                style: TextStyle(color: _muted, fontSize: 10),
              ),
              const SizedBox(height: 3),
              Text(
                username,
                key: const Key('community-current-username'),
                style: const TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          key: const Key('community-edit-username'),
          onPressed: onEdit,
          child: const Text('Edit name'),
        ),
      ],
    ),
  );
}

class _CommunityUsernameDialog extends StatefulWidget {
  const _CommunityUsernameDialog({required this.initialUsername});

  final String initialUsername;

  @override
  State<_CommunityUsernameDialog> createState() =>
      _CommunityUsernameDialogState();
}

class _CommunityUsernameDialogState extends State<_CommunityUsernameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUsername);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Choose a username'),
    content: TextField(
      key: const Key('community-username-input'),
      controller: _controller,
      autofocus: true,
      maxLength: 24,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(hintText: 'Your display name'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('community-username-save'),
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Save'),
      ),
    ],
  );
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.post,
    required this.isOwnPost,
    required this.liked,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onDelete,
    required this.onReport,
  });

  final _CommunityPost post;
  final bool isOwnPost;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 19,
              backgroundColor: Color(0xFFF5E6E6),
              child: Icon(Icons.person_rounded, color: _cafMaroon, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.author,
                    key: const Key('community-post-author'),
                    style: TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Just now · Community post',
                    style: TextStyle(color: _muted, fontSize: 10),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Post options',
              onSelected: (action) {
                if (action == 'delete') {
                  onDelete();
                } else {
                  onReport();
                }
              },
              itemBuilder: (context) => [
                if (isOwnPost)
                  const PopupMenuItem(
                    key: Key('community-delete-post'),
                    value: 'delete',
                    child: Text('Delete post'),
                  )
                else
                  const PopupMenuItem(
                    value: 'report',
                    child: Text('Report post'),
                  ),
              ],
              child: const Icon(Icons.more_horiz_rounded, color: _muted),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (post.content.isNotEmpty)
          Text(
            post.content,
            key: const Key('community-post-content'),
            style: const TextStyle(color: _ink, fontSize: 14, height: 1.5),
          ),
        if (post.content.isNotEmpty && post.media.isNotEmpty)
          const SizedBox(height: 12),
        for (final media in post.media) ...[
          if (media != post.media.first) const SizedBox(height: 10),
          _CommunityPostMedia(media: media),
        ],
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFE9EFEB)),
        const SizedBox(height: 5),
        Row(
          children: [
            TextButton.icon(
              key: const Key('community-like-post'),
              onPressed: onLike,
              icon: Icon(
                liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: liked ? const Color(0xFFD84343) : _muted,
                size: 18,
              ),
              label: Text(
                '${liked ? 'Liked' : 'Like'} ${post.likes + (liked ? 1 : 0)}',
                style: TextStyle(
                  color: liked ? const Color(0xFFD84343) : _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              key: const Key('community-comment-post'),
              onPressed: onComment,
              icon: const Icon(Icons.mode_comment_outlined, size: 17),
              label: Text(
                'Comment ${post.comments.length}',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              key: const Key('community-share-post'),
              tooltip: 'Share post',
              onPressed: onShare,
              icon: const Icon(Icons.share_outlined, color: _muted, size: 19),
            ),
          ],
        ),
      ],
    ),
  );
}

class _CommunityCommentsSheet extends StatefulWidget {
  const _CommunityCommentsSheet({required this.comments});

  final List<String> comments;

  @override
  State<_CommunityCommentsSheet> createState() =>
      _CommunityCommentsSheetState();
}

class _CommunityCommentsSheetState extends State<_CommunityCommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _controller.text.trim();
    if (comment.isEmpty) return;
    Navigator.of(context).pop(comment);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .82,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 12, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Comments',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close comments',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: widget.comments.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(22),
                          child: Text(
                            'No comments yet. Start the conversation.',
                            style: TextStyle(color: _muted, fontSize: 12),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: widget.comments.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) => Text(
                          widget.comments[index],
                          key: const Key('community-comment'),
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('community-comment-input'),
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Write a comment…',
                          filled: true,
                          fillColor: _canvas,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      key: const Key('community-submit-comment'),
                      onPressed: _submit,
                      style: IconButton.styleFrom(
                        backgroundColor: _cafMaroon,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedMediaThumbnail extends StatelessWidget {
  const _SelectedMediaThumbnail({required this.media, required this.onRemove});

  final _CommunityMedia media;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 92,
    height: 86,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (media.isVideo)
            Container(
              color: _cafMaroonDeep,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 31,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'VIDEO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
          else
            FutureBuilder(
              future: media.file.readAsBytes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const ColoredBox(
                    color: Color(0xFFE9EFEB),
                    child: Center(
                      child: Icon(Icons.image_outlined, color: _muted),
                    ),
                  );
                }
                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(
                        color: Color(0xFFE9EFEB),
                        child: Icon(Icons.broken_image_outlined, color: _muted),
                      ),
                );
              },
            ),
          Positioned(
            top: 3,
            right: 3,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CommunityPostMedia extends StatelessWidget {
  const _CommunityPostMedia({required this.media});

  final _CommunityMedia media;

  @override
  Widget build(BuildContext context) {
    if (media.isVideo) {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux)) {
        return _videoUnavailableCard();
      }
      return _CommunityVideoPlayer(media: media);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FutureBuilder(
        future: media.file.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 220,
              child: ColoredBox(
                color: Color(0xFFE9EFEB),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          return Image.memory(
            snapshot.data!,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              height: 110,
              child: ColoredBox(
                color: Color(0xFFE9EFEB),
                child: Center(
                  child: Text('This image could not be displayed.'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _videoUnavailableCard() => Container(
    width: double.infinity,
    height: 190,
    decoration: BoxDecoration(
      color: _cafMaroonDeep,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.play_circle_fill_rounded,
          color: Colors.white,
          size: 48,
        ),
        const SizedBox(height: 6),
        Text(
          media.file.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    ),
  );
}

class _CommunityVideoPlayer extends StatefulWidget {
  const _CommunityVideoPlayer({required this.media});

  final _CommunityMedia media;

  @override
  State<_CommunityVideoPlayer> createState() => _CommunityVideoPlayerState();
}

class _CommunityVideoPlayerState extends State<_CommunityVideoPlayer> {
  late final VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = community_video.createController(widget.media.file.path);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      if (mounted) setState(() {});
    } on PlatformException {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 190,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _cafMaroonDeep,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'This video could not be played.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    if (!_controller.value.isInitialized) {
      return const SizedBox(
        height: 190,
        child: ColoredBox(
          color: _cafMaroonDeep,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller),
            Align(
              alignment: Alignment.center,
              child: IconButton.filled(
                tooltip: _controller.value.isPlaying
                    ? 'Pause video'
                    : 'Play video',
                onPressed: () => setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                }),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 30,
                ),
              ),
            ),
            VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: _cafMaroon,
                bufferedColor: Colors.white54,
                backgroundColor: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityEmptyState extends StatelessWidget {
  const _CommunityEmptyState();

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4D9),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(Icons.forum_rounded, color: _cafMaroon, size: 27),
        ),
        const SizedBox(height: 12),
        const Text(
          'Start the conversation',
          style: TextStyle(
            color: _ink,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Be the first to post. Share a thought, question, or matchday moment.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
        ),
      ],
    ),
  );
}

class _CommunitySafetyNote extends StatelessWidget {
  const _CommunitySafetyNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF5DD),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.shield_outlined, color: Color(0xFF8A6210), size: 18),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            'Be respectful. You can report a post from its options menu. Posts are visible only during this app session until community accounts and shared storage are connected.',
            style: TextStyle(color: _ink, fontSize: 11, height: 1.45),
          ),
        ),
      ],
    ),
  );
}

class _AssistantReply extends StatelessWidget {
  const _AssistantReply({
    required this.question,
    required this.response,
    required this.loading,
  });
  final String question;
  final String? response;
  final bool loading;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF5DD),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You asked: "$question"',
          style: const TextStyle(
            color: _ink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        if (loading)
          const Row(
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _cafMaroon,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Checking verified AFCON information...',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          )
        else
          Text(
            response ?? 'No answer returned.',
            style: const TextStyle(color: _ink, fontSize: 12, height: 1.5),
          ),
      ],
    ),
  );
}

class _FeatureHero extends StatelessWidget {
  const _FeatureHero({required this.feature});
  final String feature;

  IconData get icon => switch (feature) {
    'Ask AFCON' => Icons.auto_awesome_rounded,
    'Follow teams' => Icons.star_rounded,
    'Notifications' => Icons.notifications_active_rounded,
    'Events' => Icons.event_rounded,
    'Venues' => Icons.stadium_rounded,
    'Media' => Icons.play_circle_fill_rounded,
    _ => Icons.forum_rounded,
  };

  String get description => switch (feature) {
    'Ask AFCON' =>
      'A multilingual tournament guide, grounded in verified information.',
    'Follow teams' => 'Keep your favorite teams and matches close.',
    'Notifications' =>
      'Choose the matchday reminders and tournament news you want.',
    'Events' => 'Find tournament activities by city, region, date and time.',
    'Venues' =>
      'Plan your matchday with official stadium and location information.',
    'Media' => 'Interviews, highlights, photographs and stories from AFCON.',
    _ => 'Share the excitement with fans in a respectful, welcoming space.',
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE6EBE7)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.toUpperCase(),
                style: const TextStyle(
                  color: _cafMaroon,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                description,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  feature == 'Community'
                      ? 'POST IN THIS SESSION'
                      : 'FEATURE PREVIEW',
                  style: const TextStyle(
                    color: _cafMaroon,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFF5E6E6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _cafMaroon, size: 27),
        ),
      ],
    ),
  );
}

class _OfficialVideoCard extends StatelessWidget {
  const _OfficialVideoCard({
    required this.title,
    required this.round,
    required this.date,
    required this.youtubeId,
    required this.source,
    required this.onTap,
  });

  final String title;
  final String round;
  final String date;
  final String youtubeId;
  final String source;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Image.network(
                  'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF183326),
                    child: const Icon(
                      Icons.sports_soccer_rounded,
                      color: Colors.white70,
                      size: 42,
                    ),
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 54,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 12)],
                  ),
                ),
                Positioned(
                  right: 9,
                  bottom: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      source,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        round,
                        style: const TextStyle(
                          color: _cafMaroon,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.open_in_new_rounded, color: _cafMaroon),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: _ink,
      fontSize: 17,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE6EBE7)),
    ),
    child: child,
  );
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.title,
    required this.detail,
    required this.icon,
  });
  final String title;
  final String detail;
  final IconData icon;
  @override
  Widget build(BuildContext context) => _Panel(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF5E6E6),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: _cafMaroon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                detail,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'AWAITING VERIFIED CONTENT',
                style: TextStyle(
                  color: Color(0xFF8A6210),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .45,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SourceNote extends StatelessWidget {
  const _SourceNote();
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.verified_user_outlined, color: _cafMaroon, size: 17),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'Schedules, venue details, media and tournament answers should be shown only when confirmed by an approved source.',
          style: TextStyle(color: _muted, fontSize: 11, height: 1.45),
        ),
      ),
    ],
  );
}
