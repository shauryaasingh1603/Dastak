import 'package:material_ui/material_ui.dart';

const _brand = Color(0xFFB4441F);
const fontFamily = 'NotoSansDevanagari';

/// Large, high-contrast type: the spec asks for at least 16 sp body text and
/// 20 sp titles, readable outdoors on low-end phones.
ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: _brand, primary: _brand);
  final base = ThemeData(colorScheme: scheme, fontFamily: fontFamily, useMaterial3: true);
  // Devanagari has tall matras above and below the line; give it room.
  final text = base.textTheme.apply(fontFamily: fontFamily).copyWith(
        bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 17, height: 1.5),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
        bodySmall: base.textTheme.bodySmall?.copyWith(fontSize: 14, height: 1.45),
        titleLarge: base.textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w700, height: 1.4),
        titleMedium: base.textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700, height: 1.4),
        labelLarge: base.textTheme.labelLarge?.copyWith(fontSize: 17, fontWeight: FontWeight.w500, height: 1.4),
      );
  return base.copyWith(
    textTheme: text,
    scaffoldBackgroundColor: const Color(0xFFF6F5F1),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      titleTextStyle: text.titleLarge?.copyWith(color: scheme.onPrimary, fontSize: 20),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48), textStyle: text.labelLarge),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2DFD6)),
      ),
    ),
  );
}
