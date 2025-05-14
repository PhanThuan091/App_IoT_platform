import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static final Color _lightPrimaryColor = Color(0xFF2196F3);
  static final Color _lightAccentColor = Color(0xFF03A9F4);
  static final Color _lightBackgroundColor = Color(0xFFF5F5F5);
  static final Color _lightCardColor = Colors.white;
  static final Color _lightTextColor = Color(0xFF333333);
  static final Color _lightIconColor = Color(0xFF757575);

  // Dark Theme Colors
  static final Color _darkPrimaryColor = Color(0xFF1565C0);
  static final Color _darkAccentColor = Color(0xFF0288D1);
  static final Color _darkBackgroundColor = Color(0xFF121212);
  static final Color _darkCardColor = Color(0xFF1E1E1E);
  static final Color _darkTextColor = Color(0xFFEEEEEE);
  static final Color _darkIconColor = Color(0xFFBDBDBD);

  // Common Properties
  static const double _borderRadius = 12.0;
  static const double _cardElevation = 1.0;

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: _lightBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightPrimaryColor,
      iconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      color: _lightCardColor,
      elevation: _cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: _lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: _lightTextColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: _lightTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: _lightTextColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: _lightTextColor,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: _lightTextColor.withOpacity(0.7),
        fontSize: 12,
      ),
    ),
    iconTheme: IconThemeData(
      color: _lightIconColor,
    ),
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      secondary: _lightAccentColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      surface: _lightCardColor,
      background: _lightBackgroundColor,
      onSurface: _lightTextColor,
      onBackground: _lightTextColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return _lightPrimaryColor;
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return _lightPrimaryColor.withOpacity(0.5);
        }
        return Colors.grey.withOpacity(0.5);
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: _lightPrimaryColor,
      inactiveTrackColor: _lightPrimaryColor.withOpacity(0.3),
      thumbColor: _lightPrimaryColor,
      overlayColor: _lightPrimaryColor.withOpacity(0.2),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkPrimaryColor,
      iconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      color: _darkCardColor,
      elevation: _cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: _darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: _darkTextColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: _darkTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: _darkTextColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: _darkTextColor,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: _darkTextColor.withOpacity(0.7),
        fontSize: 12,
      ),
    ),
    iconTheme: IconThemeData(
      color: _darkIconColor,
    ),
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _darkAccentColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      surface: _darkCardColor,
      background: _darkBackgroundColor,
      onSurface: _darkTextColor,
      onBackground: _darkTextColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return _darkPrimaryColor;
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return _darkPrimaryColor.withOpacity(0.5);
        }
        return Colors.grey.withOpacity(0.5);
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: _darkPrimaryColor,
      inactiveTrackColor: _darkPrimaryColor.withOpacity(0.3),
      thumbColor: _darkPrimaryColor,
      overlayColor: _darkPrimaryColor.withOpacity(0.2),
    ),
  );
}