import 'package:refena_flutter/refena_flutter.dart';
import 'package:video_player/video_player.dart';

class AriaVideoState {
  final VideoPlayerController? controller;
  final bool isInitialized;
  final bool isPlaying;

  const AriaVideoState({
    this.controller,
    this.isInitialized = false,
    this.isPlaying = false,
  });

  AriaVideoState copyWith({
    VideoPlayerController? controller,
    bool? isInitialized,
    bool? isPlaying,
  }) {
    return AriaVideoState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class AriaVideoNotifier extends Notifier<AriaVideoState> {
  @override
  AriaVideoState init() => const AriaVideoState();
}
