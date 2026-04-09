# Android dev loop (Godot + Android Studio Emulator)

Goal: edit in Godot, deploy/run quickly on an emulator or device **before** committing/PRs.

## Why this repo adds a debug preset

If you have a release-signed APK installed (`com.monarchgame.app`), a debug deploy may fail to replace it (signature mismatch).

This repo provides a second export preset with a separate package id:

- **Release / CI**: `com.monarchgame.app`
- **Dev / Emulator**: `com.monarchgame.app.debug`

That lets you keep both installed and avoid confusion about which build is running.

## Emulator notes (Mac mini M4 / Apple Silicon)

Android Studio typically uses **ARM64** system images on Apple Silicon. This preset also enables **x86_64** so it works if you create an x86_64 AVD.

## Setup

1. Start your AVD in Android Studio.
2. Confirm ADB sees it:

   ```sh
   adb devices
   ```

   You should see `emulator-5554 device`.

3. In Godot:
   - Set Android paths in **Editor Settings → Export → Android** (SDK + JDK).
   - Open **Project → Export…**

## Run / Deploy

In **Project → Export…**, select:

- **Android Debug (Emulator/Dev)** → click **Run**

This installs/updates `com.monarchgame.app.debug` and launches it.

## Common issues

- **Still seeing the old UI / old build**:
  - Ensure you’re running the `*.debug` app (different icon/name), or uninstall the release app:

    ```sh
    adb uninstall com.monarchgame.app
    ```

- **Install fails on emulator**:
  - If you made an x86_64 AVD, ensure the export preset includes x86_64 (it does by default).

