#!/bin/bash

# Verification Script - Run this ON THE SERVER

echo "🔍 Verifying Deployment..."
echo ""

echo "1️⃣ Checking Backend Service..."
systemctl status eventorganising-backend --no-pager -l | head -15

echo ""
echo "2️⃣ Checking Nginx Service..."
systemctl status nginx --no-pager -l | head -10

echo ""
echo "3️⃣ Testing Backend API (localhost)..."
curl -s http://localhost:3000/health || echo "❌ Backend not responding on port 3000"

echo ""
echo "4️⃣ Testing Backend API (via Nginx)..."
curl -s http://72.61.232.15/api/health || echo "❌ Backend not accessible via Nginx"

echo ""
echo "5️⃣ Checking if port 3000 is listening..."
netstat -tulpn | grep 3000 || echo "❌ Port 3000 not listening"

echo ""
echo "6️⃣ Checking Frontend files..."
ls -la /var/www/eventorganising/frontend/ | head -10

echo ""
echo "7️⃣ Checking Backend files..."
ls -la /var/www/eventorganising/backend/ | head -10

echo ""
echo "✅ Verification complete!"
echo ""
echo "🌐 Access your application:"
echo "   Frontend: http://72.61.232.15"
echo "   Backend API: http://72.61.232.15/api"
echo "   API Docs: http://72.61.232.15/api/docs"

