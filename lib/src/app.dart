import 'package:flutter/material.dart';
import 'package:kakaollama/src/controller/settings.controller.dart';
import 'package:kakaollama/src/models/room.model.dart';
import 'package:kakaollama/src/pages/room/room.page.dart';
import 'package:kakaollama/src/theme.dart';
import 'package:kakaollama/src/util.dart';
import 'pages/home/home.page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // NOTE: Here a example of custom route animation for SampleItemDetailsView
  Route _createSampleItemDetailsRoute(Room room) {
    const duration = Duration(milliseconds: 400);

    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => RoomPage(room: room),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // NOTE: You can use different transitions like ScaleTransition, FadeTransition, etc...
        // (read https://docs.flutter.dev/cookbook/animation/page-route-animation)
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: Create your own custom Theme and TextTheme
    TextTheme textTheme = createTextTheme(context, "Kanit", "Albert Sans");
    MaterialTheme theme = MaterialTheme(textTheme);

    return ListenableBuilder(
      listenable: SettingsController(),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          theme: theme.light(),
          darkTheme: theme.dark(),
          themeMode: SettingsController().themeMode,
          onGenerateRoute: _onGenerateRoute,
        );
      },
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case HomePage.routeName:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (context) => const HomePage(),
        );
      case RoomPage.routeName:
        final room = routeSettings.arguments as Room;
        return _createSampleItemDetailsRoute(room);
      default:
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (context) => const HomePage(),
        );
    }
  }
}
