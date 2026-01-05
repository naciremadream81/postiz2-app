# Guacamole Database Initialization

This directory contains scripts for initializing the Guacamole database.

## Database Schema Initialization

The Guacamole database schema has been initialized. The initialization script was run using:

```bash
docker exec postiz-guacamole /opt/guacamole/bin/initdb.sh --mysql | \
  docker exec -i postiz-guacamole-db mysql -u guacamole_user -pguacamole-password guacamole_db
```

## Admin User Setup

A default admin user `guacadmin` has been created with full administrative permissions.

### Important Notes:

1. **Password**: The default password hash may not work with modern Guacamole versions that use bcrypt. You may need to:
   - Log in through the web interface if a default password was set
   - Use the "Forgot Password" feature if available
   - Or create a new admin user through the web interface

2. **First Login**: After first successful login, immediately change the default password.

3. **Creating New Users**: 
   - Use the Guacamole web interface (recommended)
   - Or use the SQL scripts in this directory (requires proper password hashing)

## Accessing Guacamole

- URL: https://guac.permitpro.icu
- Default username: `guacadmin`
- Default password: Check with your administrator or create a new user through the web interface

## Database Connection Details

- Host: `guacamole-db` (internal Docker network)
- Database: `guacamole_db`
- User: `guacamole_user`
- Password: `guacamole-password`

## Manual Database Access

To access the database directly:

```bash
docker exec -it postiz-guacamole-db mysql -u guacamole_user -pguacamole-password guacamole_db
```

## Re-initializing the Database

If you need to re-initialize the database (⚠️ **WARNING: This will delete all data**):

```bash
# Stop Guacamole services
docker compose -f docker-compose.yaml stop guacamole

# Drop and recreate the database
docker exec postiz-guacamole-db mysql -u root -pguacamole-root-password -e "DROP DATABASE guacamole_db; CREATE DATABASE guacamole_db;"
docker exec postiz-guacamole-db mysql -u root -pguacamole-root-password -e "GRANT ALL PRIVILEGES ON guacamole_db.* TO 'guacamole_user'@'%';"

# Run initialization script
docker exec postiz-guacamole /opt/guacamole/bin/initdb.sh --mysql | \
  docker exec -i postiz-guacamole-db mysql -u guacamole_user -pguacamole-password guacamole_db

# Restart Guacamole
docker compose -f docker-compose.yaml start guacamole
```

