# Migration Guide: Upgrading to New Docker Configuration

## Overview

This guide helps you migrate from the old Docker configuration to the new, improved setup. The migration process should take 5-10 minutes.

## ⚠️ Before You Begin

### Backup Your Data

```bash
# Backup PostgreSQL database
docker exec postiz-postgres pg_dump -U postiz-local postiz-db-local > backup_$(date +%Y%m%d).sql

# Backup Redis data (if needed)
docker exec postiz-redis redis-cli -a dev-redis-password --rdb backup.rdb

# Or backup volumes
docker run --rm -v postiz-postgres-volume:/data -v $(pwd):/backup alpine tar czf /backup/postgres-backup.tar.gz /data
```

## 🔄 Migration Steps

### Step 1: Stop Current Services

```bash
# Stop all running containers
docker-compose down

# If using old docker-compose.dev.yaml
docker-compose -f docker-compose.dev.yaml down
```

**Note**: This preserves your data volumes.

### Step 2: Pull Latest Changes

```bash
git stash  # Stash any local changes
git pull origin main
git stash pop  # Restore local changes if needed
```

### Step 3: Set Up Environment Variables

```bash
# Copy the example file
cp docker.env.example .env

# Edit with your preferences
nano .env  # or vim, code, etc.
```

**Important Environment Variables to Configure:**

```bash
# Database credentials (keep your existing ones if you want to preserve data)
POSTGRES_USER=postiz-local
POSTGRES_PASSWORD=postiz-local-pwd  # Change for better security
POSTGRES_DB=postiz-db-local

# Redis password (NEW - required!)
REDIS_PASSWORD=dev-redis-password  # Change this!

# Admin tools
PGADMIN_EMAIL=admin@admin.com
PGADMIN_PASSWORD=admin
```

### Step 4: Update Application Configuration

If your application connects to Redis, update the connection to include the password:

**Before:**
```javascript
const redis = new Redis({
  host: 'postiz-redis',
  port: 6379
});
```

**After:**
```javascript
const redis = new Redis({
  host: 'postiz-redis',
  port: 6379,
  password: process.env.REDIS_PASSWORD || 'dev-redis-password'
});
```

Or using connection URL:
```javascript
const redis = new Redis(process.env.REDIS_URL || 'redis://:dev-redis-password@postiz-redis:6379');
```

### Step 5: Start New Configuration

```bash
# Start services with new configuration
docker-compose -f docker-compose.dev.yaml up -d

# Watch logs to ensure everything starts correctly
docker-compose -f docker-compose.dev.yaml logs -f
```

### Step 6: Verify Services

```bash
# Check all services are running
docker ps

# Should see:
# - postiz-postgres (healthy)
# - postiz-redis (healthy)
# - postiz-pg-admin (running)
# - postiz-redisinsight (running)

# Test PostgreSQL connection
docker exec -it postiz-postgres psql -U postiz-local -d postiz-db-local -c "SELECT 1;"

# Test Redis connection
docker exec -it postiz-redis redis-cli -a dev-redis-password PING
```

### Step 7: Restore Data (if needed)

If you started fresh or need to restore:

```bash
# Restore PostgreSQL database
docker exec -i postiz-postgres psql -U postiz-local postiz-db-local < backup_YYYYMMDD.sql
```

## 🔍 Verification Checklist

- [ ] All services start without errors
- [ ] PostgreSQL health check passes (`docker ps` shows "healthy")
- [ ] Redis health check passes (`docker ps` shows "healthy")
- [ ] Can connect to PostgreSQL via psql
- [ ] Can connect to Redis via redis-cli
- [ ] pgAdmin accessible at http://localhost:8081
- [ ] RedisInsight accessible at http://localhost:5540
- [ ] Application can connect to PostgreSQL
- [ ] Application can connect to Redis with password
- [ ] Application functions normally

## 🆘 Troubleshooting

### Issue: Redis Connection Refused

**Symptom**: Application can't connect to Redis

**Solution**: 
1. Check Redis password in `.env` matches application config
2. Update application to use password authentication
3. Restart application after updating config

```bash
# Test Redis connection manually
docker exec -it postiz-redis redis-cli -a dev-redis-password PING
```

### Issue: PostgreSQL Connection Issues

**Symptom**: Can't connect to database

**Solution**:
1. Check if PostgreSQL is healthy: `docker ps`
2. View logs: `docker-compose -f docker-compose.dev.yaml logs postiz-postgres`
3. Verify credentials in `.env`
4. Check if port is already in use: `sudo lsof -i :5432`

### Issue: Port Conflicts

**Symptom**: Service fails to start, port already in use

**Solution**: Change port in `.env`:

```bash
POSTGRES_PORT=5433
REDIS_PORT=6380
PGADMIN_PORT=8082
REDISINSIGHT_PORT=5541
```

Then restart services:
```bash
docker-compose -f docker-compose.dev.yaml down
docker-compose -f docker-compose.dev.yaml up -d
```

### Issue: Data Lost After Migration

**Symptom**: Database is empty

**Solution**: 
1. Stop services: `docker-compose -f docker-compose.dev.yaml down`
2. List volumes: `docker volume ls`
3. If old volume exists with different name, restore from backup
4. Restore database: `docker exec -i postiz-postgres psql -U postiz-local postiz-db-local < backup.sql`

### Issue: Permission Errors in Logs

**Symptom**: Container logs show permission denied errors

**Solution**:
```bash
# Fix volume permissions
docker-compose -f docker-compose.dev.yaml down
sudo chown -R $USER:$USER .
docker-compose -f docker-compose.dev.yaml up -d
```

## 📊 What's Changed?

### Configuration Files

| File | Status | Notes |
|------|--------|-------|
| `docker-compose.dev.yaml` | Modified | Security, health checks, resource limits added |
| `Dockerfile.dev` | Modified | Optimized caching, non-root user, security |
| `.dockerignore` | New | Build optimization |
| `docker.env.example` | New | Environment variable template |
| `docker-compose.base.yaml` | New | Shared configuration |
| `docker-compose.prod.yaml` | New | Production example |

### Service Changes

| Service | Changes |
|---------|---------|
| PostgreSQL | Health checks, resource limits, env var support |
| Redis | **Password authentication**, health checks, AOF persistence |
| pgAdmin | Version pinned, data persistence, depends_on |
| RedisInsight | Version pinned, depends_on |

### New Features

- ✅ Health checks for all services
- ✅ Resource limits (CPU/memory)
- ✅ Log rotation
- ✅ Redis password authentication
- ✅ Environment variable support
- ✅ Non-root user in containers
- ✅ Optimized build caching
- ✅ Comprehensive documentation

## 🔐 Security Improvements

1. **Passwords**: Now configurable via environment variables
2. **Redis**: Requires password authentication
3. **Container User**: Runs as non-root user
4. **Resource Limits**: Prevents resource exhaustion
5. **Port Exposure**: Configurable, can be removed

## 📚 New Documentation

After migration, familiarize yourself with:

1. **DOCKER_QUICK_REFERENCE.md** - Daily commands
2. **DOCKER_SETUP.md** - Complete setup guide
3. **DOCKER_IMPROVEMENTS_SUMMARY.md** - All changes detailed
4. **docker.env.example** - All available env vars

## 🎯 Next Steps After Migration

1. **Update CI/CD**: Update pipeline to use new configuration
2. **Update Team Docs**: Inform team about changes
3. **Test Thoroughly**: Verify all application features work
4. **Update .env**: Use secure passwords (especially for production)
5. **Setup Backups**: Configure automated backups (see DOCKER_SETUP.md)

## 💡 Tips for Smooth Migration

1. **Do it during downtime**: Migrate when not actively developing
2. **Keep old backup**: Don't delete old backups for at least a week
3. **Test locally first**: Ensure everything works before committing
4. **Update one service at a time**: If issues arise, easier to debug
5. **Read the logs**: Most issues are visible in logs

## 🔄 Rollback Procedure

If you need to rollback:

```bash
# Stop new services
docker-compose -f docker-compose.dev.yaml down

# Checkout old configuration
git checkout HEAD~1 docker-compose.dev.yaml Dockerfile.dev

# Start old configuration
docker-compose -f docker-compose.dev.yaml up -d

# Restore data if needed
docker exec -i postiz-postgres psql -U postiz-local postiz-db-local < backup.sql
```

## 📞 Getting Help

If you encounter issues during migration:

1. Check this guide's troubleshooting section
2. Review service logs: `docker-compose -f docker-compose.dev.yaml logs -f`
3. Check `DOCKER_SETUP.md` for detailed troubleshooting
4. Create an issue on GitHub with:
   - Migration step where you encountered the issue
   - Complete error logs
   - Your OS and Docker version
   - Contents of `.env` (without passwords!)

## ✅ Post-Migration Tasks

- [ ] Remove backup files after confirming everything works
- [ ] Update project documentation
- [ ] Inform team members about changes
- [ ] Update onboarding documentation
- [ ] Schedule team training session if needed

---

**Migration should take 5-10 minutes. Most issues are related to Redis password authentication - ensure your application is updated to use the password.**

