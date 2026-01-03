# n8n CSS Asset Loading Issue - Fix Guide

## Problem
n8n is unable to preload CSS files (`/assets/WorkflowsView-CLgqCJRp.css` and other assets), returning 404 errors when accessed through Cloudflare Tunnel.

## Root Cause
1. **Cloudflare Dashboard Config Override**: When using a token for authentication, Cloudflare Dashboard configuration takes precedence over the local `cloudflare-tunnel-config.yaml` file.
2. **Asset Path Mismatch**: The assets work correctly when accessed directly through Traefik (`localhost:8000`), but fail through Cloudflare Tunnel.

## Diagnosis
- ✅ Assets work through Traefik directly: `curl -I http://localhost:8000/assets/src-DS0bffpn.css` → 200 OK
- ❌ Assets fail through Cloudflare: `curl -I https://n8n.swonger-armstrong.org/assets/src-DS0bffpn.css` → 404

## Solutions

### Solution 1: Clear Browser Cache (Quick Fix)
The CSS file names are hashed and change with each build. Your browser may be caching an old reference:
1. Open n8n in an incognito/private window
2. Or clear your browser cache and hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
3. The issue may resolve itself as n8n serves the correct asset names

### Solution 2: Verify Cloudflare Dashboard Configuration
Since you're using token authentication, verify your Cloudflare Dashboard has the correct routing:

1. Go to Cloudflare Dashboard → Networks → Tunnels
2. Find your tunnel (`60ed5b46-7eb7-40ae-beaa-bf00a14ae91a`)
3. Check the "Public Hostnames" configuration for `n8n.swonger-armstrong.org`
4. Ensure it routes to: `http://postiz-traefik:80` (or `http://traefik:80`)
5. Verify the `httpHostHeader` is set to: `n8n.swonger-armstrong.org`

### Solution 3: Disable Cloudflare Caching for n8n Assets (Recommended)
In Cloudflare Dashboard:
1. Go to your domain: `swonger-armstrong.org`
2. Navigate to Rules → Transform Rules → Modify Response Header
3. Create a rule to add `Cache-Control: no-cache` for n8n assets:
   - **Rule name**: `n8n-no-cache`
   - **When**: `(http.host eq "n8n.swonger-armstrong.org" and http.request.uri.path contains "/assets/")`
   - **Then**: Set header `Cache-Control` to `no-cache, no-store, must-revalidate`

Alternatively, use a Page Rule:
- URL: `n8n.swonger-armstrong.org/assets/*`
- Setting: Cache Level → Bypass

### Solution 4: Switch to Credentials File (Advanced)
If you want local config to take precedence:
1. Switch from token-based to credentials-file authentication
2. Update `cloudflare-tunnel-config.yaml` to use `credentials-file` instead of `token`
3. This ensures your local config file is used instead of Dashboard config

### Solution 5: Restart n8n to Clear Internal Cache
Sometimes n8n needs a restart to regenerate correct asset references:
```bash
docker compose -f docker-compose.yaml restart n8n
```

## Current Status
- n8n service is running correctly
- Traefik routing is working (assets accessible locally)
- Cloudflare Tunnel is connected
- Issue is with asset serving through Cloudflare (likely caching/routing)

## Verification
After applying fixes, verify assets load:
```bash
# Should return 200 OK
curl -I https://n8n.swonger-armstrong.org/assets/src-DS0bffpn.css

# Should return 200 OK  
curl -I https://n8n.swonger-armstrong.org/assets/index-DvVzFVr2.js
```

## Additional Notes
- The CSS file name `WorkflowsView-CLgqCJRp.css` includes a hash that changes with each build
- If the file doesn't exist, n8n may have been updated and the asset names changed
- This is normal behavior - the browser should load the correct assets referenced in the HTML

