# Flutter SDK & Cross-Platform Machine Setup

This guide covers everything needed to set up a development machine for the VibeSwipe Flutter project, including SDK installation, platform tooling, CocoaPods, emulators/simulators, and cache purging for machine migration.

**Note:** The Firebase Emulator is NOT used in this project. The app connects directly to production Firebase.

---

## 1. Version Locking

| Component | Version / Constraint | Source |
|---|---|---|
| Dart SDK | `>=3.0.0 <4.0.0` | `pubspec.yaml` |
| Flutter Channel | `stable` | `.metadata` |
| Flutter Revision | `00b0c91f06209d9e4a41f71b7a512d6eb3b9c694` | `.metadata` |
| Gradle | 8.14 | `android/gradle/wrapper/gradle-wrapper.properties` |
| Android Gradle Plugin | 8.11.1 | `android/settings.gradle.kts` |
| Kotlin | 2.2.20 | `android/settings.gradle.kts` |
| Java Compatibility | 17 (`JavaVersion.VERSION_17`) | `android/app/build.gradle.kts` |
| CocoaPods | 1.16.2 | `ios/Podfile.lock` |
| iOS Deployment Target | 15.0 | `ios/Podfile` |
| macOS Deployment Target | 10.15 | `macos/Podfile` |
| Swift Version | 5.0 | `ios/Runner.xcodeproj/project.pbxproj` |
| Core Library Desugaring | `com.android.tools:desugar_jdk_libs:2.1.4` | `android/app/build.gradle.kts` |

**Note:** This project does NOT use FVM (Flutter Version Management). The `.gitignore` excludes `.fvm/` and `.fvmrc`.

---

## 2. System Dependencies (macOS from Scratch)

### Homebrew & Git

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Git
brew install git
```

### Flutter SDK

```bash
# Download Flutter stable
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Add to PATH (add to ~/.zshrc for persistence)
export PATH="$HOME/flutter/bin:$PATH"

# Reload shell
source ~/.zshrc

# Verify installation
flutter doctor
```

### Python 3.10+

```bash
brew install python@3.10
python3 --version
```

### Java 17 (Required for Android builds)

```bash
brew install openjdk@17

# Add to PATH
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
```

---

## 2B. System Dependencies (Windows from Scratch)

### Git

Download from https://git-scm.com/download/win and install with default options.

### Flutter SDK

1. Download Flutter from https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter` (or your preferred location)
3. Add `C:\flutter\bin` to system PATH
4. Open a new terminal and run:
   ```cmd
   flutter doctor
   ```

### Python 3.10+

1. Download from https://www.python.org/downloads/
2. **Check "Add Python to PATH"** during installation
3. Verify:
   ```cmd
   python --version
   pip --version
   ```

### Java 17 (Required for Android builds)

1. Download from https://adoptium.net/ (Temurin JDK 17)
2. Set `JAVA_HOME` environment variable:
   ```cmd
   setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot"
   ```
3. Or use the helper script: `install-java21.ps1` (in project root)

### Android Studio

1. Download from https://developer.android.com/studio
2. Run installer with default options
3. In SDK Manager, install:
   - Android SDK Platform 34+
   - Android SDK Build-Tools 34+
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools
4. Accept Android licenses:
   ```cmd
   flutter doctor --android-licenses
   ```

### Windows Convenience Scripts

The project includes two scripts in the root directory:

| Script | Purpose |
|---|---|
| `start-web.bat` | Runs `flutter run -d chrome` |
| `run-web.ps1` | PowerShell version of the same |
| `install-java21.ps1` | Java 21 installation guide (for Firebase Emulator) |

---

## 3. Xcode Setup (iOS Development)

### Install Xcode

1. App Store → Search "Xcode" → Install
2. Accept the license:
   ```bash
   sudo xcodebuild -license accept
   ```
3. Install Command Line Tools:
   ```bash
   xcode-select --install
   ```

### Apple Silicon vs Intel Considerations

| Issue | Solution |
|---|---|
| CocoaPods architecture mismatch | Use `arch -x86_64 pod install` from `ios/` directory |
| Flutter build errors on M1/M2/M3 | Flutter stable supports Apple Silicon natively — no Rosetta needed for Flutter itself |
| Java/Gradle architecture issues | Ensure Homebrew packages match your architecture (`/opt/homebrew` for ARM, `/usr/local` for Intel) |

### iOS Simulator Setup

```bash
# List available simulators
xcrun simctl list devices

# Boot a specific simulator
xcrun simctl boot "iPhone 15 Pro"

# Open Simulator app
open -a Simulator
```

Alternatively, use Xcode → Window → Devices and Simulators.

---

## 4. Android SDK Setup

### Install Android Studio

1. Download from https://developer.android.com/studio
2. Run the installer and follow setup wizard
3. In SDK Manager, install:
   - Android SDK Platform 34+
   - Android SDK Build-Tools 34+
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools

### Environment Variables

Add to `~/.zshrc`:

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### Android Emulator Setup

```bash
# List available AVDs (Android Virtual Devices)
emulator -list-avds

# Create a new AVD
avdmanager create avd -n pixel_7 -k "system-images;android-34;google_apis;arm64-v8a"

# Launch emulator
emulator -avd pixel_7
```

Alternatively, use Android Studio → Tools → Device Manager to create and launch emulators.

### Android Build Configuration

From `android/app/build.gradle.kts`:

| Setting | Value |
|---|---|
| Application ID | `com.sliconsystems.vibe_swipe` |
| compileSdk | `flutter.compileSdkVersion` (dynamic) |
| minSdk | `flutter.minSdkVersion` (dynamic) |
| targetSdk | `flutter.targetSdkVersion` (dynamic) |
| Java/Kotlin | 17 / 2.2.20 |
| Core library desugaring | Enabled |
| JVM args | `-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m` |
| Release signing | **Debug keys (not production-ready)** |

### Android Permissions (from `AndroidManifest.xml`)

```xml
CAMERA, READ_EXTERNAL_STORAGE (max SDK 32), READ_MEDIA_IMAGES,
POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, VIBRATE
```

Network security config allows cleartext for `localhost`, `127.0.0.1`, `10.0.2.2` (emulator).

---

## 5. CocoaPods Management (iOS)

### Installation

```bash
# System Ruby (recommended)
sudo gem install cocoapods

# For Apple Silicon architecture issues:
arch -x86_64 sudo gem install cocoapods
```

### Pod Install

```bash
cd ios/

# Standard install
pod install

# If pod install fails, update the repo first
pod repo update
pod install

# For Apple Silicon Macs with architecture issues:
arch -x86_64 pod install
```

### Podfile Configuration

The `ios/Podfile` is configured as:

```ruby
platform :ios, '15.0'
# use_frameworks! is enabled
# post_install enforces IPHONEOS_DEPLOYMENT_TARGET = '15.0' for all pod targets
```

### Key iOS Native Dependencies (from `ios/Podfile.lock`)

| Pod | Version | Purpose |
|---|---|---|
| Firebase/CoreOnly | 12.14.0 | Firebase core |
| Firebase/Messaging | 12.14.0 | Push notifications |
| firebase_core | 4.10.0 | FlutterFire core |
| firebase_messaging | 16.3.0 | FlutterFire messaging |
| flutter_secure_storage_darwin | 10.0.0 | Secure storage |
| permission_handler_apple | 9.3.0 | Permission handling |
| image_picker_ios | 0.0.1 | Camera/gallery |
| path_provider_foundation | 0.0.1 | File paths |
| sqflite_darwin | 0.0.4 | Local database |

---

## 6. Cache Purging Checklist (Machine Migration)

When moving between machines, native build caches cause failures. Run these commands **in order**:

### Full Clean (Recommended for Machine Migration)

```bash
# Step 1: Flutter clean
flutter clean

# Step 2: Remove native build artifacts
rm -rf ios/Pods ios/Podfile.lock
rm -rf android/.gradle android/app/build android/build
rm -rf build/
rm -rf .dart_tool/

# Step 3: Re-fetch Flutter dependencies
flutter pub get

# Step 4: Reinstall CocoaPods (macOS only — required for iOS builds)
cd ios
pod repo update
pod install
cd ..

# Step 5: Rebuild
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run               # Connected device or emulator
```

### Platform-Specific Deep Clean

```bash
# iOS deep clean (macOS only)
cd ios
xcodebuild clean
cd ..
flutter clean

# Android deep clean
cd android
./gradlew clean          # macOS/Linux
# gradlew.bat clean      # Windows
cd ..
flutter clean

# Web (just rebuild — no native artifacts)
flutter clean
flutter run -d chrome
```

### Windows-Specific Clean

```cmd
:: Command Prompt
flutter clean
rmdir /s /q ios\Pods
rmdir /s /q android\.gradle
rmdir /s /q android\app\build
rmdir /s /q android\build
rmdir /s /q build
rmdir /s /q .dart_tool
flutter pub get
```

```powershell
# PowerShell
flutter clean
Remove-Item -Recurse -Force ios\Pods -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\.gradle -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\app\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue
flutter pub get
```

---

## 7. Xcode Certificate Provisioning (iOS)

### Current Configuration (from `project.pbxproj`)

| Setting | Debug | Release | Profile |
|---|---|---|---|
| `CODE_SIGN_IDENTITY` | Apple Development | Apple Distribution | iPhone Distribution |
| `CODE_SIGN_STYLE` | Manual | Manual | Manual |
| `DEVELOPMENT_TEAM` | `37P5TUK792` | `37P5TUK792` | `37P5TUK792` |
| `PROVISIONING_PROFILE_SPECIFIER` | match Development com.vibeswipellc.vibeswipe | match AppStore com.vibeswipellc.vibeswipe | (inherits Release) |
| `PRODUCT_BUNDLE_IDENTIFIER` | `com.vibeswipellc.vibeswipe` | `com.vibeswipellc.vibeswipe` | `com.vibeswipellc.vibeswipe` |
| `SWIFT_VERSION` | 5.0 | 5.0 | 5.0 |
| `TARGETED_DEVICE_FAMILY` | 1,2 (iPhone + iPad) | 1,2 | 1,2 |

### Setup for New Machine

1. Open `ios/Runner.xcodeproj` in Xcode
2. Select the **Runner** target
3. Go to **Signing & Capabilities** tab
4. Verify Team is set to `37P5TUK792`
5. If using fastlane match for code signing:

```bash
cd ios

# Install fastlane (if not installed)
gem install fastlane

# Fetch certificates and provisioning profiles
# Requires MATCH_PASSWORD and MATCH_GIT_URL environment variables
bundle exec fastlane match development
bundle exec fastlane match appstore
```

**Fastlane env vars needed:**
- `MATCH_PASSWORD` — password for the match certificates repo
- `MATCH_GIT_URL` — Git URL for the match certificates repo
- `BUNDLE_ID` — `com.vibeswipellc.vibeswipe`

### IMPORTANT: GoogleService-Info.plist

**This file is MISSING from the repository.** Firebase will fail to initialize on iOS without it.

**How to fix:**

1. Go to https://console.firebase.google.com/
2. Select project: **vibe-swipe-llc**
3. Click the gear icon → **Project settings**
4. Go to **General** tab → scroll to **Your apps**
5. Select the iOS app (`com.vibeswipellc.vibeswipe`)
6. Click **Download GoogleService-Info.plist**
7. Move the downloaded file to `ios/Runner/GoogleService-Info.plist`
8. In Xcode, drag the file into the **Runner** group
9. Ensure "Copy items if needed" is checked
10. Ensure "Add to targets: Runner" is checked

---

## 8. Build & Run Commands

```bash
# Web (fastest for development)
flutter run -d chrome

# macOS native
flutter run -d macos

# iOS Simulator
flutter run -d iPhone

# iOS Physical Device (connect via USB first)
flutter devices              # List available devices
flutter run -d <device-id>

# Android Emulator
flutter run -d android

# Android Physical Device (enable USB debugging first)
flutter run -d <device-id>

# Build release artifacts
flutter build apk            # Android APK
flutter build appbundle      # Android App Bundle
flutter build ios            # iOS (release)
flutter build web            # Web
flutter build macos          # macOS
```

---

## 9. Verification Steps

After setup, verify each item:

- [ ] `flutter doctor` — no critical issues
- [ ] `flutter --version` — shows stable channel, Dart >=3.0.0
- [ ] `flutter pub get` — succeeds without errors
- [ ] `pod install` — succeeds from `ios/` directory (macOS only)
- [ ] `flutter run -d chrome` — app launches in browser
- [ ] `flutter run -d android` — app launches on Android emulator
- [ ] Backend starts — `cd backend && python app.py`
- [ ] App connects to backend at `http://127.0.0.1:8000`
- [ ] App connects to Firebase production (not emulator)

---

## 10. Common Failures & Fixes

| Symptom | Cause | Fix |
|---|---|---|
| `pod install` fails on Apple Silicon | Architecture mismatch | Use `arch -x86_64 pod install` |
| `flutter doctor` shows Xcode issues | CLI tools missing | Run `xcode-select --install` |
| Android build fails with SDK error | Missing SDK components | Open Android Studio → SDK Manager → install missing items |
| `GoogleService-Info.plist not found` | File missing from repo | Download from Firebase Console (see §7) |
| Gradle out of memory | Insufficient JVM heap | Verify `-Xmx8G` in `android/gradle.properties` |
| `Unable to find a suitable Flutter SDK` | PATH not configured | Add `~/flutter/bin` to PATH |
| iOS build fails with provisioning error | Certificates not installed | Use fastlane match or manually install certificates in Xcode |
| `AgoraRTC_N-4.22.0.js` not loading (web) | CDN blocked or offline | Check network; Agora web SDK loaded via CDN in `web/index.html` |
| `flutter run` hangs on "Launching..." | Emulator/simulator not responding | Kill and restart the emulator/simulator |
| `BASE_URL` not found in .env | Missing env var | Add `BASE_URL=http://127.0.0.1:8000` to root `.env` |

---

## 11. iOS Info.plist Permissions

From `ios/Runner/Info.plist`:

| Key | Value |
|---|---|
| `NSCameraUsageDescription` | "Used to capture your profile picture" |
| `NSPhotoLibraryUsageDescription` | "Used to select your profile picture from your photo library" |
| `CFBundleDisplayName` | "Vibe Swipe" |
| `CFBundleName` | "vibe_swipe" |
| Scene manifest | Enabled (single scene, `UIWindowScene`) |
| Supported orientations (iPhone) | Portrait, Landscape Left, Landscape Right |
| Supported orientations (iPad) | All 4 orientations |
