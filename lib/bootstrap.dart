import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/scanwise_app.dart';

void bootstrap() {
  runApp(const ProviderScope(child: ScanWiseApp()));
}
