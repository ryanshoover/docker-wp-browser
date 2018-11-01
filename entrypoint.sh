#!/bin/bash

# Ensure Apache is running
service apache2 start

# Link codeception config if not yet linked
if ! $( ls codeception.dist.yml ); then
	ln -s ../config/codeception.dist.yml ./codeception.dist.yml
fi

# Download WordPress if not yet downloaded
if ! $( wp core version --allow-root ); then
	wp core download --skip-content --quiet --allow-root
fi

# Config WordPress if not yet config'd
if ! $( wp config path --allow-root ); then
	wp config create \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="$DB_HOST" \
		--dbprefix="$WP_TABLE_PREFIX" \
		--skip-check \
		--allow-root
fi

# Install WP if not yet installed
if ! $( wp core is-installed --allow-root ); then
    wp core install \
		--url=$WP_URL \
		--title='Test' \
		--admin_user=$ADMIN_USERNAME \
		--admin_password=$ADMIN_PASSWORD \
		--admin_email=$ADMIN_EMAIL \
		--allow-root
fi

# Run the passed command
exec "$@"
