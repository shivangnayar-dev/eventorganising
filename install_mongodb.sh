#!/bin/bash

# Install MongoDB - Run this ON THE SERVER

echo "🍃 Installing MongoDB..."

# Import MongoDB public GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Update package list
apt update

# Install MongoDB
apt install -y mongodb-org

# Start MongoDB
systemctl start mongod
systemctl enable mongod

# Check status
systemctl status mongod

echo ""
echo "✅ MongoDB installation complete!"

