# Scan No Ads

A free, no-ads, no-watermark, offline document scanner for Android. Built with
Flutter. Part of the **365 Days App Challenge · Day 3** by
**Ir. Riovan Styx Roring** (Institut Teknologi Kalimantan).

## Download

- **Latest APK (install on Android):** https://github.com/hostingrakyat/ScanNoAds/releases/latest/download/ScanNoAds-release.apk
- **Latest AAB (Google Play upload):** https://github.com/hostingrakyat/ScanNoAds/releases/latest/download/ScanNoAds-release.aab
- All builds: https://github.com/hostingrakyat/ScanNoAds/releases

## Features

- Camera capture with automatic edge detection and document cropping (ML Kit)
- Manual corner adjustment after capture
- Image enhancement: Auto, Grayscale, Black & White, Original
- Multi-page scanning combined into a single PDF
- Save as PDF or JPG
- Share / open in other apps
- Recent scans list on the home screen
- English 🇺🇸 / Bahasa Indonesia 🇮🇩 language picker
- Material 3 design, light & dark themes
- 100% offline. No ads. No tracking.

## Tech stack

- Flutter 3.24.5, Dart 3.5
- Android Gradle Plugin 8.6.1, Gradle 8.7, Kotlin 1.9.24
- compileSdk 35, targetSdk 35, minSdk 21
- Repositories: `google()` and `mavenCentral()` only

Key packages: `cunning_document_scanner`, `image`, `pdf`, `share_plus`,
`path_provider`, `shared_preferences`, `permission_handler`, `url_launcher`.

## Building (GitHub Actions)

Builds run entirely in CI — no local toolchain required.

1. **Generate a signing keystore (once):** run the **Generate Keystore**
   workflow manually (Actions tab → Generate Keystore → Run workflow). Copy the
   four values from the job summary into repository secrets:
   `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`.
2. **Build APK + AAB:** the **Build APK & AAB** workflow runs on every push and
   can be triggered manually. It produces a signed APK and AAB, uploads them as
   artifacts, and publishes a GitHub Release. If no keystore secrets are set the
   build falls back to debug signing so it still succeeds.

Outputs:
- `ScanNoAds-release.apk` — install directly on a device
- `ScanNoAds-release.aab` — for Google Play

## Credits

Created by: **Ir. Riovan Styx Roring**
- TikTok: https://www.tiktok.com/@ir.riovansroring
- Instagram: https://www.instagram.com/ir.riovansroring/
- YouTube: https://youtube.com/@ir.riovanroring
