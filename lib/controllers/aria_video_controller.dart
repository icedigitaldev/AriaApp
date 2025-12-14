import 'package:flutter/material.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:video_player/video_player.dart';
import '../states/aria_video_state.dart';

class AriaVideoController extends AriaVideoNotifier {
  bool _hasInitialized = false;

  Future<void> initialize() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    final controller = VideoPlayerController.asset('assets/media/aria.webm');

    try {
      await controller.initialize();
      await controller.setVolume(0);
      controller.setLooping(true);
      await controller.play();

      state = state.copyWith(
        controller: controller,
        isInitialized: true,
        isPlaying: true,
      );
    } catch (e) {
      debugPrint('Error al inicializar video: $e');
    }
  }

  void play() {
    if (state.isInitialized && !state.isPlaying) {
      state.controller?.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  void pause() {
    if (state.isInitialized && state.isPlaying) {
      state.controller?.pause();
      state = state.copyWith(isPlaying: false);
    }
  }

  void disposeController() {
    state.controller?.dispose();
    state = const AriaVideoState();
    _hasInitialized = false;
  }
}

final ariaVideoControllerProvider =
    NotifierProvider<AriaVideoController, AriaVideoState>(
      (ref) => AriaVideoController(),
    );
