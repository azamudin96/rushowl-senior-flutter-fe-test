import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  const ImageTile({super.key, required this.imageUrl});

  final String imageUrl;

  static const double _tileHeight = 200;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final pixelWidth = (mq.size.width * mq.devicePixelRatio).toInt();
    final pixelHeight = (_tileHeight * mq.devicePixelRatio).toInt();

    return RepaintBoundary(
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: _tileHeight,
          memCacheWidth: pixelWidth,
          memCacheHeight: pixelHeight,
          fadeInDuration: const Duration(milliseconds: 300),
          placeholder: (context, url) => const ColoredBox(
            color: Color(0xFFE0E0E0),
          ),
          errorWidget: (context, url, error) => const ColoredBox(
            color: Color(0xFFEEEEEE),
            child: Center(
              child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
