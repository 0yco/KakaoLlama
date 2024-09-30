import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakaollama/src/controller/settings.controller.dart';
import 'package:kakaollama/src/services/shared_pref.service.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefService().init();
  await SettingsController().loadSettings();
  Animate.defaultCurve = Curves.decelerate;
  Animate.defaultDuration = const Duration(milliseconds: 500);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}
