#!/bin/bash

# Fix .env file - Run this ON THE SERVER

cd /var/www/eventorganising/backend

# Backup current .env
cp .env .env.backup

# Create correct .env file
cat > .env << 'EOF'
NODE_ENV=production
PORT=3000
DATABASE_URL=mongodb://localhost:27017/eventorganising
JWT_SECRET=48c418d81011f4047ac9adce37a365a2e8110e30d484349fa997d2004681daf7
JWT_EXPIRES_IN=1d
CORS_ORIGIN=http://72.61.232.15
FRONTEND_URL=http://72.61.232.15
EOF

echo "✅ .env file fixed!"
echo ""
echo "Changes made:"
echo "  - ENVIRONMENT → NODE_ENV"
echo "  - Removed JWT_REFRESH_EXPIRES_IN (not used in Settings model)"
echo ""
echo "Restart the service:"
echo "  systemctl restart eventorganising-backend"

