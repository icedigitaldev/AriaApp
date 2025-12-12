import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TransparentVideoPlayer extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool loop;
  final bool autoPlay;
  final BorderRadius? borderRadius;

  const TransparentVideoPlayer({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.loop = true,
    this.autoPlay = true,
    this.borderRadius,
  });

  @override
  State<TransparentVideoPlayer> createState() => _TransparentVideoPlayerState();
}

class _TransparentVideoPlayerState extends State<TransparentVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(widget.assetPath);

    await _controller.initialize();

    if (widget.loop) {
      _controller.setLooping(true);
    }

    if (widget.autoPlay) {
      _controller.play();
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return SizedBox(width: widget.width, height: widget.height);
    }

    Widget videoWidget = SizedBox(
      width: widget.width,
      height: widget.height,
      child: FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );

    // Aplicar borderRadius si está definido
    if (widget.borderRadius != null) {
      videoWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: videoWidget,
      );
    }

    return videoWidget;
  }
}
