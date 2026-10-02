import 'package:flutter/material.dart';

enum OutboundMode {
  rule,
  global,
  direct,
}

extension OutboundModeExt on OutboundMode {
  String get label {
    switch (this) {
      case OutboundMode.rule:
        return '规则';
      case OutboundMode.global:
        return '全局';
      case OutboundMode.direct:
        return '直连';
    }
  }

  String get apiValue {
    switch (this) {
      case OutboundMode.rule:
        return 'Rule';
      case OutboundMode.global:
        return 'Global';
      case OutboundMode.direct:
        return 'Direct';
    }
  }

  static OutboundMode fromString(String mode) {
    switch (mode.toLowerCase()) {
      case 'global':
        return OutboundMode.global;
      case 'direct':
        return OutboundMode.direct;
      case 'rule':
      default:
        return OutboundMode.rule;
    }
  }
}

class DashboardState {
  final bool isRunning;
  final bool isCoreStarting;
  final String upSpeed;
  final String downSpeed;
  final double ramMb;
  final String outboundIp;
  final String countryFlag;
  final int latencyMs;
  final OutboundMode outboundMode;
  final int activeNavIndex;
  final int monetSeedIndex;
  final ThemeMode themeMode;
  final String? coreVersion;
  final bool systemProxyEnabled;
  final String? activeProfileName;
  final List<String> coreLogs;

  const DashboardState({
    required this.isRunning,
    this.isCoreStarting = false,
    required this.upSpeed,
    required this.downSpeed,
    required this.ramMb,
    required this.outboundIp,
    required this.countryFlag,
    required this.latencyMs,
    required this.outboundMode,
    required this.activeNavIndex,
    this.monetSeedIndex = 0,
    this.themeMode = ThemeMode.dark,
    this.coreVersion,
    this.systemProxyEnabled = false,
    this.activeProfileName,
    this.coreLogs = const [],
  });

  DashboardState copyWith({
    bool? isRunning,
    bool? isCoreStarting,
    String? upSpeed,
    String? downSpeed,
    double? ramMb,
    String? outboundIp,
    String? countryFlag,
    int? latencyMs,
    OutboundMode? outboundMode,
    int? activeNavIndex,
    int? monetSeedIndex,
    ThemeMode? themeMode,
    String? coreVersion,
    bool? systemProxyEnabled,
    String? activeProfileName,
    List<String>? coreLogs,
  }) {
    return DashboardState(
      isRunning: isRunning ?? this.isRunning,
      isCoreStarting: isCoreStarting ?? this.isCoreStarting,
      upSpeed: upSpeed ?? this.upSpeed,
      downSpeed: downSpeed ?? this.downSpeed,
      ramMb: ramMb ?? this.ramMb,
      outboundIp: outboundIp ?? this.outboundIp,
      countryFlag: countryFlag ?? this.countryFlag,
      latencyMs: latencyMs ?? this.latencyMs,
      outboundMode: outboundMode ?? this.outboundMode,
      activeNavIndex: activeNavIndex ?? this.activeNavIndex,
      monetSeedIndex: monetSeedIndex ?? this.monetSeedIndex,
      themeMode: themeMode ?? this.themeMode,
      coreVersion: coreVersion ?? this.coreVersion,
      systemProxyEnabled: systemProxyEnabled ?? this.systemProxyEnabled,
      activeProfileName: activeProfileName ?? this.activeProfileName,
      coreLogs: coreLogs ?? this.coreLogs,
    );
  }

  factory DashboardState.initial() {
    return const DashboardState(
      isRunning: true,
      isCoreStarting: false,
      upSpeed: '0 B/s',
      downSpeed: '0 B/s',
      ramMb: 0.0,
      outboundIp: '检测中...',
      countryFlag: '🌐',
      latencyMs: 0,
      outboundMode: OutboundMode.rule,
      activeNavIndex: 0,
      monetSeedIndex: 0,
      themeMode: ThemeMode.dark,
      coreVersion: 'v1.18.8 (Mihomo)',
      systemProxyEnabled: false,
      activeProfileName: 'Default Profile',
      coreLogs: [],
    );
  }
}
