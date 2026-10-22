import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import 'community_video_controller_native.dart'
    if (dart.library.html) 'community_video_controller_web.dart'
    as community_video;

const _forest = Color(0xFF176B46);
const _deepForest = Color(0xFF104A34);
const _gold = Color(0xFFD8A441);
const _ink = Color(0xFF19251F);
const _muted = Color(0xFF69766F);
const _canvas = Color(0xFFF6F8F6);

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
  final Set<String> _followedTeams = {};
  String _selectedMediaTab = 'Details';
  final Map<String, bool> _notificationPreferences = {
    'Match reminders': true,
    'Kick-off changes': true,
    'Team news': false,
    'Tournament announcements': true,
  };
  final TextEditingController _questionController = TextEditingController();
  String? _submittedQuestion;
  final List<_CommunityPost> _communityPosts = [];
  final Set<int> _likedCommunityPosts = {};

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

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
              backgroundColor: _forest,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Create post'),
            )
          : null,
      body: feature == 'Media'
          ? ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                _mediaContent(),
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
                          onPressed: () =>
                              setState(() => _submittedQuestion = question),
                          backgroundColor: const Color(0xFFEAF3ED),
                          side: BorderSide.none,
                          labelStyle: const TextStyle(
                            color: _forest,
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
              onSubmitted: (value) =>
                  setState(() => _submittedQuestion = value.trim()),
              decoration: InputDecoration(
                hintText: 'Ask in your language…',
                suffixIcon: IconButton(
                  tooltip: 'Send question',
                  onPressed: () => setState(
                    () => _submittedQuestion = _questionController.text.trim(),
                  ),
                  icon: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(backgroundColor: _forest),
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
              _AssistantReply(question: question),
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
        child: Column(
          children: [
            for (final team in [
              'Uganda',
              'Ghana',
              'Ivory Coast',
              'Nigeria',
              'Morocco',
              'Senegal',
              'Egypt',
              'South Africa',
              'Kenya',
              'Tanzania',
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEAF3ED),
                  child: Text(
                    team[0],
                    style: const TextStyle(
                      color: _forest,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                title: Text(
                  team,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'Team profile and tournament updates',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
                trailing: IconButton(
                  tooltip: _followedTeams.contains(team)
                      ? 'Unfollow $team'
                      : 'Follow $team',
                  onPressed: () => setState(
                    () => _followedTeams.contains(team)
                        ? _followedTeams.remove(team)
                        : _followedTeams.add(team),
                  ),
                  icon: Icon(
                    _followedTeams.contains(team)
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: _followedTeams.contains(team)
                        ? const Color(0xFFB17A00)
                        : _muted,
                  ),
                ),
              ),
          ],
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
                  activeTrackColor: _forest,
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
      const _EventCard(
        title: 'Fan events',
        detail: 'Official fan activities will appear here when confirmed.',
        icon: Icons.groups_rounded,
      ),
      const SizedBox(height: 10),
      const _EventCard(
        title: 'City guide',
        detail: 'Explore activities by host city and region.',
        icon: Icons.location_city_rounded,
      ),
      const SizedBox(height: 10),
      const _EventCard(
        title: 'Community events',
        detail: 'Community-submitted listings will be clearly identified and dated.',
        icon: Icons.event_available_rounded,
      ),
    ],
  );

  Widget _venueContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Matchday locations'),
      const SizedBox(height: 10),
      const _EventCard(
        title: 'Stadium details',
        detail: 'Venue name, city, gates and facilities will be shown when official details are available.',
        icon: Icons.stadium_rounded,
      ),
      const SizedBox(height: 10),
      const _EventCard(
        title: 'Getting there',
        detail: 'Directions will link to verified venue locations.',
        icon: Icons.directions_rounded,
      ),
      const SizedBox(height: 10),
      const _EventCard(
        title: 'Your selected match',
        detail:
            'Open Matches to choose a fixture and view its confirmed location.',
        icon: Icons.place_rounded,
      ),
    ],
  );

  Widget _mediaContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 17, 18, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF101B2B), Color(0xFF173B2D), Color(0xFF102318)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const Text(
              'AFCON 2025  ·  OFFICIAL MEDIA',
              style: TextStyle(
                color: Color(0xFFDCE8DF),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MediaTeamBadge(label: 'AFCON'),
                Column(
                  children: [
                    Text(
                      'VIDEO',
                      style: TextStyle(
                        color: Color(0xFFB7C4BD),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'HIGHLIGHTS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                _MediaTeamBadge(label: '2025'),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Goals, match moments and tournament stories',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFE2E8E4), fontSize: 11),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 42,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final tab in [
                'Details',
                'Lineups',
                'Ratings',
                'H2H',
                'Predictions',
                'Analysis',
              ])
                InkWell(
                  onTap: () => setState(() => _selectedMediaTab = tab),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedMediaTab == tab
                              ? _forest
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: _selectedMediaTab == tab ? _forest : _muted,
                        fontSize: 11,
                        fontWeight: _selectedMediaTab == tab
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      const Divider(height: 1, color: Color(0xFFE6E9EC)),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Match Report'),
            const SizedBox(height: 9),
            _MediaReportCard(onTap: _openMediaNotice),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: _SectionTitle('Match Moments')),
                TextButton(
                  onPressed: _openMediaNotice,
                  child: const Text(
                    'VIEW ALL',
                    style: TextStyle(
                      color: _forest,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 112,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _MediaMomentCard(
                    title: 'Opening moments',
                    subtitle: 'AFCON matchday',
                    icon: Icons.sports_soccer_rounded,
                    colors: const [Color(0xFF174A36), Color(0xFF377957)],
                    onTap: _openMediaNotice,
                  ),
                  _MediaMomentCard(
                    title: 'Best chances',
                    subtitle: 'Key match moments',
                    icon: Icons.bolt_rounded,
                    colors: const [Color(0xFF7C3E25), Color(0xFFD67A32)],
                    onTap: _openMediaNotice,
                  ),
                  _MediaMomentCard(
                    title: 'Full-time reaction',
                    subtitle: 'From the touchline',
                    icon: Icons.celebration_rounded,
                    colors: const [Color(0xFF263B66), Color(0xFF5682A5)],
                    onTap: _openMediaNotice,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 17),
            const _SectionTitle('Highlights & Playback'),
            const SizedBox(height: 9),
            _MediaPlaybackCard(onTap: _openMediaNotice),
            const SizedBox(height: 10),
            const Text(
              'Official video clips will appear here when licensed tournament media is available.',
              style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
            ),
            const SizedBox(height: 18),
            const _SectionTitle('More from AFCON'),
            const SizedBox(height: 9),
            const _EventCard(
              title: 'Interviews & press conferences',
              detail: 'Official team and player interviews.',
              icon: Icons.mic_rounded,
            ),
            const SizedBox(height: 9),
            const _EventCard(
              title: 'Photos & stories',
              detail: 'Tournament galleries and newsroom updates.',
              icon: Icons.photo_library_rounded,
            ),
          ],
        ),
      ),
    ],
  );

  void _openMediaNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Official video playback will be available when licensed clips are connected.',
        ),
      ),
    );
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
                    backgroundColor: _forest,
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
            backgroundColor: Color(0xFFEAF3ED),
            child: Icon(Icons.person_rounded, color: _forest),
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
              color: const Color(0xFFEAF3ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_rounded, color: _forest),
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
              backgroundColor: Color(0xFFEAF3ED),
              child: Icon(Icons.person_rounded, color: _forest, size: 21),
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
              color: _deepForest,
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
      color: _deepForest,
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
          color: _deepForest,
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
          color: _deepForest,
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
                playedColor: _gold,
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
          child: const Icon(Icons.forum_rounded, color: _forest, size: 27),
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
  const _AssistantReply({required this.question});
  final String question;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF5DD),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      'You asked: “$question”\n\nI can answer this once connected to current, approved AFCON sources. I won’t guess about fixtures or venues.',
      style: const TextStyle(color: _ink, fontSize: 12, height: 1.5),
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
                  color: _forest,
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
                  color: const Color(0xFFEAF3ED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  feature == 'Community'
                      ? 'POST IN THIS SESSION'
                      : 'FEATURE PREVIEW',
                  style: const TextStyle(
                    color: _forest,
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
            color: const Color(0xFFEAF3ED),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _forest, size: 27),
        ),
      ],
    ),
  );
}

class _MediaTeamBadge extends StatelessWidget {
  const _MediaTeamBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: .25)),
        ),
        child: const Icon(
          Icons.sports_soccer_rounded,
          color: Colors.white,
          size: 23,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _MediaReportCard extends StatelessWidget {
  const _MediaReportCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD97C38), Color(0xFF9B392D)],
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AFCON matchday report',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Goals, key chances and the moments that shaped the game.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _muted, fontSize: 10, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right_rounded, color: _muted, size: 19),
          ],
        ),
      ),
    ),
  );
}

class _MediaMomentCard extends StatelessWidget {
  const _MediaMomentCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 142,
    child: Padding(
      padding: const EdgeInsets.only(right: 9),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -4,
                        bottom: -13,
                        child: Icon(
                          icon,
                          size: 72,
                          color: Colors.white.withValues(alpha: .18),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 8),
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

class _MediaPlaybackCard extends StatelessWidget {
  const _MediaPlaybackCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    key: const Key('media-playback-card'),
    color: const Color(0xFF102319),
    borderRadius: BorderRadius.circular(9),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 172,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, .45),
                  radius: 1.1,
                  colors: [
                    Color(0xFF558555),
                    Color(0xFF1B4935),
                    Color(0xFF111B2A),
                  ],
                ),
              ),
            ),
            Positioned(
              left: -20,
              right: -20,
              bottom: -30,
              child: Icon(
                Icons.stadium_rounded,
                size: 180,
                color: Colors.white.withValues(alpha: .14),
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 54,
                shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
              ),
            ),
            const Positioned(
              left: 11,
              right: 11,
              bottom: 10,
              child: Text(
                'AFCON HIGHLIGHTS  ·  FULL MATCH PLAYBACK',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .5,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
                ),
              ),
            ),
          ],
        ),
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
            color: const Color(0xFFEAF3ED),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: _forest),
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
      const Icon(Icons.verified_user_outlined, color: _forest, size: 17),
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
