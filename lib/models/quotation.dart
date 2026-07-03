import 'package:intl/intl.dart';

import '../services/quotation_calculator.dart';

class QuotationDraft {
  final String quotedTo;
  final String contactNo;
  final String email;
  final String quotationNumber;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String projectDescription;

  // Solar Panels
  final String? panelMake;
  final int panelQty;
  final int panelUnitPrice;

  // Inverter
  final String? inverterMake;
  final int inverterQty;
  final int inverterUnitPrice;

  // Battery
  final String? batteryMake;
  final int batteryQty;
  final int batteryUnitPrice;
  final String batteryWarranty;

  // Mounting Structure
  final String mountingType;
  final int mountingQty;
  final int mountingUnitPrice;

  // Balance of System
  final int bosUnitPrice;
  final String? bosId;  // ← NEW: BOS ID for selected template

  // Earthing
  final int earthingQty;
  final int earthingUnitPrice;

  // Installation & Transport
  final int installationUnitPrice;

  // Discount
  final int discountedPrice;

  const QuotationDraft({
    required this.quotedTo,
    required this.contactNo,
    required this.email,
    required this.quotationNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.projectDescription,
    this.panelMake,
    this.panelQty = 0,
    this.panelUnitPrice = 0,
    this.inverterMake,
    this.inverterQty = 0,
    this.inverterUnitPrice = 0,
    this.batteryMake,
    this.batteryQty = 0,
    this.batteryUnitPrice = 0,
    this.batteryWarranty = '5',
    this.mountingType = '',
    this.mountingQty = 0,
    this.mountingUnitPrice = 0,
    this.bosUnitPrice = 0,
    this.bosId,
    this.earthingQty = 0,
    this.earthingUnitPrice = 30000,
    this.installationUnitPrice = 0,
    this.discountedPrice = 0,
  });

  List<QuotationLine> get lines => QuotationCalculator.buildLines(this);

  int get grandTotal => QuotationCalculator.grandTotal(this);

  List<String> get warranties => QuotationCalculator.warranties(this);

  bool get hasDiscount => discountedPrice > 0;

  int get savings => hasDiscount ? grandTotal - discountedPrice : 0;

  bool get hasPanels => panelQty > 0;
  bool get hasInverter => inverterQty > 0;
  bool get hasBattery => batteryQty > 0;
  bool get hasMounting => mountingQty > 0;
  bool get hasBos => bosUnitPrice > 0;
  bool get hasEarthing => earthingQty > 0;
  bool get hasInstallation => installationUnitPrice > 0;

  QuotationDraft copyWith({
    String? quotedTo,
    String? contactNo,
    String? email,
    String? quotationNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? projectDescription,
    String? panelMake,
    int? panelQty,
    int? panelUnitPrice,
    String? inverterMake,
    int? inverterQty,
    int? inverterUnitPrice,
    String? batteryMake,
    int? batteryQty,
    int? batteryUnitPrice,
    String? batteryWarranty,
    String? mountingType,
    int? mountingQty,
    int? mountingUnitPrice,
    int? bosUnitPrice,
    String? bosId,
    int? earthingQty,
    int? earthingUnitPrice,
    int? installationUnitPrice,
    int? discountedPrice,
  }) {
    return QuotationDraft(
      quotedTo: quotedTo ?? this.quotedTo,
      contactNo: contactNo ?? this.contactNo,
      email: email ?? this.email,
      quotationNumber: quotationNumber ?? this.quotationNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      projectDescription: projectDescription ?? this.projectDescription,
      panelMake: panelMake ?? this.panelMake,
      panelQty: panelQty ?? this.panelQty,
      panelUnitPrice: panelUnitPrice ?? this.panelUnitPrice,
      inverterMake: inverterMake ?? this.inverterMake,
      inverterQty: inverterQty ?? this.inverterQty,
      inverterUnitPrice: inverterUnitPrice ?? this.inverterUnitPrice,
      batteryMake: batteryMake ?? this.batteryMake,
      batteryQty: batteryQty ?? this.batteryQty,
      batteryUnitPrice: batteryUnitPrice ?? this.batteryUnitPrice,
      batteryWarranty: batteryWarranty ?? this.batteryWarranty,
      mountingType: mountingType ?? this.mountingType,
      mountingQty: mountingQty ?? this.mountingQty,
      mountingUnitPrice: mountingUnitPrice ?? this.mountingUnitPrice,
      bosUnitPrice: bosUnitPrice ?? this.bosUnitPrice,
      bosId: bosId ?? this.bosId,
      earthingQty: earthingQty ?? this.earthingQty,
      earthingUnitPrice: earthingUnitPrice ?? this.earthingUnitPrice,
      installationUnitPrice: installationUnitPrice ?? this.installationUnitPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
    );
  }

  Map<String, dynamic> toJson() => {
    'quotedTo': quotedTo,
    'contactNo': contactNo,
    'email': email,
    'quotationNumber': quotationNumber,
    'issueDate': issueDate.toIso8601String(),
    'expiryDate': expiryDate.toIso8601String(),
    'projectDescription': projectDescription,
    'panelMake': panelMake,
    'panelQty': panelQty,
    'panelUnitPrice': panelUnitPrice,
    'inverterMake': inverterMake,
    'inverterQty': inverterQty,
    'inverterUnitPrice': inverterUnitPrice,
    'batteryMake': batteryMake,
    'batteryQty': batteryQty,
    'batteryUnitPrice': batteryUnitPrice,
    'batteryWarranty': batteryWarranty,
    'mountingType': mountingType,
    'mountingQty': mountingQty,
    'mountingUnitPrice': mountingUnitPrice,
    'bosUnitPrice': bosUnitPrice,
    'bosId': bosId,
    'earthingQty': earthingQty,
    'earthingUnitPrice': earthingUnitPrice,
    'installationUnitPrice': installationUnitPrice,
    'discountedPrice': discountedPrice,
  };

  factory QuotationDraft.fromJson(Map<String, dynamic> json) {
    return QuotationDraft(
      quotedTo: json['quotedTo'] as String? ?? '',
      contactNo: json['contactNo'] as String? ?? '',
      email: json['email'] as String? ?? '',
      quotationNumber: json['quotationNumber'] as String? ?? '',
      issueDate: json['issueDate'] != null
          ? DateTime.parse(json['issueDate'] as String)
          : DateTime.now(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : DateTime.now().add(const Duration(days: 7)),
      projectDescription: json['projectDescription'] as String? ?? '',
      panelMake: json['panelMake'] as String?,
      panelQty: json['panelQty'] as int? ?? 0,
      panelUnitPrice: json['panelUnitPrice'] as int? ?? 0,
      inverterMake: json['inverterMake'] as String?,
      inverterQty: json['inverterQty'] as int? ?? 0,
      inverterUnitPrice: json['inverterUnitPrice'] as int? ?? 0,
      batteryMake: json['batteryMake'] as String?,
      batteryQty: json['batteryQty'] as int? ?? 0,
      batteryUnitPrice: json['batteryUnitPrice'] as int? ?? 0,
      batteryWarranty: json['batteryWarranty'] as String? ?? '5',
      mountingType: json['mountingType'] as String? ?? '',
      mountingQty: json['mountingQty'] as int? ?? 0,
      mountingUnitPrice: json['mountingUnitPrice'] as int? ?? 0,
      bosUnitPrice: json['bosUnitPrice'] as int? ?? 0,
      bosId: json['bosId'] as String?,
      earthingQty: json['earthingQty'] as int? ?? 0,
      earthingUnitPrice: json['earthingUnitPrice'] as int? ?? 30000,
      installationUnitPrice: json['installationUnitPrice'] as int? ?? 0,
      discountedPrice: json['discountedPrice'] as int? ?? 0,
    );
  }
}

class QuotationLine {
  final int serialNo;
  final String item;
  final String makeDescription;
  final String quantityLabel;
  final int quantity;
  final int unitPrice;
  final int lineTotal;

  const QuotationLine({
    required this.serialNo,
    required this.item,
    required this.makeDescription,
    required this.quantityLabel,
    this.quantity = 0,
    this.unitPrice = 0,
    this.lineTotal = 0,
  });
}