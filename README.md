Debian Nginx-1.12.0, PHP7.x-FPM, Composer image
=========================================================

This is the [specbee/appserver](https://hub.docker.com/r/specbee/appserver/) Docker image providing Nginx 1.12.0,PHP-FPM 7.x(Configurable for 7.0, 7.1, 7.2) and Composer.

## Features

### Nginx 1.12.0

**Default host** is configured and served from `/var/www/html`. [index.php] file to added to that location with phpinfo().

### PHP-FPM 7

**PHP 7** is up & running for the default host. See [/etc/nginx/conf.d/default.conf].

[/etc/nginx/fastcgi_params](rootfs/etc/nginx/fastcgi_params) has been tweaked to work well with most PHP applications.

### Composer

**Composer** Composer is up and running.

### Directory structure
```
/var/www # Web content
/var/www/web # Root directory for the default host
/var/log/ # Nginx, PHP logs
/var/tmp/php/ # PHP temp directories
```

### Quick Start

```
docker run -d --name=app -p=80:80 -p=443:443 -d appserver:7.2-fpm
```
