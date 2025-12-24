#!/usr/bin/env bash

# =============================================================================
# Postiz Deployment Script
# =============================================================================
# This script ensures prerequisites are met and starts the Postiz services
# Usage: ./deploy.sh [compose-file]
# Example: ./deploy.sh docker-compose.yaml
# =============================================================================

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default compose file
COMPOSE_FILE="${1:-docker-compose.yaml}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Postiz Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if compose file exists
if [ ! -f "$COMPOSE_FILE" ]; then
    echo -e "${RED}Error: Compose file '$COMPOSE_FILE' not found${NC}"
    exit 1
fi

echo -e "${YELLOW}Using compose file: ${COMPOSE_FILE}${NC}"
echo ""

# Ensure Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    exit 1
fi

# Check if web-proxy network exists, create if it doesn't
echo -e "${YELLOW}Checking for web-proxy network...${NC}"
if docker network inspect web-proxy > /dev/null 2>&1; then
    echo -e "${GREEN}✓ web-proxy network exists${NC}"
else
    echo -e "${YELLOW}Creating web-proxy network...${NC}"
    docker network create web-proxy
    echo -e "${GREEN}✓ web-proxy network created${NC}"
fi
echo ""

# Check if cloudflare-tunnel-config.yaml exists (if using main compose file)
if [[ "$COMPOSE_FILE" == *"docker-compose.yaml"* ]] && [ ! -f "cloudflare-tunnel-config.yaml" ]; then
    echo -e "${YELLOW}Warning: cloudflare-tunnel-config.yaml not found${NC}"
    echo -e "${YELLOW}Copy cloudflare-tunnel-config.yaml.example to cloudflare-tunnel-config.yaml and configure it${NC}"
    echo ""
fi

# Start services
echo -e "${BLUE}Starting services with docker compose...${NC}"
echo ""

docker compose -f "$COMPOSE_FILE" up -d --build

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "View logs with:"
echo "  ${BLUE}docker compose -f ${COMPOSE_FILE} logs -f${NC}"
echo ""
echo "View service status with:"
echo "  ${BLUE}docker compose -f ${COMPOSE_FILE} ps${NC}"
echo ""

