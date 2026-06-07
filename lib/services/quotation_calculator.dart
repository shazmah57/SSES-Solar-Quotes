import 'package:intl/intl.dart';

import '../data/catalog_data.dart';
import '../models/quotation.dart';

class QuotationCalculator {
  static int lineTotalQtyTimesPrice(int qty, int unitPrice) => qty * unitPrice;

  static List<QuotationLine> buildLines(QuotationDraft q) {
    final mountingDesc = CatalogData.mountingDescription(q.mountingType);

    return [
      QuotationLine(
        serialNo: 1,
        item: 'Solar Panels',
        makeDescription: q.panelMake ?? '-',
        quantityLabel: q.panelQty.toString(),
        quantity: q.panelQty,
        unitPrice: q.panelUnitPrice,
        lineTotal: lineTotalQtyTimesPrice(q.panelQty, q.panelUnitPrice),
      ),
      QuotationLine(
        serialNo: 2,
        item: 'Solar Inverter',
        makeDescription: q.inverterMake ?? '-',
        quantityLabel: q.inverterQty.toString(),
        quantity: q.inverterQty,
        unitPrice: q.inverterUnitPrice,
        lineTotal: lineTotalQtyTimesPrice(q.inverterQty, q.inverterUnitPrice),
      ),
      QuotationLine(
        serialNo: 3,
        item: 'Battery',
        makeDescription: q.batteryMake ?? '-',
        quantityLabel: q.batteryQty.toString(),
        quantity: q.batteryQty,
        unitPrice: q.batteryUnitPrice,
        lineTotal: lineTotalQtyTimesPrice(q.batteryQty, q.batteryUnitPrice),
      ),
      QuotationLine(
        serialNo: 4,
        item: q.mountingType,
        makeDescription: mountingDesc,
        quantityLabel: q.mountingQty.toString(),
        quantity: q.mountingQty,
        unitPrice: q.mountingUnitPrice,
        lineTotal: lineTotalQtyTimesPrice(q.mountingQty, q.mountingUnitPrice),
      ),
      QuotationLine(
        serialNo: 5,
        item:
            'Balance of System (AC Cables & DC Cables, SPDs, Circuit Breakers, PVC pipes & Allied Accessories)',
        makeDescription: CatalogData.balanceOfSystemDescription,
        quantityLabel: 'Est',
        unitPrice: q.bosUnitPrice,
        lineTotal: q.bosUnitPrice,
      ),
      QuotationLine(
        serialNo: 6,
        item: 'Installation & Transport',
        makeDescription: '---',
        quantityLabel: '1 Job',
        unitPrice: q.installationUnitPrice,
        lineTotal: q.installationUnitPrice,
      ),
    ];
  }

  static int grandTotal(QuotationDraft q) {
    return buildLines(q).fold(0, (sum, line) => sum + line.lineTotal);
  }

  /// Warranty rules copied from your Excel formulas.
  static List<String> warranties(QuotationDraft q) {
    final items = <String>[];

    if (q.panelQty > 0) {
      items.add('Solar Panels- 12 years replaceable- 25 years life');
    }

    final inverter = q.inverterMake ?? '';
    if (inverter.isEmpty || q.inverterQty == 0) {
      items.add('Inverter - 0');
    } else {
      final lower = inverter.toLowerCase();
      if (lower.contains('ip66')) {
        items.add('Inverter- 5 years');
      } else if (lower.contains('ip54')) {
        items.add('Inverter- 3 years');
      }
    }

    if ((q.batteryMake ?? '').isEmpty || q.batteryQty == 0) {
      items.add('Battery - 0');
    } else {
      items.add('Battery - 5 years');
    }

    if (q.installationUnitPrice > 0) {
      items.add('Workmanship - 2 year');
    }

    return items;
  }

  static final _currency = NumberFormat('#,##0', 'en_US');

  static String formatCurrency(int amount) => _currency.format(amount);
}
