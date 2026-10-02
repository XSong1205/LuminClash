import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';
import '../models/profile_model.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  Future<Directory> getProfilesDirectory() async {
    Directory baseDir;
    try {
      baseDir = await getApplicationSupportDirectory();
    } catch (_) {
      baseDir = Directory(p.join(
        Platform.environment['APPDATA'] ?? Directory.current.path,
        'LuminClash',
      ));
    }
    final dir = Directory(p.join(baseDir.path, 'profiles'));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  File _getProfilesIndexFile(Directory dir) {
    return File(p.join(dir.path, 'profiles.json'));
  }

  /// 加载所有保存的订阅档案
  Future<List<ProfileItem>> loadProfiles() async {
    try {
      final dir = await getProfilesDirectory();
      final indexFile = _getProfilesIndexFile(dir);
      if (!indexFile.existsSync()) {
        return [];
      }
      final content = await indexFile.readAsString();
      final list = jsonDecode(content) as List<dynamic>;
      return list
          .map((e) => ProfileItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ProfileService] loadProfiles error: $e');
      return [];
    }
  }

  /// 保存订阅档案索引
  Future<void> saveProfiles(List<ProfileItem> profiles) async {
    try {
      final dir = await getProfilesDirectory();
      final indexFile = _getProfilesIndexFile(dir);
      final jsonList = profiles.map((p) => p.toJson()).toList();
      await indexFile.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[ProfileService] saveProfiles error: $e');
    }
  }

  /// 从远程 URL 拉取订阅并保存
  Future<ProfileItem?> fetchAndAddProfile({
    required String name,
    required String url,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('User-Agent', 'ClashMeta/1.18.8');
      final response = await request.close();

      if (response.statusCode != 200) {
        debugPrint('[ProfileService] fetch failed with code: ${response.statusCode}');
        return null;
      }

      // 解析流量与到期信息 (Subscription-Userinfo header)
      final userinfo = response.headers.value('subscription-userinfo');
      int? uploadBytes;
      int? downloadBytes;
      int? totalBytes;
      DateTime? expireDate;

      if (userinfo != null) {
        for (final item in userinfo.split(';')) {
          final kv = item.trim().split('=');
          if (kv.length == 2) {
            final key = kv[0].trim();
            final val = int.tryParse(kv[1].trim());
            if (val != null) {
              if (key == 'upload') uploadBytes = val;
              if (key == 'download') downloadBytes = val;
              if (key == 'total') totalBytes = val;
              if (key == 'expire') {
                expireDate = DateTime.fromMillisecondsSinceEpoch(val * 1000);
              }
            }
          }
        }
      }

      final content = await response.transform(utf8.decoder).join();
      final nodeCount = _countNodesInYaml(content);

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final dir = await getProfilesDirectory();
      final filePath = p.join(dir.path, '$id.yaml');
      final file = File(filePath);
      await file.writeAsString(content);

      final currentProfiles = await loadProfiles();
      final isFirst = currentProfiles.isEmpty;

      final newItem = ProfileItem(
        id: id,
        name: name,
        url: url,
        filePath: filePath,
        lastUpdated: DateTime.now(),
        nodeCount: nodeCount,
        isActive: isFirst,
        uploadBytes: uploadBytes,
        downloadBytes: downloadBytes,
        totalBytes: totalBytes,
        expireDate: expireDate,
      );

      final updatedList = [...currentProfiles, newItem];
      await saveProfiles(updatedList);
      return newItem;
    } catch (e) {
      debugPrint('[ProfileService] fetchAndAddProfile exception: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// 刷新指定订阅
  Future<ProfileItem?> updateProfile(ProfileItem profile) async {
    if (profile.url == null || profile.url!.isEmpty) return null;
    return fetchAndAddProfile(name: profile.name, url: profile.url!);
  }

  /// 删除订阅
  Future<void> deleteProfile(String id) async {
    final profiles = await loadProfiles();
    final target = profiles.where((p) => p.id == id).firstOrNull;
    if (target != null) {
      try {
        final f = File(target.filePath);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
    }
    final remaining = profiles.where((p) => p.id != id).toList();
    await saveProfiles(remaining);
  }

  /// 统计 YAML 中的节点数量
  int _countNodesInYaml(String yamlContent) {
    try {
      final doc = loadYaml(yamlContent);
      if (doc is Map && doc['proxies'] is List) {
        return (doc['proxies'] as List).length;
      }
    } catch (_) {}
    return 0;
  }
}
