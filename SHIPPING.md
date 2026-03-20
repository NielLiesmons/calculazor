# Shipping Calculazor to Zapstore

## 1. Launcher icon

- Put your app icon at **`assets/images/logo.png`** (square, at least 1024×1024 px).
- From the `calculazor` directory run:
  ```bash
  dart run flutter_launcher_icons
  ```
- This generates all Android densities. Rebuild the app to see the new icon.

## 2. Build release APK

```bash
cd calculazor
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## 3. Zapstore (zsp)

- Install zsp: `go install github.com/zapstore/zsp@latest`
- In **`zapstore.yaml`** set `repository` to your real repo URL (e.g. `https://github.com/YourUsername/calculazor`).
- Sign and publish (see [zsp](https://github.com/zapstore/zsp)):
  ```bash
  cd calculazor
  SIGN_WITH=nsec1... zsp publish
  ```
  Or first-time: `zsp publish --wizard`
- Optional: add `images:` (screenshots) in `zapstore.yaml` for the store listing.
