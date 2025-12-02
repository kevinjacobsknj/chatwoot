#!/bin/bash

# Pre-Deployment Checklist Script
# Run this before deploying to verify everything is ready

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SERVER_IP="134.199.192.48"
SERVER_USER="root"

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Pre-Deployment Checklist${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check 1: SSH Connection
echo -e "${YELLOW}[1/8] Checking SSH connection...${NC}"
if ssh -o ConnectTimeout=5 ${SERVER_USER}@${SERVER_IP} "echo 'Connected'" &>/dev/null; then
    echo -e "${GREEN}✓ SSH connection successful${NC}"
else
    echo -e "${RED}✗ Cannot connect to server${NC}"
    echo "Please check your SSH configuration and network connectivity"
    exit 1
fi
echo ""

# Check 2: Directory exists
echo -e "${YELLOW}[2/8] Checking if /root/chatwoot directory exists...${NC}"
if ssh ${SERVER_USER}@${SERVER_IP} "test -d /root/chatwoot"; then
    echo -e "${GREEN}✓ Directory exists${NC}"
else
    echo -e "${RED}✗ Directory /root/chatwoot not found${NC}"
    exit 1
fi
echo ""

# Check 3: Git repository
echo -e "${YELLOW}[3/8] Checking git repository...${NC}"
GIT_STATUS=$(ssh ${SERVER_USER}@${SERVER_IP} "cd /root/chatwoot && git status" 2>&1)
if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ Git repository found${NC}"
    echo "Current branch:"
    ssh ${SERVER_USER}@${SERVER_IP} "cd /root/chatwoot && git branch --show-current"
else
    echo -e "${RED}✗ Not a git repository${NC}"
    exit 1
fi
echo ""

# Check 4: Docker installed
echo -e "${YELLOW}[4/8] Checking Docker installation...${NC}"
if ssh ${SERVER_USER}@${SERVER_IP} "which docker" &>/dev/null; then
    echo -e "${GREEN}✓ Docker is installed${NC}"
    DOCKER_VERSION=$(ssh ${SERVER_USER}@${SERVER_IP} "docker --version")
    echo "  $DOCKER_VERSION"
else
    echo -e "${RED}✗ Docker not found${NC}"
    echo "Note: If you're not using Docker, use the manual deployment script instead"
fi
echo ""

# Check 5: docker-compose installed
echo -e "${YELLOW}[5/8] Checking docker-compose...${NC}"
if ssh ${SERVER_USER}@${SERVER_IP} "which docker-compose" &>/dev/null; then
    echo -e "${GREEN}✓ docker-compose is installed${NC}"
    COMPOSE_VERSION=$(ssh ${SERVER_USER}@${SERVER_IP} "docker-compose --version")
    echo "  $COMPOSE_VERSION"
else
    echo -e "${RED}✗ docker-compose not found${NC}"
fi
echo ""

# Check 6: Running containers
echo -e "${YELLOW}[6/8] Checking running containers...${NC}"
CONTAINERS=$(ssh ${SERVER_USER}@${SERVER_IP} "cd /root/chatwoot && docker-compose -f docker-compose.production.yaml ps -q" 2>/dev/null | wc -l)
if [ $CONTAINERS -gt 0 ]; then
    echo -e "${GREEN}✓ Found $CONTAINERS running container(s)${NC}"
    ssh ${SERVER_USER}@${SERVER_IP} "cd /root/chatwoot && docker-compose -f docker-compose.production.yaml ps"
else
    echo -e "${YELLOW}⚠ No containers running${NC}"
    echo "This is okay if it's a fresh installation"
fi
echo ""

# Check 7: Disk space
echo -e "${YELLOW}[7/8] Checking disk space...${NC}"
DISK_INFO=$(ssh ${SERVER_USER}@${SERVER_IP} "df -h /root/chatwoot | tail -1")
DISK_USAGE=$(echo $DISK_INFO | awk '{print $5}' | sed 's/%//')
echo "  $DISK_INFO"
if [ $DISK_USAGE -lt 80 ]; then
    echo -e "${GREEN}✓ Sufficient disk space (${DISK_USAGE}% used)${NC}"
else
    echo -e "${RED}✗ Low disk space (${DISK_USAGE}% used)${NC}"
    echo "Consider cleaning up old Docker images: docker system prune -a"
fi
echo ""

# Check 8: Environment file
echo -e "${YELLOW}[8/8] Checking .env file...${NC}"
if ssh ${SERVER_USER}@${SERVER_IP} "test -f /root/chatwoot/.env"; then
    echo -e "${GREEN}✓ .env file exists${NC}"

    # Check for required variables
    ENV_ISSUES=0

    if ! ssh ${SERVER_USER}@${SERVER_IP} "cd /root/chatwoot && grep -q '^SECRET_KEY_BASE=' .env"; then
        echo -e "${RED}  ✗ SECRET_KEY_BASE not set${NC}"
        ENV_ISSUES=$((ENV_ISSUES + 1))
    fi

    if ! ssh ${SERVER_USER}@${SERVER_IP} "cd /root/chatwoot && grep -q '^POSTGRES_PASSWORD=' .env"; then
        echo -e "${RED}  ✗ POSTGRES_PASSWORD not set${NC}"
        ENV_ISSUES=$((ENV_ISSUES + 1))
    fi

    if ! ssh ${SERVER_USER}@${SERVER_IP} "cd /root/chatwoot && grep -q '^FRONTEND_URL=' .env"; then
        echo -e "${RED}  ✗ FRONTEND_URL not set${NC}"
        ENV_ISSUES=$((ENV_ISSUES + 1))
    fi

    if [ $ENV_ISSUES -eq 0 ]; then
        echo -e "${GREEN}  ✓ Required environment variables are set${NC}"
    else
        echo -e "${YELLOW}  ⚠ Please review your .env file${NC}"
    fi
else
    echo -e "${RED}✗ .env file not found${NC}"
    echo "You need to create a .env file before deploying"
    exit 1
fi
echo ""

# Summary
echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Pre-Deployment Summary${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Recommend backup
echo -e "${YELLOW}⚠ Important: Backup your database before deploying!${NC}"
echo ""
echo "Run this command to create a backup:"
echo -e "${GREEN}ssh ${SERVER_USER}@${SERVER_IP} 'cd /root/chatwoot && docker-compose -f docker-compose.production.yaml exec postgres pg_dump -U postgres chatwoot > backup_\$(date +%Y%m%d_%H%M%S).sql'${NC}"
echo ""

echo -e "${GREEN}All checks passed! You're ready to deploy.${NC}"
echo ""
echo "To deploy, run:"
echo -e "${GREEN}./deploy-willo.sh${NC}"
echo ""
