#!/bin/bash

# Backend Setup Script - Run this ON THE SERVER
# SSH into server first: ssh root@72.61.232.15

set -e

echo "🚀 Setting up EventOrganising Backend..."
echo ""

# Navigate to backend directory
cd /var/www/eventorganising/backend

echo "📦 Step 1: Creating Python virtual environment..."
python3 -m venv venv

echo "✅ Virtual environment created"
echo ""

echo "📦 Step 2: Activating virtual environment and upgrading pip..."
source venv/bin/activate
pip install --upgrade pip

echo "✅ Pip upgraded"
echo ""

echo "📦 Step 3: Installing Python dependencies..."
pip install -r requirements.txt

echo "✅ Dependencies installed"
echo ""

echo "📝 Step 4: Checking .env file..."
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating template..."
    cat > .env << 'EOF'
# Environment
ENVIRONMENT=production

# Server
PORT=3000

# Database (MongoDB)
DATABASE_URL=mongodb://localhost:27017/eventorganising

# JWT Secret (CHANGE THIS - generate with: openssl rand -hex 32)
JWT_SECRET=CHANGE_THIS_TO_A_SECURE_RANDOM_STRING_AT_LEAST_32_CHARACTERS_LONG
JWT_EXPIRES_IN=1d
JWT_REFRESH_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=http://72.61.232.15

# Frontend URL
FRONTEND_URL=http://72.61.232.15
EOF
    echo "✅ .env template created"
    echo ""
    echo "⚠️  IMPORTANT: Edit .env file and set JWT_SECRET!"
    echo "   Run: nano /var/www/eventorganising/backend/.env"
    echo "   Generate secret: openssl rand -hex 32"
else
    echo "✅ .env file exists"
fi

echo ""
echo "📝 Step 5: Creating systemd service..."
cat > /etc/systemd/system/eventorganising-backend.service << 'EOF'
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
EOF

echo "✅ Systemd service file created"
echo ""

echo "🔄 Step 6: Reloading systemd and enabling service..."
systemctl daemon-reload
systemctl enable eventorganising-backend

echo "✅ Service enabled"
echo ""

echo "📝 Step 7: Initializing database (creating admin user)..."
python scripts/create_admin.py

echo ""
echo "✅ Backend setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Edit .env file and set JWT_SECRET:"
echo "   nano /var/www/eventorganising/backend/.env"
echo "   Generate secret: openssl rand -hex 32"
echo ""
echo "2. Start the backend service:"
echo "   systemctl start eventorganising-backend"
echo ""
echo "3. Check service status:"
echo "   systemctl status eventorganising-backend"
echo ""
echo "4. View logs:"
echo "   journalctl -u eventorganising-backend -f"

