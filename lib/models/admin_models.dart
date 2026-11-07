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
    required this.brandMake,
    required this.technology,
    required this.wattage,
    this.unitPrice = 0,
    this.warranty = '',
    this.active = true,
  });

  String get displayName {
    if (brandMake.isNotEmpty && panelName.isNotEmpty) {
      return '$brandMake $panelName';
    }
    return panelName.isNotEmpty ? panelName : brandMake;
  }

  String get fullDescription {
    String desc = displayName;
    if (technology.isNotEmpty) {
      desc += ' · $technology';
    }
    if (wattage > 0) {
      desc += ' · ${wattage}W';
    }
    return desc;
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

  factory SolarPanelRecord.fromJson(Map<String, dynamic> json) => SolarPanelRecord(
    id: json['id'] as String,
    panelName: json['panelName'] as String? ?? '',
    brandMake: json['brandMake'] as String? ?? '',
    technology: json['technology'] as String? ?? '',
    wattage: json['wattage'] as int? ?? 0,
    unitPrice: json['unitPrice'] as int? ?? 0,
    warranty: json['warranty'] as String? ?? '',
    active: json['active'] as bool? ?? true,
  );

  SolarPanelRecord copyWith({
    String? id,
    String? panelName,
    String? brandMake,
    String? technology,
    int? wattage,
    int? unitPrice,
    String? warranty,
    bool? active,
  }) {
    return SolarPanelRecord(
      id: id ?? this.id,
      panelName: panelName ?? this.panelName,
      brandMake: brandMake ?? this.brandMake,
      technology: technology ?? this.technology,
      wattage: wattage ?? this.wattage,
      unitPrice: unitPrice ?? this.unitPrice,
      warranty: warranty ?? this.warranty,
      active: active ?? this.active,
    );
  }
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
    required this.brandMake,
    required this.phaseType,
    required this.capacity,
    required this.ipRating,
    this.unitPrice = 0,
    this.warranty = '',
    this.active = true,
  });

  String get displayName {
    if (brandMake.isNotEmpty && inverterName.isNotEmpty) {
      return '$brandMake $inverterName';
    }
    return inverterName.isNotEmpty ? inverterName : brandMake;
  }

  String get fullDescription {
    String desc = displayName;
    if (phaseType.isNotEmpty) {
      desc += ' · $phaseType';
    }
    if (capacity.isNotEmpty) {
      desc += ' · $capacity';
    }
    if (ipRating.isNotEmpty) {
      desc += ' · $ipRating';
    }
    return desc;
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

  factory SolarInverterRecord.fromJson(Map<String, dynamic> json) => SolarInverterRecord(
    id: json['id'] as String,
    inverterName: json['inverterName'] as String? ?? '',
    brandMake: json['brandMake'] as String? ?? '',
    phaseType: json['phaseType'] as String? ?? '',
    capacity: json['capacity'] as String? ?? '',
    ipRating: json['ipRating'] as String? ?? '',
    unitPrice: json['unitPrice'] as int? ?? 0,
    warranty: json['warranty'] as String? ?? '',
    active: json['active'] as bool? ?? true,
  );

  SolarInverterRecord copyWith({
    String? id,
    String? inverterName,
    String? brandMake,
    String? phaseType,
    String? capacity,
    String? ipRating,
    int? unitPrice,
    String? warranty,
    bool? active,
  }) {
    return SolarInverterRecord(
      id: id ?? this.id,
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
    required this.brandMake,
    required this.batteryType,
    required this.capacity,
    required this.ipRating,
    this.unitPrice = 0,
    this.warranty = '',
    this.active = true,
  });

  String get displayName {
    if (brandMake.isNotEmpty && batteryName.isNotEmpty) {
      return '$brandMake $batteryName';
    }
    return batteryName.isNotEmpty ? batteryName : brandMake;
  }

  String get fullDescription {
    String desc = displayName;
    if (batteryType.isNotEmpty) {
      desc += ' · $batteryType';
    }
    if (capacity.isNotEmpty) {
      desc += ' · $capacity';
    }
    if (ipRating.isNotEmpty) {
      desc += ' · $ipRating';
    }
    return desc;
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

  factory BatteryRecord.fromJson(Map<String, dynamic> json) => BatteryRecord(
    id: json['id'] as String,
    batteryName: json['batteryName'] as String? ?? '',
    brandMake: json['brandMake'] as String? ?? '',
    batteryType: json['batteryType'] as String? ?? '',
    capacity: json['capacity'] as String? ?? '',
    ipRating: json['ipRating'] as String? ?? '',
    unitPrice: json['unitPrice'] as int? ?? 0,
    warranty: json['warranty'] as String? ?? '',
    active: json['active'] as bool? ?? true,
  );

  BatteryRecord copyWith({
    String? id,
    String? batteryName,
    String? brandMake,
    String? batteryType,
    String? capacity,
    String? ipRating,
    int? unitPrice,
    String? warranty,
    bool? active,
  }) {
    return BatteryRecord(
      id: id ?? this.id,
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
    required this.description,
    required this.materialDetails,
    this.unitPrice = 0,
    this.active = true,
  });

  String get displayName => structureName;

  String get fullDescription {
    String desc = structureName;
    if (description.isNotEmpty) {
      desc += ' · $description';
    }
    if (materialDetails.isNotEmpty) {
      desc += ' · $materialDetails';
    }
    return desc;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'structureName': structureName,
    'description': description,
    'materialDetails': materialDetails,
    'unitPrice': unitPrice,
    'active': active,
  };

  factory MountingStructureRecord.fromJson(Map<String, dynamic> json) => MountingStructureRecord(
    id: json['id'] as String,
    structureName: json['structureName'] as String? ?? '',
    description: json['description'] as String? ?? '',
    materialDetails: json['materialDetails'] as String? ?? '',
    unitPrice: json['unitPrice'] as int? ?? 0,
    active: json['active'] as bool? ?? true,
  );

  MountingStructureRecord copyWith({
    String? id,
    String? structureName,
    String? description,
    String? materialDetails,
    int? unitPrice,
    bool? active,
  }) {
    return MountingStructureRecord(
      id: id ?? this.id,
      structureName: structureName ?? this.structureName,
      description: description ?? this.description,
      materialDetails: materialDetails ?? this.materialDetails,
      unitPrice: unitPrice ?? this.unitPrice,
      active: active ?? this.active,
    );
  }
}

// ═════════════════════════════════════════════════════════════
// TERMS RECORD - Added to fix the build errors
// ═════════════════════════════════════════════════════════════

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

  factory TermsRecord.fromJson(Map<String, dynamic> json) => TermsRecord(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    sortOrder: json['sortOrder'] as int? ?? 0,
    active: json['active'] as bool? ?? true,
  );

  TermsRecord copyWith({
    String? id,
    String? title,
    String? description,
    int? sortOrder,
    bool? active,
  }) {
    return TermsRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
    );
  }
}