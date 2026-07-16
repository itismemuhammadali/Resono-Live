# Network Port & Environment Variable Inventory

This document is the source-of-truth for every port, localhost reference, and network endpoint in the VibeSwipe project. Use it to diagnose port conflicts, firewall blocks, and connection failures when moving between Windows and macOS.

---

## Source-of-Truth Port Table

| Service / Platform | Default Port / URL | Configuration File | How to Change |
|---|---|---|---|
| Python Flask API | `0.0.0.0:8000` | `backend/.env` (`PORT=8000`, `HOST=0.0.0.0`) | Change `PORT` value in `backend/.env` |
| Flutter Web Dev Server | `localhost:<dynamic>` | Flutter auto-assigns | N/A (auto) |
| Stripe Checkout Fallback | `localhost:51311` | `backend/routes/stripe_payments.py:236` | Update hardcoded fallback in Python |
| Firebase Storage CORS | `localhost:53529`, `localhost:5000` | `cors.json` | Edit `cors.json` |
| Backend CORS Origins | `:53529`, `:3000`, `:8080`, `:50229`, `:51311` | `backend/.env` (`CORS_ORIGINS`) | Edit `CORS_ORIGINS` in `backend/.env` |
| Android Emulator Loopback | `10.0.2.2` | `android/app/src/main/res/xml/network_security_config.xml` | Edit XML |
| localhost / 127.0.0.1 | All services | Multiple files | See individual configs below |

---

## Complete localhost / 127.0.0.1 Reference Map

### Dart Source Files

| File | Line | Content | Port |
|---|---|---|---|
| `lib/src/core/services/stripe_service.dart` | 11 | `dotenv.get('PYTHON_API_URL', fallback: 'http://127.0.0.1:8000')` | 8000 |
| `lib/src/core/services/agora_service.dart` | 19 | `dotenv.get('PYTHON_API_URL', fallback: 'http://127.0.0.1:8000')` | 8000 |
| `lib/src/core/services/python_api_service.dart` | 7 | `dotenv.get('PYTHON_API_URL', fallback: 'http://127.0.0.1:8000')` | 8000 |
| `lib/src/core/services/network_service/routes/api_routes.dart` | 7 | `dotenv.get('BASE_URL')` — **NOT defined in any .env** | — |

### Environment Files

| File | Variables with localhost/ports |
|---|---|
| `.env` (root) | `PYTHON_API_URL=http://127.0.0.1:8000` |
| `assets/.env` | `PYTHON_API_URL=http://127.0.0.1:8000` |
| `backend/.env` | `HOST=0.0.0.0`, `PORT=8000`, `CORS_ORIGINS=http://localhost:53529,http://localhost:3000,http://localhost:8080,http://127.0.0.1:53529,http://localhost:50229,http://localhost:51311` |
| `backend/.env.production` | `HOST=0.0.0.0`, `CORS_ORIGINS=http://localhost:3000,http://localhost:8080` |
| `backend/.env.example` | `HOST=0.0.0.0`, `CORS_ORIGINS=http://localhost:53529,http://localhost:3000,http://localhost:8080` |

### Backend Source Files

| File | Line | Content | Port |
|---|---|---|---|
| `backend/config.py` | 12 | `HOST: str = os.getenv("HOST", "0.0.0.0")` | 0.0.0.0 |
| `backend/config.py` | 16 | `CORS_ORIGINS` defaults to `http://localhost:3000` | 3000 |
| `backend/routes/stripe_payments.py` | 236 | `request.headers.get("Origin", "http://localhost:51311")` | 51311 |
| `backend/routes/stripe_payments.py` | 237 | `request.headers.get("Origin", "http://localhost:51311")` | 51311 |
| `backend/app.py` | 42 | `print(f"[VibeSwipe API] Running on {settings.HOST}:{settings.PORT}")` | 8000 |

### Android Config

| File | Content |
|---|---|
| `android/app/src/main/res/xml/network_security_config.xml` | Allows cleartext for `10.0.2.2`, `localhost`, `127.0.0.1` |

### Firebase Config

| File | Content |
|---|---|
| `cors.json` | Allows `localhost:53529`, `localhost:5000` for Firebase Storage |

---

## Hardcoded Port Risk: localhost:51311

**Location:** `backend/routes/stripe_payments.py` lines 236-237

```python
success_url = request.headers.get("Origin", "http://localhost:51311") + "/payment-success?session_id={CHECKOUT_SESSION_ID}"
cancel_url = request.headers.get("Origin", "http://localhost:51311") + "/payment-cancelled"
```

**What this does:** When creating a Stripe Checkout Session, the backend uses the browser's `Origin` header to build the success/cancel redirect URLs. If the Origin header is missing (e.g., server-to-server calls), it falls back to `http://localhost:51311`.

**When this causes problems:**
- If you see Stripe checkout redirects going to port 51311, this is the cause
- Port 51311 is a dynamic Flutter web port — it changes each run
- In normal browser usage, the Origin header is sent automatically, so this fallback rarely triggers

**Fix if needed:** Update the hardcoded fallback in `backend/routes/stripe_payments.py` to match your actual Flutter web port, or ensure the Origin header is always present.

---

## OS-Specific Port Collision & Firewall Resolution

### macOS Troubleshooting

#### Audit Blocked Ports

```bash
# Find what's using a specific port
sudo lsof -i :8000

# Kill the process
kill -9 <PID>
```

#### Known macOS Port Conflicts

| Port | Conflict | Fix |
|---|---|---|
| 5000 | macOS "AirPlay Receiver" service | System Settings → General → AirDrop & Handoff → AirPlay Receiver → OFF |
| 7000 | macOS "AirPlay Receiver" service | Same as above |
| 53529 | Flutter web dynamic port | Normal — auto-assigned per run |
| 8080 | Common alternative HTTP port | Check with `lsof -i :8080` |

#### macOS Firewall

1. System Settings → Network → Firewall → Options
2. If running Flask backend locally, ensure Python is allowed incoming connections
3. Or temporarily disable firewall for testing

#### macOS Network Permissions (macOS Ventura+)

macOS may prompt "Do you want the application 'python' to accept incoming network connections?"
- Click "Allow" for local development
- This happens when Flask binds to `0.0.0.0`

#### CocoaPods Network Issues

```bash
# If pod install hangs, check DNS resolution
nslookup trunk.cocoapods.org

# Try switching DNS to public resolvers
# System Settings → Network → Details → DNS → Add 8.8.8.8, 1.1.1.1
```

---

### Windows Troubleshooting

#### Audit Blocked Ports

```cmd
:: Command Prompt
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

```powershell
# PowerShell
Get-NetTCPConnection -LocalPort 8000
Stop-Process -Id <PID> -Force
```

#### Known Windows Port Conflicts

| Port | Conflict | Fix |
|---|---|---|
| 80 | IIS (Internet Information Services) | Disable IIS: Control Panel → Programs → Turn Windows features on/off → Uncheck IIS |
| 443 | IIS or SQL Server Reporting Services | Same as above, or change Flask port |
| 3306 | MySQL Server | Stop MySQL service or change Flask port |
| 5432 | PostgreSQL | Stop PostgreSQL service or change Flask port |
| 8080 | Tomcat, Jenkins, or other Java apps | Check with `netstat -ano | findstr :8080` |

#### Windows Defender Firewall

If backend connections are silently blocked on LAN:

**Option 1: Allow Python through firewall**
1. Windows Security → Firewall & network protection → Allow an app through firewall
2. Click "Change settings" → "Allow another app"
3. Browse to Python executable (e.g., `C:\Users\<you>\backend\.venv\Scripts\python.exe`)
4. Check both Private and Public boxes

**Option 2: Add firewall rule via command**
```cmd
netsh advfirewall firewall add rule name="VibeSwipe Flask" dir=in action=allow program="C:\path\to\python.exe" enable=yes
```

**Option 3: Temporarily disable firewall for testing**
```cmd
netsh advfirewall set allprofiles state off
:: Remember to re-enable after testing:
netsh advfirewall set allprofiles state on
```

#### Windows Antivirus Software

Some antivirus software (Norton, McAfee, Avast) block localhost connections.
- Add exceptions for Python and Flutter processes
- Or temporarily disable real-time protection for testing

#### Windows localhost Resolution

Windows sometimes resolves `localhost` to IPv6 `::1` instead of IPv4 `127.0.0.1`.
If connections fail, try using `127.0.0.1` explicitly instead of `localhost`.

---

## Port Change Checklist

If you need to change the backend port from 8000 to something else:

| Step | File | Change |
|---|---|---|
| 1 | `backend/.env` | Change `PORT=8000` to `PORT=<new_port>` |
| 2 | `.env` (root) | Change `PYTHON_API_URL=http://127.0.0.1:8000` to use new port |
| 3 | `assets/.env` | Change `PYTHON_API_URL=http://127.0.0.1:8000` to use new port |
| 4 | `INSTRUCTIONS.md` | Update all port references |
| 5 | `transfer_guide/` | Update all port references in guide docs |

**Note:** The Flutter app reads `PYTHON_API_URL` from `.env` via `flutter_dotenv`. The backend reads `PORT` from `backend/.env` via `python-dotenv`. These are the TWO places that control the port.

---

## Quick Port Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                    VibeSwipe Port Map                        │
├─────────────────────────────────────────────────────────────┤
│  Flask API Server        :8000   (backend/.env)             │
│  Flutter Web Dev Server  :????   (auto-assigned by Flutter) │
│  Stripe Checkout Fallback:51311  (hardcoded in Python)      │
│  Firebase Storage CORS   :53529, :5000  (cors.json)         │
│  Backend CORS Origins    :53529, :3000, :8080, :50229,      │
│                          :51311  (backend/.env)             │
│  Android Emulator        :10.0.2.2 (network_security.xml)   │
│  localhost / 127.0.0.1   All services                       │
└─────────────────────────────────────────────────────────────┘
```
