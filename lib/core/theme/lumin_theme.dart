import 'package:flutter/material.dart';

/// LuminClash Material 3 Expressive (M3E) 动态色彩规范
class LuminTheme {
  // Material 3 Expressive 精选高饱和表现力色彩种子（通过 DynamicSchemeVariant.expressive 算法驱动）
  static const List<MonetSeedItem> monetSeedPalette = [
    MonetSeedItem('像素深蓝', 'Electric Blue', Color(0xFF2563EB)),
    MonetSeedItem('翡翠霓虹', 'Emerald Mint', Color(0xFF059669)),
    MonetSeedItem('极光紫罗兰', 'Aurora Violet', Color(0xFF7C3AED)),
    MonetSeedItem('蔚蓝冰海', 'Ocean Cyan', Color(0xFF0284C7)),
    MonetSeedItem('珊瑚绯焰', 'Coral Rose', Color(0xFFE11D48)),
    MonetSeedItem('琥珀日落', 'Sunset Gold', Color(0xFFD97706)),
  ];

  static const double cardRadius = 26.0;

  static ThemeData createTheme({
    Color seedColor = const Color(0xFF2563EB),
    Brightness brightness = Brightness.dark,
  }) {
    // 启用 Material 3 Expressive 色彩生成算法，获得高表现力互补三级色 (Tertiary) 与鲜活色阶
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.expressive,
    );

    final textTheme = ThemeData(brightness: brightness).textTheme.copyWith(
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 11.5,
        color: colorScheme.onSurfaceVariant,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: 'Inter',
      fontFamilyFallback: const [
        'TwemojiCountryFlags',
        'Segoe UI Emoji',
        'Segoe UI',
        'PingFang SC',
        'Microsoft YaHei UI',
        'sans-serif',
      ],
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

class MonetSeedItem {
  final String nameZh;
  final String nameEn;
  final Color color;

  const MonetSeedItem(this.nameZh, this.nameEn, this.color);
}
