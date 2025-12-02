# Willo Deployment Guide

This guide helps you deploy your Willo customizations to your DigitalOcean server.

## Quick Start

**For Docker-based deployments (recommended):**
```bash
./deploy-willo.sh
```

**For manual/non-Docker deployments:**
```bash
./deploy-willo-manual.sh
```

---

## Deployment Scripts

### 1. `deploy-willo.sh` (Docker Deployment)

**Use this if:** You're running Chatwoot with Docker (using docker-compose)

**What it does:**
1. SSH into your server (134.199.192.48)
2. Navigates to /root/chatwoot
3. Stops Docker containers
4. Updates git remote to your fork
5. Pulls latest changes from willo-customizations branch
6. Builds custom Docker image with Willo branding
7. Tags image for docker-compose
8. Runs database migrations
9. Runs database seeds (adds Willo branding config)
10. Starts Docker containers
11. Shows logs and health check

**Requirements:**
- Docker and docker-compose installed on server
- SSH access to root@134.199.192.48
- Git repository at /root/chatwoot

**Run it:**
```bash
./deploy-willo.sh
```

**Estimated time:** 15-20 minutes (Docker build takes longest)

---

### 2. `deploy-willo-manual.sh` (Manual Deployment)

**Use this if:** You're running Chatwoot directly without Docker

**What it does:**
1. SSH into your server
2. Navigates to /root/chatwoot
3. Stops services (you need to customize this)
4. Pulls latest changes
5. Installs dependencies (bundle, pnpm)
6. Runs migrations
7. Runs seeds
8. Precompiles assets
9. Clears cache
10. Restarts services (you need to customize this)

**Requirements:**
- Ruby, Node.js, pnpm installed on server
- Process manager (systemd/pm2/foreman) set up
- SSH access

**Important:** You need to edit this script to:
- Uncomment and adjust the service stop command (line 30)
- Uncomment and adjust the service start command (line 70)

**Run it:**
```bash
./deploy-willo-manual.sh
```

---

## Before First Deployment

### 1. Verify SSH Access
```bash
ssh root@134.199.192.48
```

### 2. Check Server Setup

**For Docker deployments:**
```bash
ssh root@134.199.192.48 "cd /root/chatwoot && docker-compose -f docker-compose.production.yaml ps"
```

**For manual deployments:**
```bash
ssh root@134.199.192.48 "cd /root/chatwoot && bundle -v && pnpm -v"
```

### 3. Backup Database (Important!)

Before running migrations, backup your database:

```bash
ssh root@134.199.192.48 << 'EOF'
cd /root/chatwoot
docker-compose -f docker-compose.production.yaml exec postgres pg_dump -U postgres chatwoot > backup_$(date +%Y%m%d_%H%M%S).sql
EOF
```

Or for manual installations:
```bash
ssh root@134.199.192.48 "pg_dump -U postgres chatwoot > /root/backup_$(date +%Y%m%d_%H%M%S).sql"
```

---

## After Deployment

### 1. Verify Willo Branding

Visit your Chatwoot instance and check:
- Login page shows Willo logo
- Dashboard shows Willo branding
- Favicon is the Willo icon

### 2. Test Calendar Feature

1. Go to your profile settings
2. Add a Google Calendar URL
3. Navigate to Calendar page in sidebar
4. Verify calendar displays correctly

### 3. Check Logs

**Docker:**
```bash
ssh root@134.199.192.48 "cd /root/chatwoot && docker-compose -f docker-compose.production.yaml logs -f rails"
```

**Manual:**
```bash
ssh root@134.199.192.48 "cd /root/chatwoot && tail -f log/production.log"
```

---

## Troubleshooting

### Issue: Docker image build fails

**Solution:** Check available disk space
```bash
ssh root@134.199.192.48 "df -h"
```

Clean up old Docker images:
```bash
ssh root@134.199.192.48 "docker system prune -a"
```

### Issue: Migrations fail

**Solution:** Check database connection
```bash
ssh root@134.199.192.48 "cd /root/chatwoot && docker-compose -f docker-compose.production.yaml exec postgres psql -U postgres -c '\l'"
```

### Issue: Assets not updating

**Solution:** Clear browser cache and hard refresh (Cmd+Shift+R or Ctrl+Shift+R)

### Issue: Calendar not showing

**Checklist:**
1. Migration ran successfully? Check with `docker-compose exec rails bundle exec rails db:migrate:status`
2. User model has google_calendar_url field? Check in Rails console
3. Frontend built correctly? Check browser console for errors

---

## Rollback Procedure

If deployment fails and you need to rollback:

```bash
ssh root@134.199.192.48 << 'EOF'
cd /root/chatwoot
docker-compose -f docker-compose.production.yaml down
git checkout develop  # or your previous branch
git pull
docker build -f docker/Dockerfile -t chatwoot/chatwoot:latest .
docker-compose -f docker-compose.production.yaml up -d
EOF
```

---

## Manual Commands

### Connect to Rails Console
```bash
ssh root@134.199.192.48 "cd /root/chatwoot && docker-compose -f docker-compose.production.yaml run --rm rails bundle exec rails console"
```

### Run Specific Migration
```bash
ssh root@134.199.192.48 "cd /root/chatwoot && docker-compose -f docker-compose.production.yaml run --rm rails bundle exec rails db:migrate:up VERSION=20251201212834"
```

### Restart Specific Service
```bash
ssh root@134.199.192.48 "cd /root/chatwoot && docker-compose -f docker-compose.production.yaml restart rails"
```

### View Container Stats
```bash
ssh root@134.199.192.48 "cd /root/chatwoot && docker stats"
```

---

## Environment Variables

Make sure these are set in `/root/chatwoot/.env`:

```bash
# Required
SECRET_KEY_BASE=<your-secret-key>
POSTGRES_PASSWORD=<your-db-password>
REDIS_PASSWORD=<your-redis-password>
FRONTEND_URL=https://your-domain.com

# For production
RAILS_ENV=production
NODE_ENV=production
INSTALLATION_ENV=docker
```

---

## Support

If you encounter issues:

1. Check the logs first
2. Verify all environment variables are set
3. Ensure database is accessible
4. Check Docker/system resources
5. Review Chatwoot documentation: https://www.chatwoot.com/docs/

---

## What Changed in This Deployment

- ✅ Replaced Chatwoot branding with Willo logos and text
- ✅ Added Google Calendar integration feature
- ✅ Added google_calendar_url field to users table
- ✅ Added Calendar page in dashboard sidebar
- ✅ Generated all required favicon sizes
- ✅ Updated InstallationConfig with Willo branding

---

## Database Changes

**New Migration:** `20251201212834_add_google_calendar_url_to_users.rb`
- Adds `google_calendar_url` string column to `users` table

**New Seeds:**
- InstallationConfig entries for Willo logos
- InstallationConfig entries for Willo brand name
