import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumin_clash/main.dart';
import 'package:lumin_clash/core/models/app_state.dart';
import 'package:lumin_clash/core/theme/lumin_theme.dart';
import 'package:lumin_clash/ui/pages/dashboard_page.dart';
import 'package:lumin_clash/ui/widgets/blur_number_ticker.dart';
import 'package:lumin_clash/ui/widgets/bouncy_tap.dart';
import 'package:lumin_clash/ui/widgets/fluid_segmented_bar.dart';
import 'package:lumin_clash/ui/widgets/network_probe_card.dart';
import 'package:lumin_clash/ui/widgets/power_fab_button.dart';
import 'package:lumin_clash/core/models/proxy_models.dart';
import 'package:lumin_clash/core/models/profile_model.dart';
import 'package:lumin_clash/core/services/core_process_service.dart';
import 'package:lumin_clash/ui/pages/proxies_page.dart';
import 'package:lumin_clash/ui/pages/rules_page.dart';
import 'package:lumin_clash/ui/pages/profiles_page.dart';
import 'package:lumin_clash/ui/widgets/proxy_node_card.dart';

void main() {
  testWidgets('LuminClash smoke test and compact typography verification', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LuminClashApp(),
      ),
    );

    // Verify key UI elements render
    expect(find.text('网络检测'), findsOneWidget);
    expect(find.text('内存占用'), findsOneWidget);
    expect(find.text('出站模式'), findsOneWidget);
    expect(find.text('运行中'), findsOneWidget);

    // Verify Dashboard title font size is reduced to 22
    final titleText = tester.widget<Text>(
      find.descendant(
        of: find.byType(DashboardPage),
        matching: find.text('仪表盘'),
      ),
    );
    expect(titleText.style?.fontSize, 22.0);

    // Verify Power FAB button renders
    expect(find.byType(PowerFabButton), findsOneWidget);
  });

  testWidgets('Power FAB toggles state smoothly with MD animations', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LuminClashApp(),
      ),
    );

    expect(find.text('运行中'), findsOneWidget);

    // Tap Power FAB to toggle power
    await tester.tap(find.byType(PowerFabButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('已暂停'), findsOneWidget);

    // Tap again to toggle back
    await tester.tap(find.byType(PowerFabButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('运行中'), findsOneWidget);
  });

  testWidgets('Settings page renders with compact typography', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LuminClashApp(),
      ),
    );

    // Switch to Settings tab (last item in left rail)
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify settings title is 22sp
    final settingsTitle = tester.widget<Text>(find.text('设置'));
    expect(settingsTitle.style?.fontSize, 22.0);
    expect(find.text('外观与个性化'), findsOneWidget);
    expect(find.text('M3E 引擎'), findsOneWidget);
  });

  test('LuminTheme produces Material 3 Expressive color scheme', () {
    final darkTheme = LuminTheme.createTheme(brightness: Brightness.dark);
    final lightTheme = LuminTheme.createTheme(brightness: Brightness.light);

    expect(darkTheme.useMaterial3, true);
    expect(lightTheme.useMaterial3, true);
    expect(darkTheme.colorScheme.primary, isNotNull);
    expect(darkTheme.colorScheme.tertiary, isNotNull);
    expect(darkTheme.colorScheme.surfaceContainer, isNotNull);
  });

  testWidgets('BouncyTap triggers callback and scales', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BouncyTap(
              onTap: () {
                tapped = true;
              },
              child: const Text('TapMe'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('TapMe'), findsOneWidget);
    await tester.tap(find.text('TapMe'));
    await tester.pumpAndSettle();
    expect(tapped, true);
  });

  testWidgets('FluidSegmentedBar renders options and changes mode', (WidgetTester tester) async {
    OutboundMode currentMode = OutboundMode.rule;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return FluidSegmentedBar(
                selectedMode: currentMode,
                onModeChanged: (mode) {
                  setState(() {
                    currentMode = mode;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('规则'), findsOneWidget);
    expect(find.text('全局'), findsOneWidget);
    expect(find.text('直连'), findsOneWidget);

    await tester.tap(find.text('全局'));
    await tester.pumpAndSettle();
    expect(currentMode, OutboundMode.global);

    await tester.tap(find.text('直连'));
    await tester.pumpAndSettle();
    expect(currentMode, OutboundMode.direct);
  });

  test('LuminTheme registers TwemojiCountryFlags in fontFamilyFallback for Windows flag support', () {
    final theme = LuminTheme.createTheme();
    expect(theme.textTheme.bodyMedium?.fontFamilyFallback, contains('TwemojiCountryFlags'));
  });

  testWidgets('NetworkProbeCard renders colored latency number without dot and uses Twemoji for flag', (WidgetTester tester) async {
    const testState = DashboardState(
      isRunning: true,
      upSpeed: '0 B/s',
      downSpeed: '0 B/s',
      ramMb: 35.4,
      outboundIp: '104.28.19.42',
      countryFlag: '🇭🇰',
      latencyMs: 30,
      outboundMode: OutboundMode.rule,
      activeNavIndex: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: LuminTheme.createTheme(),
        home: Scaffold(
          body: Center(
            child: NetworkProbeCard(
              state: testState,
              onRefresh: () {},
            ),
          ),
        ),
      ),
    );

    // Verify '30' is rendered with emerald green (0xFF10B981)
    final latencyTextFinder = find.text('30');
    expect(latencyTextFinder, findsOneWidget);
    final latencyText = tester.widget<Text>(latencyTextFinder);
    expect(latencyText.style?.color, const Color(0xFF10B981));

    // Verify flag is rendered with TwemojiCountryFlags font family
    final flagFinder = find.text('🇭🇰');
    expect(flagFinder, findsOneWidget);
    final flagText = tester.widget<Text>(flagFinder);
    expect(flagText.style?.fontFamily, 'TwemojiCountryFlags');
  });

  testWidgets('BlurNumberTicker updates text and transitions without bottom-left offset', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BlurNumberTicker(
            text: '100',
          ),
        ),
      ),
    );

    expect(find.text('100'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BlurNumberTicker(
            text: '200',
          ),
        ),
      ),
    );

    // Pump halfway through transition (should have both old and new text transitioning)
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('200'), findsOneWidget);

    // Settle transition
    await tester.pumpAndSettle();
    expect(find.text('200'), findsOneWidget);
    expect(find.text('100'), findsNothing);
  });

  test('ProxyNode and ProxyGroup model serialization', () {
    final nodeJson = {
      'type': 'Shadowsocks',
      'udp': true,
      'history': [
        {'time': '2026-10-01T12:00:00Z', 'delay': 45}
      ],
    };
    final node = ProxyNode.fromJson('HK-01', nodeJson);
    expect(node.name, 'HK-01');
    expect(node.type, 'Shadowsocks');
    expect(node.delay, 45);
    expect(node.udp, true);

    final groupJson = {
      'type': 'Selector',
      'now': 'HK-01',
      'all': ['HK-01', 'SG-02', 'JP-03'],
    };
    final group = ProxyGroup.fromJson('PROXY', groupJson);
    expect(group.name, 'PROXY');
    expect(group.type, 'Selector');
    expect(group.now, 'HK-01');
    expect(group.all.length, 3);
  });

  test('ProfileItem model serialization', () {
    final item = ProfileItem(
      id: '123',
      name: 'Test Profile',
      url: 'https://example.com/sub',
      filePath: 'C:/temp/123.yaml',
      lastUpdated: DateTime.now(),
      nodeCount: 15,
      isActive: true,
    );
    final json = item.toJson();
    final restored = ProfileItem.fromJson(json);
    expect(restored.id, '123');
    expect(restored.name, 'Test Profile');
    expect(restored.nodeCount, 15);
    expect(restored.isActive, true);
  });

  testWidgets('ProxyNodeCard renders with latency and triggers callbacks', (WidgetTester tester) async {
    var selected = false;
    var pinged = false;

    final node = const ProxyNode(
      name: 'HK Ultra 01',
      type: 'VLESS',
      delay: 42,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProxyNodeCard(
            node: node,
            isSelected: true,
            onSelect: () => selected = true,
            onPing: () => pinged = true,
          ),
        ),
      ),
    );

    expect(find.text('HK Ultra 01'), findsOneWidget);
    expect(find.text('VLESS'), findsOneWidget);
    expect(find.text('42 ms'), findsOneWidget);

    await tester.tap(find.text('HK Ultra 01'));
    expect(selected, true);

    await tester.tap(find.byIcon(Icons.bolt_rounded));
    expect(pinged, true);
  });

  testWidgets('ProxiesPage renders smoothly in ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProxiesPage(),
        ),
      ),
    );

    expect(find.text('节点与策略组'), findsOneWidget);
    expect(find.text('刷新'), findsOneWidget);
  });

  testWidgets('RulesPage renders with tab bars', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RulesPage(),
        ),
      ),
    );

    expect(find.text('规则与连接'), findsOneWidget);
    expect(find.textContaining('分流规则'), findsOneWidget);
    expect(find.textContaining('活动连接'), findsOneWidget);
  });

  testWidgets('ProfilesPage renders with import button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfilesPage(),
        ),
      ),
    );

    expect(find.text('订阅配置'), findsOneWidget);
    expect(find.text('导入订阅'), findsOneWidget);
  });

  test('CoreProcessService detects bundled precompiled Mihomo binary', () async {
    final coreService = CoreProcessService();
    final exePath = await coreService.findCoreExecutable();
    expect(exePath, isNotNull);
    expect(exePath!.contains('mihomo'), true);
  });
}

