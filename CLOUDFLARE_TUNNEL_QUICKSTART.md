# Cloudflare Tunnel Quick Start

## 🚀 5-Minute Setup

### What You Get
Your Postiz app will be accessible at: **https://postiz.permitpro.icu**

### Prerequisites
- ✅ Cloudflare account (free)
- ✅ Domain `permitpro.icu` added to Cloudflare
- ✅ Docker running

---

## Quick Setup Steps

### 1. Create Tunnel in Cloudflare Dashboard

```
1. Go to: https://one.dash.cloudflare.com/
2. Click: Networks → Tunnels
3. Click: "Create a tunnel"
4. Name it: "postiz-app"
5. Click: "Save tunnel"
```

**Save the Tunnel ID shown!** (looks like: `abc123-def456-ghi789`)

### 2. Configure Public Hostname

In the tunnel page:

```
1. Click: "Public Hostnames" tab
2. Click: "Add a public hostname"
3. Fill in:
   - Subdomain: postiz
   - Domain: permitpro.icu
   - Service Type: HTTP
   - URL: postiz-frontend:3000
4. Click: "Save hostname"
```

### 3. Get Credentials

Two options:

**Option A: Download from Dashboard**
```
1. In tunnel page, click "Configure"
2. Look for "Install connector"
3. Click "Download credentials" or copy the JSON
4. Save as: cloudflared-credentials.json
```

**Option B: Use Tunnel Token**
```
1. Copy the tunnel token (starts with "eyJ...")
2. We'll use it in the next step
```

### 4. Create Credentials File

Create `cloudflared-credentials.json` in your project root:

```bash
cd /home/archie/codebase/postiz-app
nano cloudflared-credentials.json
```

Paste your credentials JSON:

```json
{
  "AccountTag": "your-account-id",
  "TunnelID": "abc123-def456-ghi789",
  "TunnelSecret": "your-base64-secret",
  "TunnelName": "postiz-app"
}
```

Save and exit (Ctrl+X, Y, Enter).

### 5. Update Configuration

Edit `cloudflare-tunnel-config.yaml`:

```bash
nano cloudflare-tunnel-config.yaml
```

Replace the tunnel ID on line 5:

```yaml
tunnel: abc123-def456-ghi789  # ← Your actual tunnel ID
```

Update service name if needed (line 12):

```yaml
service: http://postiz-frontend:3000  # ← Your frontend service
```

Save and exit.

### 6. Secure Credentials

```bash
chmod 600 cloudflared-credentials.json
```

### 7. Start Everything

```bash
docker-compose -f docker-compose.dev.yaml up -d
```

### 8. Check Tunnel Status

```bash
# View cloudflared logs
docker logs -f postiz-cloudflared

# Should see: "Connection <ID> registered"
```

### 9. Test It!

Open in browser: **https://postiz.permitpro.icu**

---

## ✅ Success!

If you see your Postiz application, you're done! 🎉

The tunnel will:
- ✅ Automatically reconnect if disconnected
- ✅ Provide free SSL/TLS certificates
- ✅ Give you DDoS protection
- ✅ Work without opening firewall ports

---

## 🔧 If It's Not Working

### Check 1: Is cloudflared running?

```bash
docker ps | grep cloudflared
```

Should show: `postiz-cloudflared` with status "Up"

### Check 2: Are there errors in logs?

```bash
docker logs postiz-cloudflared
```

Common errors:
- **"Authentication failed"** → Check credentials file
- **"Unable to reach origin"** → Check service name in config
- **"Tunnel not found"** → Check tunnel ID in config

### Check 3: Is your app service running?

```bash
docker ps | grep frontend
```

If not running, start your app first.

### Check 4: Is DNS configured?

Check in Cloudflare dashboard:
- Go to: DNS → Records
- Look for: `postiz` → `<tunnel-id>.cfargotunnel.com`

If missing, add it manually or wait 2-3 minutes.

---

## 🛠️ Common Fixes

### Fix 1: Restart Tunnel

```bash
docker-compose -f docker-compose.dev.yaml restart postiz-cloudflared
```

### Fix 2: Recreate Everything

```bash
docker-compose -f docker-compose.dev.yaml down
docker-compose -f docker-compose.dev.yaml up -d
```

### Fix 3: Check Service Name

Your service name in `cloudflare-tunnel-config.yaml` must match the actual Docker service name.

To find service names:
```bash
docker ps --format "{{.Names}}"
```

Update config to match:
```yaml
service: http://YOUR-ACTUAL-SERVICE-NAME:3000
```

---

## 📝 Configuration Examples

### Simple Single Service

```yaml
tunnel: your-tunnel-id
credentials-file: /etc/cloudflared/credentials.json

ingress:
  - hostname: postiz.permitpro.icu
    service: http://postiz-frontend:3000
  - service: http_status:404
```

### Multiple Routes

```yaml
tunnel: your-tunnel-id
credentials-file: /etc/cloudflared/credentials.json

ingress:
  # Main app
  - hostname: postiz.permitpro.icu
    service: http://postiz-frontend:3000
    
  # API (path-based routing)
  - hostname: postiz.permitpro.icu
    path: /api/*
    service: http://postiz-backend:4200
    
  # Catch-all
  - service: http_status:404
```

### With Different Subdomains

```yaml
tunnel: your-tunnel-id
credentials-file: /etc/cloudflared/credentials.json

ingress:
  # Main app
  - hostname: postiz.permitpro.icu
    service: http://postiz-frontend:3000
    
  # Admin panel
  - hostname: admin.postiz.permitpro.icu
    service: http://postiz-pg-admin:80
    
  # Catch-all
  - service: http_status:404
```

---

## 🔐 Security Tips

### 1. Protect Your Credentials

```bash
# Never commit to git (already in .gitignore)
chmod 600 cloudflared-credentials.json
```

### 2. Add Authentication (Optional)

In Cloudflare dashboard:
```
1. Go to: Zero Trust → Access → Applications
2. Click: "Add an application"
3. Select: "Self-hosted"
4. Set: postiz.permitpro.icu
5. Choose: Authentication method (Google, email, etc.)
```

This adds a login page before accessing your app.

### 3. Enable Rate Limiting (Optional)

In Cloudflare dashboard:
```
1. Go to: Security → WAF
2. Create rate limiting rule
3. Set: 100 requests per minute
```

---

## 📊 Monitoring

### View Logs

```bash
# Real-time logs
docker logs -f postiz-cloudflared

# Last 100 lines
docker logs --tail 100 postiz-cloudflared
```

### Check Connection Status

```bash
# Should show "Connection registered"
docker logs postiz-cloudflared | grep -i "connection"
```

### View Metrics

Enable metrics in docker-compose:

```yaml
postiz-cloudflared:
  command: tunnel --config /etc/cloudflared/config.yaml --metrics localhost:9090 run
  ports:
    - "9090:9090"
```

Then access: http://localhost:9090/metrics

---

## 💡 Pro Tips

1. **Multiple Environments**: Create separate tunnels for dev/staging/prod
2. **Custom Domains**: Add more subdomains in the tunnel config
3. **Automatic Updates**: cloudflared auto-updates when restarted
4. **Zero Downtime**: Cloudflare keeps connections alive during restarts
5. **Global CDN**: Your app is automatically cached at Cloudflare's edge

---

## 🆘 Still Having Issues?

### Get More Help

1. **Full Documentation**: See `CLOUDFLARE_TUNNEL_SETUP.md`
2. **Docker Logs**: `docker-compose -f docker-compose.dev.yaml logs`
3. **Cloudflare Community**: https://community.cloudflare.com/
4. **Cloudflare Docs**: https://developers.cloudflare.com/cloudflare-one/

### Debug Checklist

- [ ] Tunnel created in Cloudflare dashboard
- [ ] Tunnel ID correct in `cloudflare-tunnel-config.yaml`
- [ ] Credentials file exists: `cloudflared-credentials.json`
- [ ] Credentials file has correct permissions (600)
- [ ] Service name matches actual Docker service
- [ ] DNS record exists in Cloudflare
- [ ] cloudflared container is running
- [ ] No errors in cloudflared logs
- [ ] Application service is running

---

## 🎯 Next Steps

Once working:

1. **Add HTTPS**: Already included! Cloudflare provides free SSL
2. **Add Authentication**: Use Cloudflare Access (see Security Tips)
3. **Monitor Traffic**: Check analytics in Cloudflare dashboard
4. **Scale**: Add more services and routes
5. **Optimize**: Enable caching rules in Cloudflare

---

**Your URL**: https://postiz.permitpro.icu

Enjoy secure access to your Postiz application! 🚀

