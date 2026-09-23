import 'package:flutter/material.dart';

/// Paleta tomada directamente del diseno en Figma (verde cancha para las
/// acciones principales, violeta para todo lo relacionado a "turno fijo").
class AppColors {
  AppColors._();
  static const primario = Color(0xFF2F7A3D);
  static const primarioOscuro = Color(0xFF1D5A2A);
  static const fijoAccent = Color(0xFF5B4FC7);
  static const fijoFondo = Color(0xFFF0EEFB);
  static const peligro = Color(0xFFDC2626);
  static const fondo = Color(0xFFFAFAFA);
  static const texto = Color(0xFF18181B);
  static const textoSecundario = Color(0xFF71717A);
  static const borde = Color(0xFFE4E4E7);
}

class AppTheme {
  AppTheme._();
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primario,
      primary: AppColors.primario,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.fondo,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texto,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primario,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primario,
          side: const BorderSide(color: AppColors.primario, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borde),
        ),
      ),
    );
  }
}
