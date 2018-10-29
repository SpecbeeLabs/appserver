FROM php:7.1-fpm

ENV DEBIAN_FRONTEND noninteractive

# Common
RUN apt-get update \
    && apt-get install -y \
        git \
        openssl \
        supervisor \
        wget

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
    libmemcached-dev \
    libpq-dev \
    libxml2-dev \
    mysql-client \
    openssh-client \
    rsync \
    xfonts-base \
    xfonts-75dpi \
    && pecl install \
       imagick \
       memcached \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-enable \
        imagick \
        memcached \
    && docker-php-ext-install \
        bcmath \
        bz2 \
        calendar \
        dom \
        gd \
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

COPY "./templates/core-php.ini" "/usr/local/etc/php/conf.d/core-php.ini"

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Put a turbo on composer.
RUN composer global require hirak/prestissimo

WORKDIR /etc/supervisor

COPY ./templates/supervisord.conf conf.d/super.conf
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/super.conf"]

COPY ./app/index.php /var/www/web/index.php

WORKDIR /var/www/web

RUN apt-get -y clean \
    && apt-get -y autoclean \
    && apt-get -y autoremove

#RUN sed -e 's/max_execution_time = 30/max_execution_time = 120/' -i /etc/php/7.1/fpm/php.ini
