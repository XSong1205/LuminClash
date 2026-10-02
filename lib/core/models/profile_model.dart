class ProfileItem {
  final String id;
  final String name;
  final String? url;
  final String filePath;
  final DateTime lastUpdated;
  final int nodeCount;
  final bool isActive;
  final int? uploadBytes;
  final int? downloadBytes;
  final int? totalBytes;
  final DateTime? expireDate;

  const ProfileItem({
    required this.id,
    required this.name,
    this.url,
    required this.filePath,
    required this.lastUpdated,
    this.nodeCount = 0,
    this.isActive = false,
    this.uploadBytes,
    this.downloadBytes,
    this.totalBytes,
    this.expireDate,
  });

  ProfileItem copyWith({
    String? id,
    String? name,
    String? url,
    String? filePath,
    DateTime? lastUpdated,
    int? nodeCount,
    bool? isActive,
    int? uploadBytes,
    int? downloadBytes,
    int? totalBytes,
    DateTime? expireDate,
  }) {
    return ProfileItem(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      nodeCount: nodeCount ?? this.nodeCount,
      isActive: isActive ?? this.isActive,
      uploadBytes: uploadBytes ?? this.uploadBytes,
      downloadBytes: downloadBytes ?? this.downloadBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      expireDate: expireDate ?? this.expireDate,
    );
  }

  factory ProfileItem.fromJson(Map<String, dynamic> json) {
    return ProfileItem(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String?,
      filePath: json['filePath'] as String,
      lastUpdated: DateTime.tryParse(json['lastUpdated'] as String? ?? '') ??
          DateTime.now(),
      nodeCount: (json['nodeCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      uploadBytes: (json['uploadBytes'] as num?)?.toInt(),
      downloadBytes: (json['downloadBytes'] as num?)?.toInt(),
      totalBytes: (json['totalBytes'] as num?)?.toInt(),
      expireDate: json['expireDate'] != null
          ? DateTime.tryParse(json['expireDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'filePath': filePath,
        'lastUpdated': lastUpdated.toIso8601String(),
        'nodeCount': nodeCount,
        'isActive': isActive,
        'uploadBytes': uploadBytes,
        'downloadBytes': downloadBytes,
        'totalBytes': totalBytes,
        'expireDate': expireDate?.toIso8601String(),
      };
}
