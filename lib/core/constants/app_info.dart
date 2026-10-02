/// LuminClash 全局版本与应用元数据
class AppInfo {
  static const String appName = 'LuminClash';
  static const String version = '0.1.0-beta';
  static const int buildNumber = 1;
  static const String fullVersion = '$version+$buildNumber';
  static const String releaseStage = 'Beta';
  static const String coreEngine = 'Mihomo (with_gvisor)';

  // 跨平台最低与推荐运行限制
  static const String androidMinSdk = 'Android 7.0 (API 24)';
  static const String androidTargetSdk = 'Android 15 (API 35)';
  static const String windowsMinVersion = 'Windows 10 1809+ (x64)';
}
