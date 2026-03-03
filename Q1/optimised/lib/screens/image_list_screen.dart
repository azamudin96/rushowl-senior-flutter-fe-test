import 'package:flutter/material.dart';

import '../widgets/image_tile.dart';

const int itemCount = 1000;

class ImageListScreen extends StatelessWidget {
  const ImageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimised Image List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: itemCount,
        itemExtent: 200,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        cacheExtent: 1200,
        itemBuilder: (context, index) {
          return ImageTile(
            imageUrl: 'https://picsum.photos/seed/$index/600/400',
          );
        },
      ),
    );
  }
}
