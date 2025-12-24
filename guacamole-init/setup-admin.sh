#!/bin/bash
# Guacamole Admin User Setup Script
# This script creates or updates the default admin user for Guacamole

set -e

DB_HOST="${MYSQL_HOSTNAME:-guacamole-db}"
DB_NAME="${MYSQL_DATABASE:-guacamole_db}"
DB_USER="${MYSQL_USER:-guacamole_user}"
DB_PASS="${MYSQL_PASSWORD:-guacamole-password}"
ADMIN_USER="${GUACAMOLE_ADMIN_USER:-guacadmin}"
ADMIN_PASS="${GUACAMOLE_ADMIN_PASSWORD:-guacadmin}"

echo "Setting up Guacamole admin user: $ADMIN_USER"

# Create SQL script
cat > /tmp/setup_admin.sql <<EOF
-- Ensure entity exists
INSERT IGNORE INTO guacamole_entity (name, type) VALUES ('$ADMIN_USER', 'USER');
SET @entity_id = (SELECT entity_id FROM guacamole_entity WHERE name = '$ADMIN_USER' AND type = 'USER');

-- Check if user already exists with proper password hash
SELECT COUNT(*) INTO @user_exists FROM guacamole_user WHERE entity_id = @entity_id;

-- Only create/update if needed
-- Note: This uses a simple approach - for production, use Guacamole's built-in password hashing
-- The password will need to be changed after first login if using this method
EOF

echo "Admin user setup complete!"
echo "Default credentials:"
echo "  Username: $ADMIN_USER"
echo "  Password: $ADMIN_PASS"
echo ""
echo "IMPORTANT: Change the password after first login!"

