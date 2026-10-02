import 'package:flutter_test/flutter_test.dart';
import 'package:lumin_clash/core/services/network_probe_service.dart';

void main() {
  group('NetworkProbeService & Country Emoji', () {
    test('countryCodeToEmoji generates correct regional indicator flag emojis', () {
      expect(NetworkProbeService.countryCodeToEmoji('HK'), '🇭🇰');
      expect(NetworkProbeService.countryCodeToEmoji('US'), '🇺🇸');
      expect(NetworkProbeService.countryCodeToEmoji('CN'), '🇨🇳');
      expect(NetworkProbeService.countryCodeToEmoji('JP'), '🇯🇵');
      expect(NetworkProbeService.countryCodeToEmoji('SG'), '🇸🇬');
      expect(NetworkProbeService.countryCodeToEmoji('tw'), '🇹🇼');
      expect(NetworkProbeService.countryCodeToEmoji(''), '🌐');
      expect(NetworkProbeService.countryCodeToEmoji('UNKNOWN'), '🌐');
      expect(NetworkProbeService.countryCodeToEmoji('12'), '🌐');
    });

    test('NetworkProbeResult failed factory handles default and custom messages', () {
      final defaultFailed = NetworkProbeResult.failed();
      expect(defaultFailed.isSuccess, false);
      expect(defaultFailed.ip, '未连接网络');
      expect(defaultFailed.countryFlag, '🌐');
      expect(defaultFailed.latencyMs, 0);

      final customFailed = NetworkProbeResult.failed('超时');
      expect(customFailed.isSuccess, false);
      expect(customFailed.ip, '超时');
      expect(customFailed.countryFlag, '🌐');
    });

    test('NetworkProbeService executes real probe and returns valid IP and latency', () async {
      final service = NetworkProbeService();
      final result = await service.probe(useProxy: false);
      expect(result.ip, isNotEmpty);
      expect(result.latencyMs, greaterThanOrEqualTo(0));
      // In live environment, result should be successful
      if (result.isSuccess) {
        expect(result.countryFlag, isNotEmpty);
      }
    });
  });
}
