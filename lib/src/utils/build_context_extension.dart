import 'package:flutter/material.dart';

extension BuildContextEntension<T> on BuildContext {

  // SCREEN SIZES

  bool get isMobile => MediaQuery.of(this).size.width <= 500.0;
  bool get isTablet => MediaQuery.of(this).size.width < 1024.0 && MediaQuery.of(this).size.width >= 650.0;
  bool get isSmallTablet => MediaQuery.of(this).size.width < 650.0 && MediaQuery.of(this).size.width > 500.0;
  bool get isDesktop => MediaQuery.of(this).size.width >= 1024.0;
  bool get isSmall => MediaQuery.of(this).size.width < 850.0 && MediaQuery.of(this).size.width >= 560.0;
  Size get screenSize => MediaQuery.of(this).size;


  // TEXT STYLES

  TextTheme get text => Theme.of(this).textTheme;

  // COLORS

  ColorScheme get color => Theme.of(this).colorScheme;


  // NAVIGATION

  NavigatorState get nav => Navigator.of(this);


  // INTERACTIONS

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(String message) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        // behavior: SnackBarBehavior.floating,
        // backgroundColor: primary,
      ),
    );
  }
}