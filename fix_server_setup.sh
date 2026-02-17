#!/bin/bash

# Fix Server Setup - Run this ON THE SERVER
# This fixes missing Python packages

echo "🔧 Installing required Python packages..."

# Install Python venv and pip
apt update
apt install -y python3-venv python3-pip

echo "✅ Packages installed"
echo ""

# Remove old venv if it exists
cd /var/www/eventorganising/backend
if [ -d "venv" ]; then
    echo "Removing old virtual environment..."
    rm -rf venv
fi

# Create new virtual environment
echo "Creating new virtual environment..."
python3 -m venv venv

# Activate and upgrade pip
echo "Activating virtual environment and upgrading pip..."
source venv/bin/activate
pip install --upgrade pip

echo ""
echo "✅ Virtual environment created successfully!"
echo ""
echo "Next steps:"
echo "1. Install dependencies: pip install -r requirements.txt"
echo "2. Create .env file"
echo "3. Setup systemd service"

