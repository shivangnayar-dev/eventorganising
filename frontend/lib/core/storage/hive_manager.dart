import 'package:hive_flutter/hive_flutter.dart';

class HiveManager {
  static const _settingsBox = 'settings';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_settingsBox)) {
      await Hive.openBox(_settingsBox);
    }
  }

  static Future<void> setThemeMode(bool isDark) async {
    final box = Hive.box(_settingsBox);
    await box.put('isDark', isDark);
  }

  static bool get isDark {
    if (!Hive.isBoxOpen(_settingsBox)) {
      throw StateError('Settings box is not initialized.');
    }
    return Hive.box(_settingsBox).get('isDark', defaultValue: false) as bool;
  }
}
