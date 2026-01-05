# Docker Quick Reference Guide

## 🚀 Quick Start

```bash
# 1. Set up environment
cp docker.env.example .env

# 2. Start services
docker-compose -f docker-compose.dev.yaml up -d

# 3. View logs
docker-compose -f docker-compose.dev.yaml logs -f
```

## 📝 Common Commands

### Service Management
```bash
# Start all services
docker-compose -f docker-compose.dev.yaml up -d

# Stop all services
docker-compose -f docker-compose.dev.yaml down

# Restart specific service
docker-compose -f docker-compose.dev.yaml restart postiz-postgres

# View service status
docker ps
```

### Logs
```bash
# All services
docker-compose -f docker-compose.dev.yaml logs -f

# Specific service
docker-compose -f docker-compose.dev.yaml logs -f postiz-postgres

# Last 100 lines
docker-compose -f docker-compose.dev.yaml logs --tail=100
```

### Database Operations
```bash
# Connect to PostgreSQL
docker exec -it postiz-postgres psql -U postiz-local -d postiz-db-local

# Backup database
docker exec postiz-postgres pg_dump -U postiz-local postiz-db-local > backup.sql

# Restore database
docker exec -i postiz-postgres psql -U postiz-local postiz-db-local < backup.sql

# View tables
docker exec -it postiz-postgres psql -U postiz-local -d postiz-db-local -c "\dt"
```

### Redis Operations
```bash
# Connect to Redis
docker exec -it postiz-redis redis-cli -a dev-redis-password

# Monitor commands
docker exec -it postiz-redis redis-cli -a dev-redis-password MONITOR

# Get info
docker exec -it postiz-redis redis-cli -a dev-redis-password INFO

# Clear all data (WARNING!)
docker exec -it postiz-redis redis-cli -a dev-redis-password FLUSHALL
```

### Build & Rebuild
```bash
# Rebuild all services
docker-compose -f docker-compose.dev.yaml build

# Rebuild specific service
docker-compose -f docker-compose.dev.yaml build postiz-backend

# Rebuild without cache
docker-compose -f docker-compose.dev.yaml build --no-cache

# Build and start
docker-compose -f docker-compose.dev.yaml up -d --build
```

### Cleanup
```bash
# Stop and remove containers (keep volumes)
docker-compose -f docker-compose.dev.yaml down

# Remove containers and volumes (DATA LOSS!)
docker-compose -f docker-compose.dev.yaml down -v

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Complete cleanup
docker system prune -a --volumes
```

## 🔍 Debugging

### Check Service Health
```bash
# Container status
docker ps

# Service logs
docker-compose -f docker-compose.dev.yaml logs -f [service-name]

# Inspect service
docker inspect postiz-postgres

# Resource usage
docker stats
```

### Access Container Shell
```bash
# PostgreSQL container
docker exec -it postiz-postgres sh

# Redis container
docker exec -it postiz-redis sh

# Application container (when added)
docker exec -it postiz-backend sh
```

### Network Debugging
```bash
# List networks
docker network ls

# Inspect network
docker network inspect postiz-network

# Test connectivity
docker exec -it postiz-backend ping postiz-postgres
```

## 🌐 Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| PostgreSQL | `localhost:5432` | user: postiz-local, pwd: postiz-local-pwd |
| Redis | `localhost:6379` | pwd: dev-redis-password |
| pgAdmin | http://localhost:8081 | admin@admin.com / admin |
| RedisInsight | http://localhost:5540 | (set on first access) |

## 🔐 Environment Variables

Key variables in `.env`:

```bash
# Database
POSTGRES_USER=postiz-local
POSTGRES_PASSWORD=your-secure-password
POSTGRES_DB=postiz-db-local

# Redis
REDIS_PASSWORD=your-redis-password

# Admin Tools
PGADMIN_EMAIL=admin@admin.com
PGADMIN_PASSWORD=admin
```

## 🏗️ Production Deployment

```bash
# Build production images
docker-compose -f docker-compose.base.yaml -f docker-compose.prod.yaml build

# Start production services
docker-compose -f docker-compose.base.yaml -f docker-compose.prod.yaml up -d

# View production logs
docker-compose -f docker-compose.base.yaml -f docker-compose.prod.yaml logs -f
```

## 🆘 Troubleshooting

### Port Already in Use
```bash
# Find process on port 5432
sudo lsof -i :5432

# Kill process
kill -9 <PID>

# Or change port in .env
POSTGRES_PORT=5433
```

### Container Won't Start
```bash
# Check logs
docker-compose -f docker-compose.dev.yaml logs [service-name]

# Remove and recreate
docker-compose -f docker-compose.dev.yaml down
docker-compose -f docker-compose.dev.yaml up -d --force-recreate
```

### Permission Errors
```bash
# Fix permissions
sudo chown -R $USER:$USER .

# Restart with clean state
docker-compose -f docker-compose.dev.yaml down -v
docker-compose -f docker-compose.dev.yaml up -d
```

### Out of Memory
```bash
# Check Docker memory settings
docker info | grep Memory

# Increase in Docker Desktop:
# Settings > Resources > Memory
```

## 📚 Additional Resources

- Full Documentation: `DOCKER_SETUP.md`
- Implementation Details: `DOCKER_IMPROVEMENTS_SUMMARY.md`
- Environment Config: `docker.env.example`

## 💡 Tips

1. **Always use `-f docker-compose.dev.yaml`** for development
2. **Never commit `.env`** files - they're in `.gitignore`
3. **Check logs first** when debugging issues
4. **Use health checks** to verify service readiness
5. **Backup data** before running `down -v`
6. **Keep images updated** regularly with `pull` and `build`

## 🌐 Cloudflare Tunnel Commands

### Tunnel Management
```bash
# Start tunnel
docker-compose -f docker-compose.dev.yaml up -d postiz-cloudflared

# Stop tunnel
docker-compose -f docker-compose.dev.yaml stop postiz-cloudflared

# Restart tunnel
docker-compose -f docker-compose.dev.yaml restart postiz-cloudflared

# View tunnel logs
docker logs -f postiz-cloudflared

# Check tunnel status
docker logs postiz-cloudflared | grep -i "connection.*registered"
```

### Test Tunnel
```bash
# Test external access
curl https://postiz.permitpro.icu

# Test with verbose output
curl -v https://postiz.permitpro.icu
```

### Troubleshooting Tunnel
```bash
# Check tunnel configuration
docker exec postiz-cloudflared cloudflared tunnel ingress validate

# Test connectivity to services
docker exec postiz-cloudflared ping postiz-frontend

# Get tunnel info
docker exec postiz-cloudflared cloudflared tunnel info
```

---

## 🔄 Daily Workflow

```bash
# Morning - Start services
docker-compose -f docker-compose.dev.yaml up -d

# During development - View logs
docker-compose -f docker-compose.dev.yaml logs -f

# After changes - Rebuild
docker-compose -f docker-compose.dev.yaml up -d --build

# End of day - Stop services
docker-compose -f docker-compose.dev.yaml stop

# Or keep running in background (recommended)
# Services will auto-start with Docker Desktop
```

---

## 📚 Additional Guides

- **Docker Setup**: `DOCKER_SETUP.md`
- **Cloudflare Tunnel Quick Start**: `CLOUDFLARE_TUNNEL_QUICKSTART.md`
- **Cloudflare Tunnel Setup**: `CLOUDFLARE_TUNNEL_SETUP.md`
- **Migration Guide**: `MIGRATION_GUIDE.md`

---

**For detailed information, see the guides above.**

