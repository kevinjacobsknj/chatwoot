# Willo Chatwoot Deployment Guide

## Overview
This guide covers deploying the Willo-branded Chatwoot instance to the production server.

**Server Details:**
- IP: 134.199.192.48
- User: root
- Directory: /root/chatwoot
- Branch: willo-customizations
- Docker Image: willo-app:latest

## What's Included in This Release

### Branding ✓
- Willo logos (light and dark modes)
- Login page: "Login to Willo"
- Email templates updated
- Super admin interface branding
- Installation configs for Willo

### Features ✓
1. **Calendar Integration**
   - New "Calendar" tab in sidebar
   - Google Calendar embedding support
   - Profile settings for calendar URL
   - Database migration for `google_calendar_url` field

2. **AI Captain** (Enabled with feature flags)
   - Captain tab in sidebar
   - FAQs, Documents, Scenarios
   - Playground, Inboxes, Tools
   - Settings and Guidelines

3. **Premium Features Enabled**
   - `captain_integration` - AI Captain v1
   - `captain_integration_v2` - AI Captain v2
   - `disable_branding` - Custom branding
   - `audit_logs` - Audit logging
   - `sla` - SLA management
   - `custom_roles` - Custom user roles

## Quick Deployment

### Option 1: Automated Script (Recommended)
```bash
# From your local machine
cd /Users/kebing/chatwoot
./deploy-willo-production.sh
```

This script will:
1. Pull latest code from GitHub
2. Rebuild Docker image (no cache)
3. Stop containers
4. Run database migrations
5. Run database seeds
6. Enable features for existing accounts
7. Start containers
8. Clear caches

### Option 2: Manual Deployment

```bash
# SSH into the server
ssh root@134.199.192.48

# Navigate to app directory
cd /root/chatwoot

# Pull latest code
git fetch origin
git checkout willo-customizations
git pull origin willo-customizations

# Rebuild Docker image (no cache for fresh assets)
docker build --no-cache -t willo-app:latest -f docker/Dockerfile .

# Stop containers
docker-compose down

# Run migrations
docker-compose run --rm rails bundle exec rails db:migrate

# Run seeds (for feature flags and branding)
docker-compose run --rm rails bundle exec rails db:seed

# Enable features for existing accounts
docker-compose run --rm rails bundle exec rails runner "
Account.find_each do |account|
  account.enable_features!('captain_integration', 'captain_integration_v2', 'disable_branding', 'audit_logs', 'sla', 'custom_roles')
  puts \"Enabled features for account: #{account.name}\"
end
"

# Start containers
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f rails
```

## Verification Checklist

After deployment, verify the following:

### 1. Access the Application
- [ ] Visit your Willo instance in browser
- [ ] Clear browser cache (Cmd+Shift+R or Ctrl+Shift+R)

### 2. Check Branding
- [ ] Login page shows "Login to Willo"
- [ ] Willo logos visible in sidebar
- [ ] Dark mode logos display correctly
- [ ] Favicon is Willo logo

### 3. Check Calendar Feature
- [ ] "Calendar" tab appears in sidebar
- [ ] Click Calendar tab - see setup instructions
- [ ] Go to Profile Settings → see "Google Calendar URL" field
- [ ] Paste a Google Calendar embed URL
- [ ] Return to Calendar tab → see embedded calendar

### 4. Check AI Captain Feature
- [ ] "Captain" tab appears in sidebar (with AI icon)
- [ ] Click Captain → see sub-items: FAQs, Documents, Scenarios, Playground, Inboxes, Tools, Settings
- [ ] Access each sub-section to verify it loads

### 5. Check Other Features
- [ ] Conversations, Contacts, Companies all work
- [ ] Reports section accessible
- [ ] Settings → Custom Roles available
- [ ] Settings → Audit Logs available
- [ ] Settings → SLA available

## Troubleshooting

### Captain Tab Not Showing

**Step 1: Verify Enterprise Mode**
```bash
ssh root@134.199.192.48
cd /root/chatwoot

# Check if enterprise directory exists
ls -la | grep enterprise
# Should show: drwxr-xr-x ... enterprise

# Check if enterprise is enabled in Rails
docker-compose run --rm rails bundle exec rails runner "puts ChatwootApp.enterprise?"
# Should output: true

# Check environment variable
docker-compose run --rm rails bundle exec rails runner "puts ENV['DISABLE_ENTERPRISE']"
# Should output: (blank) or false, NOT true
```

**Step 2: Verify Feature Flags**
```bash
# Check account features
docker-compose run --rm rails bundle exec rails console
# In Rails console:
Account.first.enabled_features
# Should include "captain_integration" and "captain_integration_v2"

# If not, enable manually:
Account.find_each do |account|
  account.enable_features!('captain_integration', 'captain_integration_v2')
end
```

**Step 3: Check Installation Type in Browser**
- Open browser console (F12)
- Type: `window.chatwootConfig.isEnterprise`
- Should output: `"true"`
- Type: `window.globalConfig.isEnterprise`
- Should output: `true`

### Calendar Tab Not Showing
- Calendar tab should always show (no feature flag required)
- Check that migration ran: `docker-compose run --rm rails bundle exec rails db:migrate:status`
- Look for: `20251201212834_add_google_calendar_url_to_users`

### Branding Not Updating
```bash
# Clear Docker image cache
docker system prune -a
docker build --no-cache -t willo-app:latest -f docker/Dockerfile .
docker-compose up -d

# Clear browser cache
# Chrome/Edge: Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)
# Firefox: Cmd+Shift+R (Mac) or Ctrl+F5 (Windows)
```

### Database Issues
```bash
# Check migrations
docker-compose run --rm rails bundle exec rails db:migrate:status

# Run migrations if pending
docker-compose run --rm rails bundle exec rails db:migrate

# Check database connection
docker-compose run --rm rails bundle exec rails db:version
```

## Environment Variables

Make sure these are set in `/root/chatwoot/.env`:

```bash
# Required for production
RAILS_ENV=production
NODE_ENV=production
SECRET_KEY_BASE=<your-secret-key>

# Database (should match docker-compose.yaml)
POSTGRES_HOST=postgres
POSTGRES_DB=chatwoot
POSTGRES_USER=postgres
POSTGRES_PASSWORD=<your-password>

# Redis
REDIS_URL=redis://redis:6379
REDIS_PASSWORD=<your-password>

# Frontend URL
FRONTEND_URL=http://your-domain.com  # or https://

# CRITICAL: Enterprise Features
# DO NOT SET DISABLE_ENTERPRISE=true or Captain won't work!
# Enterprise features are enabled automatically if enterprise/ directory exists

# Optional: For Captain AI features
OPENAI_API_KEY=<your-openai-key>  # If using OpenAI for Captain
```

## How Enterprise Features Work

**Captain is an Enterprise Feature** that requires:

1. **Enterprise directory present** ✓ (Already in your repo)
   - The `enterprise/` directory contains all Captain backend code
   - `ChatwootApp.enterprise?` returns `true` if this directory exists

2. **Feature flags enabled** ✓ (Configured in seeds.rb)
   - `captain_integration`
   - `captain_integration_v2`

3. **NOT disabled by environment** (Check your .env)
   - Make sure `DISABLE_ENTERPRISE` is NOT set to `true`
   - If not set at all, that's fine - it defaults to false

**License Note:**
- Enterprise code in `enterprise/` directory has a separate license
- For development/testing/self-hosted use: You can use it freely
- For production commercial use: Technically requires Chatwoot Enterprise license
- See `enterprise/LICENSE` for full details

## Logs and Monitoring

### View Logs
```bash
# All services
docker-compose logs -f

# Rails only
docker-compose logs -f rails

# Sidekiq only
docker-compose logs -f sidekiq

# Last 100 lines
docker-compose logs --tail=100 rails
```

### Container Status
```bash
# Check running containers
docker-compose ps

# Check resource usage
docker stats
```

## Rollback

If something goes wrong, rollback to previous commit:

```bash
ssh root@134.199.192.48
cd /root/chatwoot

# Find previous commit
git log --oneline -5

# Checkout previous commit (e.g., 2aa629748)
git checkout 2aa629748

# Rebuild and restart
docker build -t willo-app:latest -f docker/Dockerfile .
docker-compose down
docker-compose up -d
```

## Support

### Check This First
1. View server logs: `docker-compose logs -f rails`
2. Check container status: `docker-compose ps`
3. Verify migrations: `docker-compose run --rm rails bundle exec rails db:migrate:status`
4. Check enabled features: Rails console → `Account.first.enabled_features`

### Common Issues
- **502 Bad Gateway**: Rails container may be starting up (wait 30-60 seconds)
- **Features not showing**: Run feature enablement command again
- **Branding not updating**: Rebuild Docker image with `--no-cache`
- **Database errors**: Check migrations and database connection

## Next Steps After Deployment

1. **Configure Captain AI**
   - Add OpenAI API key if using OpenAI
   - Configure Captain settings in the UI
   - Add FAQs and documents

2. **Set Up Google Calendar**
   - Get Google Calendar public embed URL
   - Add to profile settings
   - Test calendar display

3. **User Training**
   - Show users where Calendar tab is
   - Demonstrate Captain AI features
   - Explain how to set up their own calendar

4. **Monitoring**
   - Set up uptime monitoring
   - Configure backup schedules
   - Monitor Docker container health

---

**Last Updated:** 2025-12-01
**Commit:** 2503b98a9 - Update Willo branding logos and enable premium features
