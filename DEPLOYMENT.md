# 🚀 Deployment Guide - EventOrganising

This guide explains how to deploy both the backend (FastAPI) and frontend (Flutter Web) to your server at **72.61.232.15**.

## 📋 Prerequisites

- Server with Ubuntu/Debian Linux (or similar)
- SSH access to the server (IP: 72.61.232.15)
- Domain name (optional, or use IP address)
- MongoDB installed on server (or remote MongoDB connection)

## 🏗️ Architecture Overview

```
Internet → Nginx (Port 80/443) → Backend (Port 3000) + Frontend (Static Files)
                ↓
         MongoDB (Port 27017)
```

## 📦 Part 1: Server Setup

### Step 1: Connect to Your Server

```bash
ssh root@72.61.232.15
# Or if you have a user account:
ssh your_username@72.61.232.15
```

### Step 2: Update System

```bash
sudo apt update
sudo apt upgrade -y
```

### Step 3: Install Required Software

```bash
# Install Python 3.9+ and pip
sudo apt install -y python3 python3-pip python3-venv

# Install MongoDB
sudo apt install -y mongodb

# Or use official MongoDB installation:
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

# Install Nginx
sudo apt install -y nginx

# Install Git
sudo apt install -y git

# Install Node.js (for Flutter web build, if needed)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### Step 4: Create Application Directory

```bash
sudo mkdir -p /var/www/eventorganising
sudo chown -R $USER:$USER /var/www/eventorganising
```

---

## 🔧 Part 2: Backend Deployment

### Step 1: Upload Backend Code

From your local machine:

```bash
# Create a tarball of backend
cd /Users/shivangnayar/eventorganising
tar --exclude='backend_python/venv' --exclude='backend_python/__pycache__' --exclude='backend_python/.git' --exclude='backend_python/logs/*.log' -czf backend.tar.gz backend_python/

# Upload to server
scp backend.tar.gz root@72.61.232.15:/tmp/

# Or use rsync (recommended for updates)
rsync -avz --exclude 'venv' --exclude '__pycache__' --exclude '.git' --exclude 'logs/*.log' backend_python/ root@72.61.232.15:/var/www/eventorganising/backend/
```

### Step 2: Setup Backend on Server

SSH into the server and run:

```bash
cd /var/www/eventorganising

# Extract if using tar
tar -xzf /tmp/backend.tar.gz -C .
mv backend_python backend

# Or if using rsync, skip extraction

cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file
nano .env
```

### Step 3: Configure Backend Environment

Create `.env` file with the following content:

```bash
# Environment
NODE_ENV=production

# Server
PORT=3000

# Database (MongoDB)
DATABASE_URL=mongodb://localhost:27017/eventorganising
# Or remote MongoDB:
# DATABASE_URL=mongodb://username:password@mongodb-host:27017/eventorganising

# JWT (Generate a strong secret: openssl rand -hex 32)
JWT_SECRET=your_super_secret_jwt_key_here_at_least_32_characters_long
JWT_EXPIRES_IN=1d

# CORS (Use your domain or IP)
CORS_ORIGIN=http://72.61.232.15,https://yourdomain.com
# Or for all origins (less secure):
# CORS_ORIGIN=*

# Frontend URL
FRONTEND_URL=http://72.61.232.15

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX=100

# Email (Optional - for notifications)
# SMTP_HOST=smtp.gmail.com
# SMTP_PORT=587
# SMTP_USER=your-email@gmail.com
# SMTP_PASS=your-app-password
```

Generate a secure JWT secret:

```bash
openssl rand -hex 32
```

### Step 4: Create Systemd Service

Create a systemd service to run the backend:

```bash
sudo nano /etc/systemd/system/eventorganising-backend.service
```

Add the following content:

```ini
[Unit]
Description=EventOrganising Backend API
After=network.target mongod.service

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/eventorganising/backend
Environment="PATH=/var/www/eventorganising/backend/venv/bin"
ExecStart=/var/www/eventorganising/backend/venv/bin/python run.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable eventorganising-backend
sudo systemctl start eventorganising-backend
sudo systemctl status eventorganising-backend
```

### Step 5: Initialize Database (First Time)

```bash
cd /var/www/eventorganising/backend
source venv/bin/activate
python scripts/create_admin.py
```

---

## 🎨 Part 3: Frontend Deployment

### Step 1: Build Flutter Web App (On Local Machine)

```bash
cd /Users/shivangnayar/eventorganising/frontend

# Update API URL in environment.dart to use server IP
# Change API_BASE_URL to: http://72.61.232.15:3000
# Or use domain: https://yourdomain.com/api

# Build for web
flutter build web --release --web-renderer html

# This creates build/web/ directory
```

### Step 2: Configure Frontend API URL

Edit `frontend/lib/config/environment.dart` to use production API URL:

```dart
// Change the production API URL
static String get apiBaseUrl {
  if (kDebugMode) {
    return 'http://localhost:3000';
  }
  return 'http://72.61.232.15:3000';  // Or your domain
}
```

Rebuild after changing:

```bash
flutter clean
flutter build web --release --web-renderer html
```

### Step 3: Upload Frontend to Server

From your local machine:

```bash
# Upload build files
rsync -avz frontend/build/web/ root@72.61.232.15:/var/www/eventorganising/frontend/

# Or use scp
scp -r frontend/build/web/* root@72.61.232.15:/var/www/eventorganising/frontend/
```

---

## 🌐 Part 4: Nginx Configuration

### Step 1: Create Nginx Configuration

```bash
sudo nano /etc/nginx/sites-available/eventorganising
```

Add the following configuration:

```nginx
server {
    listen 80;
    server_name 72.61.232.15 yourdomain.com;

    # Frontend (Flutter Web)
    location / {
        root /var/www/eventorganising/frontend;
        try_files $uri $uri/ /index.html;
        index index.html;
        
        # CORS headers (if needed)
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type' always;
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

    # Backend direct (for API docs)
    location /docs {
        proxy_pass http://localhost:3000/docs;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Health check
    location /health {
        proxy_pass http://localhost:3000/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
```

### Step 2: Enable Site and Test

```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/eventorganising /etc/nginx/sites-enabled/

# Remove default site (optional)
sudo rm /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### Step 3: Configure Firewall

```bash
# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# If ufw is enabled, check status
sudo ufw status
```

---

## ✅ Part 5: Verification

### Test Backend API

```bash
# From server
curl http://localhost:3000/health

# From local machine
curl http://72.61.232.15/api/health
```

### Test Frontend

Open in browser:
- `http://72.61.232.15`
- Or if you have a domain: `http://yourdomain.com`

### Check Services Status

```bash
# Backend service
sudo systemctl status eventorganising-backend

# Nginx
sudo systemctl status nginx

# MongoDB
sudo systemctl status mongod

# View backend logs
sudo journalctl -u eventorganising-backend -f
```

---

## 🔄 Part 6: Updating Deployment

### Update Backend

```bash
# From local machine
rsync -avz --exclude 'venv' --exclude '__pycache__' --exclude '.git' --exclude 'logs/*.log' backend_python/ root@72.61.232.15:/var/www/eventorganising/backend/

# SSH to server
ssh root@72.61.232.15

# Restart backend
cd /var/www/eventorganising/backend
source venv/bin/activate
pip install -r requirements.txt  # If dependencies changed
sudo systemctl restart eventorganising-backend
```

### Update Frontend

```bash
# From local machine
cd frontend
flutter build web --release --web-renderer html
rsync -avz build/web/ root@72.61.232.15:/var/www/eventorganising/frontend/

# No restart needed - nginx serves static files
```

---

## 🔒 Part 7: SSL/HTTPS Setup (Recommended)

### Using Let's Encrypt (Certbot)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get certificate (replace with your domain)
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal is set up automatically
# Test renewal:
sudo certbot renew --dry-run
```

After SSL setup, update:
1. `CORS_ORIGIN` in backend `.env` to include `https://yourdomain.com`
2. Frontend `apiBaseUrl` to use `https://yourdomain.com/api`
3. Rebuild frontend and upload

---

## 🐛 Troubleshooting

### Backend Not Starting

```bash
# Check logs
sudo journalctl -u eventorganising-backend -n 50

# Check if port 3000 is in use
sudo netstat -tlnp | grep 3000

# Test manually
cd /var/www/eventorganising/backend
source venv/bin/activate
python run.py
```

### Frontend Not Loading

```bash
# Check nginx error logs
sudo tail -f /var/log/nginx/error.log

# Check nginx access logs
sudo tail -f /var/log/nginx/access.log

# Verify files are in place
ls -la /var/www/eventorganising/frontend/
```

### MongoDB Connection Issues

```bash
# Check MongoDB status
sudo systemctl status mongod

# Check MongoDB logs
sudo tail -f /var/log/mongodb/mongod.log

# Test connection
mongosh
```

### CORS Errors

- Ensure `CORS_ORIGIN` in backend `.env` includes your frontend URL
- Check nginx configuration for CORS headers
- Restart backend after changing `.env`

---

## 📝 Quick Reference

### Service Management

```bash
# Backend
sudo systemctl start eventorganising-backend
sudo systemctl stop eventorganising-backend
sudo systemctl restart eventorganising-backend
sudo systemctl status eventorganising-backend

# Nginx
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl status nginx

# MongoDB
sudo systemctl start mongod
sudo systemctl stop mongod
sudo systemctl restart mongod
sudo systemctl status mongod
```

### File Locations

- Backend: `/var/www/eventorganising/backend/`
- Frontend: `/var/www/eventorganising/frontend/`
- Backend logs: `sudo journalctl -u eventorganising-backend`
- Nginx config: `/etc/nginx/sites-available/eventorganising`
- Environment file: `/var/www/eventorganising/backend/.env`

---

## 🎯 Summary

1. ✅ Server setup (Python, MongoDB, Nginx)
2. ✅ Backend deployment (FastAPI with systemd service)
3. ✅ Frontend deployment (Flutter web build)
4. ✅ Nginx configuration (reverse proxy)
5. ✅ SSL setup (optional but recommended)
6. ✅ Service management and monitoring

Your application should now be accessible at:
- **Frontend:** http://72.61.232.15 (or your domain)
- **Backend API:** http://72.61.232.15/api/
- **API Docs:** http://72.61.232.15/docs

