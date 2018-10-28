FROM php:7.1-fpm

ENV DEBIAN_FRONTEND noninteractive

# Common
RUN apt-get update \
    && apt-get install -y \
        git \
        openssl \
        supervisor \
        wget \
    gnupg

RUN chmod -R 777 /tmp

#Install nginx
RUN apt-get update \
    && apt-get -y install nginx

WORKDIR /etc/nginx
RUN rm -Rf conf.d/default.conf
ADD ./templates/default.nginx.cnf sites-available/default
EXPOSE 80 443

# PHP
RUN apt-get install -y \
    bzip2 \
    curl \
    imagemagick \
    libbz2-dev \
    libc-client2007e-dev \
    libjpeg-dev \
    libkrb5-dev \
    libldap2-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libpq-dev \
    libxml2-dev \
    mysql-client \
    rsync \
    xfonts-base \
    xfonts-75dpi \
    && docker-php-ext-configure \
        gd --with-png-dir=/usr --with-jpeg-dir=/usr \
        intl \
        opcache \
        zip \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install \
        calendar \
        dom \
        gd \
        imagick \
        intl \
        json \
        mcrypt \
        mbstring \
        mysqli \
        opcache \
        pdo \
        pdo_mysql \
        soap \
        xml \
        zip \
     && echo default_mimetype="" > /usr/local/etc/php/conf.d/default_mimetype.ini
COPY "memory-limit-php.ini" "/usr/local/etc/php/conf.d/memory-limit-php.ini"

# Memcached
# TODO PECL not available for PHP 7 yet, we must compile it.
RUN apt-get install -y \
        libmemcached-dev \
        libmemcached11

WORKDIR /tmp
RUN git clone -b php7 https://github.com/php-memcached-dev/php-memcached \
    && cd php-memcached \
    && phpize \
    && ./configure \
    && make \
    && cp /tmp/php-memcached/modules/memcached.so /usr/local/lib/php/extensions/no-debug-non-zts-20160303/memcached.so \
    && docker-php-ext-enable memcached

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Put a turbo on composer.
RUN composer global require hirak/prestissimo

# Set the Drush version.
RUN composer global require drush/drush --prefer-dist \
    && rm -f /usr/local/bin/drush \
    && ln -s ~/.composer/vendor/bin/drush /usr/local/bin/drush \
    && drush core-status -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/supervisor

COPY ./templates/supervisord.conf conf.d/super.conf
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/super.conf"]

COPY ./app/index.php /var/www/web/index.php

WORKDIR /var/www/web

RUN apt-get -y clean \
    && apt-get -y autoclean \
    && apt-get -y autoremove
