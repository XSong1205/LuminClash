import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/clash_provider.dart';
import '../../core/theme/lumin_motion.dart';
import '../widgets/left_status_rail.dart';
import '../widgets/window_title_bar.dart';
import 'dashboard_page.dart';
import 'profiles_page.dart';
import 'proxies_page.dart';
import 'rules_page.dart';
import 'settings_page.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MainScreenContent();
  }
}

class _MainScreenContent extends ConsumerStatefulWidget {
  const _MainScreenContent();

  @override
  ConsumerState<_MainScreenContent> createState() => _MainScreenContentState();
}

class _MainScreenContentState extends ConsumerState<_MainScreenContent> {
  int _previousNav = 0;

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    final activeNav = ref.watch(dashboardProvider.select((s) => s.activeNavIndex));
    final colorScheme = Theme.of(context).colorScheme;

    final isForward = activeNav >= _previousNav;
    _previousNav = activeNav;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            // 桌面端顶栏拖拽与控制 (移动端自动为空)
            const WindowTitleBar(),

            // 核心内容区 (左侧深色状态轨 + 右侧主内容)
            Expanded(
              child: Row(
                children: [
                  // 左侧紧凑状态与导航轨
                  const LeftStatusRail(),

                  // 右侧主画卷 (移动端整体下沉避让状态栏，呈现独立圆角辨识度)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: _isDesktop ? 0 : 6,
                        bottom: _isDesktop ? 0 : 6,
                        right: _isDesktop ? 0 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: _isDesktop
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                bottomLeft: Radius.circular(24),
                              )
                            : BorderRadius.circular(24),
                        boxShadow: _isDesktop
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: ClipRRect(
                        borderRadius: _isDesktop
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                bottomLeft: Radius.circular(24),
                              )
                            : BorderRadius.circular(24),
                        child: AnimatedSwitcher(
                          duration: LuminMotion.standard,
                          switchInCurve: LuminMotion.fluid,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            final slideTween = isForward
                                ? Tween<Offset>(
                                    begin: const Offset(0.0, 0.04),
                                    end: Offset.zero,
                                  )
                                : Tween<Offset>(
                                    begin: const Offset(0.0, -0.04),
                                    end: Offset.zero,
                                  );

                            return SlideTransition(
                              position: slideTween.animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: KeyedSubtree(
                            key: ValueKey(activeNav),
                            child: _buildBody(activeNav),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(int activeNavIndex) {
    switch (activeNavIndex) {
      case 0:
        return const DashboardPage();
      case 1:
        return const ProxiesPage();
      case 2:
        return const RulesPage();
      case 3:
        return const ProfilesPage();
      case 4:
        return const SettingsPage();
      default:
        return const DashboardPage();
    }
  }
}
