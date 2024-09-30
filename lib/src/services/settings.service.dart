import 'package:flutter/material.dart';
import 'package:kakaollama/src/services/shared_pref.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final SharedPreferences prefs = SharedPrefService().prefs;

  Future<ThemeMode> themeMode() async {
    return ThemeMode.values[prefs.getInt('theme') ?? ThemeMode.system.index];
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    await prefs.setInt('theme', theme.index);
  }

  Future<bool> switchValue(String key) async {
    return prefs.getBool(key) ?? false;
  }

  Future<void> updateSwitch(String key, bool value) async {
    await prefs.setBool(key, value);
  }
}
