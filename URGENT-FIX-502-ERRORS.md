# 🚨 URGENT: Fix 502 Errors - Cloudflare Dashboard Configuration

## The Problem

Your Cloudflare Dashboard has **incorrect routes** that are overriding your local config file. The logs show:

- ❌ `n8n.permitpro.icu` → `http://traefik:80` (WRONG - should be `postiz-traefik`)
- ❌ `guac.permitpro.icu` → `https://traefik:80` (WRONG - wrong protocol AND wrong name)
- ✅ `postiz.permitpro.icu` → `http://postiz-traefik:80` (CORRECT)

## Why This Happens

When using a **token** for authentication, the Cloudflare Dashboard configuration **takes precedence** over your local `cloudflare-tunnel-config.yaml` file. The dashboard routes are being merged/overridden with incorrect service names.

## Fix Options

### Option 1: Delete ALL Dashboard Routes (Recommended)

This allows your local config file to be used exclusively:

1. Go to https://one.dash.cloudflare.com/
2. Navigate to **Networks** → **Tunnels**
3. Click on your tunnel (ID: `c9dc2d8d-c7e5-4ead-a7a6-fbe396fe63ea`)
4. Go to the **Public Hostnames** tab
5. **Delete ALL existing routes** (you may see 2-3 routes there)
6. Wait 1-2 minutes for Cloudflare to sync
7. Restart cloudflared: `docker compose restart cloudflared`

### Option 2: Update Dashboard Routes to Match Local Config

If you want to keep using Dashboard configuration, update each route:

**For n8n.permitpro.icu:**
- Service: `http://postiz-traefik:80` (NOT `traefik`)

**For guac.permitpro.icu:**
- Service: `http://postiz-traefik:80` (NOT `https://traefik` - must be HTTP, not HTTPS)

**For postiz.permitpro.icu:**
- Service: `http://postiz-traefik:80` (Already correct)

## Verify the Fix

After making changes, check the logs:

```bash
docker logs postiz-cloudflared --tail 20 | grep "ingress"
```

You should see ALL routes using `http://postiz-traefik:80` consistently.

## Test Your Services

After fixing, test each service:

```bash
# Test postiz
curl -I https://postiz.permitpro.icu

# Test n8n
curl -I https://n8n.permitpro.icu

# Test guac
curl -I https://guac.permitpro.icu/guacamole/
```

All should return 200/307 instead of 502.

