class ProxyHistoryDelay {
  final String time;
  final int delay;

  const ProxyHistoryDelay({
    required this.time,
    required this.delay,
  });

  factory ProxyHistoryDelay.fromJson(Map<String, dynamic> json) {
    return ProxyHistoryDelay(
      time: json['time'] as String? ?? '',
      delay: (json['delay'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time,
        'delay': delay,
      };
}

class ProxyNode {
  final String name;
  final String type;
  final int delay;
  final bool udp;
  final List<ProxyHistoryDelay> history;

  const ProxyNode({
    required this.name,
    required this.type,
    this.delay = 0,
    this.udp = true,
    this.history = const [],
  });

  ProxyNode copyWith({
    String? name,
    String? type,
    int? delay,
    bool? udp,
    List<ProxyHistoryDelay>? history,
  }) {
    return ProxyNode(
      name: name ?? this.name,
      type: type ?? this.type,
      delay: delay ?? this.delay,
      udp: udp ?? this.udp,
      history: history ?? this.history,
    );
  }

  factory ProxyNode.fromJson(String name, Map<String, dynamic> json) {
    final historyList = (json['history'] as List<dynamic>?)
            ?.map((e) => ProxyHistoryDelay.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];
    final lastDelay = (json['extra']?['delay'] as num?)?.toInt() ??
        (historyList.isNotEmpty ? historyList.last.delay : 0);

    return ProxyNode(
      name: name,
      type: json['type'] as String? ?? 'Unknown',
      delay: lastDelay,
      udp: json['udp'] as bool? ?? true,
      history: historyList,
    );
  }
}

class ProxyGroup {
  final String name;
  final String type; // Selector, URLTest, Fallback, etc.
  final String now;
  final List<String> all;
  final bool hidden;
  final String? icon;

  const ProxyGroup({
    required this.name,
    required this.type,
    required this.now,
    required this.all,
    this.hidden = false,
    this.icon,
  });

  ProxyGroup copyWith({
    String? name,
    String? type,
    String? now,
    List<String>? all,
    bool? hidden,
    String? icon,
  }) {
    return ProxyGroup(
      name: name ?? this.name,
      type: type ?? this.type,
      now: now ?? this.now,
      all: all ?? this.all,
      hidden: hidden ?? this.hidden,
      icon: icon ?? this.icon,
    );
  }

  factory ProxyGroup.fromJson(String name, Map<String, dynamic> json) {
    final allList = (json['all'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return ProxyGroup(
      name: name,
      type: json['type'] as String? ?? 'Selector',
      now: json['now'] as String? ?? (allList.isNotEmpty ? allList.first : ''),
      all: allList,
      hidden: json['hidden'] as bool? ?? false,
      icon: json['icon'] as String?,
    );
  }
}
