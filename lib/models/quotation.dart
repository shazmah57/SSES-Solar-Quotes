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

  final String? panelMake;
  final int panelQty;
  final int panelUnitPrice;

  final String? inverterMake;
  final int inverterQty;
  final int inverterUnitPrice;
  final String inverterWarranty; // NEW

  final String? batteryMake;
  final int batteryQty;
  final int batteryUnitPrice;
  final String batteryWarranty;

  final String? mountingType;
  final int mountingQty;
  final int mountingUnitPrice;

  final int bosUnitPrice;
  final String? bosId;

  final int earthingQty;
  final int earthingUnitPrice;

  final int installationUnitPrice;
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
    this.inverterWarranty = '3', // NEW
    this.batteryMake,
    this.batteryQty = 0,
    this.batteryUnitPrice = 0,
    this.batteryWarranty = '5',
    this.mountingType,
    this.mountingQty = 0,
    this.mountingUnitPrice = 0,
    this.bosUnitPrice = 0,
    this.bosId,
    this.earthingQty = 0,
    this.earthingUnitPrice = 0,
    this.installationUnitPrice = 0,
    this.discountedPrice = 0,
  });

  List<QuotationLine> get lines => QuotationCalculator.buildLines(this);

  int get grandTotal => QuotationCalculator.grandTotal(this);

  List<String> get warranties => QuotationCalculator.warranties(this);

  Map<String, dynamic> toJson() {
    return {
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
      'inverterWarranty': inverterWarranty, // NEW
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
  }

  factory QuotationDraft.fromJson(Map<String, dynamic> json) {
    return QuotationDraft(
      quotedTo: json['quotedTo'] ?? '',
      contactNo: json['contactNo'] ?? '',
      email: json['email'] ?? '',
      quotationNumber: json['quotationNumber'] ?? '',
      issueDate: DateTime.parse(json['issueDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      projectDescription: json['projectDescription'] ?? '',
      panelMake: json['panelMake'],
      panelQty: json['panelQty'] ?? 0,
      panelUnitPrice: json['panelUnitPrice'] ?? 0,
      inverterMake: json['inverterMake'],
      inverterQty: json['inverterQty'] ?? 0,
      inverterUnitPrice: json['inverterUnitPrice'] ?? 0,
      inverterWarranty: json['inverterWarranty'] ?? '3', // NEW
      batteryMake: json['batteryMake'],
      batteryQty: json['batteryQty'] ?? 0,
      batteryUnitPrice: json['batteryUnitPrice'] ?? 0,
      batteryWarranty: json['batteryWarranty'] ?? '5',
      mountingType: json['mountingType'],
      mountingQty: json['mountingQty'] ?? 0,
      mountingUnitPrice: json['mountingUnitPrice'] ?? 0,
      bosUnitPrice: json['bosUnitPrice'] ?? 0,
      bosId: json['bosId'],
      earthingQty: json['earthingQty'] ?? 0,
      earthingUnitPrice: json['earthingUnitPrice'] ?? 0,
      installationUnitPrice: json['installationUnitPrice'] ?? 0,
      discountedPrice: json['discountedPrice'] ?? 0,
    );
  }

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
    String? inverterWarranty,
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
      inverterWarranty: inverterWarranty ?? this.inverterWarranty,
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