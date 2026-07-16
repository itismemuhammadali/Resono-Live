# VibeSwipe — Project Instructions

## Architecture

```
Flutter App (Firebase SDK)
    ├── (file uploads) ──────────> Firebase Storage (direct)
    ├── (auth) ───────────────────> Firebase Auth
    └── (all data ops) ──────────> Python Flask API (:8000)
                                        └──> Firebase Firestore + Auth
```

---

## Prerequisites

- Python 3.10+ (`python --version`)
- Flutter SDK (`flutter --version`)
- Firebase project configured (vibe-swipe-llc)

---

## Services

| Service              | Port | URL                           |
|----------------------|------|-------------------------------|
| Python API           | 8000 | http://127.0.0.1:8000         |
| Python API Docs      | 8000 | http://127.0.0.1:8000/docs    |
| Flutter Web          | 3000 | http://localhost:3000          |

---

## Quick Start

### Terminal 1 — Python API Server

```bash
cd "C:\Users\iamsh\Desktop\Company Project\VipeSwipe\backend"
.venv\Scripts\activate
python app.py
```

### Terminal 2 — Flutter App

```bash
flutter run -d chrome
```

---

## Verify Everything Works

1. Backend health: `http://localhost:8000/health`
2. API docs: `http://localhost:8000/docs`
3. Flutter app connects to Firebase production

---

## Stopping Services

### Graceful Stop
Press `Ctrl + C` in each terminal.

### Force Stop
```powershell
taskkill /F /IM python.exe /T
taskkill /F /IM dart.exe /T
```

---

## Firebase Configuration

Project: `vibe-swipe-llc`

### Flutter App
- Uses `firebase_options.dart` for Firebase config
- Connects directly to production Firebase

### Python Backend
- Uses `serviceAccountKey.json` for credentials
- Project ID: `vibe-swipe-llc`

---

## Firestore Collections

| Collection | Description |
|------------|-------------|
| users | User profiles |
| performances | Live sessions & recordings |
| posts | Community posts |
| discussions | Discussion threads |
| chats | Chat conversations |
| notifications | User notifications |
| otp_verifications | OTP data |

---

## Troubleshooting

**Python module not found:**
```bash
cd "C:\Users\iamsh\Desktop\Company Project\VipeSwipe\backend"
.venv\Scripts\activate
pip install -r requirements.txt
```

**Port already in use:**
```powershell
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

**Flutter can't connect to API:**
1. Verify Python server: `curl http://127.0.0.1:8000/health`
2. Check `.env` has `PYTHON_API_URL=http://127.0.0.1:8000`
3. Restart Flutter after starting Python server

---

## Stripe Test Cards

| Card | Number | Behavior |
|------|--------|----------|
| Visa | 4242 4242 4242 4242 | Succeeds |
| Visa (debit) | 4000 0566 5566 5556 | Succeeds |
| Mastercard | 5555 5555 5555 4444 | Succeeds |
| Declined | 4000 0000 0000 0002 | Declined |
| Insufficient funds | 4000 0000 0000 9995 | Declined |

Use any future expiry date (e.g. 12/34), any 3-digit CVC, and any postal code.

---

## Command Cheat Sheet

```bash
# Start
cd "C:\Users\iamsh\Desktop\Company Project\VipeSwipe\backend" && .venv\Scripts\activate && python app.py
flutter run

# Stop
taskkill /F /IM python.exe /T
taskkill /F /IM dart.exe /T

# Health Check
curl http://127.0.0.1:8000/health
```
