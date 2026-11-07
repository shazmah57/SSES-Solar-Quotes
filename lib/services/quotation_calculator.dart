import 'package:intl/intl.dart';

import '../data/catalog_data.dart';
import '../models/quotation.dart';
import 'admin_data_service.dart';

class QuotationCalculator {
  static int lineTotalQtyTimesPrice(int qty, int unitPrice) => qty * unitPrice;

  static List<QuotationLine> buildLines(QuotationDraft q) {
    // Get the selected records from AdminDataService
    final panels = AdminDataService.instance.activePanels;
    final inverters = AdminDataService.instance.activeInverters;
    final batteries = AdminDataService.instance.activeBatteries;
    final structures = AdminDataService.instance.activeStructures;

    // Find selected records by matching displayName
    final selectedPanel = panels.where((p) => p.displayName == q.panelMake).firstOrNull;
    final selectedInverter = inverters.where((i) => i.displayName == q.inverterMake).firstOrNull;
    final selectedBattery = batteries.where((b) => b.displayName == q.batteryMake).firstOrNull;
    final selectedStructure = structures.where((s) => s.displayName == q.mountingType).firstOrNull;

    // Build all lines first (only if they have values)
    final List<QuotationLine> allLines = [];

    // 1. Solar Panels (only if qty > 0)
    if (q.panelQty > 0) {
      final description = selectedPanel?.fullDescription ?? q.panelMake ?? '-';
      allLines.add(
        QuotationLine(
          serialNo: 0,
          item: 'Solar Panels',
          makeDescription: description,
          quantityLabel: q.panelQty.toString(),
          quantity: q.panelQty,
          unitPrice: q.panelUnitPrice,
          lineTotal: lineTotalQtyTimesPrice(q.panelQty, q.panelUnitPrice),
        ),
      );
    }

    // 2. Solar Inverter (only if qty > 0)
    if (q.inverterQty > 0) {
      final description = selectedInverter?.fullDescription ?? q.inverterMake ?? '-';
      allLines.add(
        QuotationLine(
          serialNo: 0,
          item: 'Solar Inverter',
          makeDescription: description,
          quantityLabel: q.inverterQty.toString(),
          quantity: q.inverterQty,
          unitPrice: q.inverterUnitPrice,
          lineTotal: lineTotalQtyTimesPrice(q.inverterQty, q.inverterUnitPrice),
        ),
      );
    }

    // 3. Battery (only if qty > 0)
    if (q.batteryQty > 0) {
      final description = selectedBattery?.fullDescription ?? q.batteryMake ?? '-';
      allLines.add(
        QuotationLine(
          serialNo: 0,
          item: 'Battery',
          makeDescription: description,
          quantityLabel: q.batteryQty.toString(),
          quantity: q.batteryQty,
          unitPrice: q.batteryUnitPrice,
          lineTotal: lineTotalQtyTimesPrice(q.batteryQty, q.batteryUnitPrice),
        ),
      );
    }

    // 4. Mounting Structure (only if qty > 0)
    if (q.mountingQty > 0) {
      // Build description without the structure name
      String description = '';
      if (selectedStructure != null) {
        // Combine description and material details only
        if (selectedStructure.description.isNotEmpty) {
          description = selectedStructure.description;
        }
        if (selectedStructure.materialDetails.isNotEmpty) {
          if (description.isNotEmpty) description += ' · ';
          description += selectedStructure.materialDetails;
        }
      }
      if (description.isEmpty) {
        description = q.mountingType ?? '-';
      }
      
      allLines.add(
        QuotationLine(
          serialNo: 0,
          item: q.mountingType ?? 'Mounting Structure',
          makeDescription: description,
          quantityLabel: q.mountingQty.toString(),
          quantity: q.mountingQty,
          unitPrice: q.mountingUnitPrice,
          lineTotal: lineTotalQtyTimesPrice(q.mountingQty, q.mountingUnitPrice),
        ),
      );
    }

    // 5. Balance of System (only if price > 0)
    if (q.bosUnitPrice > 0) {
      String bosDescription = CatalogData.balanceOfSystemDescription;
      final bosRecords = AdminDataService.instance.activeBosRecords;
      if (q.bosId != null && q.bosId!.isNotEmpty) {
        final bosRecord = bosRecords.where((r) => r.id == q.bosId).firstOrNull;
        if (bosRecord != null) {
          bosDescription = bosRecord.description;
        }
      } else if (bosRecords.isNotEmpty) {
        bosDescription = bosRecords.first.description;
      }
      allLines.add(
        QuotationLine(
          serialNo: 0,
          item: 'Balance of System',
          makeDescription: bosDescription,
          quantityLabel: 'Est',
          unitPrice: q.bosUnitPrice,
          lineTotal: q.bosUnitPrice,
        ),
      );
    }

    // 6. Earthing (only if qty > 0)
    if (q.earthingQty > 0) {
      allLines.add(
        QuotationLine(
          serialNo: 0,
          item: 'Earthing (Optional)',
          makeDescription: 'Less than 5ohms',
          quantityLabel: '${q.earthingQty} ${q.earthingQty == 1 ? "Job" : "Jobs"}',
          quantity: q.earthingQty,
          unitPrice: q.earthingUnitPrice,
          lineTotal: lineTotalQtyTimesPrice(q.earthingQty, q.earthingUnitPrice),
        ),
      );
    }

    // 7. Installation & Transport (only if price > 0)
    if (q.installationUnitPrice > 0) {
      allLines.add(
        QuotationLine(
          serialNo: 0,
          item: 'Installation & Transport',
          makeDescription: '---',
          quantityLabel: '1 Job',
          unitPrice: q.installationUnitPrice,
          lineTotal: q.installationUnitPrice,
        ),
      );
    }

    // Renumber serial numbers sequentially
    for (int i = 0; i < allLines.length; i++) {
      final line = allLines[i];
      allLines[i] = QuotationLine(
        serialNo: i + 1,
        item: line.item,
        makeDescription: line.makeDescription,
        quantityLabel: line.quantityLabel,
        quantity: line.quantity,
        unitPrice: line.unitPrice,
        lineTotal: line.lineTotal,
      );
    }

    return allLines;
  }

  static int grandTotal(QuotationDraft q) {
    return buildLines(q).fold(0, (sum, line) => sum + line.lineTotal);
  }

  static List<String> warranties(QuotationDraft q) {
    final items = <String>[];

    // 1. Solar Panels Warranty
    if (q.panelQty > 0) {
      items.add('Solar Panels - 12 years replaceable - 25 years life');
    }

    // 2. Solar Inverter Warranty - Uses the user input field
    if (q.inverterQty > 0 && q.inverterWarranty.isNotEmpty) {
      items.add('Inverter - ${q.inverterWarranty} years');
    } else if (q.inverterQty > 0) {
      // Fallback to default if empty
      items.add('Inverter - 3 years');
    }

    // 3. Battery Warranty
    if (q.batteryQty > 0 && q.batteryWarranty.isNotEmpty) {
      items.add('Battery - ${q.batteryWarranty} years');
    } else if (q.batteryQty > 0) {
      items.add('Battery - 5 years');
    }

    // 4. Workmanship Warranty
    if (q.installationUnitPrice > 0) {
      items.add('Workmanship - 2 year');
    }

    return items;
  }

  static final _currency = NumberFormat('#,##0', 'en_US');

  static String formatCurrency(int amount) => _currency.format(amount);
}