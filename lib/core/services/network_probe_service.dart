import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// 网络检测与 IP 查询结果实体
class NetworkProbeResult {
  final String ip;
  final String countryCode;
  final String countryFlag;
  final int latencyMs;
  final bool isSuccess;
  final String? errorMessage;

  const NetworkProbeResult({
    required this.ip,
    required this.countryCode,
    required this.countryFlag,
    required this.latencyMs,
    required this.isSuccess,
    this.errorMessage,
  });

  factory NetworkProbeResult.failed([String message = '未连接网络']) {
    return NetworkProbeResult(
      ip: message,
      countryCode: '',
      countryFlag: '🌐',
      latencyMs: 0,
      isSuccess: false,
      errorMessage: message,
    );
  }
}

/// 真实网络探测与高可用出口 IP 查询服务 (多源冗余兜底)
class NetworkProbeService {
  static final NetworkProbeService _instance = NetworkProbeService._internal();
  factory NetworkProbeService() => _instance;
  NetworkProbeService._internal();

  /// 将 2 字母 ISO 国家/地区代码转换为标准 Emoji 国旗字符
  static String countryCodeToEmoji(String countryCode) {
    final code = countryCode.trim().toUpperCase();
    if (code.length != 2) return '🌐';
    final firstChar = code.codeUnitAt(0);
    final secondChar = code.codeUnitAt(1);
    if (firstChar < 0x41 || firstChar > 0x5A || secondChar < 0x41 || secondChar > 0x5A) {
      return '🌐';
    }
    final first = firstChar - 0x41 + 0x1F1E6;
    final second = secondChar - 0x41 + 0x1F1E6;
    return String.fromCharCode(first) + String.fromCharCode(second);
  }

  /// 执行高可用网络出口探测
  /// [useProxy] 是否尝试通过本地内核代理端口进行探测
  /// [proxyPort] 本地代理端口，默认为 7890
  Future<NetworkProbeResult> probe({
    bool useProxy = false,
    int proxyPort = 7890,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    // 候选 API 列表，按可用性与速度优先级轮询
    final candidates = [
      _ProbeTarget(
        name: 'IP.SB',
        uri: Uri.parse('https://api.ip.sb/geoip'),
        parser: _parseIpSb,
      ),
      _ProbeTarget(
        name: 'ipwho.is',
        uri: Uri.parse('https://ipwho.is/'),
        parser: _parseIpWhoIs,
      ),
      _ProbeTarget(
        name: 'Cloudflare Trace (1.1.1.1)',
        uri: Uri.parse('https://1.1.1.1/cdn-cgi/trace'),
        parser: _parseCloudflareTrace,
      ),
      _ProbeTarget(
        name: 'Cloudflare Trace (cdn-cgi)',
        uri: Uri.parse('https://cloudflare.com/cdn-cgi/trace'),
        parser: _parseCloudflareTrace,
      ),
      _ProbeTarget(
        name: 'ipify',
        uri: Uri.parse('https://api.ipify.org?format=json'),
        parser: _parseIpify,
      ),
    ];

    for (final target in candidates) {
      try {
        final result = await _executeProbeTarget(
          target,
          useProxy: useProxy,
          proxyPort: proxyPort,
          timeout: timeout,
        );
        if (result != null && result.isSuccess) {
          return result;
        }
      } catch (e) {
        debugPrint('[NetworkProbeService] ${target.name} probe error: $e');
      }
    }

    return NetworkProbeResult.failed('网络不可达或超时');
  }

  Future<NetworkProbeResult?> _executeProbeTarget(
    _ProbeTarget target, {
    required bool useProxy,
    required int proxyPort,
    required Duration timeout,
  }) async {
    final client = HttpClient()..connectionTimeout = timeout;
    if (useProxy) {
      client.findProxy = (uri) => 'PROXY 127.0.0.1:$proxyPort; DIRECT';
    } else {
      client.findProxy = (uri) => 'DIRECT';
    }

    final stopwatch = Stopwatch()..start();
    try {
      final req = await client.getUrl(target.uri).timeout(timeout);
      req.headers.set('User-Agent', 'LuminClash/0.1.0 (Flutter; Multiplatform)');
      final resp = await req.close().timeout(timeout);
      if (resp.statusCode == 200) {
        final body = await resp.transform(utf8.decoder).join().timeout(timeout);
        stopwatch.stop();
        final latency = stopwatch.elapsedMilliseconds;
        final parsed = target.parser(body, latency);
        if (parsed != null) {
          return parsed;
        }
      }
    } catch (_) {
      // 忽略单个节点异常，交由下一个候选接口处理
    } finally {
      client.close(force: true);
    }
    return null;
  }

  static NetworkProbeResult? _parseIpSb(String body, int latency) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final ip = json['ip'] as String?;
      if (ip == null || ip.isEmpty) return null;
      final countryCode = (json['country_code'] as String? ?? '').toUpperCase();
      return NetworkProbeResult(
        ip: ip,
        countryCode: countryCode,
        countryFlag: countryCode.isNotEmpty ? countryCodeToEmoji(countryCode) : '🌐',
        latencyMs: latency,
        isSuccess: true,
      );
    } catch (_) {
      return null;
    }
  }

  static NetworkProbeResult? _parseIpWhoIs(String body, int latency) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final success = json['success'] as bool? ?? false;
      final ip = json['ip'] as String?;
      if (!success || ip == null || ip.isEmpty) return null;
      final countryCode = (json['country_code'] as String? ?? '').toUpperCase();
      final flagData = json['flag'];
      String? emoji;
      if (flagData is Map<String, dynamic>) {
        emoji = flagData['emoji'] as String?;
      }
      return NetworkProbeResult(
        ip: ip,
        countryCode: countryCode,
        countryFlag: emoji != null && emoji.isNotEmpty
            ? emoji
            : (countryCode.isNotEmpty ? countryCodeToEmoji(countryCode) : '🌐'),
        latencyMs: latency,
        isSuccess: true,
      );
    } catch (_) {
      return null;
    }
  }

  static NetworkProbeResult? _parseCloudflareTrace(String body, int latency) {
    try {
      String? ip;
      String? loc;
      for (final line in body.split(RegExp(r'[\r\n]+'))) {
        final trimmed = line.trim();
        if (trimmed.startsWith('ip=')) {
          ip = trimmed.substring(3).trim();
        } else if (trimmed.startsWith('loc=')) {
          loc = trimmed.substring(4).trim().toUpperCase();
        }
      }
      if (ip == null || ip.isEmpty) return null;
      final countryCode = loc ?? '';
      return NetworkProbeResult(
        ip: ip,
        countryCode: countryCode,
        countryFlag: countryCode.isNotEmpty ? countryCodeToEmoji(countryCode) : '🌐',
        latencyMs: latency,
        isSuccess: true,
      );
    } catch (_) {
      return null;
    }
  }

  static NetworkProbeResult? _parseIpify(String body, int latency) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final ip = json['ip'] as String?;
      if (ip == null || ip.isEmpty) return null;
      return NetworkProbeResult(
        ip: ip,
        countryCode: '',
        countryFlag: '🌐',
        latencyMs: latency,
        isSuccess: true,
      );
    } catch (_) {
      return null;
    }
  }
}

typedef _ProbeParser = NetworkProbeResult? Function(String body, int latency);

class _ProbeTarget {
  final String name;
  final Uri uri;
  final _ProbeParser parser;

  const _ProbeTarget({
    required this.name,
    required this.uri,
    required this.parser,
  });
}
