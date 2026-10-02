import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/connection_model.dart';
import '../services/clash_api_client.dart';

class RulesState {
  final bool isLoading;
  final List<RuleItem> rules;
  final List<ConnectionItem> connections;
  final int totalUpload;
  final int totalDownload;
  final String? error;

  const RulesState({
    this.isLoading = false,
    this.rules = const [],
    this.connections = const [],
    this.totalUpload = 0,
    this.totalDownload = 0,
    this.error,
  });

  RulesState copyWith({
    bool? isLoading,
    List<RuleItem>? rules,
    List<ConnectionItem>? connections,
    int? totalUpload,
    int? totalDownload,
    String? error,
  }) {
    return RulesState(
      isLoading: isLoading ?? this.isLoading,
      rules: rules ?? this.rules,
      connections: connections ?? this.connections,
      totalUpload: totalUpload ?? this.totalUpload,
      totalDownload: totalDownload ?? this.totalDownload,
      error: error,
    );
  }
}

class RulesNotifier extends Notifier<RulesState> {
  late final ClashApiClient _apiClient;
  Timer? _pollingTimer;

  @override
  RulesState build() {
    _apiClient = ClashApiClient();
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });
    Future.microtask(() {
      loadRules();
      loadConnections();
      _startPolling();
    });
    return const RulesState(isLoading: true);
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      loadConnections();
    });
  }

  Future<void> loadRules() async {
    try {
      final list = await _apiClient.getRules();
      state = state.copyWith(rules: list, isLoading: false);
    } catch (e) {
      debugPrint('[RulesNotifier] loadRules error: $e');
    }
  }

  Future<void> loadConnections() async {
    try {
      final list = await _apiClient.getConnections();
      int upSum = 0;
      int downSum = 0;
      for (final c in list) {
        upSum += c.upload;
        downSum += c.download;
      }
      state = state.copyWith(
        connections: list,
        totalUpload: upSum,
        totalDownload: downSum,
      );
    } catch (_) {}
  }

  Future<void> closeConnection(String id) async {
    await _apiClient.closeConnection(id);
    await loadConnections();
  }

  Future<void> closeAllConnections() async {
    await _apiClient.closeAllConnections();
    await loadConnections();
  }
}

final rulesProvider =
    NotifierProvider<RulesNotifier, RulesState>(RulesNotifier.new);
