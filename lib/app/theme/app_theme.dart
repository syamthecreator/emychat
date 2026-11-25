import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  /// Ultra Premium Midnight Sapphire Dark Theme
  static ThemeData get darkTheme {
    final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
      primary: AppColors.arcticBlue,
      onPrimary: AppColors.midnightNavy,
      secondary: AppColors.sapphireBlue,
      onSecondary: Colors.white,
      surface: AppColors.darkCard,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.darkCardMuted,
      error: AppColors.error,
      onError: AppColors.onError,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.deepNavy,
      canvasColor: AppColors.midnightNavy,
      dividerColor: AppColors.darkDivider,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.midnightNavy,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
    );
  }

  /// Ultra Premium Arctic Silver Sapphire Light Theme
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: AppColors.sapphireBlue,
      onPrimary: Colors.white,
      secondary: AppColors.arcticBlue,
      onSecondary: AppColors.lightTextPrimary,
      surface: AppColors.lightCard,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightCardMuted,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      canvasColor: Colors.white,
      dividerColor: AppColors.lightBorder,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
    );
  }
}
