class ApplianceRecord {
  final String id;
  final String applianceName;
  final int watts;
  final int backupSlots;
  final bool active;

  const ApplianceRecord({
    required this.id,
    required this.applianceName,
    required this.watts,
    this.backupSlots = 5,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'applianceName': applianceName,
    'watts': watts,
    'backupSlots': backupSlots,
    'active': active,
  };

  factory ApplianceRecord.fromJson(Map<String, dynamic> json) => ApplianceRecord(
    id: json['id'] as String,
    applianceName: json['applianceName'] as String,
    watts: json['watts'] as int,
    backupSlots: json['backupSlots'] as int? ?? 5,
    active: json['active'] as bool? ?? true,
  );

  ApplianceRecord copyWith({
    String? id,
    String? applianceName,
    int? watts,
    int? backupSlots,
    bool? active,
  }) {
    return ApplianceRecord(
      id: id ?? this.id,
      applianceName: applianceName ?? this.applianceName,
      watts: watts ?? this.watts,
      backupSlots: backupSlots ?? this.backupSlots,
      active: active ?? this.active,
    );
  }
}