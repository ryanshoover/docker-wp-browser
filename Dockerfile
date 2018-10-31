FROM php:7.2-apache-stretch

# Install required system packages
RUN apt-get update && \
    apt-get -y install \
    # WordPress dependencies
    libjpeg-dev \
    libpng-dev \
    mysql-client \
    # CircleCI depedencies
    git \
    ssh \
    tar \
    gzip

# Install php extensions
RUN docker-php-ext-install \
    bcmath \
    zip \
    gd \
    pdo_mysql \
    mysqli \
    opcache

# Configure php
RUN echo "date.timezone = UTC" >> /usr/local/etc/php/php.ini

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN curl -sS https://getcomposer.org/installer | php -- \
    --filename=composer \
    --install-dir=/usr/local/bin

# Install tool to speed up composer installations
RUN composer global require --optimize-autoloader \
    "hirak/prestissimo"

# Install wp-browser globally
RUN composer global require lucatume/wp-browser:^2.1

# Add composer global binaries to PATH
RUN echo "PATH=\$PATH:$(composer global config bin-dir --absolute)" >> ~/.bashrc

# Set up config
ENV WP_ROOT_FOLDER="."
ENV WP_URL="http://localhost"
ENV WP_DOMAIN="locahost"
ENV WP_TABLE_PREFIX="wp_"
ENV ADMIN_EMAIL="admin@wp.local"
ENV ADMIN_USERNAME="admin"
ENV ADMIN_PASSWORD="password"

# Set up wp-browser / codeception
WORKDIR /var/www/html
COPY    codeception.dist.yml codeception.dist.yml

# Install WordPress
RUN wp core download --allow-root

# Create WordPress wp-config
RUN wp config create \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASSWORD" \
    --dbhost="$DB_HOST" \
    --dbprefix="$WP_TABLE_PREFIX" \
    --skip-check \
    --allow-root

# Set up Apache
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# CircleCI Compatibility
# LABEL com.circleci.preserve-entrypoint=true

# Set up entrypoint
COPY       entrypoint.sh /entrypoint.sh
RUN        chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
