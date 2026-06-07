class SolarPanelRecord {
  final String id;
  final String panelName;
  final String brandMake;
  final String technology;
  final int wattage;
  final int unitPrice;
  final String warranty;
  final bool active;

  const SolarPanelRecord({
    required this.id,
    required this.panelName,
    this.brandMake = '',
    this.technology = '',
    this.wattage = 0,
    this.unitPrice = 0,
    this.warranty = '',
    this.active = true,
  });

  String get displayName {
    final parts = <String>[];
    if (brandMake.isNotEmpty) parts.add(brandMake);
    if (technology.isNotEmpty) parts.add(technology);
    if (wattage > 0) parts.add('${wattage}W');
    if (parts.isEmpty) return panelName;
    return parts.join(' ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'panelName': panelName,
        'brandMake': brandMake,
        'technology': technology,
        'wattage': wattage,
        'unitPrice': unitPrice,
        'warranty': warranty,
        'active': active,
      };

  factory SolarPanelRecord.fromJson(Map<String, dynamic> j) =>
      SolarPanelRecord(
        id: j['id'] as String? ?? '',
        panelName: j['panelName'] as String? ?? '',
        brandMake: j['brandMake'] as String? ?? '',
        technology: j['technology'] as String? ?? '',
        wattage: (j['wattage'] as num?)?.toInt() ?? 0,
        unitPrice: (j['unitPrice'] as num?)?.toInt() ?? 0,
        warranty: j['warranty'] as String? ?? '',
        active: j['active'] as bool? ?? true,
      );

  SolarPanelRecord copyWith({
    String? panelName,
    String? brandMake,
    String? technology,
    int? wattage,
    int? unitPrice,
    String? warranty,
    bool? active,
  }) =>
      SolarPanelRecord(
        id: id,
        panelName: panelName ?? this.panelName,
        brandMake: brandMake ?? this.brandMake,
        technology: technology ?? this.technology,
        wattage: wattage ?? this.wattage,
        unitPrice: unitPrice ?? this.unitPrice,
        warranty: warranty ?? this.warranty,
        active: active ?? this.active,
      );
}

class SolarInverterRecord {
  final String id;
  final String inverterName;
  final String brandMake;
  final String phaseType;
  final String capacity;
  final String ipRating;
  final int unitPrice;
  final String warranty;
  final bool active;

  const SolarInverterRecord({
    required this.id,
    required this.inverterName,
    this.brandMake = '',
    this.phaseType = '',
    this.capacity = '',
    this.ipRating = '',
    this.unitPrice = 0,
    this.warranty = '',
    this.active = true,
  });

  String get displayName {
    final parts = <String>[];
    if (brandMake.isNotEmpty) parts.add(brandMake);
    if (phaseType.isNotEmpty) parts.add(phaseType);
    if (capacity.isNotEmpty) parts.add(capacity);
    if (ipRating.isNotEmpty) parts.add('- $ipRating');
    if (parts.isEmpty) return inverterName;
    return parts.join(' ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'inverterName': inverterName,
        'brandMake': brandMake,
        'phaseType': phaseType,
        'capacity': capacity,
        'ipRating': ipRating,
        'unitPrice': unitPrice,
        'warranty': warranty,
        'active': active,
      };

  factory SolarInverterRecord.fromJson(Map<String, dynamic> j) =>
      SolarInverterRecord(
        id: j['id'] as String? ?? '',
        inverterName: j['inverterName'] as String? ?? '',
        brandMake: j['brandMake'] as String? ?? '',
        phaseType: j['phaseType'] as String? ?? '',
        capacity: j['capacity'] as String? ?? '',
        ipRating: j['ipRating'] as String? ?? '',
        unitPrice: (j['unitPrice'] as num?)?.toInt() ?? 0,
        warranty: j['warranty'] as String? ?? '',
        active: j['active'] as bool? ?? true,
      );

  SolarInverterRecord copyWith({
    String? inverterName,
    String? brandMake,
    String? phaseType,
    String? capacity,
    String? ipRating,
    int? unitPrice,
    String? warranty,
    bool? active,
  }) =>
      SolarInverterRecord(
        id: id,
        inverterName: inverterName ?? this.inverterName,
        brandMake: brandMake ?? this.brandMake,
        phaseType: phaseType ?? this.phaseType,
        capacity: capacity ?? this.capacity,
        ipRating: ipRating ?? this.ipRating,
        unitPrice: unitPrice ?? this.unitPrice,
        warranty: warranty ?? this.warranty,
        active: active ?? this.active,
      );
}

class BatteryRecord {
  final String id;
  final String batteryName;
  final String brandMake;
  final String batteryType;
  final String capacity;
  final String ipRating;
  final int unitPrice;
  final String warranty;
  final bool active;

  const BatteryRecord({
    required this.id,
    required this.batteryName,
    this.brandMake = '',
    this.batteryType = '',
    this.capacity = '',
    this.ipRating = '',
    this.unitPrice = 0,
    this.warranty = '',
    this.active = true,
  });

  String get displayName {
    final parts = <String>[];
    if (brandMake.isNotEmpty) parts.add(brandMake);
    if (batteryType.isNotEmpty) parts.add(batteryType);
    if (capacity.isNotEmpty) parts.add(capacity);
    if (ipRating.isNotEmpty) parts.add('- $ipRating');
    if (parts.isEmpty) return batteryName;
    return parts.join(' ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'batteryName': batteryName,
        'brandMake': brandMake,
        'batteryType': batteryType,
        'capacity': capacity,
        'ipRating': ipRating,
        'unitPrice': unitPrice,
        'warranty': warranty,
        'active': active,
      };

  factory BatteryRecord.fromJson(Map<String, dynamic> j) => BatteryRecord(
        id: j['id'] as String? ?? '',
        batteryName: j['batteryName'] as String? ?? '',
        brandMake: j['brandMake'] as String? ?? '',
        batteryType: j['batteryType'] as String? ?? '',
        capacity: j['capacity'] as String? ?? '',
        ipRating: j['ipRating'] as String? ?? '',
        unitPrice: (j['unitPrice'] as num?)?.toInt() ?? 0,
        warranty: j['warranty'] as String? ?? '',
        active: j['active'] as bool? ?? true,
      );

  BatteryRecord copyWith({
    String? batteryName,
    String? brandMake,
    String? batteryType,
    String? capacity,
    String? ipRating,
    int? unitPrice,
    String? warranty,
    bool? active,
  }) =>
      BatteryRecord(
        id: id,
        batteryName: batteryName ?? this.batteryName,
        brandMake: brandMake ?? this.brandMake,
        batteryType: batteryType ?? this.batteryType,
        capacity: capacity ?? this.capacity,
        ipRating: ipRating ?? this.ipRating,
        unitPrice: unitPrice ?? this.unitPrice,
        warranty: warranty ?? this.warranty,
        active: active ?? this.active,
      );
}

class MountingStructureRecord {
  final String id;
  final String structureName;
  final String description;
  final String materialDetails;
  final int unitPrice;
  final bool active;

  const MountingStructureRecord({
    required this.id,
    required this.structureName,
    this.description = '',
    this.materialDetails = '',
    this.unitPrice = 0,
    this.active = true,
  });

  String get displayName => structureName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'structureName': structureName,
        'description': description,
        'materialDetails': materialDetails,
        'unitPrice': unitPrice,
        'active': active,
      };

  factory MountingStructureRecord.fromJson(Map<String, dynamic> j) =>
      MountingStructureRecord(
        id: j['id'] as String? ?? '',
        structureName: j['structureName'] as String? ?? '',
        description: j['description'] as String? ?? '',
        materialDetails: j['materialDetails'] as String? ?? '',
        unitPrice: (j['unitPrice'] as num?)?.toInt() ?? 0,
        active: j['active'] as bool? ?? true,
      );

  MountingStructureRecord copyWith({
    String? structureName,
    String? description,
    String? materialDetails,
    int? unitPrice,
    bool? active,
  }) =>
      MountingStructureRecord(
        id: id,
        structureName: structureName ?? this.structureName,
        description: description ?? this.description,
        materialDetails: materialDetails ?? this.materialDetails,
        unitPrice: unitPrice ?? this.unitPrice,
        active: active ?? this.active,
      );
}

class TermsRecord {
  final String id;
  final String title;
  final String description;
  final int sortOrder;
  final bool active;

  const TermsRecord({
    required this.id,
    this.title = '',
    required this.description,
    this.sortOrder = 0,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'sortOrder': sortOrder,
        'active': active,
      };

  factory TermsRecord.fromJson(Map<String, dynamic> j) => TermsRecord(
        id: j['id'] as String? ?? '',
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        sortOrder: (j['sortOrder'] as num?)?.toInt() ?? 0,
        active: j['active'] as bool? ?? true,
      );

  TermsRecord copyWith({
    String? title,
    String? description,
    int? sortOrder,
    bool? active,
  }) =>
      TermsRecord(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        sortOrder: sortOrder ?? this.sortOrder,
        active: active ?? this.active,
      );
}
