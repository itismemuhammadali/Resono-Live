# VibeSwipe — Environment Transfer Guide

## Project Snapshot

| Field | Value |
|---|---|
| **App Name** | VibeSwipe |
| **Version** | 1.0.0+2 |
| **Dart SDK** | `>=3.0.0 <4.0.0` |
| **Flutter Channel** | stable |
| **Firebase Project** | `vibe-swipe-llc` |
| **Backend** | Python Flask on port 8000 + Firebase Cloud Functions |
| **Platforms** | iOS, Android, Web (primary targets) |
| **State Management** | Riverpod (hooks_riverpod + flutter_hooks) |
| **Routing** | go_router |
| **DI** | GetIt (service locator) |

### Architecture

```
Flutter App (Firebase SDK)
    ├── (file uploads) ──────────> Firebase Storage (direct)
    ├── (auth) ───────────────────> Firebase Auth
    ├── (community/live chat) ───> Cloud Firestore (direct)
    ├── (Agora tokens) ───────────> Firebase Cloud Function: generateAgoraToken
    ├── (Stripe payments) ────────> Firebase Cloud Functions: createPaymentIntent, createCheckoutSession
    ├── (Stripe webhooks) ────────> Firebase Cloud Function: stripeWebhook
    ├── (Access/tip checks) ─────> Firebase Cloud Functions: checkAccess, checkTipStatus
    ├── (Transaction history) ───> Firebase Cloud Function: getTransactionHistory
    └── (User/Post/Chat ops) ────> Python Flask API (:8000)
                                        └──> Firebase Firestore + Auth
```

### Third-Party Services

| Service | Purpose | Config Locations |
|---|---|---|
| Firebase Auth | User authentication | `firebase_options.dart`, `google-services.json`, `serviceAccountKey.json` |
| Cloud Firestore | Database (direct + API) | `firestore.rules`, `firestore.indexes.json` |
| Firebase Storage | File/image/video uploads | `storage.rules` |
| Firebase Cloud Messaging | Push notifications | `AndroidManifest.xml`, `NotificationService` |
| Firebase Cloud Functions | Agora tokens, Stripe payments/webhooks | `functions/src/` |
| Stripe | Payments (test mode) | Firebase secrets (not .env) |
| Agora RTC | Live streaming | Firebase secrets + `assets/.env` (App ID only) |

---

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] Git installed (`git --version`)
- [ ] Flutter SDK stable channel (`flutter --version`)
- [ ] Python 3.10+ (`python --version`)
- [ ] Xcode 15+ (macOS only, for iOS builds)
- [ ] Android Studio (for Android SDK and emulators)
- [ ] Firebase Console access (project: `vibe-swipe-llc`)
- [ ] Stripe Dashboard access (test keys)
- [ ] Agora Console access (App ID + certificate)

---

## Migration Workflow

### Phase 1: Clone & Base Setup

1. Clone the repository
   ```bash
   git clone <repo-url> vibe_swipe
   cd vibe_swipe
   ```

2. Install Flutter SDK (if not already installed)
   - See **[FLUTTER_AND_EMULATORS.md](FLUTTER_AND_EMULATORS.md)** for complete setup

3. Set up the Python backend
   - See **[BACKEND_AND_KEYS.md](BACKEND_AND_KEYS.md)** for complete setup

### Phase 2: Environment Configuration

4. Copy or create the `.env` files (see **[BACKEND_AND_KEYS.md](BACKEND_AND_KEYS.md)** for details)
   - Root `.env` — Flutter app runtime config
   - `assets/.env` — Bundled Flutter asset
   - `backend/.env` — Flask server config

5. Download `GoogleService-Info.plist` for iOS **(REQUIRED — missing from repo)**
   - Firebase Console → Project Settings → iOS app → Download
   - Place in `ios/Runner/GoogleService-Info.plist`

6. Verify `backend/serviceAccountKey.json` exists

### Phase 3: Build & Run

7. Clean and fetch dependencies
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..   # macOS only (required for iOS builds)
   ```

8. Start the backend
   ```bash
   cd backend
   python -m venv .venv
   .venv\Scripts\activate            # Windows
   # source .venv/bin/activate       # macOS/Linux
   pip install -r requirements.txt
   python app.py
   ```

9. Start the Flutter app
   ```bash
   flutter run -d chrome             # Web (fastest for dev)
   flutter run -d macos              # macOS native
   flutter run -d iPhone             # iOS Simulator
   flutter run -d android            # Android Emulator
   flutter run                       # Connected device
   ```

### Phase 4: Verify

10. Backend health check: `curl http://127.0.0.1:8000/health`
11. API docs: http://127.0.0.1:8000/docs
12. Firebase connection — app should load user data
13. Stripe — test payment with card `4242 4242 4242 4242`
14. Agora — live stream should connect

---

## Quick Troubleshooting

| Symptom | Fix |
|---|---|
| `flutter doctor` shows Xcode issues | Run `xcode-select --install` |
| `pod install` fails on Apple Silicon | Use `arch -x86_64 pod install` |
| `ModuleNotFoundError: No module named 'flask'` | Activate the Python virtual environment |
| `GoogleService-Info.plist not found` | Download from Firebase Console (see Phase 2) |
| Android build fails with SDK error | Open Android Studio → SDK Manager → install missing components |
| `StripeAuthenticationError` | Check `STRIPE_SECRET_KEY` in `backend/.env` |
| `AgoraConnectionFailed` | Verify `AGORA_APP_ID` and `AGORA_APP_CERTIFICATE` in `.env` |
| CORS error in browser | Check `CORS_ORIGINS` in `backend/.env` |
| `PYTHON_API_URL unreachable` | Start the backend first, verify port 8000 |
| Gradle out of memory | Verify `-Xmx8G` in `android/gradle.properties` |
| `BASE_URL` not found in .env | Add `BASE_URL=http://127.0.0.1:8000` to root `.env` |

---

## Network Port Reference

For the complete port inventory, port collision troubleshooting, and OS-specific firewall guides, see **[NETWORK_PORTS.md](NETWORK_PORTS.md)**.

Quick reference:

| Service | Port | Config File |
|---|---|---|
| Python Flask API | 8000 | `backend/.env` |
| Flutter Web | Dynamic (auto-assigned) | Flutter CLI |
| Stripe Checkout Fallback | 51311 (hardcoded) | `backend/routes/stripe_payments.py` |
| Firebase Storage CORS | 53529, 5000 | `cors.json` |
| Backend CORS Origins | 53529, 3000, 8080, 50229, 51311 | `backend/.env` |

---

## Detailed Guides

| Document | Covers |
|---|---|
| **[NETWORK_PORTS.md](NETWORK_PORTS.md)** | Port inventory, localhost reference map, OS-specific port collision & firewall resolution (Windows & Mac) |
| **[FLUTTER_AND_EMULATORS.md](FLUTTER_AND_EMULATORS.md)** | SDK versions, Windows & macOS bootstrap, Xcode, Android Studio, CocoaPods, emulators/simulators, cache purging, certificate provisioning |
| **[BACKEND_AND_KEYS.md](BACKEND_AND_KEYS.md)** | Python setup (Windows & Mac), .env files, Firebase, Stripe, Agora, security checklist |

---

## Known Issues

1. **`GoogleService-Info.plist` missing for iOS** — Must be downloaded from Firebase Console manually
2. **`assets/.env` not gitignored** — Contains Agora certificate; secrets are bundled in app binary
3. **macOS bundle ID is placeholder** — Still `com.example.vibeSwipe` in `macos/Runner/Configs/AppInfo.xcconfig`
4. **Android release signing not configured** — Uses debug keys; no `key.properties` file exists
5. **SSL verification disabled** — `lib/src/core/services/network_service/handshake_resolver.dart` accepts all certificates
6. **`BASE_URL` not defined in `.env`** — `api_routes.dart` reads `dotenv.get('BASE_URL')` which will throw at runtime
7. **No CI/CD pipeline** — Only Fastlane for iOS signing (`ios/fastlane/Fastfile`)
8. **Firebase not configured for macOS/Windows/Linux** — `firebase_options.dart` throws `UnsupportedError` on these platforms
