# Shipping Calculazor to Zapstore

## 1. Your own release keystore (do this once)

**Do not use the debug keystore for publishing.** Create a keystore only you have and keep it backed up safely.

From the **`calculazor`** directory:

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Use a strong password and remember it. You’ll be asked for name, org, etc.; you can fill something or use defaults.

Create **`calculazor/android/key.properties`** (this file is gitignored; never commit it):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

Replace the two passwords with what you set. The release build will use this; without it, release falls back to the debug keystore (only for local testing).

## 2. Launcher icon

- Put your app icon at **`assets/images/logo.png`** (square, at least 1024×1024 px).
- From the `calculazor` directory run:
  ```bash
  dart run flutter_launcher_icons
  ```
- This generates all Android densities. Rebuild the app to see the new icon.

## 3. Build release APK

```bash
cd calculazor
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## 4. Zapstore (zsp)

- Install zsp: `go install github.com/zapstore/zsp@latest`
- In **`zapstore.yaml`** set `repository` to your real repo URL (e.g. `https://github.com/YourUsername/calculazor`).
- Sign and publish (see [zsp](https://github.com/zapstore/zsp)):
  ```bash
  cd calculazor
  SIGN_WITH=nsec1... zsp publish
  ```
  Or first-time: `zsp publish --wizard`
- When zsp asks for the keystore path, use: **`android/upload-keystore.jks`** (relative to calculazor) or the full path. That links your Nostr identity to your app’s signing key so Zapstore can show verified ownership.
- Optional: add `images:` (screenshots) in `zapstore.yaml` for the store listing.
