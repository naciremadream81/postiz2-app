# Fix 502 Errors - Cloudflare Dashboard Configuration Issue

## Problem
The Cloudflare Dashboard configuration is overriding/merging with the local config file, causing incorrect service names:
- n8n: Using `traefik:80` instead of `postiz-traefik:80`
- guac: Using `https://traefik:80` instead of `http://postiz-traefik:80`  
- postiz: Correctly using `postiz-traefik:80`

## Solution

### Option 1: Delete All Dashboard Routes (Recommended)
This allows the local config file to be used exclusively:

1. Go to https://one.dash.cloudflare.com/
2. Navigate to **Networks** → **Tunnels**
3. Click on your tunnel (ID: `c9dc2d8d-c7e5-4ead-a7a6-fbe396fe63ea`)
4. Go to the **Public Hostnames** tab
5. **Delete ALL existing routes** (they have old or incorrect configurations)
6. Restart cloudflared: `docker compose restart cloudflared`
7. Wait 1-2 minutes for Cloudflare to sync

### Option 2: Update Dashboard Routes to Match Local Config
If you want to keep using Dashboard configuration:

For each route (postiz, n8n, guac):
1. Edit the route in Dashboard
2. Set **Service** to: `http://postiz-traefik:80`
3. Make sure protocol is `http://` not `https://`
4. Save and wait for sync

### Verify Fix

After making changes, check the logs:
```bash
docker logs postiz-cloudflared --tail 20 | grep "ingress"
```

You should see all three routes using `http://postiz-traefik:80`

### Test Connectivity

```bash
# Test postiz
curl -I https://postiz.permitpro.icu

# Test n8n  
curl -I https://n8n.permitpro.icu

# Test guac
curl -I https://guac.permitpro.icu
```

All should return 200/307 instead of 502.

