import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// LuminClash 非线性物理动效与动效节奏规范
class LuminMotion {
  // 动效时长常量
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration snappy = Duration(milliseconds: 220);
  static const Duration standard = Duration(milliseconds: 320);
  static const Duration expressive = Duration(milliseconds: 460);
  static const Duration breathe = Duration(milliseconds: 2800);

  // 非线性物理动效曲线
  /// 带轻微超调的弹簧曲线，用于按压回弹、Tab胶囊滑入、FAB 切换
  static const Curve springOvershoot = Curves.easeOutBack;

  /// 类似 iOS 顶级流体平滑减速曲线，用于卡片平移与大画卷切页
  static const Curve fluid = Cubic(0.2, 0.9, 0.2, 1.0);

  /// 敏捷利落的退出与微缩放曲线
  static const Curve snappyCurve = Curves.easeOutCubic;

  /// 极光呼吸与光晕周期的正弦缓动
  static const Curve breatheCurve = Curves.easeInOutSine;
}

/// LuminClash 全平台安全触感反馈工具箱
class LuminHaptics {
  static bool get _supportsHaptics {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// 轻微触感：用于通用卡片点击、微交互
  static Future<void> light() async {
    if (!_supportsHaptics) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// 中等触感：用于核心启停、分段选择
  static Future<void> medium() async {
    if (!_supportsHaptics) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// 强力触感：用于紧急停止、重置或危险操作
  static Future<void> heavy() async {
    if (!_supportsHaptics) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// 刻度吸附感：用于 Tab 切换、出站模式滑块吸附、色板点选
  static Future<void> selection() async {
    if (!_supportsHaptics) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
