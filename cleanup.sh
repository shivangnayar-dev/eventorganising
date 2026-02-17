#!/bin/bash

# Cleanup script - Removes all deployment files and keeps only code
# This will delete:
# - All .md files (documentation)
# - All .sh files (deployment scripts)
# - All .tar.gz files (Docker images)
# - Dockerfile and docker-compose.yml
# Keeps: backend/ and frontend/ directories

set -e

echo "🧹 Cleaning up deployment files..."
echo ""

# Delete all markdown files (except README.md files)
echo "Deleting documentation files..."
find . -maxdepth 1 -name "*.md" -type f ! -name "README.md" -delete
echo "✓ Documentation files deleted"

# Delete all shell scripts in root
echo "Deleting deployment scripts..."
find . -maxdepth 1 -name "*.sh" -type f -delete
echo "✓ Deployment scripts deleted"

# Delete Docker images
echo "Deleting Docker image files..."
rm -f *.tar.gz
echo "✓ Docker images deleted"

# Delete Docker files
echo "Deleting Docker configuration files..."
rm -f Dockerfile docker-compose.yml
echo "✓ Docker files deleted"

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "Remaining files:"
ls -la | grep -E "^d" | awk '{print $9}' | grep -v "^\.$" | grep -v "^\.\.$"
echo ""
echo "Code directories kept:"
echo "  - backend/"
echo "  - frontend/"

