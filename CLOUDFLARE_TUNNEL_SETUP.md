# Cloudflare Tunnel Setup Guide

## Overview

This guide will help you set up Cloudflare Tunnel to securely expose your Postiz application at `https://postiz.permitpro.icu` without opening any ports on your firewall.

## 🎯 What is Cloudflare Tunnel?

Cloudflare Tunnel (formerly Argo Tunnel) creates a secure, outbound-only connection from your server to Cloudflare's edge network. This means:

- ✅ No need to open inbound firewall ports
- ✅ Built-in DDoS protection
- ✅ Free SSL/TLS certificates
- ✅ Traffic goes through Cloudflare's global network
- ✅ Easy access control and security features

## 📋 Prerequisites

1. **Cloudflare Account** (free tier works)
2. **Domain managed by Cloudflare** (`permitpro.icu`)
3. **Docker and Docker Compose** (already set up)
4. **Cloudflare Tunnel created** (we'll do this below)

## 🚀 Setup Methods

There are two ways to set up the tunnel:

### Method 1: Using Cloudflare Dashboard (Recommended - Easiest)
### Method 2: Using cloudflared CLI (Advanced)

---

## Method 1: Cloudflare Dashboard Setup (Recommended)

### Step 1: Access Cloudflare Zero Trust Dashboard

1. Go to https://one.dash.cloudflare.com/
2. Log in to your Cloudflare account
3. Select your account
4. Navigate to **Networks** → **Tunnels**

### Step 2: Create a New Tunnel

1. Click **"Create a tunnel"**
2. Select **"Cloudflared"** as the connector type
3. Enter a name: `postiz-app` (or any name you prefer)
4. Click **"Save tunnel"**

### Step 3: Get Tunnel Credentials

After creating the tunnel, you'll see:
- **Tunnel ID**: A UUID like `a1b2c3d4-e5f6-7890-abcd-ef1234567890`
- **Tunnel Token**: A long string starting with `eyJ...`

**Save both of these securely!**

### Step 4: Install Connector (Skip - We're Using Docker)

The dashboard will show installation instructions. **Skip this step** - we're using Docker instead.

### Step 5: Configure Public Hostname

1. In the tunnel configuration page, find **"Public Hostnames"**
2. Click **"Add a public hostname"**
3. Configure:
   - **Subdomain**: `postiz`
   - **Domain**: `permitpro.icu`
   - **Path**: (leave empty)
   - **Service Type**: `HTTP`
   - **URL**: `postiz-frontend:3000` (or your frontend service name)

4. Click **"Save hostname"**

### Step 6: Create Credentials File

Create a file named `cloudflared-credentials.json` in your project root:

```bash
cd /home/archie/codebase/postiz-app
nano cloudflared-credentials.json
```

Paste the following structure (replace with your actual values):

```json
{
  "AccountTag": "your-account-id",
  "TunnelID": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "TunnelName": "postiz-app",
  "TunnelSecret": "your-tunnel-secret-base64-string"
}
```

**To get these values:**
- Download the credentials JSON from the dashboard, OR
- Use the tunnel token to extract them (see Method 2 below)

### Step 7: Update Configuration

Edit `cloudflare-tunnel-config.yaml`:

```bash
nano cloudflare-tunnel-config.yaml
```

Replace `YOUR_TUNNEL_ID_HERE` with your actual tunnel ID:

```yaml
tunnel: a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

Update the ingress rules to match your services:

```yaml
ingress:
  # Route all traffic to your frontend
  - hostname: postiz.permitpro.icu
    service: http://postiz-frontend:3000
    originRequest:
      noTLSVerify: true
  
  # Catch-all (required)
  - service: http_status:404
```

### Step 8: Secure the Credentials File

```bash
# Add to .gitignore to prevent committing credentials
echo "cloudflared-credentials.json" >> .gitignore

# Set appropriate permissions
chmod 600 cloudflared-credentials.json
```

### Step 9: Start Services

```bash
# Start all services including cloudflared
docker-compose -f docker-compose.dev.yaml up -d

# Check cloudflared logs
docker-compose -f docker-compose.dev.yaml logs -f postiz-cloudflared
```

### Step 10: Test Your Tunnel

1. Wait 10-30 seconds for the tunnel to establish
2. Visit: https://postiz.permitpro.icu
3. You should see your Postiz application!

---

## Method 2: Using cloudflared CLI (Advanced)

### Step 1: Install cloudflared Locally (Optional)

If you want to manage tunnels from CLI:

```bash
# On Linux
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Verify installation
cloudflared --version
```

### Step 2: Authenticate with Cloudflare

```bash
cloudflared tunnel login
```

This opens a browser window. Select your domain (`permitpro.icu`).

### Step 3: Create Tunnel

```bash
# Create a new tunnel
cloudflared tunnel create postiz-app

# This creates a credentials file at:
# ~/.cloudflared/<TUNNEL-ID>.json
```

**Copy the credentials to your project:**

```bash
cp ~/.cloudflared/<TUNNEL-ID>.json /home/archie/codebase/postiz-app/cloudflared-credentials.json
```

### Step 4: Create DNS Record

```bash
# Route traffic to your tunnel
cloudflared tunnel route dns postiz-app postiz.permitpro.icu
```

### Step 5: Update Configuration

Update `cloudflare-tunnel-config.yaml` with your tunnel ID (shown in the create output).

### Step 6: Start Services

```bash
docker-compose -f docker-compose.dev.yaml up -d
```

---

## 🔧 Configuration Options

### Basic Configuration (Single Service)

```yaml
tunnel: YOUR_TUNNEL_ID
credentials-file: /etc/cloudflared/credentials.json

ingress:
  - hostname: postiz.permitpro.icu
    service: http://postiz-frontend:3000
  - service: http_status:404
```

### Advanced Configuration (Multiple Routes)

```yaml
tunnel: YOUR_TUNNEL_ID
credentials-file: /etc/cloudflared/credentials.json

ingress:
  # Main app
  - hostname: postiz.permitpro.icu
    service: http://postiz-frontend:3000
    originRequest:
      noTLSVerify: true
      connectTimeout: 30s
      
  # API endpoints
  - hostname: postiz.permitpro.icu
    path: /api/*
    service: http://postiz-backend:4200
    
  # WebSocket support
  - hostname: postiz.permitpro.icu
    path: /ws/*
    service: http://postiz-backend:4200
    originRequest:
      noTLSVerify: true
      disableChunkedEncoding: true
      
  # Admin tools (optional)
  - hostname: admin.postiz.permitpro.icu
    service: http://postiz-pg-admin:80
    
  # Catch-all
  - service: http_status:404
```

---

## 🔍 Troubleshooting

### Issue: Tunnel Won't Start

**Check logs:**
```bash
docker-compose -f docker-compose.dev.yaml logs postiz-cloudflared
```

**Common causes:**
1. Invalid credentials file
2. Wrong tunnel ID in config
3. Network connectivity issues

**Solution:**
```bash
# Verify credentials file exists
ls -la cloudflared-credentials.json

# Verify tunnel ID in config
cat cloudflare-tunnel-config.yaml | grep tunnel:

# Test connectivity
docker exec -it postiz-cloudflared cloudflared tunnel info
```

### Issue: 502 Bad Gateway

**Cause:** Cloudflare can't reach your service

**Solutions:**
1. Verify service name in config matches docker-compose service name
2. Check if your application service is running
3. Verify the port number is correct

```bash
# Check running services
docker ps

# Test internal connectivity
docker exec -it postiz-cloudflared ping postiz-frontend

# Check service logs
docker-compose -f docker-compose.dev.yaml logs postiz-frontend
```

### Issue: DNS Not Resolving

**Cause:** DNS record not created or not propagated

**Solution:**
1. Check DNS in Cloudflare dashboard: DNS → Records
2. Verify CNAME record exists: `postiz` → `<TUNNEL-ID>.cfargotunnel.com`
3. Wait a few minutes for propagation
4. Clear your DNS cache: `sudo systemd-resolve --flush-caches`

### Issue: Authentication Failed

**Cause:** Invalid or expired tunnel token

**Solution:**
1. Generate new credentials from Cloudflare dashboard
2. Re-create `cloudflared-credentials.json`
3. Restart the container:
   ```bash
   docker-compose -f docker-compose.dev.yaml restart postiz-cloudflared
   ```

---

## 🔐 Security Best Practices

### 1. Protect Credentials

```bash
# Never commit credentials
echo "cloudflared-credentials.json" >> .gitignore
echo "*.pem" >> .gitignore

# Restrict file permissions
chmod 600 cloudflared-credentials.json
chmod 600 cloudflare-tunnel-config.yaml
```

### 2. Use Access Control

Enable Cloudflare Access for additional security:

1. Go to **Zero Trust** → **Access** → **Applications**
2. Click **"Add an application"**
3. Select **"Self-hosted"**
4. Configure authentication (email, Google, GitHub, etc.)

### 3. Enable WAF Rules

In Cloudflare dashboard:
1. Go to **Security** → **WAF**
2. Enable managed rules
3. Configure rate limiting

### 4. Monitor Tunnel Health

```bash
# Check tunnel status
docker-compose -f docker-compose.dev.yaml logs -f postiz-cloudflared

# View metrics (if configured)
curl http://localhost:metrics
```

---

## 📊 Health Check & Monitoring

### Check Tunnel Status

```bash
# View tunnel logs
docker logs postiz-cloudflared

# Check if tunnel is connected
docker exec postiz-cloudflared cloudflared tunnel info

# View metrics
docker exec postiz-cloudflared wget -qO- http://localhost:metrics
```

### Enable Prometheus Metrics

Add to `docker-compose.dev.yaml`:

```yaml
postiz-cloudflared:
  command: tunnel --config /etc/cloudflared/config.yaml --metrics localhost:9090 run
  ports:
    - "9090:9090"  # Expose metrics
```

---

## 🎯 Common Use Cases

### Use Case 1: Development Preview

Share your local development with team members:

```yaml
ingress:
  - hostname: dev.postiz.permitpro.icu
    service: http://postiz-frontend:3000
  - service: http_status:404
```

### Use Case 2: Staging Environment

```yaml
ingress:
  - hostname: staging.postiz.permitpro.icu
    service: http://postiz-frontend:3000
  - service: http_status:404
```

### Use Case 3: Multiple Services

```yaml
ingress:
  - hostname: app.postiz.permitpro.icu
    service: http://postiz-frontend:3000
  - hostname: api.postiz.permitpro.icu
    service: http://postiz-backend:4200
  - hostname: admin.postiz.permitpro.icu
    service: http://postiz-pg-admin:80
  - service: http_status:404
```

---

## 🚀 Quick Start Checklist

- [ ] Cloudflare account created
- [ ] Domain added to Cloudflare
- [ ] Tunnel created in dashboard
- [ ] Tunnel credentials downloaded
- [ ] `cloudflared-credentials.json` created in project root
- [ ] `cloudflare-tunnel-config.yaml` updated with tunnel ID
- [ ] Credentials file added to `.gitignore`
- [ ] DNS record created (CNAME)
- [ ] Docker services started
- [ ] Tunnel logs checked for errors
- [ ] Application accessible at https://postiz.permitpro.icu

---

## 📚 Additional Resources

- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Cloudflared GitHub](https://github.com/cloudflare/cloudflared)
- [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
- [Ingress Rules Reference](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/ingress/)

---

## 💡 Tips

1. **Start Simple**: Begin with a single hostname pointing to one service
2. **Test Locally First**: Ensure your services work without the tunnel
3. **Monitor Logs**: Keep an eye on cloudflared logs during initial setup
4. **Use Access Control**: Add authentication for sensitive applications
5. **Enable Caching**: Configure Cloudflare caching rules for better performance
6. **Set Up Alerts**: Configure notifications for tunnel disconnections

---

## 🆘 Getting Help

If you encounter issues:

1. Check the logs: `docker logs postiz-cloudflared`
2. Review this troubleshooting guide
3. Check [Cloudflare Community](https://community.cloudflare.com/)
4. Verify your configuration against examples
5. Ensure all services are running: `docker ps`

---

**Your application will be accessible at: https://postiz.permitpro.icu**

Enjoy secure, zero-configuration external access to your Postiz application! 🎉

