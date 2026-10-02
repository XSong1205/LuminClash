import 'package:flutter/material.dart';
import '../../core/models/proxy_models.dart';
import '../../core/theme/lumin_motion.dart';
import 'bouncy_tap.dart';

class ProxyNodeCard extends StatelessWidget {
  final ProxyNode node;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onPing;

  const ProxyNodeCard({
    super.key,
    required this.node,
    required this.isSelected,
    required this.onSelect,
    required this.onPing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color delayColor;
    if (node.delay <= 0) {
      delayColor = colorScheme.outline;
    } else if (node.delay < 300) {
      delayColor = colorScheme.primary;
    } else if (node.delay < 800) {
      delayColor = colorScheme.secondary;
    } else {
      delayColor = colorScheme.error;
    }

    return BouncyTap(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: LuminMotion.snappy,
        curve: LuminMotion.fluid,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // 节点选中状态指示圆点
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 节点名称与类型
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    node.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    node.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // 延迟微胶囊与单个测速按钮
            InkWell(
              onTap: onPing,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: delayColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      node.delay > 0 ? '${node.delay} ms' : '---',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: delayColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: delayColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
