import 'package:flutter/material.dart';

const ink = Color(0xFF1E0053);
const purple = Color(0xFF3C00A7);
const violet = Color(0xFF5A00FB);
const paper = Color(0xFFFCFCFC);

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Montserrat',
  scaffoldBackgroundColor: paper,
  colorScheme: ColorScheme.fromSeed(
    seedColor: violet,
    primary: purple,
    onPrimary: Colors.white,
    surface: paper,
    onSurface: ink,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 16, color: ink),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w900,
      color: ink,
    ),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: paper,
    foregroundColor: ink,
    titleTextStyle: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 48),
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
);

class StatChip extends StatelessWidget {
  const StatChip(this.label, this.value, {super.key});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF0E9FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '$label: $value',
      style: const TextStyle(fontWeight: FontWeight.w700),
    ),
  );
}
