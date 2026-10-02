import 'package:flutter/material.dart';
import '../../core/theme/lumin_motion.dart';

enum HapticType { none, light, medium, heavy, selection }

/// 触觉弹性按压容器：按下平滑缩小、释放弹簧超调回弹并触发物理微震动
class BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressScale;
  final HapticType hapticType;
  final BorderRadius? borderRadius;
  final bool enabled;

  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressScale = 0.96,
    this.hapticType = HapticType.light,
    this.borderRadius,
    this.enabled = true,
  });

  @override
  State<BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<BouncyTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  Offset? _startPointerPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: LuminMotion.snappy,
      reverseDuration: LuminMotion.standard,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: LuminMotion.springOvershoot,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant BouncyTap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pressScale != widget.pressScale) {
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: widget.pressScale,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
          reverseCurve: LuminMotion.springOvershoot,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    switch (widget.hapticType) {
      case HapticType.light:
        LuminHaptics.light();
        break;
      case HapticType.medium:
        LuminHaptics.medium();
        break;
      case HapticType.heavy:
        LuminHaptics.heavy();
        break;
      case HapticType.selection:
        LuminHaptics.selection();
        break;
      case HapticType.none:
        break;
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled || (widget.onTap == null && widget.onLongPress == null)) {
      return;
    }
    _startPointerPosition = event.position;
    _controller.forward();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_startPointerPosition != null) {
      final delta = (event.position - _startPointerPosition!).distance;
      if (delta > 14.0) {
        _startPointerPosition = null;
        _controller.reverse();
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _startPointerPosition = null;
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _startPointerPosition = null;
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _handleTap() {
    if (!widget.enabled || widget.onTap == null) return;
    _triggerHaptic();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidget = ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );

    if (!widget.enabled || (widget.onTap == null && widget.onLongPress == null)) {
      return effectiveWidget;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          onLongPress: widget.onLongPress != null
              ? () {
                  _triggerHaptic();
                  widget.onLongPress!();
                }
              : null,
          child: effectiveWidget,
        ),
      ),
    );
  }
}
