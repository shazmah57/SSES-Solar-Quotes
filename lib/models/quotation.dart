import '../data/catalog_data.dart';
import '../services/quotation_calculator.dart';

class QuotationLine {
  final int serialNo;
  final String item;
  final String makeDescription;
  final String quantityLabel;
  final int? quantity;
  final int unitPrice;
  final int lineTotal;

  const QuotationLine({
    required this.serialNo,
    required this.item,
    required this.makeDescription,
    required this.quantityLabel,
    this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });
}

class QuotationDraft {
  String quotedTo;
  String contactNo;
  String email;
  String quotationNumber;
  DateTime issueDate;
  DateTime expiryDate;
  String projectDescription;

  String? panelMake;
  int panelQty;
  int panelUnitPrice;

  String? inverterMake;
  int inverterQty;
  int inverterUnitPrice;

  String? batteryMake;
  int batteryQty;
  int batteryUnitPrice;

  String mountingType;
  int mountingQty;
  int mountingUnitPrice;

  int bosUnitPrice;
  int installationUnitPrice;

  QuotationDraft({
    this.quotedTo = '',
    this.contactNo = '',
    this.email = '',
    this.quotationNumber = '',
    DateTime? issueDate,
    DateTime? expiryDate,
    this.projectDescription = '',
    this.panelMake,
    this.panelQty = 0,
    this.panelUnitPrice = 0,
    this.inverterMake,
    this.inverterQty = 0,
    this.inverterUnitPrice = 0,
    this.batteryMake,
    this.batteryQty = 0,
    this.batteryUnitPrice = 0,
    String? mountingType,
    this.mountingQty = 0,
    this.mountingUnitPrice = 0,
    this.bosUnitPrice = 0,
    this.installationUnitPrice = 0,
  }) : mountingType = mountingType ?? CatalogData.mountingStructureTypes.first,
       issueDate = issueDate ?? DateTime.now(),
       expiryDate = expiryDate ?? DateTime.now().add(const Duration(days: 7));

  List<QuotationLine> get lines => QuotationCalculator.buildLines(this);

  int get grandTotal => QuotationCalculator.grandTotal(this);

  List<String> get warranties => QuotationCalculator.warranties(this);
}
