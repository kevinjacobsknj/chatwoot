#!/bin/bash

# Alternative Willo Deployment Script (Non-Docker / Manual Deployment)
# Use this if you're running Chatwoot directly without Docker

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Server configuration
SERVER_IP="134.199.192.48"
SERVER_USER="root"
SERVER_DIR="/root/chatwoot"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Willo Manual Deployment Script${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

ssh ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'

set -e

echo "Connected to server successfully!"
echo ""

# Navigate to directory
echo "Step 1: Navigating to /root/chatwoot..."
cd /root/chatwoot
echo ""

# Stop services (adjust these commands based on how you're running Chatwoot)
echo "Step 2: Stopping services..."
# If using systemd:
# sudo systemctl stop chatwoot.target
# If using foreman/overmind:
# pkill -f "bundle exec"
# Or if running with a process manager like PM2:
# pm2 stop chatwoot
echo "⚠ Note: Adjust the stop command based on your process manager"
echo ""

# Update git remote
echo "Step 3: Updating git remote to your fork..."
if git remote | grep -q "^origin$"; then
    CURRENT_URL=$(git remote get-url origin)
    if [[ "$CURRENT_URL" != *"kevinjacobsknj/chatwoot"* ]]; then
        git remote set-url origin https://github.com/kevinjacobsknj/chatwoot.git
    fi
else
    git remote add origin https://github.com/kevinjacobsknj/chatwoot.git
fi
echo ""

# Pull latest changes
echo "Step 4: Pulling latest changes..."
git fetch origin
git checkout willo-customizations
git pull origin willo-customizations
echo ""

echo "Latest commit:"
git log -1 --oneline
echo ""

# Install dependencies
echo "Step 5: Installing Ruby dependencies..."
bundle install
echo ""

echo "Step 6: Installing Node dependencies..."
pnpm install
echo ""

# Run database migrations
echo "Step 7: Running database migrations..."
RAILS_ENV=production bundle exec rails db:migrate
echo ""

# Run database seeds
echo "Step 8: Running database seeds..."
RAILS_ENV=production bundle exec rails db:seed
echo ""

# Precompile assets
echo "Step 9: Precompiling assets..."
RAILS_ENV=production bundle exec rails assets:precompile
echo ""

# Clear cache
echo "Step 10: Clearing Rails cache..."
RAILS_ENV=production bundle exec rails cache:clear
echo ""

# Restart services
echo "Step 11: Restarting services..."
# If using systemd:
# sudo systemctl start chatwoot.target
# If using foreman/overmind:
# overmind start -f Procfile &
# Or if using PM2:
# pm2 restart chatwoot
echo "⚠ Note: Adjust the start command based on your process manager"
echo ""

echo "======================================"
echo "Deployment completed! 🎉"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Manually restart your process manager (systemd/pm2/foreman)"
echo "2. Check logs to ensure services started correctly"
echo "3. Visit your application to verify Willo branding"
echo ""

ENDSSH

echo -e "${GREEN}Deployment script finished!${NC}"
