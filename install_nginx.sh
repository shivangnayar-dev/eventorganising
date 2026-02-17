#!/bin/bash

# Install Nginx - Run this ON THE SERVER

echo "🌐 Installing Nginx..."

# Update package list
apt update

# Install Nginx
apt install -y nginx

# Check if installation was successful
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx installed and running"
else
    echo "⚠️  Starting Nginx..."
    systemctl start nginx
    systemctl enable nginx
fi

# Check status
systemctl status nginx

echo ""
echo "✅ Nginx installation complete!"
echo ""
echo "Next: Configure Nginx (see instructions)"

