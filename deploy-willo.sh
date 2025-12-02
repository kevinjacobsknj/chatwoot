#!/bin/bash

# Willo Deployment Script for DigitalOcean Server
# This script deploys the Willo customizations to your production server

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Server configuration
SERVER_IP="134.199.192.48"
SERVER_USER="root"
SERVER_DIR="/root/chatwoot"
FORK_URL="https://github.com/kevinjacobsknj/chatwoot.git"
BRANCH="willo-customizations"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Willo Deployment Script${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Function to run commands on remote server
run_remote() {
    ssh ${SERVER_USER}@${SERVER_IP} "$@"
}

echo -e "${YELLOW}Step 1: Connecting to server...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'

set -e

echo "Connected to server successfully!"
echo ""

# Navigate to Chatwoot directory
echo "Step 2: Navigating to /root/chatwoot..."
cd /root/chatwoot
echo "Current directory: $(pwd)"
echo ""

# Check current git status
echo "Step 3: Checking current git status..."
git status
echo ""

# Stop Docker containers
echo "Step 4: Stopping Docker containers..."
docker-compose -f docker-compose.production.yaml down
echo "Containers stopped successfully!"
echo ""

# Update git remote to point to your fork (if not already set)
echo "Step 5: Updating git remote to your fork..."
if git remote | grep -q "^origin$"; then
    CURRENT_URL=$(git remote get-url origin)
    echo "Current remote URL: $CURRENT_URL"
    if [[ "$CURRENT_URL" != *"kevinjacobsknj/chatwoot"* ]]; then
        echo "Updating remote URL to your fork..."
        git remote set-url origin https://github.com/kevinjacobsknj/chatwoot.git
    fi
else
    git remote add origin https://github.com/kevinjacobsknj/chatwoot.git
fi
echo ""

# Fetch latest changes
echo "Step 6: Fetching latest changes from your fork..."
git fetch origin
echo ""

# Checkout and pull the willo-customizations branch
echo "Step 7: Checking out willo-customizations branch..."
git checkout willo-customizations
git pull origin willo-customizations
echo "Branch updated successfully!"
echo ""

# Show latest commit
echo "Latest commit:"
git log -1 --oneline
echo ""

# Build custom Docker image with Willo branding
echo "Step 8: Building custom Docker image..."
echo "This may take 10-15 minutes..."
docker build -f docker/Dockerfile -t chatwoot-willo:latest .
echo "Docker image built successfully!"
echo ""

# Tag the image so docker-compose can use it
echo "Step 9: Tagging Docker image..."
docker tag chatwoot-willo:latest chatwoot/chatwoot:latest
echo "Image tagged successfully!"
echo ""

# Run database migrations
echo "Step 10: Running database migrations..."
docker-compose -f docker-compose.production.yaml run --rm rails bundle exec rails db:migrate
echo "Migrations completed successfully!"
echo ""

# Run database seeds
echo "Step 11: Running database seeds for Willo branding..."
docker-compose -f docker-compose.production.yaml run --rm rails bundle exec rails db:seed
echo "Seeds completed successfully!"
echo ""

# Start Docker containers
echo "Step 12: Starting Docker containers..."
docker-compose -f docker-compose.production.yaml up -d
echo "Containers started successfully!"
echo ""

# Wait for services to start
echo "Step 13: Waiting for services to start (30 seconds)..."
sleep 30
echo ""

# Check container status
echo "Step 14: Checking container status..."
docker-compose -f docker-compose.production.yaml ps
echo ""

# Check logs for any errors
echo "Step 15: Checking recent logs..."
echo "========== Rails Logs =========="
docker-compose -f docker-compose.production.yaml logs --tail=50 rails
echo ""
echo "========== Sidekiq Logs =========="
docker-compose -f docker-compose.production.yaml logs --tail=50 sidekiq
echo ""

# Test if the application is responding
echo "Step 16: Testing application health..."
if curl -f http://localhost:3000/health >/dev/null 2>&1; then
    echo "✓ Application is healthy and responding!"
else
    echo "⚠ Warning: Application health check failed. Check logs above."
fi
echo ""

echo "======================================"
echo "Deployment completed successfully! 🎉"
echo "======================================"
echo ""
echo "Your Willo-branded Chatwoot is now running!"
echo ""
echo "Next steps:"
echo "1. Visit your server to verify the changes"
echo "2. Check that the Willo branding is visible"
echo "3. Test the Calendar feature by adding a Google Calendar URL in your profile settings"
echo ""
echo "Useful commands:"
echo "  View logs:           docker-compose -f docker-compose.production.yaml logs -f"
echo "  Restart containers:  docker-compose -f docker-compose.production.yaml restart"
echo "  Stop containers:     docker-compose -f docker-compose.production.yaml down"
echo ""

ENDSSH

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Deployment script finished!${NC}"
echo -e "${GREEN}=====================================${NC}"
