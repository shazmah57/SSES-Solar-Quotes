import 'package:intl/intl.dart';

class SavedQuotation {
  final String id;
  final String quotationNumber;
  final String quotedTo;
  final String contactNo;
  final String email;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String projectDescription;
  final String? panelMake;
  final int panelQty;
  final int panelUnitPrice;
  final String? inverterMake;
  final int inverterQty;
  final int inverterUnitPrice;
  final String? inverterWarranty; // FIX: added
  final String? batteryMake;
  final int batteryQty;
  final int batteryUnitPrice;
  final String? batteryWarranty;
  final String mountingType;
  final int mountingQty;
  final int mountingUnitPrice;
  final int bosUnitPrice;
  final String? bosId; // FIX: added
  final int earthingQty;
  final int earthingUnitPrice;
  final int installationUnitPrice;
  final int discountedPrice;
  final DateTime savedAt;
  final DateTime? lastModified;

  SavedQuotation({
    required this.id,
    required this.quotationNumber,
    required this.quotedTo,
    required this.contactNo,
    required this.email,
    required this.issueDate,
    required this.expiryDate,
    required this.projectDescription,
    this.panelMake,
    required this.panelQty,
    required this.panelUnitPrice,
    this.inverterMake,
    required this.inverterQty,
    required this.inverterUnitPrice,
    this.inverterWarranty, // FIX: added
    this.batteryMake,
    required this.batteryQty,
    required this.batteryUnitPrice,
    this.batteryWarranty,
    required this.mountingType,
    required this.mountingQty,
    required this.mountingUnitPrice,
    required this.bosUnitPrice,
    this.bosId, // FIX: added
    required this.earthingQty,
    required this.earthingUnitPrice,
    required this.installationUnitPrice,
    required this.discountedPrice,
    required this.savedAt,
    this.lastModified,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'quotationNumber': quotationNumber,
        'quotedTo': quotedTo,
        'contactNo': contactNo,
        'email': email,
        'issueDate': issueDate.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
        'projectDescription': projectDescription,
        'panelMake': panelMake,
        'panelQty': panelQty,
        'panelUnitPrice': panelUnitPrice,
        'inverterMake': inverterMake,
        'inverterQty': inverterQty,
        'inverterUnitPrice': inverterUnitPrice,
        'inverterWarranty': inverterWarranty, // FIX: added
        'batteryMake': batteryMake,
        'batteryQty': batteryQty,
        'batteryUnitPrice': batteryUnitPrice,
        'batteryWarranty': batteryWarranty,
        'mountingType': mountingType,
        'mountingQty': mountingQty,
        'mountingUnitPrice': mountingUnitPrice,
        'bosUnitPrice': bosUnitPrice,
        'bosId': bosId, // FIX: added
        'earthingQty': earthingQty,
        'earthingUnitPrice': earthingUnitPrice,
        'installationUnitPrice': installationUnitPrice,
        'discountedPrice': discountedPrice,
        'savedAt': savedAt.toIso8601String(),
        'lastModified': lastModified?.toIso8601String(),
      };

  factory SavedQuotation.fromJson(Map<String, dynamic> json) => SavedQuotation(
        id: json['id'] as String,
        quotationNumber: json['quotationNumber'] as String,
        quotedTo: json['quotedTo'] as String,
        contactNo: json['contactNo'] as String,
        email: json['email'] as String,
        issueDate: DateTime.parse(json['issueDate'] as String),
        expiryDate: DateTime.parse(json['expiryDate'] as String),
        projectDescription: json['projectDescription'] as String,
        panelMake: json['panelMake'] as String?,
        panelQty: json['panelQty'] as int,
        panelUnitPrice: json['panelUnitPrice'] as int,
        inverterMake: json['inverterMake'] as String?,
        inverterQty: json['inverterQty'] as int,
        inverterUnitPrice: json['inverterUnitPrice'] as int,
        inverterWarranty: json['inverterWarranty'] as String?, // FIX: added
        batteryMake: json['batteryMake'] as String?,
        batteryQty: json['batteryQty'] as int,
        batteryUnitPrice: json['batteryUnitPrice'] as int,
        batteryWarranty: json['batteryWarranty'] as String?,
        mountingType: json['mountingType'] as String,
        mountingQty: json['mountingQty'] as int,
        mountingUnitPrice: json['mountingUnitPrice'] as int,
        bosUnitPrice: json['bosUnitPrice'] as int,
        bosId: json['bosId'] as String?, // FIX: added
        earthingQty: json['earthingQty'] as int,
        earthingUnitPrice: json['earthingUnitPrice'] as int,
        installationUnitPrice: json['installationUnitPrice'] as int,
        discountedPrice: json['discountedPrice'] as int,
        savedAt: DateTime.parse(json['savedAt'] as String),
        lastModified: json['lastModified'] != null
            ? DateTime.parse(json['lastModified'] as String)
            : null,
      );

  SavedQuotation copyWith({
    String? id,
    String? quotationNumber,
    String? quotedTo,
    String? contactNo,
    String? email,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? projectDescription,
    String? panelMake,
    int? panelQty,
    int? panelUnitPrice,
    String? inverterMake,
    int? inverterQty,
    int? inverterUnitPrice,
    String? inverterWarranty, // FIX: added
    String? batteryMake,
    int? batteryQty,
    int? batteryUnitPrice,
    String? batteryWarranty,
    String? mountingType,
    int? mountingQty,
    int? mountingUnitPrice,
    int? bosUnitPrice,
    String? bosId, // FIX: added
    int? earthingQty,
    int? earthingUnitPrice,
    int? installationUnitPrice,
    int? discountedPrice,
    DateTime? savedAt,
    DateTime? lastModified,
  }) {
    return SavedQuotation(
      id: id ?? this.id,
      quotationNumber: quotationNumber ?? this.quotationNumber,
      quotedTo: quotedTo ?? this.quotedTo,
      contactNo: contactNo ?? this.contactNo,
      email: email ?? this.email,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      projectDescription: projectDescription ?? this.projectDescription,
      panelMake: panelMake ?? this.panelMake,
      panelQty: panelQty ?? this.panelQty,
      panelUnitPrice: panelUnitPrice ?? this.panelUnitPrice,
      inverterMake: inverterMake ?? this.inverterMake,
      inverterQty: inverterQty ?? this.inverterQty,
      inverterUnitPrice: inverterUnitPrice ?? this.inverterUnitPrice,
      inverterWarranty: inverterWarranty ?? this.inverterWarranty, // FIX: added
      batteryMake: batteryMake ?? this.batteryMake,
      batteryQty: batteryQty ?? this.batteryQty,
      batteryUnitPrice: batteryUnitPrice ?? this.batteryUnitPrice,
      batteryWarranty: batteryWarranty ?? this.batteryWarranty,
      mountingType: mountingType ?? this.mountingType,
      mountingQty: mountingQty ?? this.mountingQty,
      mountingUnitPrice: mountingUnitPrice ?? this.mountingUnitPrice,
      bosUnitPrice: bosUnitPrice ?? this.bosUnitPrice,
      bosId: bosId ?? this.bosId, // FIX: added
      earthingQty: earthingQty ?? this.earthingQty,
      earthingUnitPrice: earthingUnitPrice ?? this.earthingUnitPrice,
      installationUnitPrice: installationUnitPrice ?? this.installationUnitPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      savedAt: savedAt ?? this.savedAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  String get formattedDate => DateFormat('dd-MM-yyyy HH:mm').format(savedAt);
  String get formattedIssueDate => DateFormat('dd-MM-yyyy').format(issueDate);
}