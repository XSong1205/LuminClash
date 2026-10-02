import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_state.dart';
import '../services/clash_api_client.dart';
import '../services/core_process_service.dart';
import '../services/network_probe_service.dart';
import '../services/system_proxy_service.dart';
import '../theme/lumin_theme.dart';
import 'proxies_provider.dart';

class DashboardNotifier extends Notifier<DashboardState> {
  late final CoreProcessService _coreService;
  late final ClashApiClient _apiClient;
  late final NetworkProbeService _probeService;

  StreamSubscription<TrafficData>? _trafficSub;
  StreamSubscription<MemoryData>? _memorySub;
  bool _isProbing = false;

  @override
  DashboardState build() {
    _coreService = CoreProcessService();
    _apiClient = ClashApiClient();
    _probeService = NetworkProbeService();

    ref.onDispose(() {
      _trafficSub?.cancel();
      _memorySub?.cancel();
    });

    _initCoreConnections();
    return DashboardState.initial();
  }

  Future<void> _initCoreConnections() async {
    // 监听实时流量与内存
    _trafficSub = _apiClient.connectTrafficStream().listen((traffic) {
      if (!state.isRunning) return;
      state = state.copyWith(
        upSpeed: traffic.formattedUp,
        downSpeed: traffic.formattedDown,
      );
    });

    _memorySub = _apiClient.connectMemoryStream().listen((memory) {
      if (!state.isRunning) return;
      state = state.copyWith(ramMb: memory.inuseMb);
    });

    // 获取版本信息并确保运行态内核被拉起
    try {
      var version = await _apiClient.getVersion();
      if (version == null && state.isRunning) {
        state = state.copyWith(isCoreStarting: true);
        final started = await _coreService.startCore();
        state = state.copyWith(isCoreStarting: false);
        if (started) {
          if (Platform.isWindows && state.systemProxyEnabled) {
            await SystemProxyService.enableSystemProxy();
          }
          version = await _apiClient.getVersion();
        }
      }
      if (version != null) {
        state = state.copyWith(coreVersion: version);
      }
    } catch (_) {
      state = state.copyWith(isCoreStarting: false);
    }

    // 检查系统代理状态
    final sysProxy = SystemProxyService.isSystemProxyEnabled();
    state = state.copyWith(systemProxyEnabled: sysProxy);

    // 启动初始网络检测与真实出口 IP 查询
    unawaited(refreshProbe());
  }

  Future<void> togglePower() async {
    final nextRunning = !state.isRunning;
    if (!nextRunning) {
      state = state.copyWith(
        isRunning: false,
        upSpeed: '0 B/s',
        downSpeed: '0 B/s',
        systemProxyEnabled: false,
      );
      await _coreService.stopCore();
      if (Platform.isWindows) {
        await SystemProxyService.disableSystemProxy();
      }
      unawaited(refreshProbe());
    } else {
      state = state.copyWith(
        isRunning: true,
        upSpeed: '0 B/s',
        downSpeed: '0 B/s',
        systemProxyEnabled: Platform.isWindows,
      );
      final started = await _coreService.startCore();
      if (started) {
        if (Platform.isWindows) {
          await SystemProxyService.enableSystemProxy();
        }
        final v = await _apiClient.getVersion();
        if (v != null) {
          state = state.copyWith(coreVersion: v);
        }
        unawaited(refreshProbe());
        unawaited(ref.read(proxiesProvider.notifier).loadProxies());
      } else {
        state = state.copyWith(
          isRunning: false,
          systemProxyEnabled: false,
        );
      }
    }
  }

  Future<void> setOutboundMode(OutboundMode mode) async {
    state = state.copyWith(outboundMode: mode);
    await _apiClient.patchConfigs({'mode': mode.apiValue});
    unawaited(refreshProbe());
  }

  Future<void> toggleSystemProxy() async {
    final next = !state.systemProxyEnabled;
    if (next) {
      await SystemProxyService.enableSystemProxy();
    } else {
      await SystemProxyService.disableSystemProxy();
    }
    state = state.copyWith(systemProxyEnabled: next);
  }

  void setActiveNav(int index) {
    state = state.copyWith(activeNavIndex: index);
  }

  void setMonetSeedIndex(int index) {
    if (index >= 0 && index < LuminTheme.monetSeedPalette.length) {
      state = state.copyWith(monetSeedIndex: index);
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  Future<void> refreshProbe() async {
    if (_isProbing) return;
    _isProbing = true;
    try {
      final probeResult = await _probeService.probe(
        useProxy: state.isRunning,
        proxyPort: 7890,
      );

      int latency = probeResult.latencyMs;
      if (state.isRunning) {
        final delay = await _apiClient.testDelay('GLOBAL');
        if (delay != null && delay > 0) {
          latency = delay;
        }
      }

      state = state.copyWith(
        outboundIp: probeResult.ip,
        countryFlag: probeResult.countryFlag,
        latencyMs: latency,
      );
    } catch (e) {
      debugPrint('[DashboardNotifier] refreshProbe exception: $e');
    } finally {
      _isProbing = false;
    }
  }
}

final dashboardProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);
