import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/storage/hive_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveManager.initialize();
  runApp(const ProviderScope(child: EventOrganisingApp()));
}
