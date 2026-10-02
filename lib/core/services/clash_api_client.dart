import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/connection_model.dart';

class TrafficData {
  final int up; // bytes per second
  final int down; // bytes per second

  const TrafficData({required this.up, required this.down});

  String get formattedUp => _formatSpeed(up);
  String get formattedDown => _formatSpeed(down);

  static String _formatSpeed(int bytes) {
    if (bytes <= 0) return '0 B/s';
    if (bytes < 1024) return '$bytes B/s';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB/s';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB/s';
  }
}

class MemoryData {
  final int inuse; // bytes

  const MemoryData({required this.inuse});

  double get inuseMb => inuse / (1024 * 1024);
}

class ClashApiClient {
  final String host;
  final int port;
  final String secret;
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 3);

  ClashApiClient({
    this.host = '127.0.0.1',
    this.port = 9090,
    this.secret = '',
  });

  String get _baseUrl => 'http://$host:$port';
  String get _wsUrl => 'ws://$host:$port';

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (secret.isNotEmpty) {
      headers['Authorization'] = 'Bearer $secret';
    }
    return headers;
  }

  /// 获取内核版本
  Future<String?> getVersion() async {
    try {
      final req = await _client.getUrl(Uri.parse('$_baseUrl/version'));
      _headers.forEach(req.headers.set);
      final resp = await req.close();
      if (resp.statusCode == 200) {
        final body = await resp.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final version = json['version'] as String? ?? 'Mihomo Core';
        return version;
      }
    } catch (_) {}
    return null;
  }

  /// 获取内核配置
  Future<Map<String, dynamic>?> getConfigs() async {
    try {
      final req = await _client.getUrl(Uri.parse('$_baseUrl/configs'));
      _headers.forEach(req.headers.set);
      final resp = await req.close();
      if (resp.statusCode == 200) {
        final body = await resp.transform(utf8.decoder).join();
        return jsonDecode(body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 修改内核配置 (例如出站模式)
  Future<bool> patchConfigs(Map<String, dynamic> data) async {
    try {
      final req = await _client.patchUrl(Uri.parse('$_baseUrl/configs'));
      _headers.forEach(req.headers.set);
      req.add(utf8.encode(jsonEncode(data)));
      final resp = await req.close();
      return resp.statusCode == 204 || resp.statusCode == 200;
    } catch (e) {
      debugPrint('[ClashApiClient] patchConfigs error: $e');
      return false;
    }
  }

  /// 获取所有代理节点与策略组
  Future<Map<String, dynamic>?> getProxies() async {
    try {
      final req = await _client.getUrl(Uri.parse('$_baseUrl/proxies'));
      _headers.forEach(req.headers.set);
      final resp = await req.close();
      if (resp.statusCode == 200) {
        final body = await resp.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        return json['proxies'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('[ClashApiClient] getProxies error: $e');
    }
    return null;
  }

  /// 切换策略组选中的节点
  Future<bool> selectProxy(String groupName, String proxyName) async {
    try {
      final encodedGroup = Uri.encodeComponent(groupName);
      final req = await _client.putUrl(Uri.parse('$_baseUrl/proxies/$encodedGroup'));
      _headers.forEach(req.headers.set);
      req.add(utf8.encode(jsonEncode({'name': proxyName})));
      final resp = await req.close();
      return resp.statusCode == 204 || resp.statusCode == 200;
    } catch (e) {
      debugPrint('[ClashApiClient] selectProxy error: $e');
      return false;
    }
  }

  /// 测试单个节点延迟 (ms)
  Future<int?> testDelay(
    String proxyName, {
    String url = 'http://www.gstatic.com/generate_204',
    int timeout = 5000,
  }) async {
    try {
      final encodedProxy = Uri.encodeComponent(proxyName);
      final uri = Uri.parse('$_baseUrl/proxies/$encodedProxy/delay').replace(
        queryParameters: {
          'url': url,
          'timeout': timeout.toString(),
        },
      );
      final req = await _client.getUrl(uri);
      _headers.forEach(req.headers.set);
      final resp = await req.close();
      if (resp.statusCode == 200) {
        final body = await resp.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        return (json['delay'] as num?)?.toInt();
      }
    } catch (_) {}
    return null;
  }

  /// 获取分流规则列表
  Future<List<RuleItem>> getRules() async {
    try {
      final req = await _client.getUrl(Uri.parse('$_baseUrl/rules'));
      _headers.forEach(req.headers.set);
      final resp = await req.close();
      if (resp.statusCode == 200) {
        final body = await resp.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final rulesList = json['rules'] as List<dynamic>? ?? [];
        return rulesList
            .map((e) => RuleItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// 获取活动连接列表
  Future<List<ConnectionItem>> getConnections() async {
    try {
      final req = await _client.getUrl(Uri.parse('$_baseUrl/connections'));
      _headers.forEach(req.headers.set);
      final resp = await req.close();
      if (resp.statusCode == 200) {
        final body = await resp.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final connsList = json['connections'] as List<dynamic>? ?? [];
        return connsList
            .map((e) => ConnectionItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// 关闭指定连接
  Future<bool> closeConnection(String id) async {
    try {
      final req = await _client.deleteUrl(Uri.parse('$_baseUrl/connections/$id'));
      _headers.forEach(req.headers.set);
      final resp = await req.close();
      return resp.statusCode == 204 || resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 关闭全部活动连接
  Future<bool> closeAllConnections() async {
    try {
      final req = await _client.deleteUrl(Uri.parse('$_baseUrl/connections'));
      _headers.forEach(req.headers.set);
      final resp = await req.close();
      return resp.statusCode == 204 || resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 连接实时网速 WebSocket
  Stream<TrafficData> connectTrafficStream() async* {
    while (true) {
      WebSocket? ws;
      try {
        final uri = Uri.parse('$_wsUrl/traffic');
        ws = await WebSocket.connect(
          uri.toString(),
          headers: secret.isNotEmpty ? {'Authorization': 'Bearer $secret'} : null,
        );
        await for (final message in ws) {
          final json = jsonDecode(message.toString()) as Map<String, dynamic>;
          final up = (json['up'] as num?)?.toInt() ?? 0;
          final down = (json['down'] as num?)?.toInt() ?? 0;
          yield TrafficData(up: up, down: down);
        }
      } catch (_) {
        // 重试避让
        await Future.delayed(const Duration(seconds: 2));
      } finally {
        try {
          ws?.close();
        } catch (_) {}
      }
    }
  }

  /// 连接实时内存占用 WebSocket
  Stream<MemoryData> connectMemoryStream() async* {
    while (true) {
      WebSocket? ws;
      try {
        final uri = Uri.parse('$_wsUrl/memory');
        ws = await WebSocket.connect(
          uri.toString(),
          headers: secret.isNotEmpty ? {'Authorization': 'Bearer $secret'} : null,
        );
        await for (final message in ws) {
          final json = jsonDecode(message.toString()) as Map<String, dynamic>;
          final inuse = (json['inuse'] as num?)?.toInt() ?? 0;
          yield MemoryData(inuse: inuse);
        }
      } catch (_) {
        await Future.delayed(const Duration(seconds: 3));
      } finally {
        try {
          ws?.close();
        } catch (_) {}
      }
    }
  }
}
