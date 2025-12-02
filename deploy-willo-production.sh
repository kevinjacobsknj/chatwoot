#!/bin/bash

# Willo Chatwoot Production Deployment Script
# This script deploys the latest Willo customizations to the production server

set -e  # Exit on any error

SERVER="root@134.199.192.48"
APP_DIR="/root/chatwoot"
BRANCH="willo-customizations"

echo "======================================"
echo "Willo Chatwoot Production Deployment"
echo "======================================"
echo ""
echo "Server: $SERVER"
echo "Directory: $APP_DIR"
echo "Branch: $BRANCH"
echo ""

# Step 1: SSH into server and pull latest code
echo "Step 1: Pulling latest code from GitHub..."
ssh $SERVER << 'ENDSSH'
cd /root/chatwoot
git fetch origin
git checkout willo-customizations
git pull origin willo-customizations
echo "✓ Code updated to latest commit"
ENDSSH

# Step 2: Rebuild Docker image (no cache for fresh assets)
echo ""
echo "Step 2: Rebuilding Docker image with fresh assets..."
ssh $SERVER << 'ENDSSH'
cd /root/chatwoot
# Build custom willo-app image from Dockerfile
docker build --no-cache -t willo-app:latest -f docker/Dockerfile .
echo "✓ Docker image rebuilt: willo-app:latest"
ENDSSH

# Step 3: Stop containers
echo ""
echo "Step 3: Stopping containers..."
ssh $SERVER << 'ENDSSH'
cd /root/chatwoot
# Try production compose file first, fallback to default
if [ -f "docker-compose.production.yaml" ]; then
  docker-compose -f docker-compose.production.yaml down
else
  docker-compose down
fi
echo "✓ Containers stopped"
ENDSSH

# Step 4: Run database migrations
echo ""
echo "Step 4: Running database migrations..."
ssh $SERVER << 'ENDSSH'
cd /root/chatwoot
COMPOSE_FILE=$([ -f "docker-compose.production.yaml" ] && echo "docker-compose.production.yaml" || echo "docker-compose.yaml")
docker-compose -f $COMPOSE_FILE run --rm rails bundle exec rails db:migrate
echo "✓ Migrations completed"
ENDSSH

# Step 5: Run database seeds (for feature flags and branding)
echo ""
echo "Step 5: Running database seeds..."
ssh $SERVER << 'ENDSSH'
cd /root/chatwoot
COMPOSE_FILE=$([ -f "docker-compose.production.yaml" ] && echo "docker-compose.production.yaml" || echo "docker-compose.yaml")
docker-compose -f $COMPOSE_FILE run --rm rails bundle exec rails db:seed
echo "✓ Seeds completed"
ENDSSH

# Step 6: Enable features for existing accounts
echo ""
echo "Step 6: Enabling Captain features for existing accounts..."
ssh $SERVER << 'ENDSSH'
cd /root/chatwoot
COMPOSE_FILE=$([ -f "docker-compose.production.yaml" ] && echo "docker-compose.production.yaml" || echo "docker-compose.yaml")
docker-compose -f $COMPOSE_FILE run --rm rails bundle exec rails runner "
Account.find_each do |account|
  account.enable_features!('captain_integration', 'captain_integration_v2', 'disable_branding', 'audit_logs', 'sla', 'custom_roles')
  puts \"Enabled features for account: #{account.name}\"
end
"
echo "✓ Features enabled for all accounts"
ENDSSH

# Step 7: Start containers
echo ""
echo "Step 7: Starting containers..."
ssh $SERVER << 'ENDSSH'
cd /root/chatwoot
COMPOSE_FILE=$([ -f "docker-compose.production.yaml" ] && echo "docker-compose.production.yaml" || echo "docker-compose.yaml")
docker-compose -f $COMPOSE_FILE up -d
echo "✓ Containers started"
ENDSSH

# Step 8: Clear frontend cache (if using nginx)
echo ""
echo "Step 8: Clearing frontend cache..."
ssh $SERVER << 'ENDSSH'
# Clear any nginx cache if configured
if [ -d "/var/cache/nginx" ]; then
  rm -rf /var/cache/nginx/*
  echo "✓ Nginx cache cleared"
fi

# Restart nginx if it exists
if command -v nginx &> /dev/null; then
  nginx -t && nginx -s reload
  echo "✓ Nginx reloaded"
fi
ENDSSH

# Step 9: Show container status
echo ""
echo "Step 9: Checking container status..."
ssh $SERVER << 'ENDSSH'
cd /root/chatwoot
COMPOSE_FILE=$([ -f "docker-compose.production.yaml" ] && echo "docker-compose.production.yaml" || echo "docker-compose.yaml")
docker-compose -f $COMPOSE_FILE ps
ENDSSH

echo ""
echo "======================================"
echo "✓ Deployment Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Visit your Willo instance and verify branding"
echo "2. Check that Calendar tab appears in sidebar"
echo "3. Check that Captain tab appears in sidebar"
echo "4. Test calendar URL in profile settings"
echo "5. Clear browser cache if needed (Cmd+Shift+R)"
echo ""
echo "Logs: ssh $SERVER 'cd $APP_DIR && docker-compose logs -f rails'"
echo ""
