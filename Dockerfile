FROM robcherry/docker-chromedriver

# FROM  php:7.2-apache-stretch

SHELL [ "/bin/bash", "-c" ]

RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list

# Install Libraries for Chrome, PHP & WordPress
RUN apt-get -y update && \
    apt-get -y install \
    # WordPress dependencies
    libjpeg-dev \
    libpng-dev \
    mysql-client \
    git \
    ssh \
    tar \
    zip \
    unzip \
    wget \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

RUN curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add -

RUN add-apt-repository "deb https://packages.sury.org/php/ $(lsb_release -cs) main"

RUN apt-get -y update && \
    apt-get -y install \
    apache2 \
    php7.3-common \
    php7.3-cli \
    php-pear \
    libapache2-mod-php \
    php7.3-curl \
    php7.3-bcmath \
    php7.3-zip \
    php7.3-gd \
    php7.3-mysqli \
    php7.3-mbstring

# Clean up packages
RUN apt-get -y autoremove

# Configure php
# RUN echo "date.timezone = UTC" >> /usr/local/etc/php/php.ini

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
    lucatume/wp-browser:^2.2 \
    league/factory-muffin:^3.0 \
    league/factory-muffin-faker:^2.0

# Add composer global binaries to PATH
ENV PATH "$PATH:~/.composer/vendor/bin"

# Set up WordPress config
ENV WP_ROOT_FOLDER="/var/www/html"
ENV WP_URL="http://localhost"
ENV WP_DOMAIN="localhost"
ENV WP_TABLE_PREFIX="wp_"
ENV ADMIN_EMAIL="admin@wordpress.local"
ENV ADMIN_USERNAME="admin"
ENV ADMIN_PASSWORD="password"

# Set up wp-browser / codeception
WORKDIR    /var/www/config
COPY       config/codeception.dist.yml codeception.dist.yml

# Set up Apache
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf
RUN a2enmod rewrite

# Set up entrypoint
WORKDIR    /var/www/html
COPY       entrypoint.sh /entrypoint.sh
RUN        chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
