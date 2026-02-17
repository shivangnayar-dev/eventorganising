# 🚀 Step-by-Step Deployment Commands

Run these commands **one by one** on your server (SSH: `root@72.61.232.15`)

---

## 📋 STEP 1: Check Current Setup

```bash
# Check what's installed
python3 --version
mongod --version 2>/dev/null || echo "MongoDB not installed"
nginx -v 2>/dev/null || echo "Nginx not installed"

# Check what directories exist
ls -la /var/www/ 2>/dev/null || echo "No /var/www directory"
```

---

## 🧹 STEP 2: Clean Up Old Deployment (if exists)

```bash
# Stop services (if running)
systemctl stop eventorganising-backend 2>/dev/null || true
systemctl disable eventorganising-backend 2>/dev/null || true

# Remove old directories
rm -rf /var/www/eventorganising
rm -f /etc/systemd/system/eventorganising-backend.service
rm -f /etc/nginx/sites-enabled/eventorganising
rm -f /etc/nginx/sites-available/eventorganising

# Reload systemd and nginx
systemctl daemon-reload
systemctl reload nginx
```

---

## 📦 STEP 3: Install Required Software

```bash
# Update system
apt update
apt upgrade -y

# Install Python and pip
apt install -y python3 python3-pip python3-venv

# Install MongoDB
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
apt update
apt install -y mongodb-org

# Start MongoDB
systemctl start mongod
systemctl enable mongod

# Install Nginx
apt install -y nginx

# Install Git (if needed)
apt install -y git

# Verify installations
python3 --version
mongod --version
nginx -v
```

---

## 📁 STEP 4: Create Directory Structure

```bash
# Create application directories
mkdir -p /var/www/eventorganising/backend
mkdir -p /var/www/eventorganising/frontend
mkdir -p /var/www/eventorganising/backend/logs

# Set permissions
chown -R root:root /var/www/eventorganising
chmod -R 755 /var/www/eventorganising
```

---

## 🔙 STEP 5: Upload Backend Code (Run from your LOCAL machine)

**Open a NEW terminal on your Mac (keep SSH session open)**

```bash
# From your Mac terminal, navigate to project
cd /Users/shivangnayar/eventorganising

# Upload backend code (will ask for password: Shivchin@2001)
rsync -avz --exclude 'venv' --exclude '__pycache__' --exclude '.git' --exclude '*.pyc' --exclude '.env' --exclude 'logs/*.log' backend_python/ root@72.61.232.15:/var/www/eventorganising/backend/
```

---

## ⚙️ STEP 6: Setup Backend (Back on SERVER)

**Go back to your SSH session on the server**

```bash
# Navigate to backend directory
cd /var/www/eventorganising/backend

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
```

---

## 🔐 STEP 7: Create Backend .env File

```bash
# Create .env file
nano /var/www/eventorganising/backend/.env
```

**Add this content (replace values as needed):**

```env
NODE_ENV=production
PORT=3000
DATABASE_URL=mongodb://localhost:27017/eventorganising
JWT_SECRET=CHANGE_THIS_TO_A_RANDOM_32_CHARACTER_STRING
JWT_EXPIRES_IN=1d
CORS_ORIGIN=http://72.61.232.15,http://localhost:3000
FRONTEND_URL=http://72.61.232.15
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX=100
```

**To generate a secure JWT_SECRET, run:**
```bash
openssl rand -hex 32
```

**Save and exit:** Press `Ctrl+X`, then `Y`, then `Enter`

---

## 🔧 STEP 8: Initialize Database

```bash
# Make sure you're in backend directory with venv activated
cd /var/www/eventorganising/backend
source venv/bin/activate

# Check if create_admin script exists
ls scripts/

# If it exists, run it to create admin user
python scripts/create_admin.py
```

---

## 🎯 STEP 9: Create Systemd Service

```bash
# Create service file
nano /etc/systemd/system/eventorganising-backend.service
```

**Add this content:**

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

**Save and exit:** Press `Ctrl+X`, then `Y`, then `Enter`

```bash
# Enable and start service
systemctl daemon-reload
systemctl enable eventorganising-backend
systemctl start eventorganising-backend

# Check status
systemctl status eventorganising-backend
```

---

## 🎨 STEP 10: Build Frontend (Run from LOCAL machine)

**On your Mac terminal:**

```bash
# Navigate to frontend
cd /Users/shivangnayar/eventorganising/frontend

# Build for web
flutter clean
flutter pub get
flutter build web --release --web-renderer html --dart-define=API_BASE_URL=http://72.61.232.15:3000

# Verify build
ls -la build/web/
```

---

## 📤 STEP 11: Upload Frontend (Run from LOCAL machine)

```bash
# Upload frontend build
rsync -avz --delete build/web/ root@72.61.232.15:/var/www/eventorganising/frontend/
```

---

## 🌐 STEP 12: Configure Nginx

**Back on SERVER:**

```bash
# Create nginx config
nano /etc/nginx/sites-available/eventorganising
```

**Add this content:**

```nginx
server {
    listen 80;
    server_name 72.61.232.15;

    # Frontend (Flutter Web)
    location / {
        root /var/www/eventorganising/frontend;
        try_files $uri $uri/ /index.html;
        index index.html;
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
        proxy_cache_bypass $http_upgrade;
    }

    # Backend docs
    location /docs {
        proxy_pass http://localhost:3000/docs;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }

    # Health check
    location /health {
        proxy_pass http://localhost:3000/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
```

**Save and exit:** Press `Ctrl+X`, then `Y`, then `Enter`

```bash
# Enable site
ln -s /etc/nginx/sites-available/eventorganising /etc/nginx/sites-enabled/

# Remove default site (optional)
rm /etc/nginx/sites-enabled/default

# Test nginx config
nginx -t

# Reload nginx
systemctl reload nginx
```

---

## 🔥 STEP 13: Configure Firewall

```bash
# Allow HTTP
ufw allow 80/tcp
ufw allow 443/tcp

# Check firewall status
ufw status
```

---

## ✅ STEP 14: Test Everything

```bash
# Test backend directly
curl http://localhost:3000/health

# Test through nginx
curl http://localhost/api/health

# Check backend logs
journalctl -u eventorganising-backend -n 50

# Check nginx status
systemctl status nginx

# Check MongoDB status
systemctl status mongod
```

---

## 🌍 STEP 15: Access Your Application

Open in browser:
- **Frontend:** http://72.61.232.15
- **API Docs:** http://72.61.232.15/docs
- **Health Check:** http://72.61.232.15/api/health

---

## 🐛 Troubleshooting Commands

```bash
# View backend logs
journalctl -u eventorganising-backend -f

# Restart backend
systemctl restart eventorganising-backend

# Restart nginx
systemctl restart nginx

# Check if backend is running
ps aux | grep python

# Check if port 3000 is in use
netstat -tlnp | grep 3000

# Test backend manually
cd /var/www/eventorganising/backend
source venv/bin/activate
python run.py
```

---

## 📝 Summary

After running all steps:
- ✅ Backend running on port 3000
- ✅ Frontend served by Nginx on port 80
- ✅ MongoDB running and connected
- ✅ Systemd service managing backend
- ✅ Accessible at http://72.61.232.15

