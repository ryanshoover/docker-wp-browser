#!/bin/bash

# Ensure Apache is running
service apache2 start

# Install WP if not yet installed
if ! $( ./vendor/bin/wp core is-installed --allow-root ); then
    ./vendor/bin/wp core install \
		--url=$WP_URL \
		--title='Test' \
		--admin_user=$ADMIN_USERNAME \
		--admin_password=$ADMIN_PASSWORD \
		--admin_email=$ADMIN_EMAIL \
		--allow-root
fi

# Run the passed command
exec "$@"
