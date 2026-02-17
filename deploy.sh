#!/bin/bash

# 🚀 EventOrganising Deployment Script
# This script helps deploy frontend and backend to your server

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SERVER_IP="72.61.232.15"
SERVER_USER="root"
BACKEND_DIR="/var/www/eventorganising/backend"
FRONTEND_DIR="/var/www/eventorganising/frontend"

echo -e "${GREEN}🚀 EventOrganising Deployment Script${NC}"
echo ""

# Function to print section headers
print_section() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Ask what to deploy
echo "What would you like to deploy?"
echo "1) Backend only"
echo "2) Frontend only"
echo "3) Both (Backend + Frontend)"
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        DEPLOY_BACKEND=true
        DEPLOY_FRONTEND=false
        ;;
    2)
        DEPLOY_BACKEND=false
        DEPLOY_FRONTEND=true
        ;;
    3)
        DEPLOY_BACKEND=true
        DEPLOY_FRONTEND=true
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

# Deploy Backend
if [ "$DEPLOY_BACKEND" = true ]; then
    print_section "📦 Deploying Backend"
    
    # Check if backend directory exists
    if [ ! -d "backend_python" ]; then
        echo -e "${RED}✗ backend_python directory not found${NC}"
        exit 1
    fi
    
    echo "Uploading backend files to server..."
    rsync -avz --exclude 'venv' \
               --exclude '__pycache__' \
               --exclude '*.pyc' \
               --exclude '.git' \
               --exclude 'logs' \
               backend_python/ ${SERVER_USER}@${SERVER_IP}:${BACKEND_DIR}/
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Backend files uploaded successfully${NC}"
        echo ""
        echo -e "${YELLOW}⚠️  Next steps on server:${NC}"
        echo "1. SSH into server: ssh ${SERVER_USER}@${SERVER_IP}"
        echo "2. cd ${BACKEND_DIR}"
        echo "3. python3 -m venv venv"
        echo "4. source venv/bin/activate"
        echo "5. pip install --upgrade pip"
        echo "6. pip install -r requirements.txt"
        echo "7. Create .env file (see DEPLOY_NOW.md)"
        echo "8. systemctl restart eventorganising-backend"
    else
        echo -e "${RED}✗ Backend upload failed${NC}"
        exit 1
    fi
fi

# Deploy Frontend
if [ "$DEPLOY_FRONTEND" = true ]; then
    print_section "🎨 Deploying Frontend"
    
    # Check if frontend build exists
    if [ ! -d "frontend/build/web" ]; then
        echo -e "${YELLOW}⚠️  Frontend build not found. Building now...${NC}"
        cd frontend
        flutter clean
        flutter pub get
        flutter build web --release --dart-define=BUILD_MODE=production
        cd ..
    fi
    
    echo "Uploading frontend files to server..."
    rsync -avz --delete frontend/build/web/ ${SERVER_USER}@${SERVER_IP}:${FRONTEND_DIR}/
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Frontend files uploaded successfully${NC}"
    else
        echo -e "${RED}✗ Frontend upload failed${NC}"
        exit 1
    fi
fi

# Summary
print_section "✅ Deployment Complete"
echo ""
echo -e "${GREEN}Deployment Summary:${NC}"
echo "  Server: ${SERVER_IP}"
if [ "$DEPLOY_BACKEND" = true ]; then
    echo "  Backend: ${BACKEND_DIR}"
fi
if [ "$DEPLOY_FRONTEND" = true ]; then
    echo "  Frontend: ${FRONTEND_DIR}"
fi
echo ""
echo "Access your application:"
echo "  Frontend: http://${SERVER_IP}"
echo "  Backend API: http://${SERVER_IP}/api"
echo "  API Docs: http://${SERVER_IP}/api/docs"
echo ""
