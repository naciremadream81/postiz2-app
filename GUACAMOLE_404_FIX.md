# Fix Guacamole 404 Error - Cloudflare Dashboard Configuration

## Problem
`guac.swonger-armstrong.org` is returning 404 errors because the route is not configured in the Cloudflare Dashboard.

## Root Cause
When using token-based authentication, the **Cloudflare Dashboard configuration takes precedence** over your local `cloudflare-tunnel-config.yaml` file. Even though you've added the guac route in the local config file, the Dashboard doesn't have it configured, so it hits the catch-all 404 rule.

## Solution: Add Route in Cloudflare Dashboard

### Step 1: Open Cloudflare Dashboard
1. Go to: https://one.dash.cloudflare.com/
2. Select your domain: **swonger-armstrong.org**
3. Navigate to: **Networks** → **Tunnels**

### Step 2: Select Your Tunnel
1. Find your tunnel: **60ed5b46-7eb7-40ae-beaa-bf00a14ae91a**
2. Click on the tunnel name to open its details

### Step 3: Configure Public Hostname
1. Click the **Configure** button (or go to **Public Hostnames** tab)
2. Click **Add a public hostname** (or **Edit** if one exists)
3. Fill in the configuration:

   **Hostname Configuration:**
   ```
   Subdomain: guac
   Domain: swonger-armstrong.org
   Path: (leave empty)
   
   Service:
     Type: HTTP
     URL: http://postiz-traefik:80
     (or http://traefik:80 if that's what your Dashboard uses)
   
   Additional settings (click to expand):
     HTTP Host Header: guac.swonger-armstrong.org
   ```

4. Click **Save hostname**

### Step 4: Verify Configuration
After saving, you should see three public hostnames configured:
- `postiz.swonger-armstrong.org` → `http://postiz-traefik:80` (or `traefik:80`)
- `n8n.swonger-armstrong.org` → `http://postiz-traefik:80` (or `traefik:80`)
- `guac.swonger-armstrong.org` → `http://postiz-traefik:80` (or `traefik:80`)

### Step 5: Wait and Test
1. Wait **1-2 minutes** for Cloudflare to propagate the changes
2. Test the connection:
   ```bash
   curl -I https://guac.swonger-armstrong.org
   ```
3. You should now get a **200 OK** or **307 redirect** instead of 404

---

## Alternative: Use Same Service Name as Other Routes

If your Dashboard is using `http://traefik:80` for the other routes (postiz and n8n), use the same for guac to maintain consistency. The service name should match what's already working.

To check what service names are working:
- Look at your existing Dashboard routes for `postiz` and `n8n`
- Use the same service name format for `guac`

---

## Verification

### Check Tunnel Logs
After configuring, check your tunnel logs to see if it picked up the new route:
```bash
docker compose -f docker-compose.yaml logs cloudflared --tail=20 | grep -i "guac"
```

You should see the guac route in the "Updated to new configuration" log message.

### Test Locally (Should Already Work)
This confirms Traefik routing is correct:
```bash
curl -I -H "Host: guac.swonger-armstrong.org" http://localhost:8000/
```
Should return **200 OK** (this was already working).

### Test Through Cloudflare
After Dashboard configuration:
```bash
curl -I https://guac.swonger-armstrong.org
```
Should now return **200 OK** instead of 404.

---

## Troubleshooting

### Still Getting 404 After Configuration?

1. **Wait longer**: Cloudflare can take 2-3 minutes to propagate
2. **Check Dashboard**: Verify the route is saved and shows as "Active"
3. **Service name**: Make sure you're using the correct service name (`traefik:80` or `postiz-traefik:80`)
4. **HTTP Host Header**: Ensure it's set to `guac.swonger-armstrong.org`

### Service Name Confusion?

- If other routes use `traefik:80`, use `traefik:80` for guac
- If other routes use `postiz-traefik:80`, use `postiz-traefik:80` for guac
- Docker Compose creates DNS aliases for both service names, so both should work

### Want Local Config to Work Instead?

If you prefer local config file to take precedence:
1. Switch from token to credentials-file authentication
2. This is more complex - see `N8N_CSS_FIX.md` Solution 4 for details

---

## Quick Reference

**Current Status:**
- ✅ Guacamole service is running
- ✅ Traefik routing works (tested locally)
- ✅ Cloudflare Tunnel is connected
- ❌ Dashboard route missing (causing 404)

**Action Required:**
Add `guac.swonger-armstrong.org` route in Cloudflare Dashboard → Networks → Tunnels → Your Tunnel → Public Hostnames


