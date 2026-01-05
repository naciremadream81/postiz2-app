# Guacamole Setup Complete ✅

## Database Initialized

The Guacamole database has been successfully initialized with all required tables and a default admin user.

## Default Login Credentials

- **Username**: `guacadmin`
- **Password**: You need to set this through the web interface

## First Login Instructions

1. **Access Guacamole**: Go to `https://guac.permitpro.icu/guacamole/`

2. **Login Screen**: You should now see a login screen (not an error page)

3. **Set Password**:
   - If you can log in with `guacadmin` and any password, Guacamole will prompt you to change it on first login
   - If the default password doesn't work, you may need to reset it

## Reset Password (if needed)

If you cannot log in, you can reset the password by running:

```bash
docker exec -it postiz-guacamole-db mysql -u root -pguacamole-root-password guacamole_db
```

Then run this SQL (replace 'YourNewPassword123!' with your desired password):

```sql
-- For Guacamole 1.6.0, you need to use the web interface to set passwords
-- Or generate a bcrypt hash externally and update it here
UPDATE guacamole_user 
SET password_hash = '$2a$10$...' -- Generated bcrypt hash
WHERE entity_id = (SELECT entity_id FROM guacamole_entity WHERE name = 'guacadmin');
```

**Easier Method**: Use the Guacamole web interface's password reset feature if available.

## Verify Setup

Check that everything is working:

```bash
# Check database tables
docker exec postiz-guacamole-db mysql -u guacamole_user -pguacamole-password guacamole_db -e "SHOW TABLES;"

# Check admin user
docker exec postiz-guacamole-db mysql -u guacamole_user -pguacamole-password guacamole_db -e "SELECT name FROM guacamole_entity WHERE type='USER';"

# Check Guacamole logs
docker logs postiz-guacamole --tail 20
```

## Next Steps

1. **Access Guacamole**: `https://guac.permitpro.icu/guacamole/`
2. **Log in** with `guacadmin` (you'll be prompted to set/change password)
3. **Configure connections** to your remote desktops/servers
4. **Create additional users** as needed

## Troubleshooting

If you still see errors:

1. **Check logs**: `docker logs postiz-guacamole --tail 50`
2. **Check database connectivity**: `docker logs postiz-guacamole-db --tail 20`
3. **Verify guacd is running**: `docker compose ps | grep guacd`

