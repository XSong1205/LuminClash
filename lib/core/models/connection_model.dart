class ConnectionMetadata {
  final String network;
  final String type;
  final String sourceIP;
  final String sourcePort;
  final String destinationIP;
  final String destinationPort;
  final String host;
  final String process;
  final String processPath;

  const ConnectionMetadata({
    required this.network,
    required this.type,
    required this.sourceIP,
    required this.sourcePort,
    required this.destinationIP,
    required this.destinationPort,
    required this.host,
    this.process = '',
    this.processPath = '',
  });

  factory ConnectionMetadata.fromJson(Map<String, dynamic> json) {
    return ConnectionMetadata(
      network: json['network'] as String? ?? 'tcp',
      type: json['type'] as String? ?? '',
      sourceIP: json['sourceIP'] as String? ?? '',
      sourcePort: (json['sourcePort'] ?? '').toString(),
      destinationIP: json['destinationIP'] as String? ?? '',
      destinationPort: (json['destinationPort'] ?? '').toString(),
      host: json['host'] as String? ?? '',
      process: json['process'] as String? ?? '',
      processPath: json['processPath'] as String? ?? '',
    );
  }
}

class ConnectionItem {
  final String id;
  final ConnectionMetadata metadata;
  final int upload;
  final int download;
  final DateTime start;
  final List<String> chains;
  final String rule;
  final String rulePayload;

  const ConnectionItem({
    required this.id,
    required this.metadata,
    required this.upload,
    required this.download,
    required this.start,
    required this.chains,
    required this.rule,
    required this.rulePayload,
  });

  factory ConnectionItem.fromJson(Map<String, dynamic> json) {
    return ConnectionItem(
      id: json['id'] as String? ?? '',
      metadata: ConnectionMetadata.fromJson(
        (json['metadata'] as Map<String, dynamic>?) ?? {},
      ),
      upload: (json['upload'] as num?)?.toInt() ?? 0,
      download: (json['download'] as num?)?.toInt() ?? 0,
      start: DateTime.tryParse(json['start'] as String? ?? '') ?? DateTime.now(),
      chains: (json['chains'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      rule: json['rule'] as String? ?? '',
      rulePayload: json['rulePayload'] as String? ?? '',
    );
  }
}

class RuleItem {
  final String type;
  final String payload;
  final String proxy;
  final String size;

  const RuleItem({
    required this.type,
    required this.payload,
    required this.proxy,
    this.size = '',
  });

  factory RuleItem.fromJson(Map<String, dynamic> json) {
    return RuleItem(
      type: json['type'] as String? ?? '',
      payload: json['payload'] as String? ?? '',
      proxy: json['proxy'] as String? ?? '',
      size: (json['size'] ?? '').toString(),
    );
  }
}
