import '../models/panel_spec.dart';

/// Panel dimensions for structure design (edit to match your stock).
class PanelCatalog {
  PanelCatalog._();

  static const panels = <PanelSpec>[
    PanelSpec(
      id: 'longi_640',
      label: 'Longi Himo x10 640–650W',
      wattMin: 640,
      wattMax: 650,
      widthFt: 3.45,
      lengthFt: 7.35,
    ),
    PanelSpec(
      id: 'bifacial_700',
      label: 'Trina/Jinko Bifacial 700–730W',
      wattMin: 700,
      wattMax: 730,
      widthFt: 3.5,
      lengthFt: 7.5,
    ),
    PanelSpec(
      id: 'trina_700',
      label: 'Trina Bifacial 700–730W',
      wattMin: 700,
      wattMax: 730,
      widthFt: 3.5,
      lengthFt: 7.5,
    ),
    PanelSpec(
      id: 'jinko_700',
      label: 'Jinko Bifacial 700–730W',
      wattMin: 700,
      wattMax: 730,
      widthFt: 3.5,
      lengthFt: 7.5,
    ),
    PanelSpec(
      id: 'aiko_770',
      label: 'Aiko Bifacial 770W',
      wattMin: 770,
      wattMax: 770,
      widthFt: 3.55,
      lengthFt: 7.6,
    ),
  ];

  static PanelSpec get defaultPanel => panels[1];

  static PanelSpec? byId(String id) {
    for (final p in panels) {
      if (p.id == id) return p;
    }
    return null;
  }
}
