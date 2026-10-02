import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../services/core_process_service.dart';
import '../services/profile_service.dart';

class ProfilesState {
  final bool isLoading;
  final List<ProfileItem> profiles;
  final ProfileItem? activeProfile;
  final String? error;

  const ProfilesState({
    this.isLoading = false,
    this.profiles = const [],
    this.activeProfile,
    this.error,
  });

  ProfilesState copyWith({
    bool? isLoading,
    List<ProfileItem>? profiles,
    ProfileItem? activeProfile,
    String? error,
  }) {
    return ProfilesState(
      isLoading: isLoading ?? this.isLoading,
      profiles: profiles ?? this.profiles,
      activeProfile: activeProfile ?? this.activeProfile,
      error: error,
    );
  }
}

class ProfilesNotifier extends Notifier<ProfilesState> {
  late final ProfileService _profileService;
  late final CoreProcessService _coreProcessService;

  @override
  ProfilesState build() {
    _profileService = ProfileService();
    _coreProcessService = CoreProcessService();
    Future.microtask(() => loadProfiles());
    return const ProfilesState(isLoading: true);
  }

  /// 加载全部订阅
  Future<void> loadProfiles() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _profileService.loadProfiles();
      final active = list.where((p) => p.isActive).firstOrNull ?? list.firstOrNull;
      state = state.copyWith(
        isLoading: false,
        profiles: list,
        activeProfile: active,
      );
    } catch (e) {
      debugPrint('[ProfilesNotifier] loadProfiles error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 添加新订阅
  Future<bool> addProfile({required String name, required String url}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final item = await _profileService.fetchAndAddProfile(name: name, url: url);
      if (item == null) {
        state = state.copyWith(isLoading: false, error: '拉取订阅失败，请检查链接或网络');
        return false;
      }
      await loadProfiles();
      if (item.isActive) {
        await selectProfile(item.id);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// 更新订阅
  Future<bool> updateProfile(String id) async {
    final target = state.profiles.where((p) => p.id == id).firstOrNull;
    if (target == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _profileService.updateProfile(target);
      if (updated != null) {
        await loadProfiles();
        if (updated.isActive) {
          await selectProfile(updated.id);
        }
        return true;
      }
      state = state.copyWith(isLoading: false, error: '更新订阅失败');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// 删除订阅
  Future<void> deleteProfile(String id) async {
    await _profileService.deleteProfile(id);
    await loadProfiles();
  }

  /// 激活订阅
  Future<void> selectProfile(String id) async {
    final target = state.profiles.where((p) => p.id == id).firstOrNull;
    if (target == null) return;

    try {
      // 1. 读取该订阅的 YAML 内容
      final yamlFile = File(target.filePath);
      if (yamlFile.existsSync()) {
        final content = await yamlFile.readAsString();
        // 写入内核 config.yaml
        await _coreProcessService.ensureConfigFile(activeConfigContent: content);
        // 若内核在运行，重启内核以加载新配置
        if (_coreProcessService.isRunning) {
          await _coreProcessService.restartCore();
        }
      }

      // 2. 更新状态中 isActive 标记
      final updatedList = state.profiles.map((p) {
        return p.copyWith(isActive: p.id == id);
      }).toList();
      await _profileService.saveProfiles(updatedList);

      state = state.copyWith(
        profiles: updatedList,
        activeProfile: target.copyWith(isActive: true),
      );
    } catch (e) {
      debugPrint('[ProfilesNotifier] selectProfile error: $e');
    }
  }
}

final profilesProvider =
    NotifierProvider<ProfilesNotifier, ProfilesState>(ProfilesNotifier.new);
