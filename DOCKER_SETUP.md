# Docker Setup Guide for Postiz

This guide provides comprehensive instructions for setting up and running Postiz using Docker for development and production environments.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Development Environment](#development-environment)
- [Production Environment](#production-environment)
- [Common Commands](#common-commands)
- [Troubleshooting](#troubleshooting)
- [Security Best Practices](#security-best-practices)

## 🔧 Prerequisites

- Docker Engine 20.10.0 or higher
- Docker Compose v2.0.0 or higher (or Docker Compose v1.29.0+)
- At least 4GB of available RAM
- At least 10GB of available disk space

### Verify Installation

```bash
docker --version
docker-compose --version
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/postiz-app.git
cd postiz-app
```

### 2. Set Up Environment Variables

```bash
# Copy the example environment file
cp docker.env.example .env

# Edit the .env file with your preferred settings
nano .env  # or vim, code, etc.
```

### 3. Start Development Services

```bash
# Start all services
docker-compose -f docker-compose.dev.yaml up -d

# View logs
docker-compose -f docker-compose.dev.yaml logs -f
```

### 4. Access Services

Once all services are running:

- **PostgreSQL**: `localhost:5432`
- **Redis**: `localhost:6379`
- **pgAdmin**: http://localhost:8081
- **RedisInsight**: http://localhost:5540

## ⚙️ Configuration

### Environment Variables

All configuration is managed through environment variables. See `docker.env.example` for a complete list of available options.

#### Essential Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | `postiz-local` | PostgreSQL username |
| `POSTGRES_PASSWORD` | `postiz-local-pwd` | PostgreSQL password |
| `POSTGRES_DB` | `postiz-db-local` | PostgreSQL database name |
| `REDIS_PASSWORD` | `dev-redis-password` | Redis authentication password |

#### Build Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_MAX_MEMORY` | `4096` | Node.js memory limit (MB) |
| `NEXT_PUBLIC_VERSION` | `dev` | Application version tag |

### Customizing Ports

To avoid port conflicts, you can customize exposed ports in your `.env` file:

```bash
POSTGRES_PORT=5433
REDIS_PORT=6380
PGADMIN_PORT=8082
REDISINSIGHT_PORT=5541
```

## 🔨 Development Environment

### Starting Services

```bash
# Start all services in the background
docker-compose -f docker-compose.dev.yaml up -d

# Start specific service
docker-compose -f docker-compose.dev.yaml up -d postiz-postgres

# Start services with live logs
docker-compose -f docker-compose.dev.yaml up
```

### Viewing Logs

```bash
# View logs for all services
docker-compose -f docker-compose.dev.yaml logs -f

# View logs for specific service
docker-compose -f docker-compose.dev.yaml logs -f postiz-postgres

# View last 100 lines
docker-compose -f docker-compose.dev.yaml logs --tail=100
```

### Stopping Services

```bash
# Stop all services (preserves data)
docker-compose -f docker-compose.dev.yaml stop

# Stop and remove containers (preserves data)
docker-compose -f docker-compose.dev.yaml down

# Stop and remove everything including volumes (WARNING: DATA LOSS)
docker-compose -f docker-compose.dev.yaml down -v
```

### Rebuilding Services

After code changes:

```bash
# Rebuild specific service
docker-compose -f docker-compose.dev.yaml build postiz-backend

# Rebuild all services
docker-compose -f docker-compose.dev.yaml build

# Rebuild without cache
docker-compose -f docker-compose.dev.yaml build --no-cache
```

### Accessing Service Shells

```bash
# Access PostgreSQL CLI
docker exec -it postiz-postgres psql -U postiz-local -d postiz-db-local

# Access Redis CLI
docker exec -it postiz-redis redis-cli -a dev-redis-password

# Access container bash
docker exec -it postiz-postgres sh
```

## 🏭 Production Environment

### Production Build

For production, use the base configuration with production overrides:

```bash
# Build production images
docker-compose -f docker-compose.base.yaml build

# Start production services
docker-compose -f docker-compose.base.yaml up -d
```

### Production Checklist

Before deploying to production:

- [ ] Change all default passwords in `.env`
- [ ] Use strong, randomly generated secrets
- [ ] Remove port exposures for internal services
- [ ] Configure proper resource limits
- [ ] Set up backup strategies
- [ ] Configure log aggregation
- [ ] Enable monitoring and alerting
- [ ] Use production-grade secrets management (Vault, AWS Secrets Manager, etc.)
- [ ] Enable HTTPS/TLS
- [ ] Configure firewall rules

### Generating Strong Passwords

```bash
# Generate random password (32 characters)
openssl rand -base64 32

# Generate random hex string
openssl rand -hex 32
```

## 📝 Common Commands

### Health Checks

```bash
# Check service health
docker ps

# Inspect specific service
docker inspect postiz-postgres

# View service resource usage
docker stats
```

### Database Operations

```bash
# Create database backup
docker exec postiz-postgres pg_dump -U postiz-local postiz-db-local > backup.sql

# Restore database backup
docker exec -i postiz-postgres psql -U postiz-local postiz-db-local < backup.sql

# Connect to database
docker exec -it postiz-postgres psql -U postiz-local -d postiz-db-local
```

### Redis Operations

```bash
# Monitor Redis commands
docker exec -it postiz-redis redis-cli -a dev-redis-password MONITOR

# Get Redis info
docker exec -it postiz-redis redis-cli -a dev-redis-password INFO

# Flush all Redis data (WARNING: DATA LOSS)
docker exec -it postiz-redis redis-cli -a dev-redis-password FLUSHALL
```

### Volume Management

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect postiz-postgres-volume

# Remove unused volumes
docker volume prune

# Backup volume
docker run --rm -v postiz-postgres-volume:/data -v $(pwd):/backup alpine tar czf /backup/postgres-backup.tar.gz /data
```

## 🔍 Troubleshooting

### Common Issues

#### Port Already in Use

```bash
# Find process using port
sudo lsof -i :5432

# Kill process
kill -9 <PID>

# Or change port in .env file
POSTGRES_PORT=5433
```

#### Out of Memory Errors

Increase memory limits in `docker-compose.dev.yaml`:

```yaml
deploy:
  resources:
    limits:
      memory: 4G
```

Or increase Docker Desktop memory allocation in Settings > Resources.

#### Connection Refused

1. Check if service is running:
   ```bash
   docker ps | grep postiz
   ```

2. Check service logs:
   ```bash
   docker-compose -f docker-compose.dev.yaml logs postiz-postgres
   ```

3. Verify network connectivity:
   ```bash
   docker network inspect postiz-network
   ```

#### Permission Denied

If you encounter permission errors:

```bash
# Fix volume permissions
docker-compose -f docker-compose.dev.yaml down
sudo chown -R $USER:$USER ./data
docker-compose -f docker-compose.dev.yaml up -d
```

### Debug Mode

Enable verbose logging:

```bash
# Set in .env
DEBUG=true

# Or run with debug flag
docker-compose -f docker-compose.dev.yaml --verbose up
```

### Clean Slate

To completely reset your Docker environment:

```bash
# Stop all containers
docker-compose -f docker-compose.dev.yaml down -v

# Remove all images
docker rmi $(docker images 'postiz-*' -q)

# Prune system
docker system prune -a --volumes

# Start fresh
docker-compose -f docker-compose.dev.yaml up -d
```

## 🔒 Security Best Practices

### 1. Secrets Management

Never commit secrets to version control:

```bash
# Add to .gitignore
echo ".env" >> .gitignore
```

### 2. Use Strong Passwords

```bash
# Generate strong password
openssl rand -base64 32
```

### 3. Limit Network Exposure

Remove port mappings for services that don't need external access:

```yaml
# Remove this in production:
ports:
  - "5432:5432"
```

### 4. Regular Updates

```bash
# Update base images
docker-compose -f docker-compose.dev.yaml pull

# Rebuild with latest
docker-compose -f docker-compose.dev.yaml build --pull
```

### 5. Resource Limits

Always set resource limits to prevent DoS:

```yaml
deploy:
  resources:
    limits:
      cpus: '1'
      memory: 1G
```

### 6. Read-Only Filesystems

Where possible, use read-only filesystems:

```yaml
read_only: true
tmpfs:
  - /tmp
  - /var/run
```

### 7. Security Scanning

```bash
# Scan images for vulnerabilities
docker scan postiz-backend

# Use Trivy
trivy image postiz-backend
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Docker Hub](https://hub.docker.com/_/postgres)
- [Redis Docker Hub](https://hub.docker.com/_/redis)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)

## 🆘 Getting Help

If you encounter issues:

1. Check this documentation
2. Review service logs: `docker-compose logs -f`
3. Search existing issues on GitHub
4. Create a new issue with:
   - Your Docker version
   - Your OS
   - Complete error logs
   - Steps to reproduce

## 📄 License

See LICENSE file for details.

