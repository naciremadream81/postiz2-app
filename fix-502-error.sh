#!/bin/bash

# =============================================================================
# Fix 502 Error - Update Cloudflare Dashboard Configuration
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}========================================${NC}"
echo -e "${RED}502 Error Fix Guide${NC}"
echo -e "${RED}========================================${NC}"
echo ""

echo -e "${YELLOW}Problem Identified:${NC}"
echo "The tunnel is using OLD dashboard configuration that points to:"
echo "  ❌ http://postiz:5000 (Docker network - doesn't work from host)"
echo ""
echo "It needs to use:"
echo "  ✅ http://localhost:5001 (host network - works!)"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Current Status:${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check local service
echo -e "${YELLOW}Testing local service...${NC}"
if curl -s --max-time 5 http://localhost:5001 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Postiz is accessible on localhost:5001${NC}"
else
    echo -e "${RED}✗ Postiz not accessible locally${NC}"
    echo -e "${YELLOW}Run: docker-compose up -d${NC}"
    exit 1
fi

# Check tunnel
echo -e "${YELLOW}Testing tunnel...${NC}"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 https://postiz.permitpro.icu 2>/dev/null || echo "000")

if [ "$RESPONSE" = "502" ]; then
    echo -e "${YELLOW}⚠ Tunnel returns 502 (using wrong config)${NC}"
elif [ "$RESPONSE" = "200" ] || [ "$RESPONSE" = "307" ]; then
    echo -e "${GREEN}✓ Tunnel working! (problem already fixed)${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Tunnel response: $RESPONSE${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Solution: Update Dashboard Config${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}You need to update the Cloudflare Dashboard configuration.${NC}"
echo ""
echo -e "${GREEN}STEP 1: Open Cloudflare Dashboard${NC}"
echo ""
echo "  1. Open: ${BLUE}https://one.dash.cloudflare.com/${NC}"
echo "  2. Navigate to: ${BLUE}Networks → Tunnels${NC}"
echo "  3. Click on tunnel: ${BLUE}postiz-app${NC}"
echo ""

echo -e "${GREEN}STEP 2: Configure Public Hostname${NC}"
echo ""
echo "  1. Click the ${BLUE}Configure${NC} button"
echo "  2. Go to ${BLUE}Public Hostnames${NC} tab"
echo "  3. Either ${BLUE}Edit${NC} existing hostname or ${BLUE}Add${NC} new one:"
echo ""
echo "     ${YELLOW}Configuration:${NC}"
echo "     ┌─────────────────────────────────────┐"
echo "     │ Subdomain:  postiz                  │"
echo "     │ Domain:     permitpro.icu   │"
echo "     │ Path:       (leave empty)           │"
echo "     │                                     │"
echo "     │ Service:                            │"
echo "     │   Type:     HTTP                    │"
echo "     │   URL:      localhost:5001          │"
echo "     │                                     │"
echo "     │ [Save hostname]                     │"
echo "     └─────────────────────────────────────┘"
echo ""
echo "  4. Click ${BLUE}Save hostname${NC}"
echo ""

echo -e "${GREEN}STEP 3: Wait and Test${NC}"
echo ""
echo "  The tunnel will automatically pick up the new config within 1-2 minutes."
echo ""
echo "  Test with:"
echo "  ${BLUE}curl -I https://postiz.permitpro.icu${NC}"
echo ""
echo "  Expected: ${GREEN}HTTP/2 200 OK${NC} or ${GREEN}HTTP/2 307${NC}"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Alternative: Use CLI (Advanced)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "If you prefer CLI, you can delete the dashboard config:"
echo ""
echo "  ${BLUE}cloudflared tunnel route dns --overwrite-dns postiz-app postiz.permitpro.icu${NC}"
echo ""
echo "Then restart the tunnel to force it to use the local config file."
echo ""

echo -e "${YELLOW}Need help? Check:${NC}"
echo "  - SYSTEM_TUNNEL_SETUP.md"
echo "  - SETUP_COMPLETE.md"
echo ""

