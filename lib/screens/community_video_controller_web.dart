import 'package:video_player/video_player.dart';

VideoPlayerController createController(
  String path, {
  bool isNetwork = false,
}) =>
    VideoPlayerController.networkUrl(Uri.parse(path));
