# Solar Quotation App (Flutter)

This app replaces your Excel quotation workbook. It uses the same dropdown lists, calculations, warranty rules, and terms as your file **Quotation to Mobile App.xlsx**, and generates a PDF similar to your sample **SSES-S-3493 Off-Grid 6.16kW.pdf**.

## Structure Designer (phased)

Open the app → **Structure Designer** (Phase 1 is live).

| Phase | Feature | Status |
|-------|---------|--------|
| 1 | Panel catalog, layout, girder/pole BOM | **Done** |
| 2 | 3D preview (realistic panel, girder, pole models) | Planned |
| 3 | Compass, South, tilt | Planned |
| 4 | Roof photo + measurement overlay | Planned |
| 5 | BOM on quotation PDF | Planned |

**Phase 1 rules** (your site formulas):

- Row girder length = `ceil(panel width × panels per row + margin ft)`
- Row girders = `2 × number of rows`
- Pole-to-pole length = `floor(panel length × rows + walkway × (rows − 1))`
- Poles per side = 2 if span ≤ max spacing, else more intermediate poles

Edit panel dimensions in `lib/data/panel_catalog.dart`.  
Calculator: `lib/services/structure_calculator.dart`.

## What the app does

- **Yellow-style fields**: client name, contact, dates, quantities, prices, project description  
- **Blue-style fields**: dropdowns for solar panels, inverter, battery, mounting structure type  
- **Green-style logic**: line totals, grand total, mounting description text, warranty lines  

Tap **Preview & share PDF quotation** to print, save, or share the PDF.

## Cloud sync (panels / inverters / batteries)

Admin CRUD syncs through **Firebase Firestore**. Full setup steps:

**[FIREBASE_SETUP.md](FIREBASE_SETUP.md)**

Quick version:

1. Create Firebase project and Android app (`com.solarquotation.solar_quotation_app`).
2. Save `google-services.json` to `android/app/`.
3. Run `dart run tool/generate_firebase_options.dart`
4. Rebuild APK and install on phones.

## Before you run (one-time setup)

1. Install [Flutter](https://docs.flutter.dev/get-started/install/windows) on Windows.  
2. Open **PowerShell** in this folder: `f:\Cursor\solar_quotation_app`  
3. Run:
   ```powershell
   flutter pub get
   ```

## Add your company logo

1. Save your logo as: `assets/images/company_logo.png`  
2. Recommended size: about 300×200 pixels, PNG with transparent background.  
3. Edit company name and address in `lib/services/pdf_service.dart` (search for `Your Company Name`).

## Run on your PC (Windows)

```powershell
cd f:\Cursor\solar_quotation_app
flutter run -d windows
```

## Run on Android phone

1. Enable **Developer options** and **USB debugging** on the phone.  
2. Connect the phone with USB.  
3. Run:
   ```powershell
   flutter devices
   flutter run
   ```

## Build installable app

**Windows .exe:**
```powershell
flutter build windows
```
Output: `build\windows\x64\runner\Release\`

**Android APK:**
```powershell
flutter build apk --release
```
Output: `build\app\outputs\flutter-apk\app-release.apk`

## Files from your folder

Your original files stay in `f:\Cursor\`:
- `Quotation to Mobile App.xlsx`
- `SSES-S-3493 Off-Grid 6.16kW.pdf`

The Flutter project lives in `f:\Cursor\solar_quotation_app\`.

## Customize later

| What to change | File |
|----------------|------|
| Product dropdown lists | `lib/data/catalog_data.dart` |
| Warranty / total rules | `lib/services/quotation_calculator.dart` |
| PDF layout & letterhead | `lib/services/pdf_service.dart` |
| Form screens | `lib/screens/quotation_form_screen.dart` |
| Panel sizes for structure | `lib/data/panel_catalog.dart` |
| Girder / pole math | `lib/services/structure_calculator.dart` |

If you send your real company name, address, and logo, those can be set permanently in the PDF template.
