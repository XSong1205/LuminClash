import 'package:flutter/material.dart';
import '../../core/models/proxy_models.dart';
import '../../core/theme/lumin_motion.dart';
import 'bouncy_tap.dart';
import 'proxy_node_card.dart';

class ProxyGroupCard extends StatefulWidget {
  final ProxyGroup group;
  final Map<String, ProxyNode> nodes;
  final bool isTesting;
  final Function(String proxyName) onSelectNode;
  final VoidCallback onBatchTest;
  final Function(String proxyName) onSingleTest;

  const ProxyGroupCard({
    super.key,
    required this.group,
    required this.nodes,
    required this.isTesting,
    required this.onSelectNode,
    required this.onBatchTest,
    required this.onSingleTest,
  });

  @override
  State<ProxyGroupCard> createState() => _ProxyGroupCardState();
}

class _ProxyGroupCardState extends State<ProxyGroupCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 策略组顶栏
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // 策略组图标与信息
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getGroupIcon(widget.group.type),
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.group.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.group.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '当前: ${widget.group.now.isNotEmpty ? widget.group.now : "未选择"} (${widget.group.all.length}个节点)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 批量测速按钮
                  BouncyTap(
                    onTap: widget.isTesting ? () {} : widget.onBatchTest,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: widget.isTesting
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.speed_rounded,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '测速',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // 折叠展开图标
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // 展开的节点列表
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: widget.group.all.map((proxyName) {
                  final node = widget.nodes[proxyName] ??
                      ProxyNode(
                        name: proxyName,
                        type: 'Proxy',
                        delay: 0,
                      );
                  final isSelected = widget.group.now == proxyName;

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ProxyNodeCard(
                      node: node,
                      isSelected: isSelected,
                      onSelect: () => widget.onSelectNode(proxyName),
                      onPing: () => widget.onSingleTest(proxyName),
                    ),
                  );
                }).toList(),
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: LuminMotion.snappy,
          ),
        ],
      ),
    );
  }

  IconData _getGroupIcon(String type) {
    switch (type.toLowerCase()) {
      case 'urltest':
        return Icons.auto_mode_rounded;
      case 'fallback':
        return Icons.safety_check_rounded;
      case 'loadbalance':
        return Icons.balance_rounded;
      case 'selector':
      default:
        return Icons.alt_route_rounded;
    }
  }
}
