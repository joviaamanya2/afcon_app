import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
  final Set<int> _likedCommunityPosts = {};

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
                feature == 'Media' ? 'AFCON Match Center' : feature,
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

  Widget _backendMediaContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF101B2B), Color(0xFF173B2D), Color(0xFF102318)],
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.play_circle_fill_rounded,
              color: Color(0xFFFFFFFF),
              size: 38,
            ),
            SizedBox(height: 9),
            Text(
              'AFCON MEDIA LIBRARY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Published photos, videos and audio from the dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFDCE8DF), fontSize: 12),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: _Panel(
          child: _backendContentList(
            resource: 'media',
            title: 'media',
            icon: Icons.play_circle_outline_rounded,
          ),
        ),
      ),
    ],
  );

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
      _CommunityComposer(onTap: _composeCommunityPost),
      const SizedBox(height: 14),
      if (_communityPosts.isEmpty)
        const _CommunityEmptyState()
      else
        for (var index = 0; index < _communityPosts.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CommunityPostCard(
              post: _communityPosts[index],
              liked: _likedCommunityPosts.contains(
                _communityPosts[index].createdAt.microsecondsSinceEpoch,
              ),
              onLike: () => setState(() {
                final postKey =
                    _communityPosts[index].createdAt.microsecondsSinceEpoch;
                if (!_likedCommunityPosts.add(postKey)) {
                  _likedCommunityPosts.remove(postKey);
                }
              }),
              onReport: _reportCommunityPost,
            ),
          ),
      const SizedBox(height: 6),
      const _CommunitySafetyNote(),
    ],
  );

  void _reportCommunityPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thanks. This post has been flagged for review.'),
      ),
    );
  }
}

class _CommunityPost {
  const _CommunityPost({
    required this.content,
    required this.media,
    required this.createdAt,
  });

  final String content;
  final List<_CommunityMedia> media;
  final DateTime createdAt;
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
  const _CommunityComposer({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _Panel(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFF5E6E6),
            child: Icon(Icons.person_rounded, color: _cafMaroon),
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

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.post,
    required this.liked,
    required this.onLike,
    required this.onReport,
  });

  final _CommunityPost post;
  final bool liked;
  final VoidCallback onLike;
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You',
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
              onSelected: (_) => onReport(),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'report', child: Text('Report post')),
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
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onLike,
            icon: Icon(
              liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: liked ? const Color(0xFFD84343) : _muted,
              size: 18,
            ),
            label: Text(
              liked ? 'Liked' : 'Like',
              style: TextStyle(
                color: liked ? const Color(0xFFD84343) : _muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );
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
