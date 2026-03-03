import 'package:flutter/material.dart';

import 'screens/image_list_screen.dart';

class OptimisedApp extends StatelessWidget {
  const OptimisedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Optimised Image List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ImageListScreen(),
    );
  }
}
