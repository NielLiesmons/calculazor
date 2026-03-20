# Publishing Calculazor

## App icon (Android and general)

- **Android**: The launcher icon is set in **`android/app/src/main/res/`** via the `mipmap-*` folders. The manifest references it as `android:icon="@mipmap/ic_launcher"`.
  - **Option A (recommended)**  
    Use [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons). Add it under `dev_dependencies` in `pubspec.yaml`, then in `pubspec.yaml`:
    ```yaml
    flutter_launcher_icons:
      android: true
      image_path: "assets/icon/app_icon.png"
    ```
    Use a **1024×1024 PNG** as `assets/icon/app_icon.png`, then run:
    ```bash
    dart run flutter_launcher_icons
    ```
    This generates all `mipmap-*` densities and keeps Android happy.
  - **Option B (manual)**  
    Put `ic_launcher.png` in each density folder:
    - `res/mipmap-mdpi/` (48×48)
    - `res/mipmap-hdpi/` (72×72)
    - `res/mipmap-xhdpi/` (96×96)
    - `res/mipmap-xxhdpi/` (144×144)
    - `res/mipmap-xxxhdpi/` (192×192)  
    After changing icons, run `flutter clean` and rebuild.

- **iOS** (when you add it): Use the same `flutter_launcher_icons` config with `ios: true`, or set icons in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.

## Zapstore (zsp)

This project is set up for [zsp](https://github.com/zapstore/zsp).

1. **Edit `zapstore.yaml`**  
   Set `repository` to your real repo URL (e.g. `https://github.com/yourname/calculazor`).

2. **Build the APK**
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`.

3. **Publish**
   ```bash
   SIGN_WITH=nsec1... zsp publish
   ```
   Or use the wizard: `zsp publish --wizard`.  
   Other options: `SIGN_WITH=bunker://...` or `SIGN_WITH=browser` (NIP-07).

4. **Optional**: To publish from GitHub Releases instead of a local file, set `release_source` in `zapstore.yaml` to your release asset URL (or use the repo and let zsp fetch from GitHub releases).

## Smaller APK size

- **Per-ABI APK (smaller per-file size)**  
  Build one APK per architecture (zsp prefers arm64-v8a):
  ```bash
  flutter build apk --release --split-per-abi
  ```
  Then use `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` or `app-arm64-v8a-release.apk` in `release_source` or upload the arm64 one to GitHub Releases.

- **Release build**  
  This project has `isMinifyEnabled = true` and `isShrinkResources = true` in `android/app/build.gradle.kts` for the release build to reduce size.

- **Trim dependencies**  
  Remove any unused packages from `pubspec.yaml` so the tree stays small.
