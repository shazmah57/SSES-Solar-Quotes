# Firebase setup for SSES Solar Quotes

This app syncs panels, inverters, batteries, and appliance wattages through **Cloud Firestore**.  
All changes are scoped to `solar_quotation_app` only.

## 1. Create Firebase project

1. Open [Firebase Console](https://console.firebase.google.com).
2. **Add project** (e.g. `sses-solar-quotes`).
3. Enable **Cloud Firestore** → create database → start in **test mode** (or production with the rules file below).

## 2. Register Android app

1. In the project, click **Add app** → **Android**.
2. **Android package name** (must match exactly):

   `com.solarquotation.solar_quotation_app`

3. Download **`google-services.json`**.
4. Copy it to:

   `f:\Cursor\solar_quotation_app\android\app\google-services.json`

   (Do not commit this file to public repos if the repo is shared.)

## 3. Generate Flutter Firebase options

In PowerShell:

```powershell
cd f:\Cursor\solar_quotation_app
dart run tool/generate_firebase_options.dart
```

This writes `lib/firebase_options.dart` from your `google-services.json`.

## 4. Deploy Firestore rules (recommended)

Install Firebase CLI once: https://firebase.google.com/docs/cli

```powershell
npm install -g firebase-tools
firebase login
cd f:\Cursor\solar_quotation_app
firebase use --add
firebase deploy --only firestore:rules
```

Rules file: `firestore.rules` (allows read/write for catalog collections during setup).

## 5. Build and install on phone

```powershell
cd f:\Cursor\solar_quotation_app
flutter pub get
flutter build apk --release
```

Install the APK on both phones. On first launch with Firebase configured:

- The app **seeds** default panels, inverters, batteries, and appliances into Firestore if collections are empty.
- Admin panel (long-press app title → PIN `7744`) should show **connected** and allow CRUD.
- Changes on one phone appear on the other within seconds.

## Troubleshooting

| Symptom | Fix |
|--------|-----|
| Admin says cloud not connected | Ensure `google-services.json` exists and you ran `dart run tool/generate_firebase_options.dart` |
| Permission denied on write | Deploy `firestore.rules` or use test mode in console |
| Empty dropdowns after connect | Open app once online; seed runs automatically when Firestore is empty |
| Wrong package name | Firebase Android app package must be `com.solarquotation.solar_quotation_app` |

## Optional: FlutterFire CLI

Instead of step 3, you can use:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

That also generates `lib/firebase_options.dart` (overwrite is fine).
