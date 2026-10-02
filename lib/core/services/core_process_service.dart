import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:win32/win32.dart';

typedef _InitCoreC = Int32 Function(Pointer<Utf8> homeDir);
typedef _InitCoreDart = int Function(Pointer<Utf8> homeDir);

typedef _StartCoreC = Pointer<Utf8> Function(Pointer<Utf8> configPath);
typedef _StartCoreDart = Pointer<Utf8> Function(Pointer<Utf8> configPath);

typedef _StopCoreC = Void Function();
typedef _StopCoreDart = void Function();

typedef _GetCoreVersionC = Pointer<Utf8> Function();
typedef _GetCoreVersionDart = Pointer<Utf8> Function();

typedef _FreeStringC = Void Function(Pointer<Utf8> str);
typedef _FreeStringDart = void Function(Pointer<Utf8> str);

class CoreProcessService {
  static final CoreProcessService _instance = CoreProcessService._internal();
  factory CoreProcessService() => _instance;
  CoreProcessService._internal();

  Process? _process;
  int? _jobHandle;
  bool _isStarting = false;
  bool _isAndroidCoreRunning = false;

  final List<String> _logs = [];
  final StreamController<String> _logStreamController =
      StreamController<String>.broadcast();

  Stream<String> get logStream => _logStreamController.stream;
  List<String> get logs => List.unmodifiable(_logs);
  bool get isRunning => Platform.isAndroid ? _isAndroidCoreRunning : _process != null;
  int? get pid => _process?.pid;

  /// 获取 Android 原生内核版本
  String? getAndroidCoreVersion() {
    if (!Platform.isAndroid) return null;
    try {
      final lib = DynamicLibrary.open('libclash.so');
      final getVersion = lib.lookupFunction<_GetCoreVersionC, _GetCoreVersionDart>('GetCoreVersion');
      final freeString = lib.lookupFunction<_FreeStringC, _FreeStringDart>('FreeString');
      final ptr = getVersion();
      if (ptr.address != 0) {
        final version = ptr.toDartString();
        freeString(ptr);
        return version;
      }
    } catch (_) {}
    return null;
  }

  /// 获取或初始化工作目录 (AppData/LuminClash/core)
  Future<Directory> getCoreDirectory() async {
    Directory baseDir;
    try {
      baseDir = await getApplicationSupportDirectory();
    } catch (_) {
      baseDir = Directory(p.join(
        Platform.environment['APPDATA'] ?? Directory.current.path,
        'LuminClash',
      ));
    }
    final coreDir = Directory(p.join(baseDir.path, 'core'));
    if (!coreDir.existsSync()) {
      coreDir.createSync(recursive: true);
    }
    return coreDir;
  }

  /// 定位 mihomo 可执行程序路径
  Future<String?> findCoreExecutable() async {
    final coreDir = await getCoreDirectory();
    final candidateNames = Platform.isWindows
        ? ['mihomo.exe', 'FlClashCore.exe', 'clash.exe']
        : ['mihomo', 'FlClashCore', 'clash'];

    // 1. 检查工作目录下的二进制文件
    for (final name in candidateNames) {
      final file = File(p.join(coreDir.path, name));
      if (file.existsSync()) return file.path;
    }

    // 2. 检查程序同级目录、构建目录及当前项目目录
    final appExeDir = File(Platform.resolvedExecutable).parent;
    for (final name in candidateNames) {
      final candidates = [
        File(p.join(appExeDir.path, name)),
        File(p.join(appExeDir.path, 'data', 'flutter_assets', 'assets', 'core', name)),
        File(p.join(Directory.current.path, 'assets', 'core', name)),
        File(p.join(Directory.current.path, 'windows', 'runner', name)),
      ];
      for (final candidate in candidates) {
        if (candidate.existsSync()) {
          // 拷贝至工作目录以保证统一权限管理
          final dest = File(p.join(coreDir.path, name));
          if (!dest.existsSync() || dest.lengthSync() != candidate.lengthSync()) {
            try {
              candidate.copySync(dest.path);
              return dest.path;
            } catch (_) {
              return candidate.path;
            }
          }
          return dest.path;
        }
      }
    }

    // 3. 检查系统 PATH
    try {
      final checkCmd = Platform.isWindows ? 'where.exe' : 'which';
      final res = await Process.run(checkCmd, ['mihomo']);
      if (res.exitCode == 0) {
        final path = res.stdout.toString().split(RegExp(r'[\r\n]+')).first.trim();
        if (path.isNotEmpty && File(path).existsSync()) {
          return path;
        }
      }
    } catch (_) {}

    return null;
  }

  /// 生成或确保运行时默认配置 (config.yaml)
  Future<File> ensureConfigFile({String? activeConfigContent}) async {
    final coreDir = await getCoreDirectory();
    final configFile = File(p.join(coreDir.path, 'config.yaml'));

    if (activeConfigContent != null && activeConfigContent.trim().isNotEmpty) {
      await configFile.writeAsString(activeConfigContent);
      return configFile;
    }

    if (!configFile.existsSync()) {
      final defaultConfig = '''
mixed-port: 7890
allow-lan: false
mode: rule
log-level: info
external-controller: 127.0.0.1:9090
secret: ""

dns:
  enable: true
  listen: 127.0.0.1:1053
  enhanced-mode: fake-ip
  nameserver:
    - 223.5.5.5
    - 119.29.29.29
    - 1.1.1.1

proxies:
  - name: "DIRECT"
    type: direct
  - name: "REJECT"
    type: reject

proxy-groups:
  - name: "PROXY"
    type: select
    proxies:
      - DIRECT
  - name: "GLOBAL"
    type: select
    proxies:
      - PROXY
      - DIRECT

rules:
  - GEOIP,LAN,DIRECT
  - MATCH,PROXY
''';
      await configFile.writeAsString(defaultConfig);
    }

    return configFile;
  }

  /// 启动 Mihomo 内核进程 (Windows/Desktop 为独立子进程，Android 为动态库 FFI)
  Future<bool> startCore({String? customExecutablePath}) async {
    if (isRunning || _isStarting) return true;
    _isStarting = true;

    // Android 移动端走 libclash.so 原生动态库
    if (Platform.isAndroid) {
      final success = await _startCoreAndroid();
      _isStarting = false;
      return success;
    }

    try {
      final exePath = customExecutablePath ?? await findCoreExecutable();
      if (exePath == null) {
        _addLog('[CoreProcess] 未找到 Mihomo 内核二进制文件 (mihomo.exe)');
        _isStarting = false;
        return false;
      }

      final coreDir = await getCoreDirectory();
      final configFile = await ensureConfigFile();

      _addLog('[CoreProcess] 启动内核: $exePath');
      _addLog('[CoreProcess] 工作目录: ${coreDir.path}');
      _addLog('[CoreProcess] 配置文件: ${configFile.path}');

      final process = await Process.start(
        exePath,
        ['-d', coreDir.path, '-f', configFile.path],
        workingDirectory: coreDir.path,
        mode: ProcessStartMode.normal,
      );

      _process = process;

      // Windows 平台挂载 Win32 Job Object 防孤儿进程保护
      if (Platform.isWindows) {
        _attachWin32JobObject(process.pid);
      }

      // 监听日志输出
      process.stdout.transform(utf8.decoder).listen((data) {
        for (final line in data.split(RegExp(r'[\r\n]+'))) {
          if (line.trim().isNotEmpty) {
            _addLog(line.trim());
          }
        }
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        for (final line in data.split(RegExp(r'[\r\n]+'))) {
          if (line.trim().isNotEmpty) {
            _addLog('[STDERR] ${line.trim()}');
          }
        }
      });

      process.exitCode.then((code) {
        _addLog('[CoreProcess] 内核进程退出，ExitCode: $code');
        _process = null;
        _isStarting = false;
      });

      _isStarting = false;
      return true;
    } catch (e, stack) {
      _addLog('[CoreProcess] 启动内核失败: $e');
      debugPrint('[CoreProcess] startCore exception: $e\n$stack');
      _process = null;
      _isStarting = false;
      return false;
    }
  }

  /// Android 端通过 FFI 启动 libclash.so
  Future<bool> _startCoreAndroid() async {
    try {
      final coreDir = await getCoreDirectory();
      final configFile = await ensureConfigFile();

      _addLog('[CoreProcess] Android 加载 libclash.so 核心');
      final lib = DynamicLibrary.open('libclash.so');
      final initCore = lib.lookupFunction<_InitCoreC, _InitCoreDart>('InitCore');
      final startCore = lib.lookupFunction<_StartCoreC, _StartCoreDart>('StartCore');
      final freeString = lib.lookupFunction<_FreeStringC, _FreeStringDart>('FreeString');

      final homePtr = coreDir.path.toNativeUtf8();
      initCore(homePtr);
      calloc.free(homePtr);

      final cfgPtr = configFile.path.toNativeUtf8();
      final errPtr = startCore(cfgPtr);
      calloc.free(cfgPtr);

      if (errPtr.address != 0) {
        final errStr = errPtr.toDartString();
        freeString(errPtr);
        _addLog('[CoreProcess] Android libclash.so 启动错误: $errStr');
        return false;
      }

      _isAndroidCoreRunning = true;
      _addLog('[CoreProcess] Android libclash.so 启动成功 (控制器: 127.0.0.1:9090)');
      return true;
    } catch (e, stack) {
      _addLog('[CoreProcess] Android 启动失败: $e');
      debugPrint('[CoreProcess] Android startCore exception: $e\n$stack');
      return false;
    }
  }

  /// 优雅停止内核
  Future<void> stopCore() async {
    if (Platform.isAndroid) {
      if (_isAndroidCoreRunning) {
        try {
          final lib = DynamicLibrary.open('libclash.so');
          final stopCore = lib.lookupFunction<_StopCoreC, _StopCoreDart>('StopCore');
          stopCore();
          _addLog('[CoreProcess] Android libclash.so 已停止');
        } catch (e) {
          _addLog('[CoreProcess] 停止 Android 内核异常: $e');
        }
        _isAndroidCoreRunning = false;
      }
      return;
    }

    if (_process != null) {
      _addLog('[CoreProcess] 停止内核进程 PID: ${_process!.pid}');
      _process!.kill(ProcessSignal.sigterm);
      await Future.delayed(const Duration(milliseconds: 300));
      if (_process != null) {
        _process!.kill(ProcessSignal.sigkill);
      }
      _process = null;
    }
    _closeJobObject();
  }

  /// 重启内核
  Future<bool> restartCore({String? customExecutablePath}) async {
    await stopCore();
    await Future.delayed(const Duration(milliseconds: 500));
    return startCore(customExecutablePath: customExecutablePath);
  }

  void _addLog(String log) {
    if (_logs.length > 200) {
      _logs.removeAt(0);
    }
    _logs.add(log);
    if (!_logStreamController.isClosed) {
      _logStreamController.add(log);
    }
  }

  /// 将内核挂接至 Win32 Job Object (JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE)
  void _attachWin32JobObject(int pid) {
    try {
      final hJob = CreateJobObject(nullptr, nullptr);
      if (hJob == 0) return;
      _jobHandle = hJob;

      // JOBOBJECT_EXTENDED_LIMIT_INFORMATION 结构大小 144 字节
      // LimitFlags 位于偏移量 16 (下标 4 的 Uint32)
      // JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 0x2000
      // JobObjectExtendedLimitInformation = 9
      const jobObjectExtendedLimitInformation = 9;
      const jobObjectLimitKillOnJobClose = 0x2000;
      const infoSize = 144;

      final pInfo = calloc<Uint8>(infoSize);
      (pInfo.cast<Uint32>() + 4).value = jobObjectLimitKillOnJobClose;

      SetInformationJobObject(
        hJob,
        jobObjectExtendedLimitInformation,
        pInfo.cast(),
        infoSize,
      );
      free(pInfo);

      final hProcess = OpenProcess(
        PROCESS_SET_QUOTA | PROCESS_TERMINATE,
        FALSE,
        pid,
      );

      if (hProcess != 0) {
        AssignProcessToJobObject(hJob, hProcess);
        CloseHandle(hProcess);
        debugPrint('[CoreProcessService] Attached PID $pid to Win32 JobObject successfully');
      }
    } catch (e) {
      debugPrint('[CoreProcessService] Attach Win32 JobObject warning: $e');
    }
  }

  void _closeJobObject() {
    if (_jobHandle != null && _jobHandle != 0) {
      try {
        CloseHandle(_jobHandle!);
      } catch (_) {}
      _jobHandle = null;
    }
  }
}
