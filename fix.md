# Deploy Web Portal to VPS

## Step 1 — Install Node.js on server (Hostinger terminal)

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt install -y nodejs
```

## Step 2 — Upload web project (run on YOUR Windows PowerShell)

```powershell
scp -r "C:\Users\iamsh\Desktop\Company Project\VipeSwipe\vibe_swipe_web\Bryan-Beattie" root@177.7.33.210:/root/vibe_swipe_web
```

Enter root password when prompted.

## Step 3 — Install and build on server (Hostinger terminal)

```bash
cd /root/vibe_swipe_web/Bryan-Beattie && npm install && npm run build && nohup npm run start -- -p 3001 > /var/log/vibeswipe_web.log 2>&1 &
```

## Step 4 — Open port (Hostinger terminal)

```bash
ufw allow 3001/tcp && ufw reload
```

## Verify

Open **http://177.7.33.210:3001** in your browser.
