# Cloudflare Cache Bypass for n8n Assets - Step by Step Guide

## Solution 3: Disable Cloudflare Caching for n8n Assets

This guide walks you through creating a Page Rule or Transform Rule to bypass Cloudflare's cache for n8n static assets, which should fix the CSS loading issues.

---

## Method 1: Page Rule (Easier - Recommended)

### Step 1: Navigate to Page Rules
1. Log into your Cloudflare Dashboard: https://one.dash.cloudflare.com/
2. Select your domain: **swonger-armstrong.org**
3. In the left sidebar, click **Rules** → **Page Rules** (or go to **Caching** → **Configuration** → **Page Rules**)

### Step 2: Create a New Page Rule
1. Click the **Create Page Rule** button
2. In the **URL** field, enter:
   ```
   n8n.swonger-armstrong.org/assets/*
   ```
   This matches all asset requests (CSS, JS, images, etc.) on your n8n subdomain

### Step 3: Configure the Rule
1. Click **Add a Setting** or select from the dropdown
2. Choose **Cache Level**
3. Set it to **Bypass** (this disables caching completely for these URLs)
4. Click **Save and Deploy**

### Step 4: Verify the Rule
- You should see a rule listed like:
  ```
  URL: n8n.swonger-armstrong.org/assets/*
  Setting: Cache Level: Bypass
  Status: Active
  ```

### Step 5: Test
Wait 1-2 minutes for the rule to propagate, then test:
```bash
curl -I https://n8n.swonger-armstrong.org/assets/src-DS0bffpn.css
```
You should now get a 200 OK response instead of 404.

---

## Method 2: Transform Rule (More Advanced - More Control)

If you want more control or Page Rules aren't available in your plan, use Transform Rules:

### Step 1: Navigate to Transform Rules
1. Log into your Cloudflare Dashboard
2. Select your domain: **swonger-armstrong.org**
3. Click **Rules** → **Transform Rules** → **Modify Response Header**

### Step 2: Create a New Rule
1. Click **Create rule**
2. Give it a name: `n8n-assets-no-cache`

### Step 3: Configure When (Matching Condition)
1. Under **When incoming requests match**, set:
   - **Field**: `Hostname`
   - **Operator**: `equals`
   - **Value**: `n8n.swonger-armstrong.org`
   
2. Click **Add condition**
   - **Field**: `URI Path`
   - **Operator**: `contains`
   - **Value**: `/assets/`

### Step 4: Configure Then (Action)
1. Under **Then**, select **Set static**
2. Choose **Response header**
3. Set:
   - **Header name**: `Cache-Control`
   - **Value**: `no-cache, no-store, must-revalidate, private`
   - **Operation**: Set (if exists) or Add (if not exists)

### Step 5: Deploy
1. Click **Deploy** or **Save**
2. The rule will be active immediately

---

## Method 3: Cache Rules (New Cloudflare Feature)

If your Cloudflare plan supports Cache Rules (available in Pro+ plans):

### Step 1: Navigate to Cache Rules
1. Go to **Caching** → **Configuration** → **Cache Rules**
2. Click **Create rule**

### Step 2: Configure the Rule
1. **Rule name**: `n8n-assets-bypass`
2. **When**: 
   - **Hostname** equals `n8n.swonger-armstrong.org`
   - **AND** **URI Path** contains `/assets/`
3. **Then**:
   - **Cache status**: Bypass
4. Click **Deploy**

---

## Which Method Should You Use?

- **Page Rule** (Method 1): Simplest, works on all plans (Free plan allows 3 page rules)
- **Transform Rule** (Method 2): More control, available on Pro plan and above
- **Cache Rules** (Method 3): Most modern approach, available on Pro+ plans

If you're on the Free plan, use **Method 1 (Page Rule)**.

---

## Verification

After creating the rule:

1. **Wait 1-2 minutes** for Cloudflare to propagate the change
2. Clear your browser cache or use an incognito window
3. Test asset loading:
   ```bash
   curl -I https://n8n.swonger-armstrong.org/assets/src-DS0bffpn.css
   ```
4. Visit n8n in your browser: https://n8n.swonger-armstrong.org
5. Open browser DevTools (F12) → Network tab
6. Look for CSS/JS files - they should all return 200 OK

---

## Troubleshooting

### Rule Not Working?
- Wait 2-3 minutes for propagation
- Check that the URL pattern exactly matches: `n8n.swonger-armstrong.org/assets/*`
- Verify the rule is **Active** (not Draft or Disabled)
- Clear your browser cache completely

### Still Getting 404?
- The issue might not be caching - check Cloudflare Dashboard tunnel routing instead
- Verify n8n is actually serving the assets (test through Traefik directly)
- Check browser console for exact error messages

### Need to Remove the Rule?
- Go back to the same location where you created the rule
- Find the rule and click **Delete** or **Disable**
- Changes take effect immediately

---

## Alternative: Clear Cloudflare Cache Manually

If you just need a quick fix without creating rules:

1. Go to **Caching** → **Configuration** → **Purge Cache**
2. Select **Custom Purge**
3. Enter: `https://n8n.swonger-armstrong.org/assets/*`
4. Click **Purge Everything**
5. Wait a few minutes and test again

This is temporary - assets will be cached again. Use a rule for a permanent fix.

