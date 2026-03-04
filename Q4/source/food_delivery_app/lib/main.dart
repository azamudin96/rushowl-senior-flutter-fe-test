import 'package:flutter/material.dart';

import 'app.dart';
import 'di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Cap image cache to 50 entries / 50 MB — prevents OOM on low-end devices (Q2)
  PaintingBinding.instance.imageCache.maximumSize = 50;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20;

  setupDependencies();
  runApp(const FoodDeliveryApp());
}
