FROM php:apache-buster

# Install required system packages
RUN apt-get update && \
    apt-get -y install \
    default-mysql-client \
    libjpeg-dev \
    libpng-dev \
    libzip-dev \
    zip \
    gzip \
    tar \
    ssh \
    wget \
    git \
    jq \
    nodejs \
    npm

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

# Install Dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz


# Install composer
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN curl -sS https://getcomposer.org/installer | php -- \
    --filename=composer \
    --install-dir=/usr/local/bin

# Install tool to speed up composer installations
RUN composer global require --optimize-autoloader \
    "hirak/prestissimo"

# Install wp-browser globally
RUN composer global require \
    codeception/codeception \
    codeception/module-asserts \
    codeception/module-db \
    codeception/module-webdriver \
    codeception/module-phpbrowser \
    codeception/module-cli \
    codeception/module-rest \
    codeception/util-universalframework \
    codeception/module-filesystem \
    codeception/specify \
    codeception/verify \
    lucatume/wp-browser \
    hoa/console \
    vlucas/phpdotenv \
    league/factory-muffin \
    league/factory-muffin-faker

# Add composer global binaries to PATH
ENV PATH "$PATH:~/.composer/vendor/bin"

# Set up WordPress config
ENV WORDPRESS_DB_HOST="mysql"
ENV WORDPRESS_DB_USER="wordpress"
ENV WORDPRESS_DB_PASSWORD="wordpress"
ENV WORDPRESS_DB_NAME="wordpress"
ENV WORDPRESS_DB_CHARSET="utf8"
ENV WORDPRESS_ROOT_FOLDER="/var/www/html"
ENV WORDPRESS_DOMAIN="localhost"
ENV WORDPRESS_URL="http://localhost"
ENV WORDPRESS_TABLE_PREFIX="wp_"
ENV WORDPRESS_ADMIN_EMAIL="admin@wp.local"
ENV WORDPRESS_ADMIN_USERNAME="admin"
ENV WORDPRESS_ADMIN_PASSWORD="password"

# Set up Apache
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf
RUN a2enmod rewrite

# Set up our entrypoint
COPY entrypoint.sh /usr/local/bin/

# Copy Codeception configs
COPY config/codeception.*.yml /var/www/html/

# Set up entrypoint
WORKDIR    /var/www/html
ENTRYPOINT ["entrypoint.sh"]
