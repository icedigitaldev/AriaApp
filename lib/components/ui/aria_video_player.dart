import 'package:flutter/material.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:video_player/video_player.dart';
import '../../controllers/aria_video_controller.dart';

class AriaVideoPlayer extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AriaVideoPlayer({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref) {
        final videoState = ref.watch(ariaVideoControllerProvider);
        final controller = videoState.controller;

        if (!videoState.isInitialized || controller == null) {
          return SizedBox(width: width, height: height);
        }

        Widget videoWidget = SizedBox(
          width: width,
          height: height,
          child: FittedBox(
            fit: fit,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        );

        if (borderRadius != null) {
          videoWidget = ClipRRect(
            borderRadius: borderRadius!,
            child: videoWidget,
          );
        }

        return videoWidget;
      },
    );
  }
}
