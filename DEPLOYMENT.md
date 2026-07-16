# VibeSwipe Backend Deployment

## Copy & Paste This Block Into Hostinger Terminal

```bash
apt update && apt upgrade -y && apt install -y python3 python3-pip python3-venv git curl && cd /root && git clone https://github.com/shaheertariq1/vibe-swipe.git && cd vibe-swipe/backend && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt && cp .env.production .env && nohup gunicorn --bind 0.0.0.0:8000 --workers 4 --timeout 120 app:app > /var/log/vibeswipe.log 2>&1 & curl http://localhost:8000/
```

## Open Firewall Port

```bash
ufw allow 8000/tcp && ufw reload
```

## Set Up Auto-Restart on Reboot

```bash
cat > /etc/systemd/system/vibeswipe.service << 'EOF'
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
EOF

systemctl daemon-reload && systemctl enable vibeswipe && systemctl start vibeswipe && systemctl status vibeswipe
```

## Verify

```bash
curl http://177.7.33.210:8000/
curl http://177.7.33.210:8000/health
```

## Useful Commands

```bash
systemctl status vibeswipe
systemctl restart vibeswipe
systemctl stop vibeswipe
journalctl -u vibeswipe -f
```
