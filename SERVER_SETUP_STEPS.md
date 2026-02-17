# 🖥️ Server Setup Steps - Run These on Your Server

SSH into your server and run these commands one by one:

```bash
ssh root@72.61.232.15
```

---

## Step 1: Setup Python Environment

```bash
cd /var/www/eventorganising/backend

# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

---

## Step 2: Create .env File

```bash
# Generate a secure JWT secret
openssl rand -hex 32
# Copy the output - you'll need it below

# Create .env file
nano .env
```

**Paste this content (replace JWT_SECRET with the value from above):**

```env
ENVIRONMENT=production
PORT=3000
DATABASE_URL=mongodb://localhost:27017/eventorganising
JWT_SECRET=paste_your_generated_secret_here
JWT_EXPIRES_IN=1d
JWT_REFRESH_EXPIRES_IN=7d
CORS_ORIGIN=http://72.61.232.15
FRONTEND_URL=http://72.61.232.15
```

**Save:** Press `Ctrl+X`, then `Y`, then `Enter`

---

## Step 3: Create Systemd Service

```bash
nano /etc/systemd/system/eventorganising-backend.service
```

**Paste this content:**

```ini
[Unit]
Description=EventOrganising Backend API
After=network.target mongod.service

[Service]
Type=simple
User=root
WorkingDirectory=/var/www/eventorganising/backend
Environment="PATH=/var/www/eventorganising/backend/venv/bin"
ExecStart=/var/www/eventorganising/backend/venv/bin/python run.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Save:** Press `Ctrl+X`, then `Y`, then `Enter`

**Enable and start the service:**

```bash
systemctl daemon-reload
systemctl enable eventorganising-backend
systemctl start eventorganising-backend
systemctl status eventorganising-backend
```

---

## Step 4: Initialize Database

```bash
cd /var/www/eventorganising/backend
source venv/bin/activate
python scripts/create_admin.py
```

---

## Step 5: Configure Nginx

```bash
nano /etc/nginx/sites-available/eventorganising
```

**Paste this configuration:**

```nginx
server {
    listen 80;
    server_name 72.61.232.15;

    # Frontend (Flutter Web)
    location / {
        root /var/www/eventorganising/frontend;
        try_files $uri $uri/ /index.html;
        index index.html;
        
        # CORS headers
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type' always;
        
        # Handle preflight requests
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS headers for API
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type' always;
    }
}
```

**Save:** Press `Ctrl+X`, then `Y`, then `Enter`

**Enable site and restart Nginx:**

```bash
# Create symlink
ln -sf /etc/nginx/sites-available/eventorganising /etc/nginx/sites-enabled/

# Remove default site (optional)
rm -f /etc/nginx/sites-enabled/default

# Test configuration
nginx -t

# Restart Nginx
systemctl restart nginx

# Check status
systemctl status nginx
```

---

## Step 6: Verify Everything Works

```bash
# Check backend service
systemctl status eventorganising-backend

# Check backend logs
journalctl -u eventorganising-backend -n 50

# Test backend API
curl http://localhost:3000/health
# Or
curl http://72.61.232.15/api/health

# Check Nginx
systemctl status nginx
```

---

## ✅ Done!

Your application should now be live at:
- **Frontend:** http://72.61.232.15
- **Backend API:** http://72.61.232.15/api
- **API Docs:** http://72.61.232.15/api/docs

---

## 🔧 Troubleshooting

### Backend not starting?
```bash
journalctl -u eventorganising-backend -f
```

### Check if MongoDB is running?
```bash
systemctl status mongod
systemctl start mongod  # if not running
```

### Check if port 3000 is in use?
```bash
netstat -tulpn | grep 3000
```

### Restart services?
```bash
systemctl restart eventorganising-backend
systemctl restart nginx
```

