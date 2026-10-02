import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/proxy_models.dart';
import '../services/clash_api_client.dart';

class ProxiesState {
  final bool isLoading;
  final List<ProxyGroup> groups;
  final Map<String, ProxyNode> nodes;
  final String? testingGroup;
  final String? error;

  const ProxiesState({
    this.isLoading = false,
    this.groups = const [],
    this.nodes = const {},
    this.testingGroup,
    this.error,
  });

  ProxiesState copyWith({
    bool? isLoading,
    List<ProxyGroup>? groups,
    Map<String, ProxyNode>? nodes,
    String? testingGroup,
    String? error,
  }) {
    return ProxiesState(
      isLoading: isLoading ?? this.isLoading,
      groups: groups ?? this.groups,
      nodes: nodes ?? this.nodes,
      testingGroup: testingGroup,
      error: error,
    );
  }
}

class ProxiesNotifier extends Notifier<ProxiesState> {
  late final ClashApiClient _apiClient;

  @override
  ProxiesState build() {
    _apiClient = ClashApiClient();
    // 初始异步加载
    Future.microtask(() => loadProxies());
    return const ProxiesState(isLoading: true);
  }

  /// 加载全部策略组与节点
  Future<void> loadProxies() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rawData = await _apiClient.getProxies();
      if (rawData == null) {
        state = state.copyWith(
          isLoading: false,
          error: '无法连接到内核代理接口',
        );
        return;
      }

      final Map<String, ProxyNode> nodeMap = {};
      final List<ProxyGroup> groupList = [];

      rawData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final type = value['type'] as String? ?? '';
          final isGroup = ['Selector', 'URLTest', 'Fallback', 'LoadBalance']
              .contains(type);

          if (isGroup) {
            groupList.add(ProxyGroup.fromJson(key, value));
          } else {
            nodeMap[key] = ProxyNode.fromJson(key, value);
          }
        }
      });

      // 排序策略组 (GLOBAL, PROXY 靠前)
      groupList.sort((a, b) {
        if (a.name == 'GLOBAL') return -1;
        if (b.name == 'GLOBAL') return 1;
        if (a.name == 'PROXY') return -1;
        if (b.name == 'PROXY') return 1;
        return a.name.compareTo(b.name);
      });

      state = state.copyWith(
        isLoading: false,
        groups: groupList,
        nodes: nodeMap,
      );
    } catch (e) {
      debugPrint('[ProxiesNotifier] loadProxies error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 切换策略组选中的节点
  Future<void> selectNode(String groupName, String proxyName) async {
    final success = await _apiClient.selectProxy(groupName, proxyName);
    if (success) {
      final updatedGroups = state.groups.map((g) {
        if (g.name == groupName) {
          return g.copyWith(now: proxyName);
        }
        return g;
      }).toList();
      state = state.copyWith(groups: updatedGroups);
    }
  }

  /// 测试单个节点延迟
  Future<void> testNodeDelay(String proxyName) async {
    final delay = await _apiClient.testDelay(proxyName);
    if (delay != null && state.nodes.containsKey(proxyName)) {
      final currentNode = state.nodes[proxyName]!;
      final updatedNode = currentNode.copyWith(delay: delay);
      final newMap = Map<String, ProxyNode>.from(state.nodes);
      newMap[proxyName] = updatedNode;
      state = state.copyWith(nodes: newMap);
    }
  }

  /// 并发测试策略组内所有节点延迟
  Future<void> testGroupDelay(String groupName) async {
    final group = state.groups.where((g) => g.name == groupName).firstOrNull;
    if (group == null) return;

    state = state.copyWith(testingGroup: groupName);
    final futures = <Future<void>>[];

    for (final nodeName in group.all) {
      futures.add(() async {
        final delay = await _apiClient.testDelay(nodeName);
        if (delay != null && state.nodes.containsKey(nodeName)) {
          final currentNode = state.nodes[nodeName]!;
          final updatedNode = currentNode.copyWith(delay: delay);
          final newMap = Map<String, ProxyNode>.from(state.nodes);
          newMap[nodeName] = updatedNode;
          state = state.copyWith(nodes: newMap);
        }
      }());
    }

    await Future.wait(futures);
    state = state.copyWith(testingGroup: null);
  }
}

final proxiesProvider =
    NotifierProvider<ProxiesNotifier, ProxiesState>(ProxiesNotifier.new);
