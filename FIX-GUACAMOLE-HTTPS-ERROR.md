# Fix Guacamole 502 Error - HTTPS Protocol Issue

## Current Status

Your services ARE working internally ✅, but cloudflared can't reach them because:
- **Guacamole route** in Dashboard: `https://postiz-traefik:80` ❌ (wrong - Traefik only serves HTTP)
- **Should be**: `http://postiz-traefik:80` ✅

## The Fix - Update Cloudflare Dashboard

### Step 1: Access Cloudflare Dashboard
1. Go to: https://one.dash.cloudflare.com/
2. Log in to your account

### Step 2: Navigate to Your Tunnel
1. Click **Networks** in the left sidebar
2. Click **Tunnels**
3. Click on your tunnel (ID: `c9dc2d8d-c7e5-4ead-a7a6-fbe396fe63ea`)

### Step 3: Edit the Guacamole Route
1. Click the **Public Hostnames** tab
2. Find the route for `guac.permitpro.icu`
3. Click **Edit** (or the pencil icon)
4. In the **Service** field, change:
   - FROM: `https://postiz-traefik:80` 
   - TO: `http://postiz-traefik:80`
5. **IMPORTANT**: Make sure it's `http://` NOT `https://`
6. If there's a **Path** field with `/guacamole`, you can remove it (Guacamole serves from root)
7. Click **Save**

### Step 4: Verify Other Routes
While you're there, verify:
- **postiz.permitpro.icu** → `http://postiz-traefik:80` ✅
- **n8n.permitpro.icu** → `http://postiz-traefik:80` ✅
- **guac.permitpro.icu** → `http://postiz-traefik:80` ✅ (just fixed)

### Step 5: Wait and Restart
1. Wait 1-2 minutes for Cloudflare to sync the changes
2. Restart cloudflared:
   ```bash
   docker compose restart cloudflared
   ```

### Step 6: Verify
Check the logs to confirm the fix:
```bash
docker logs postiz-cloudflared --tail 20 | grep "ingress"
```

You should see:
```json
"ingress":[
  {"hostname":"guac.permitpro.icu","service":"http://postiz-traefik:80"},
  {"hostname":"n8n.permitpro.icu","service":"http://postiz-traefik:80"},
  {"hostname":"postiz.permitpro.icu","service":"http://postiz-traefik:80"}
]
```

**ALL routes should use `http://` (NOT `https://`)** because Traefik only serves HTTP (Cloudflare handles HTTPS/TLS).

## Test After Fix

```bash
# Should return 200/307 instead of 502
curl -I https://guac.permitpro.icu/guacamole/
curl -I https://n8n.permitpro.icu
curl -I https://postiz.permitpro.icu
```

