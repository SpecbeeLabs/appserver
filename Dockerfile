ARG PHP_BASE_IMAGE=7.1-fpm
FROM php:${PHP_BASE_IMAGE}

ARG PHP_BASE_IMAGE
ENV PHP_VERSION=$PHP_BASE_IMAGE

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
    libjpeg-dev \
    libldap2-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libpq-dev \
    libxml2-dev \
    mysql-client \
    openssh-client \
    rsync \
    && pecl install \
       imagick \
       memcached \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-enable \
        imagick \
        memcached \
    && docker-php-ext-install \
        calendar \
        dom \
        gd \
        json \
        mbstring \
        mysqli \
        opcache \
        pdo \
        pdo_mysql \
        soap \
        xml \
        zip \
    && echo default_mimetype="" > /usr/local/etc/php/conf.d/default_mimetype.ini

RUN echo $PHP_VERSION

# mcrypt moved to pecl in PHP 7.2
RUN if [ "$PHP_VERSION" = "7.2-fpm" ]; then \
    pecl install mcrypt-1.0.1; \
    docker-php-ext-enable mcrypt; \
    else \
    echo $PHP_VERSION; \
    docker-php-ext-install mcrypt; \
    fi;

COPY ./templates/core-php.ini /usr/local/etc/php/conf.d/core-php.ini

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Put a turbo on composer.
RUN composer global require hirak/prestissimo

WORKDIR /etc/supervisor

COPY ./templates/supervisord.conf conf.d/super.conf
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/super.conf"]

EXPOSE 80 443

WORKDIR /var/www

RUN apt-get -y clean \
    && apt-get -y autoclean \
    && apt-get -y autoremove
