#!/bin/bash

# Ensure Apache is running
service apache2 start

export PATH=~/.composer/vendor/bin:$PATH

if [ -d codeception.yml ]; then
	rm -rf codeception.yml
fi

# Update our domain to just be the docker container's IP address
export WORDPRESS_DOMAIN=$( hostname -i )
export WORDPRESS_URL="http://$WORDPRESS_DOMAIN"

# Download WordPress
wp core download \
	--quiet \
	--allow-root

# Config WordPress
wp config create \
	--dbname="$WORDPRESS_DB_NAME" \
	--dbuser="$WORDPRESS_DB_USER" \
	--dbpass="$WORDPRESS_DB_PASSWORD" \
	--dbhost="$WORDPRESS_DB_HOST" \
	--dbprefix="$WORDPRESS_TABLE_PREFIX" \
	--dbcharset="$WORDPRESS_DB_CHARSET" \
	--skip-check \
	--quiet \
	--allow-root

chown www-data:www-data wp-config.php

# Wipe out our database for good measure.
wp db clean --yes --allow-root

# Install WP if not yet installed
if ! $( wp core is-installed --allow-root ); then
	wp core install \
		--url=$WORDPRESS_URL \
		--title='Test' \
		--admin_user=$WORDPRESS_ADMIN_USERNAME \
		--admin_password=$WORDPRESS_ADMIN_PASSWORD \
		--admin_email=$WORDPRESS_ADMIN_EMAIL \
		--allow-root
fi

# Ensure a .env file is present for those who use .env params in codeception tests
touch .env
chown www-data:www-data .env

# Export a database dump
mkdir -p wp-content
mkdir -p wp-content/mu-plugins
mkdir -p wp-content/plugins
mkdir -p wp-content/themes
chown www-data:www-data wp-content
chown www-data:www-data wp-content/mu-plugins
chown www-data:www-data wp-content/plugins
chown www-data:www-data wp-content/themes

wp db export wp-content/mysql.sql \
	--skip-plugins \
	--skip-themes \
	--allow-root

chown www-data:www-data wp-content/mysql.sql

# Run the passed command
exec "$@"
