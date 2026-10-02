import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/providers/clash_provider.dart';
import 'core/theme/lumin_theme.dart';
import 'ui/pages/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 针对移动端开启边到边沉浸式状态栏
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // 针对桌面端进行沉浸式无边框窗口初始化
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    try {
      await windowManager.ensureInitialized();
      await windowManager.setSize(const Size(450, 850));
      await windowManager.setMinimumSize(const Size(400, 700));
      await windowManager.center();
      await windowManager.setTitle('LuminClash');
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await windowManager.show();
      await windowManager.focus();
    } catch (e) {
      debugPrint('WindowManager init warning: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: LuminClashApp(),
    ),
  );
}

class LuminClashApp extends ConsumerWidget {
  const LuminClashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monetIndex =
        ref.watch(dashboardProvider.select((s) => s.monetSeedIndex));
    final themeMode =
        ref.watch(dashboardProvider.select((s) => s.themeMode));
    final currentSeed = LuminTheme.monetSeedPalette[monetIndex].color;

    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    final darkTheme = LuminTheme.createTheme(
      seedColor: currentSeed,
      brightness: Brightness.dark,
    );
    final lightTheme = LuminTheme.createTheme(
      seedColor: currentSeed,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'LuminClash',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const MainScreen(),
    );
  }
}
