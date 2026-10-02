import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

class SystemProxyService {
  static const int internetOptionSettingsChanged = 39;
  static const int internetOptionRefresh = 37;

  /// 启用 Windows 系统代理
  static Future<bool> enableSystemProxy({
    String host = '127.0.0.1',
    int port = 7890,
  }) async {
    if (!Platform.isWindows) return false;

    try {
      final proxyServer = '$host:$port';
      const proxyOverride = '<local>;localhost;127.*;10.*;172.16.*;192.168.*';

      // 1. 设置注册表 HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings
      _setInternetSettingsRegistry(
        enable: 1,
        proxyServer: proxyServer,
        proxyOverride: proxyOverride,
      );

      // 2. 刷新 WinINet 设置
      _refreshWinINet();
      debugPrint('[SystemProxyService] System proxy enabled: $proxyServer');
      return true;
    } catch (e) {
      debugPrint('[SystemProxyService] Failed to enable system proxy: $e');
      return false;
    }
  }

  /// 禁用 Windows 系统代理
  static Future<bool> disableSystemProxy() async {
    if (!Platform.isWindows) return false;

    try {
      _setInternetSettingsRegistry(enable: 0);
      _refreshWinINet();
      debugPrint('[SystemProxyService] System proxy disabled');
      return true;
    } catch (e) {
      debugPrint('[SystemProxyService] Failed to disable system proxy: $e');
      return false;
    }
  }

  /// 检查当前是否开启了系统代理
  static bool isSystemProxyEnabled() {
    if (!Platform.isWindows) return false;

    try {
      final phkResult = calloc<HKEY>();
      final subKey =
          TEXT(r'Software\Microsoft\Windows\CurrentVersion\Internet Settings');

      final status = RegOpenKeyEx(
        HKEY_CURRENT_USER,
        subKey,
        0,
        KEY_READ,
        phkResult,
      );
      free(subKey);

      if (status != ERROR_SUCCESS) {
        free(phkResult);
        return false;
      }

      final hKey = phkResult.value;
      free(phkResult);

      final lpData = calloc<DWORD>();
      final lpcbData = calloc<DWORD>()..value = sizeOf<DWORD>();
      final valueName = TEXT('ProxyEnable');

      final queryStatus = RegQueryValueEx(
        hKey,
        valueName,
        nullptr,
        nullptr,
        lpData.cast(),
        lpcbData,
      );

      free(valueName);
      final isEnabled = queryStatus == ERROR_SUCCESS && lpData.value == 1;

      free(lpData);
      free(lpcbData);
      RegCloseKey(hKey);

      return isEnabled;
    } catch (e) {
      debugPrint('[SystemProxyService] Check proxy enabled error: $e');
      return false;
    }
  }

  static void _setInternetSettingsRegistry({
    required int enable,
    String? proxyServer,
    String? proxyOverride,
  }) {
    final phkResult = calloc<HKEY>();
    final subKey =
        TEXT(r'Software\Microsoft\Windows\CurrentVersion\Internet Settings');

    final status = RegOpenKeyEx(
      HKEY_CURRENT_USER,
      subKey,
      0,
      KEY_SET_VALUE,
      phkResult,
    );
    free(subKey);

    if (status != ERROR_SUCCESS) {
      free(phkResult);
      return;
    }

    final hKey = phkResult.value;
    free(phkResult);

    // ProxyEnable DWORD
    final lpData = calloc<DWORD>()..value = enable;
    final enableName = TEXT('ProxyEnable');
    RegSetValueEx(
      hKey,
      enableName,
      0,
      REG_DWORD,
      lpData.cast(),
      sizeOf<DWORD>(),
    );
    free(lpData);
    free(enableName);

    // ProxyServer String
    if (proxyServer != null) {
      final serverName = TEXT('ProxyServer');
      final serverVal = TEXT(proxyServer);
      RegSetValueEx(
        hKey,
        serverName,
        0,
        REG_SZ,
        serverVal.cast(),
        (proxyServer.length + 1) * 2,
      );
      free(serverName);
      free(serverVal);
    }

    // ProxyOverride String
    if (proxyOverride != null) {
      final overrideName = TEXT('ProxyOverride');
      final overrideVal = TEXT(proxyOverride);
      RegSetValueEx(
        hKey,
        overrideName,
        0,
        REG_SZ,
        overrideVal.cast(),
        (proxyOverride.length + 1) * 2,
      );
      free(overrideName);
      free(overrideVal);
    }

    RegCloseKey(hKey);
  }

  static void _refreshWinINet() {
    try {
      final wininet = DynamicLibrary.open('wininet.dll');
      final internetSetOption = wininet.lookupFunction<
          Int32 Function(IntPtr, Uint32, Pointer<Void>, Uint32),
          int Function(int, int, Pointer<Void>, int)>('InternetSetOptionW');

      internetSetOption(0, internetOptionSettingsChanged, nullptr, 0);
      internetSetOption(0, internetOptionRefresh, nullptr, 0);
    } catch (e) {
      debugPrint('[SystemProxyService] Failed to notify WinINet: $e');
    }
  }
}
