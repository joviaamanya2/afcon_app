import 'dart:io';

import 'package:video_player/video_player.dart';

VideoPlayerController createController(String path, {bool isNetwork = false}) =>
    isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(path))
        : VideoPlayerController.file(File(path));
