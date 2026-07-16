# Backend, API Keys & Service Configuration

This guide covers the Python Flask backend setup, Firebase Cloud Functions, all third-party service configurations (Firebase, Stripe, Agora), environment variable management, and security practices for the VibeSwipe project.

---

## 1. Architecture Overview

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

### Service Ports

| Service | Port | URL |
|---|---|---|
| Python API | 8000 | http://127.0.0.1:8000 |
| API Docs (Swagger) | 8000 | http://127.0.0.1:8000/docs |
| Firebase Cloud Functions | N/A | Auto-deployed to Firebase |

### What Runs Where

| Operation | Runs On | Why |
|---|---|---|
| Agora token generation | Cloud Functions | Secrets stay in Firebase, not on disk |
| Stripe webhook handling | Cloud Functions | Raw body verification, secure |
| Stripe payment intents | Cloud Functions | Stripe secret key stays in Firebase |
| Stripe checkout sessions | Cloud Functions | Stripe secret key stays in Firebase |
| Access/tip checks | Cloud Functions | Direct Firestore read, no server needed |
| Transaction history | Cloud Functions | Direct Firestore read, no server needed |
| User CRUD, profiles | Python Backend | Complex business logic |
| Posts, feed, swipes | Python Backend | Complex business logic |
| Discussions, replies | Python Backend | Complex business logic |
| Real-time chat | Python Backend | Complex business logic |
| Performance management | Python Backend | Complex business logic |
| Search, trending | Python Backend | Complex business logic |
| Notifications | Python Backend | Complex business logic |
| Artist dashboard | Python Backend | Complex business logic |

---

## 2. Python Backend Setup

**Note:** The Python backend is still required for User, Post, Discussion, Chat, Performance, Search, Notification, and Artist operations. However, Stripe and Agora operations have been migrated to Firebase Cloud Functions — the Python backend is NO LONGER needed for payments or live streaming tokens.

### Prerequisites

- Python 3.10+
- pip (Python package manager)

### Virtual Environment Setup

**Windows:**
```cmd
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
pip list
```

**macOS/Linux:**
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip list
```

### Backend Dependencies (`backend/requirements.txt`)

| Package | Version | Purpose |
|---|---|---|
| flask | 3.1.1 | Web framework |
| flask-cors | 5.0.1 | Cross-origin resource sharing |
| firebase-admin | 7.1.0 | Firebase Admin SDK (Firestore, Auth) |
| python-dotenv | 1.1.0 | Load .env files |
| gunicorn | 23.0.0 | Production WSGI server |
| agora-token-builder | 1.0.0 | Agora RTC token generation |
| stripe | >=11.0.0 | Stripe payment processing |

### Start the Backend

```bash
cd backend

# Activate virtual environment
.venv\Scripts\activate            # Windows
# source .venv/bin/activate       # macOS/Linux

# Start development server
python app.py
```

### Health Check

```bash
curl http://127.0.0.1:8000/health
# Expected: {"status": "healthy"}
```

### API Documentation

Once running, visit http://127.0.0.1:8000/docs for Swagger API documentation.

### Stripe Operations (Migrated to Cloud Functions)

**Note:** Stripe operations (payment intents, checkout sessions, webhooks, access checks, tip checks, transaction history) have been migrated to Firebase Cloud Functions. The Python backend's `backend/routes/stripe_payments.py` is now **legacy code** — it still exists but is no longer called by the Flutter app.

The Cloud Functions handle:
- `createPaymentIntent` — Creates Stripe PaymentIntent
- `createCheckoutSession` — Creates Stripe Checkout Session
- `stripeWebhook` — Handles Stripe webhook events
- `checkAccess` — Checks if user has paid access
- `checkTipStatus` — Checks if user has tipped an artist
- `getTransactionHistory` — Gets artist transaction history

See **[§19. Firebase Cloud Functions](#19-firebase-cloud-functions-agora--stripe)** for deployment and configuration details.

For the complete port inventory, see **[NETWORK_PORTS.md](NETWORK_PORTS.md)**.

---

## 3. Environment Variable Files — Overview

| File | Purpose | Loaded By | Gitignored? |
|---|---|---|---|
| `.env` (root) | Flutter app runtime config | `flutter_dotenv` in `main.dart` | Yes |
| `assets/.env` | Bundled Flutter asset config | `flutter_dotenv` via `pubspec.yaml` | **No** |
| `backend/.env` | Flask server config | `python-dotenv` in `config.py` | Yes |
| `backend/.env.production` | Production backend config | `python-dotenv` (manual) | Yes |
| `backend/.env.example` | Template for new developers | Reference only | No |

### CRITICAL: Security Warning

- `backend/serviceAccountKey.json` — present on disk, gitignored, contains full GCP service account credentials
- `assets/.env` — **NOT gitignored** and is bundled into the Flutter app binary. Contains Agora App ID (no certificate — that's in Firebase secrets now).
- Stripe secrets (`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`) are stored in Firebase secrets, NOT in `.env` files
- Agora certificate (`AGORA_APP_CERTIFICATE`) is stored in Firebase secrets, NOT in `.env` files
- All Stripe keys in the project are **test mode** (`pk_test_*`, `sk_test_*`) — must rotate before production

---

## 4. Root `.env` (Flutter App)

**Location:** Project root `.env`

```env
# Firebase Production Configuration
FIREBASE_PROJECT_ID=vibe-swipe-llc

# Python API Middle Layer (for User/Post/Chat/Performance ops only)
PYTHON_API_URL=http://127.0.0.1:8000

# Agora RTC Configuration
AGORA_APP_ID=88eca28baa1f457fa1d05bcf58f9dfec
AGORA_CHANNEL_NAME=live-stream-test
AGORA_TEMP_TOKEN=007eJxTYJD0ZaqMKGs9IbVgguDsy4eYDr5SzmZU2mChfsPgy4SEgMkKDBYWqcmJRhZJiYmGaSam5mmJhikGpknJaaYWaZYpaanJWd88shoCGRlaKs6xMDJAIIgvwJCTWZaqW1xSlJqYq1uSWlzCwAAAgk4j2g==
AGORA_TEST_MODE=false
```

### Variable Reference

| Variable | Purpose | Used By |
|---|---|---|
| `FIREBASE_PROJECT_ID` | Firebase project identifier | `firebase_options.dart` |
| `PYTHON_API_URL` | Backend API base URL (User/Post/Chat only) | `PythonApiService` |
| `AGORA_APP_ID` | Agora application identifier | `AgoraService` (for engine init) |
| `AGORA_CHANNEL_NAME` | Default Agora channel | `AgoraService` |
| `AGORA_TEMP_TOKEN` | Pre-generated test token | `AgoraService` (optional) |
| `AGORA_TEST_MODE` | Enable Agora test mode | `AgoraService` |

### Removed from .env (Now in Firebase Secrets)

| Variable | Location | Why |
|---|---|---|
| `STRIPE_PUBLISHABLE_KEY` | Removed | Stripe is now handled by Cloud Functions |
| `AGORA_APP_CERTIFICATE` | Firebase Secret | Sensitive — stored in `firebase functions:secrets` |

### IMPORTANT: Missing `BASE_URL`

The file `lib/src/core/services/network_service/routes/api_routes.dart` reads:
```dart
static String get baseUrl => dotenv.get('BASE_URL');
```

This variable is **NOT defined** in any `.env` file. You must add it:
```env
BASE_URL=http://127.0.0.1:8000
```

Without this, the legacy `ApiService` (used for some routes) will throw at runtime.

---

## 5. `assets/.env` (Bundled Flutter Asset)

**Location:** `assets/.env`

```env
# Firebase Production Configuration
FIREBASE_PROJECT_ID=vibe-swipe-llc

# Python API Middle Layer (for User/Post/Chat ops only)
PYTHON_API_URL=http://127.0.0.1:8000

# Agora RTC Configuration
AGORA_APP_ID=88eca28baa1f457fa1d05bcf58f9dfec
AGORA_CHANNEL_NAME=live-stream-test
AGORA_TEMP_TOKEN=007eJxTYJD0ZaqMKGs9IbVggu...
```

**Note:** `assets/.env` does NOT include `AGORA_TEST_MODE` (only the root `.env` has it).

- Referenced in `pubspec.yaml` under `assets:`
- Bundled into the Flutter app at build time
- Contains Agora App ID only (certificate is now in Firebase secrets)

---

## 6. Backend `.env`

**Location:** `backend/.env`

**Note:** Stripe and Agora certificate have been migrated to Firebase Cloud Functions. The backend `.env` no longer needs these keys for the Flutter app (though the legacy Python Stripe routes still reference them).

```env
FIREBASE_PROJECT_ID=vibe-swipe-llc
GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json
HOST=0.0.0.0
PORT=8000
DEBUG=false
CORS_ORIGINS=http://localhost:53529,http://localhost:3000,http://localhost:8080,http://127.0.0.1:53529,http://localhost:50229,http://localhost:51311

# Legacy — only needed if running the old Python Stripe routes
# (Flutter app no longer calls these)
# STRIPE_SECRET_KEY=sk_test_...
# STRIPE_WEBHOOK_SECRET=whsec_...
# AGORA_APP_ID=...
# AGORA_APP_CERTIFICATE=...
# PLATFORM_FEE_PERCENT=15
```

### Variable Reference

| Variable | Purpose | Notes |
|---|---|---|
| `FIREBASE_PROJECT_ID` | Firebase project identifier | |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to Firebase Admin SDK key | Relative to `backend/` directory |
| `HOST` | Server bind address | `0.0.0.0` for all interfaces |
| `PORT` | Server port | 8000 |
| `DEBUG` | Flask debug mode | `false` for production |
| `CORS_ORIGINS` | Allowed CORS origins | Comma-separated list |
| `PLATFORM_FEE_PERCENT` | Platform fee on payments | 15% (configurable) |

---

## 7. Backend `.env.production`

**Location:** `backend/.env.production`

```env
FIREBASE_PROJECT_ID=vibe-swipe-llc
GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json
HOST=0.0.0.0
PORT=8000
DEBUG=false
CORS_ORIGINS=https://your-production-domain.com
```

**Note:** Minimal template — Stripe and Agora keys must be added before production deployment.

---

## 8. Backend `.env.example`

**Location:** `backend/.env.example`

Template for new developers. Contains only Firebase config, server settings, and CORS origins — no secrets.

---

## 9. Firebase Configuration

### Firebase Project Details

| Field | Value |
|---|---|
| Project ID | `vibe-swipe-llc` |
| Auth Domain | `vibe-swipe-llc.firebaseapp.com` |
| Storage Bucket | `vibe-swipe-llc.firebasestorage.app` |
| Project Number | `367306858996` |

### Firebase Services Used

| Service | Purpose | Packages |
|---|---|---|
| Firebase Auth | User authentication | `firebase_auth` |
| Cloud Firestore | Primary database | `cloud_firestore` |
| Firebase Storage | File/image/video uploads | `firebase_storage` |
| Firebase Cloud Messaging | Push notifications | `firebase_messaging` |

### Firebase Configuration Files

| File | Location | Status |
|---|---|---|
| `firebase.json` | Project root | Present |
| `.firebaserc` | Project root | Present |
| `firebase_options.dart` | `lib/` | Present (FlutterFire CLI generated) |
| `google-services.json` | `android/app/` | Present |
| `GoogleService-Info.plist` | `ios/Runner/` | **MISSING** |
| `serviceAccountKey.json` | `backend/` | Present (gitignored) |
| `firestore.rules` | Project root | Present (139 lines) |
| `firestore.indexes.json` | Project root | Present (5 composite indexes) |
| `storage.rules` | Project root | Present (38 lines) |
| `database.rules.json` | Project root | Present (RTDB rules) |

### Firebase App IDs (from `firebase_options.dart`)

| Platform | App ID | API Key |
|---|---|---|
| Android | `1:367306858996:android:527dede5a1759419fc59a1` | `AIzaSyCKH-WWt_6KzINZmLfrfpZE3fHY0-nSjm0` |
| iOS | `1:367306858996:ios:5f35fb461fda99e2fc59a1` | `AIzaSyCYYmCm1tvyTxcBPPMSTS5daB6SJmGNgBk` |
| Web | `1:367306858996:web:9ac6de36516b8373fc59a1` | `AIzaSyAUbhkOuEylNRaMIofE23Q7JQZ5FU8FOaA` |
| macOS | **Not configured** | Throws `UnsupportedError` |
| Windows | **Not configured** | Throws `UnsupportedError` |
| Linux | **Not configured** | Throws `UnsupportedError` |

### How to Get `GoogleService-Info.plist` (iOS)

1. Go to https://console.firebase.google.com/
2. Select project: **vibe-swipe-llc**
3. Click the gear icon → **Project settings**
4. Go to **General** tab → scroll to **Your apps**
5. Select the iOS app (`com.vibeswipellc.vibeswipe`)
6. Click **Download GoogleService-Info.plist**
7. Place the file at `ios/Runner/GoogleService-Info.plist`
8. In Xcode, drag the file into the **Runner** group
9. Ensure "Copy items if needed" is checked
10. Ensure "Add to targets: Runner" is checked

### Firebase Admin SDK (Backend)

Configured in `backend/firebase_config.py`:
- Uses `GOOGLE_APPLICATION_CREDENTIALS` environment variable
- Points to `backend/serviceAccountKey.json`
- Provides `get_firestore_client()` and `verify_firebase_token()` functions
- Gracefully falls back to project-only init if service account key is missing

### Firestore Collections

| Collection | Purpose | Subcollections |
|---|---|---|
| `users` | User profiles | `swipes` |
| `performances` | Live performances | `viewers`, `likes`, `saves`, `views`, `chats` |
| `community_posts` | Community posts | `comments` |
| `posts` | User posts | `comments`, `likes` |
| `discussions` | Discussion threads | `replies` |
| `chats` | Chat rooms | `messages` |
| `notifications` | User notifications | — |
| `otp_verifications` | OTP verification codes | — |
| `preferences` | User preferences | — |

### Firestore Composite Indexes (from `firestore.indexes.json`)

| Collection | Fields | Query Scope |
|---|---|---|
| performances | artist_id + createdAt | Collection |
| performances | artist_id + scheduled_at | Collection |
| performances | status + scheduled_at | Collection |
| posts | author_id + created_at | Collection |
| discussions | category + created_at | Collection |

---

## 10. Stripe Configuration

### Keys Overview

| Key Type | Prefix | Location | Exposed? |
|---|---|---|---|
| Publishable Key | `pk_test_*` | `.env` (root), `assets/.env` | Yes (client-side, safe) |
| Secret Key | `sk_test_*` | `backend/.env` | **No** (server-only) |
| Webhook Secret | `whsec_*` | `backend/.env` | **No** (server-only) |

### Current Mode

All keys are **test mode**. Must rotate to production keys (`pk_live_*`, `sk_live_*`) before launch.

### Stripe Integration Points

**Flutter (client-side):**
- `lib/src/core/services/stripe_service.dart` (265 lines)
- Web flow: Creates checkout session, opens URL in in-app browser
- Native flow: Creates PaymentIntent, presents payment sheet
- Sends Firebase Auth Bearer tokens for authenticated requests
- Uses `PYTHON_API_URL` from `.env`

**Backend (server-side):**
- `backend/routes/stripe_payments.py` (484 lines)

### Stripe API Endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/stripe/create-payment-intent` | Create a PaymentIntent (tips and paid_access) |
| POST | `/stripe/confirm-payment` | Confirm payment and record transaction |
| GET | `/stripe/check-access/<user_id>/<performance_id>` | Check paid access |
| GET | `/stripe/check-tip-status/<user_id>/<artist_id>` | Check if user has tipped artist |
| GET | `/stripe/transaction-history/<artist_id>` | Transaction history with gross/fees/net |
| POST | `/stripe/create-checkout-session` | Stripe Checkout Session (web flow) |
| POST | `/stripe/checkout-complete` | Complete checkout after redirect |
| POST | `/stripe/webhook` | Webhook handler for payment events |

### Stripe Webhook Setup

1. Go to https://dashboard.stripe.com/webhooks
2. Click **Add endpoint**
3. Enter URL: `http://<your-server>:8000/stripe/webhook`
4. Select events:
   - `checkout.session.completed`
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
5. Copy the **Signing secret** → set as `STRIPE_WEBHOOK_SECRET` in `backend/.env`

### Test Card Numbers (from `INSTRUCTIONS.md`)

| Card | Number | Behavior |
|---|---|---|
| Visa | `4242 4242 4242 4242` | Succeeds |
| Visa (debit) | `4000 0566 5566 5556` | Succeeds |
| Mastercard | `5555 5555 5555 4444` | Succeeds |
| Declined | `4000 0000 0000 0002` | Declined |
| Insufficient funds | `4000 0000 0000 9995` | Declined |

Use any future expiry date (e.g. 12/34), any 3-digit CVC, and any postal code.

---

## 11. Agora Configuration

### Keys

| Variable | Locations |
|---|---|
| `AGORA_APP_ID` = `88eca28baa1f457fa1d05bcf58f9dfec` | `.env`, `assets/.env`, `backend/.env` |
| `AGORA_APP_CERTIFICATE` = `79762512424c48a89b4acdf0b63bbd85` | `.env`, `assets/.env`, `backend/.env` |
| `AGORA_CHANNEL_NAME` = `live-stream-test` | `.env` |
| `AGORA_TEST_MODE` = `false` | `.env` only |

### Agora Console

1. Go to https://console.agora.io/
2. Select or create project
3. Copy **App ID** and **App Certificate**
4. Update values in all three `.env` files if regenerating

### Agora Integration Points

**Flutter (client-side):**
- `lib/src/core/services/agora_service.dart` (272 lines)
- Uses `agora_rtc_engine` package (v6.1.0)
- Token refresh: auto-refreshes 5 minutes before expiry (300s buffer)
- Supports publisher (broadcaster) and subscriber (audience) roles
- Test mode: uses null tokens (no backend needed)

**Backend (server-side):**
- `backend/routes/agora.py` (59 lines)
- `POST /agora/token` — generates Agora RTC tokens
- Uses `agora-token-builder` package
- Token expiry: 3600 seconds (1 hour)
- Subscriber role verifies payment access against Firestore `performances` collection

**Web:**
- CDN-loaded in `web/index.html`:
  - `AgoraRTC_N-4.22.0.js`
  - `iris-web-rtc_n450_w4220_0.8.6.js`

---

## 12. Backend Route Summary

| Blueprint | Prefix | File | Purpose |
|---|---|---|---|
| `users_bp` | `/users` | `backend/routes/users.py` | User CRUD, profiles, follow, library |
| `posts_bp` | `/posts` | `backend/routes/posts.py` | Post creation, feed, swipes, likes |
| `discussions_bp` | `/discussions` | `backend/routes/discussions.py` | Discussion threads, replies |
| `chat_bp` | `/chat` | `backend/routes/chat.py` | Real-time chat |
| `performances_bp` | `/performances` | `backend/routes/performances.py` | Live performance management |
| `search_bp` | `/search` | `backend/routes/search.py` | Search users, trending genres/artists |
| `notifications_bp` | `/notifications` | `backend/routes/notifications.py` | Push notification triggers |
| `artists_bp` | `/artists` | `backend/routes/artists.py` | Artist dashboard, analytics, stats |
| `agora_bp` | `/agora` | `backend/routes/agora.py` | Agora token generation |
| `stripe_bp` | `/stripe` | `backend/routes/stripe_payments.py` | Payment processing |

### Backend Middleware

- `backend/middleware/__init__.py` — `require_auth` decorator
  - Verifies Firebase ID tokens via `auth.verify_id_token()`
  - Extracts `uid`, `email`, `name` from decoded token
  - Applied to most route handlers

### Backend Data Service

- `backend/services/firestore.py` (844 lines) — `FirestoreService` class
  - Methods for: users, posts, feed, comments, discussions, replies, chat, performances, search, trending, notifications, artist stats/analytics, follow, library, swipe recording

---

## 13. CORS Configuration

- **Backend Flask app:** Allows `settings.CORS_ORIGINS + [r".*"]` (very permissive — development only)
- **`cors.json`:** Allows `localhost:53529` and `localhost:5000` for Firebase Storage
- **Production:** Must restrict `CORS_ORIGINS` to actual production domain

---

## 14. Service Layer Architecture (Flutter)

| Service | File | Purpose |
|---|---|---|
| `PythonApiService` | `lib/src/core/services/python_api_service.dart` | HTTP client for Flask backend; attaches Firebase Auth Bearer tokens |
| `StripeService` | `lib/src/core/services/stripe_service.dart` | Stripe payments (native + web checkout) via Flask backend |
| `AgoraService` | `lib/src/core/services/agora_service.dart` | Live streaming via Agora RTC; token fetching from Flask backend |
| `FirebaseAuthService` | `lib/src/core/services/firebase_auth_service.dart` | Email/password auth via `firebase_auth` package |
| `FirestoreService` | `lib/src/core/services/firestore_service.dart` | Hybrid: uses PythonApiService for CRUD + direct Firestore for performances + Firebase Storage for uploads |
| `CommunityFirestoreService` | `lib/src/core/services/community_firestore_service.dart` | Direct Firestore reads/writes for community posts and comments |
| `LiveChatService` | `lib/src/core/services/live_chat_service.dart` | Direct Firestore for live performance chat messages |
| `NotificationService` | `lib/src/core/services/notification_service/notification_service.dart` | Firebase Cloud Messaging (FCM) + flutter_local_notifications |
| `Prefs` (SecureStorage) | `lib/src/core/services/local_db_service/secure_storage.dart` | flutter_secure_storage for tokens, user data, lists |
| `ApiService` | `lib/src/core/services/network_service/api_service.dart` | Generic HTTP client (GET/POST/PUT/DELETE/PATCH/multipart) |
| `ApiRoutes` | `lib/src/core/services/network_service/routes/api_routes.dart` | Route constants; reads `BASE_URL` from `.env` |
| `HandshakeResolver` | `lib/src/core/services/network_service/handshake_resolver.dart` | **Disables SSL certificate verification** (accepts all certs) |

---

## 15. Security Checklist

### Before Transfer/Migration

- [ ] Verify `backend/serviceAccountKey.json` is present
- [ ] Verify all `.env` files have correct values for your environment
- [ ] Do NOT commit `.env` files to version control
- [ ] Do NOT commit `serviceAccountKey.json` to version control
- [ ] Verify `PYTHON_API_URL` points to correct backend address

### Before Production

- [ ] Rotate all Stripe test keys to production keys (`pk_live_*`, `sk_live_*`)
- [ ] Regenerate Agora App Certificate
- [ ] Restrict `CORS_ORIGINS` to production domain
- [ ] Enable SSL/TLS on backend (use `gunicorn` with SSL)
- [ ] Fix `lib/src/core/services/network_service/handshake_resolver.dart` (currently disables SSL verification)
- [ ] Configure Android release signing (`android/key.properties`)
- [ ] Address `assets/.env` — either remove from version control or strip secrets
- [ ] Set `DEBUG=false` in `backend/.env`
- [ ] Set `AGORA_TEST_MODE=false`
- [ ] Add Firebase for macOS/Windows/Linux or guard `Firebase.initializeApp()` calls

---

## 16. Verification Steps

After setup, verify each item:

- [ ] Backend starts without errors: `python app.py`
- [ ] Health check responds: `curl http://127.0.0.1:8000/health`
- [ ] API docs accessible: http://127.0.0.1:8000/docs
- [ ] Firebase Admin SDK initializes (check logs for "VibeSwipe API" message)
- [ ] Flutter app connects to backend (check Network tab in browser dev tools)
- [ ] Stripe test payment works (use test card `4242 4242 4242 4242`)
- [ ] Agora token generation works (test `/agora/token` endpoint)

---

## 17. Quick Start (All-in-One)

### Terminal 1: Backend

```bash
cd backend

# Create and activate virtual environment
python -m venv .venv
.venv\Scripts\activate            # Windows
# source .venv/bin/activate       # macOS/Linux

# Install dependencies
pip install -r requirements.txt

# Start server
python app.py
```

### Terminal 2: Flutter App

```bash
# From project root
flutter pub get
flutter run -d chrome
```

---

## 18. Common Failures & Fixes

| Symptom | Cause | Fix |
|---|---|---|
| `ModuleNotFoundError: No module named 'flask'` | Virtual environment not activated | Activate `.venv` before running |
| `firebase_admin.exceptions.InvalidArgumentError` | Missing service account key | Place `serviceAccountKey.json` in `backend/` |
| `StripeAuthenticationError` | Invalid API key | Verify `STRIPE_SECRET_KEY` in `backend/.env` |
| `AgoraConnectionFailed` | Invalid App ID or Certificate | Verify `AGORA_APP_ID` and `AGORA_APP_CERTIFICATE` |
| CORS error in browser console | Backend CORS misconfigured | Check `CORS_ORIGINS` in `backend/.env` |
| `PYTHON_API_URL` unreachable | Backend not running | Start backend first, verify port 8000 |
| `dotenv` values are empty | `.env` file not found | Ensure `.env` is in the correct directory |
| Firebase init fails on iOS | Missing `GoogleService-Info.plist` | Download from Firebase Console (see §9) |
| `FileNotFoundError: serviceAccountKey.json` | Wrong path or missing file | Verify path in `GOOGLE_APPLICATION_CREDENTIALS` |
| Stripe webhook returns 400 | Wrong webhook secret | Verify `STRIPE_WEBHOOK_SECRET` matches Stripe Dashboard |
| `BASE_URL` not found | Missing env var | Add `BASE_URL=http://127.0.0.1:8000` to root `.env` |
| Agora token generation fails from Cloud Function | Secrets not set | Run `firebase functions:secrets:set AGORA_APP_ID` and `AGORA_APP_CERTIFICATE` |
| Stripe webhook not firing | Wrong endpoint URL | Update Stripe Dashboard webhook URL to Cloud Function URL |

---

## 19. Firebase Cloud Functions (Agora & Stripe)

The project uses Firebase Cloud Functions for two sensitive operations:

### Functions Overview

| Function | Trigger | Purpose |
|---|---|---|
| `generateAgoraToken` | HTTPS Callable | Generates secure Agora RTC tokens for live streaming |
| `stripeWebhook` | HTTP Request | Handles Stripe webhook events (payment confirmations) |
| `createPaymentIntent` | HTTPS Callable | Creates Stripe PaymentIntent for native mobile payments |
| `createCheckoutSession` | HTTPS Callable | Creates Stripe Checkout Session for web payments |
| `checkAccess` | HTTPS Callable | Checks if user has paid access to a performance |
| `checkTipStatus` | HTTPS Callable | Checks if user has tipped an artist |
| `getTransactionHistory` | HTTPS Callable | Gets artist transaction history |

### Cloud Functions Directory Structure

```
functions/
├── package.json           # Node.js dependencies
├── tsconfig.json          # TypeScript config
├── .eslintrc.js           # Linting config
├── src/
│   ├── index.ts           # Exports all functions
│   ├── agora.ts           # generateAgoraToken function
│   ├── stripe.ts          # All Stripe functions (7 total)
│   └── firebase-admin.ts  # Shared Firebase Admin initialization
└── lib/                   # Compiled JavaScript (auto-generated)
```

### Setting Up Cloud Functions

```bash
cd functions
npm install
npm run build
```

### Deploying Cloud Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:generateAgoraToken
firebase deploy --only functions:stripeWebhook
```

### Setting Secrets

```bash
firebase functions:secrets:set AGORA_APP_ID
firebase functions:secrets:set AGORA_APP_CERTIFICATE
firebase functions:secrets:set STRIPE_SECRET_KEY
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
```

### Testing Locally

```bash
# Start Firebase Emulator
firebase emulators:start --only functions

# Test Agora token generation
firebase functions:shell
> generateAgoraToken({ channelName: "test", uid: 0, role: "publisher" })

# Test Stripe webhook with Stripe CLI
stripe listen --forward-to http://127.0.0.1:5001/vibe-swipe-llc/us-central1/stripeWebhook
```

### Stripe Webhook Configuration

After deploying, update the webhook URL in Stripe Dashboard:
1. Go to https://dashboard.stripe.com/webhooks
2. Update endpoint URL to: `https://us-central1-vibe-swipe-llc.cloudfunctions.net/stripeWebhook`
3. Select events: `checkout.session.completed`, `payment_intent.succeeded`, `payment_intent.payment_failed`

### Flutter Client Integration

The Flutter app uses `cloud_functions` SDK to call all Stripe and Agora functions:

```dart
// Agora token generation
final callable = FirebaseFunctions.instance.httpsCallable('generateAgoraToken');
final result = await callable.call({
  'channelName': 'live-stream-test',
  'uid': 0,
  'role': 'publisher',
});

// Stripe payment intent creation
final callable = FirebaseFunctions.instance.httpsCallable('createPaymentIntent');
final result = await callable.call({
  'amount': 5.00,
  'type': 'tip',
  'artistId': 'artist_uid',
});

// Check access to paid performance
final callable = FirebaseFunctions.instance.httpsCallable('checkAccess');
final result = await callable.call({
  'userId': 'user_uid',
  'performanceId': 'perf_id',
});

// Check tip status
final callable = FirebaseFunctions.instance.httpsCallable('checkTipStatus');
final result = await callable.call({
  'userId': 'user_uid',
  'artistId': 'artist_uid',
});

// Get transaction history
final callable = FirebaseFunctions.instance.httpsCallable('getTransactionHistory');
final result = await callable.call({
  'artistId': 'artist_uid',
});
```

### Relationship to Python Backend

The Python Flask backend (`backend/`) is **NOT replaced** by Cloud Functions. It still handles:
- User CRUD, profiles, follow, library (`/users/*`)
- Posts, feed, swipes, likes (`/posts/*`)
- Discussion threads (`/discussions/*`)
- Real-time chat (`/chat/*`)
- Live performance management (`/performances/*`)
- Search functionality (`/search/*`)
- Push notifications (`/notifications/*`)
- Artist dashboard and analytics (`/artists/*`)

The following operations were migrated to Cloud Functions for security:
- Agora token generation (was `/agora/token` → now `generateAgoraToken`)
- Stripe webhook handling (was `/stripe/webhook` → now `stripeWebhook`)
- Stripe payment intent creation (was `/stripe/create-payment-intent` → now `createPaymentIntent`)
- Stripe checkout session creation (was `/stripe/create-checkout-session` → now `createCheckoutSession`)
- Access checking (was `/stripe/check-access` → now `checkAccess`)
- Tip status checking (was `/stripe/check-tip-status` → now `checkTipStatus`)
- Transaction history (was `/stripe/transaction-history` → now `getTransactionHistory`)

**Result:** The Flutter app no longer needs `PYTHON_API_URL` for Stripe or Agora operations. These are handled entirely by Firebase Cloud Functions.
- Stripe checkout session creation (was `/stripe/create-checkout-session`)
