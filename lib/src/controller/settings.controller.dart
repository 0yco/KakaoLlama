import 'package:flutter/material.dart';
import 'package:kakaollama/src/services/settings.service.dart';

class SettingsController with ChangeNotifier {
  SettingsController._privateConstructor(this._settingsService);

  static final SettingsController _instance =
      SettingsController._privateConstructor(SettingsService());

  factory SettingsController() {
    return _instance;
  }

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  late bool _devMode;

  ThemeMode get themeMode => _themeMode;
  bool get devMode => _devMode;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _devMode = await _settingsService.switchValue('devMode');

    notifyListeners();
  }

  Future<void> toggleThemeMode() async {
    final newThemeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    _themeMode = newThemeMode;

    notifyListeners();

    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> toggleDevMode() async {
    _devMode = !_devMode;

    notifyListeners();

    await _settingsService.updateSwitch('devMode', _devMode);
  }
}
