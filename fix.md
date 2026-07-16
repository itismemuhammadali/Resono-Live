# Fix: Set Up Systemd Service

## Step 1 — Create service file

```bash
nano /etc/systemd/system/vibeswipe.service
```

## Step 2 — Paste this content (replace whatever is there)

```
[Unit]
Description=VibeSwipe Flask API
After=network.target

[Service]
User=root
WorkingDirectory=/root/vibe-swipe/backend
ExecStart=/root/vibe-swipe/backend/venv/bin/gunicorn --bind 0.0.0.0:8000 --workers 4 --timeout 120 app:app
Restart=always
RestartSec=5
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
```

## Step 3 — Save and exit

Press `Ctrl+O`, then `Enter`, then `Ctrl+X`

## Step 4 — Enable and start

```bash
systemctl daemon-reload && systemctl enable vibeswipe && systemctl start vibeswipe && systemctl status vibeswipe
```

## Step 5 — Verify

```bash
curl http://177.7.33.210:8000/
```
