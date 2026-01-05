# Fix Guacamole 404 Error

## The Problem

The Cloudflare Dashboard has a **path restriction** on the guacamole route: `"path":"guacamole"`

This means:
- ✅ `https://guac.permitpro.icu/guacamole/` → Works (200 OK)
- ❌ `https://guac.permitpro.icu/` → 404 (doesn't match path restriction)

## Quick Fix - Use the Correct URL

**Access Guacamole at**: `https://guac.permitpro.icu/guacamole/`

This already works! ✅

## Permanent Fix - Remove Path Restriction

To make the root URL work, remove the path restriction in Cloudflare Dashboard:

### Steps:

1. Go to: https://one.dash.cloudflare.com/
2. Navigate to **Networks** → **Tunnels**
3. Click on your tunnel (ID: `c9dc2d8d-c7e5-4ead-a7a6-fbe396fe63ea`)
4. Go to **Public Hostnames** tab
5. Find the route for `guac.permitpro.icu`
6. Click **Edit**
7. **Remove** the **Path** field value (clear it or delete the `/guacamole` path)
8. **Keep** the Service as: `http://postiz-traefik:80`
9. Click **Save**
10. Wait 1-2 minutes for Cloudflare to sync

After removing the path restriction, **all paths** under `guac.permitpro.icu` will be forwarded to Traefik, and Traefik will route them correctly to Guacamole.

## Verify

After fixing, test:
```bash
# Root should now work
curl -I https://guac.permitpro.icu/

# And /guacamole/ should still work
curl -I https://guac.permitpro.icu/guacamole/
```

Both should return 200 or 307 (redirect) instead of 404.

