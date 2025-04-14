import 'package:flutter/material.dart';

class RetryableNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder; // ✅ Add this

  const RetryableNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.errorBuilder, // ✅ Add this
  });

  @override
  State<RetryableNetworkImage> createState() => _RetryableNetworkImageState();
}

class _RetryableNetworkImageState extends State<RetryableNetworkImage> {
  int retryCount = 0;
  bool loadFailed = false;

  @override
  Widget build(BuildContext context) {
    if (loadFailed && widget.errorBuilder != null) {
      return widget.errorBuilder!(context, Exception('Load failed'), StackTrace.current);
    }

    return Image.network(
      widget.imageUrl,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        if (retryCount < 1) {
          retryCount++;
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) setState(() {});
          });
          return const Center(child: CircularProgressIndicator());
        } else {
          loadFailed = true;
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, error, stackTrace);
          }
          return const Icon(Icons.error);
        }
      },
    );
  }
}
