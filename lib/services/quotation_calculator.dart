import 'package:intl/intl.dart';

import '../data/catalog_data.dart';
import '../models/quotation.dart';
import 'admin_data_service.dart';

class QuotationCalculator {
  static int lineTotalQtyTimesPrice(int qty, int unitPrice) => qty * unitPrice;

  static List<QuotationLine> buildLines(QuotationDraft q) {
    final mountingDesc = CatalogData.mountingDescription(q.mountingType);

    // Build all lines first (only if they have values)
    final List<QuotationLine> allLines = [];

    // 1. Solar Panels (only if qty > 0)
    if (q.panelQty > 0) {
      allLines.add(
        QuotationLine(
          serialNo: 0,
          item: 'Solar Panels',
          makeDescription: q.panelMake ?? '-',
          quantityLabel: q.panelQty.toString(),
          quantity: q.panelQty,
          unitPrice: q.panelUnitPrice,
          lineTotal: lineTotalQtyTimesPrice(q.panelQty, q.panelUnitPrice),
        ),
      );
    }

    // 2. Solar Inverter (only if qty > 0)
    if (q.inverterQty > 0) {
      allLines.add(
        QuotationLine(
          serialNo: 0,
          item: 'Solar Inverter',
          makeDescription: q.inverterMake ?? '-',
          quantityLabel: q.inverterQty.toString(),
          quantity: q.inverterQty,
          unitPrice: q.inverterUnitPrice,
          lineTotal: lineTotalQtyTimesPrice(q.inverterQty, q.inverterUnitPrice),
        ),
      );
    }

    // 3. Battery (only if qty > 0)
    if (q.batteryQty > 0) {
      allLines.add(
        QuotationLine(
          serialNo: 0,
          item: 'Battery',
          makeDescription: q.batteryMake ?? '-',
          quantityLabel: q.batteryQty.toString(),
          quantity: q.batteryQty,
          unitPrice: q.batteryUnitPrice,
          lineTotal: lineTotalQtyTimesPrice(q.batteryQty, q.batteryUnitPrice),
        ),
      );
    }

    // 4. Mounting Structure (only if qty > 0)
    if (q.mountingQty > 0) {
      allLines.add(
        QuotationLine(
          serialNo: 0,
          item: q.mountingType,
          makeDescription: mountingDesc,
          quantityLabel: q.mountingQty.toString(),
          quantity: q.mountingQty,
          unitPrice: q.mountingUnitPrice,
          lineTotal: lineTotalQtyTimesPrice(q.mountingQty, q.mountingUnitPrice),
        ),
      );
    }

// 5. Balance of System (only if price > 0)
if (q.bosUnitPrice > 0) {
  // Get BOS description from service using bosId
  String bosDescription = CatalogData.balanceOfSystemDescription;
  
  if (q.bosId != null && q.bosId!.isNotEmpty) {
    final bosRecord = AdminDataService.instance.activeBosRecords
        .where((r) => r.id == q.bosId)
        .firstOrNull;
    if (bosRecord != null) {
      bosDescription = bosRecord.description;
    }
  } else {
    // If no bosId selected, use the first active BOS
    final firstBos = AdminDataService.instance.activeBosRecords.firstOrNull;
    if (firstBos != null) {
      bosDescription = firstBos.description;
    }
  }
  
  // Replace newlines with \n for proper display in PDF
  // The description already has \n characters from the input
  
  allLines.add(
    QuotationLine(
      serialNo: 0,
      item: 'Balance of System',
      makeDescription: bosDescription,  // Contains \n for line breaks
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

    if (q.panelQty > 0) {
      items.add('Solar Panels- 12 years replaceable- 25 years life');
    }

    final inverter = q.inverterMake ?? '';
    if (inverter.isNotEmpty && q.inverterQty > 0) {
      final lower = inverter.toLowerCase();
      if (lower.contains('ip66')) {
        items.add('Inverter- 5 years');
      } else if (lower.contains('ip54')) {
        items.add('Inverter- 3 years');
      }
    }

    // Battery warranty - only if battery qty > 0
    if (q.batteryQty > 0) {
      final warrantyText = q.batteryWarranty.trim().isEmpty 
          ? 'Battery - 5 years' 
          : 'Battery - ${q.batteryWarranty.trim()} years';
      items.add(warrantyText);
    }

    if (q.installationUnitPrice > 0) {
      items.add('Workmanship - 2 year');
    }

    return items;
  }

  static final _currency = NumberFormat('#,##0', 'en_US');

  static String formatCurrency(int amount) => _currency.format(amount);
}