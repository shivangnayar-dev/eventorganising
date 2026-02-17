#!/bin/bash

# Script to create necessary directories on the server
# Run this on the SERVER (SSH into server first)

echo "Creating directories on server..."

# Create main application directory
mkdir -p /var/www/eventorganising/backend
mkdir -p /var/www/eventorganising/frontend

# Set permissions
chown -R root:root /var/www/eventorganising
chmod -R 755 /var/www/eventorganising

echo "✅ Directories created successfully!"
echo ""
echo "Directories created:"
echo "  - /var/www/eventorganising/backend"
echo "  - /var/www/eventorganising/frontend"

