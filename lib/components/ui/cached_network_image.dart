import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ice_storage/ice_storage.dart';

class CachedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<CachedNetworkImage> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<CachedNetworkImage> {
  static final Map<String, Uint8List> _memoryCache = {};

  Uint8List? _imageData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final url = widget.imageUrl;

    if (_memoryCache.containsKey(url)) {
      if (mounted) {
        setState(() {
          _imageData = _memoryCache[url];
          _isLoading = false;
          _hasError = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      Uint8List? data;

      final isCached = await IceStorage.instance.images.isImageCached(url);
      if (isCached) {
        data = await IceStorage.instance.images.getCachedImage(url);
      } else {
        data = await IceStorage.instance.images.downloadAndCacheImage(url);
      }

      if (data != null) {
        _memoryCache[url] = data;
      }

      if (mounted) {
        setState(() {
          _imageData = data;
          _isLoading = false;
          _hasError = data == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  static void clearMemoryCache() {
    _memoryCache.clear();
  }

  static void removeFromMemoryCache(String url) {
    _memoryCache.remove(url);
  }

  @override
  Widget build(BuildContext context) {
    Widget defaultPlaceholder = Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );

    Widget defaultError = Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 32,
      ),
    );

    Widget content;

    if (_isLoading) {
      content = widget.placeholder ?? defaultPlaceholder;
    } else if (_hasError || _imageData == null) {
      content = widget.errorWidget ?? defaultError;
    } else {
      content = Image.memory(
        _imageData!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: content,
        ),
      );
    }

    return SizedBox(width: widget.width, height: widget.height, child: content);
  }
}
