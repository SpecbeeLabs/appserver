Debian Nginx-1.12.0, PHP7.1-FPM, Drush, Composer,  image
=========================================================

Nginx/PHP-FPM Docker image - based on `php:7.1-fpm`.

Sample Docker build files to facilitate installation, configuration, and environment setup for Drupal CMS users.


This is the [valuebound/appserver](https://hub.docker.com/r/valuebound/appserver/builds/) Docker image providing Nginx 1.12.0,PHP-FPM 7.1, Drush and Composer with a tuned for great performance.

## Features

### Nginx 1.12.0

This image is based on [valuebound/appserver](https://hub.docker.com/r/valuebound/appserver/builds) - go there for more details.  
**Default host** is configured and served from `/var/www/html`. [index.php] file to added to that location with phpinfo().

### PHP-FPM 7.1

**PHP 7.1** is up & running for the default host. See [/etc/nginx/conf.d/default.conf].

[/etc/nginx/fastcgi_params](rootfs/etc/nginx/fastcgi_params) has been tweaked to work well with most PHP applications.

### Drush

**Drush** Drush is up and running.

### Composer

**Composer** Composer is up and running.

### Error logging

Nginx and PHP error logs are available via 'docker logs [container]'.
In addition, they are logged to `/var/log/nginx/error.log`. 

### Directory structure
```
/var/www # Web content
/var/www/web # Root directory for the default host
/var/log/ # Nginx, PHP logs
/var/tmp/php/ # PHP temp directories
```

### Pre-defined FastCGI cache for PHP backend

A PHP location with FastCGI caching can be created like this:
```
## Parse all .php file in the /var/www directory
    location ~ .php$ {
        include fastcgi_params;
        fastcgi_split_path_info ^(.+\.php)(.*)$;
        fastcgi_pass   php;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param  SCRIPT_NAME      $fastcgi_script_name;
        fastcgi_param  QUERY_STRING     $query_string;
        fastcgi_param  REQUEST_METHOD   $request_method;
        fastcgi_param  CONTENT_TYPE     $content_type;
        fastcgi_param  CONTENT_LENGTH   $content_length;
        fastcgi_intercept_errors        on;
        fastcgi_ignore_client_abort     off;
        fastcgi_connect_timeout 60;
        fastcgi_send_timeout 180;
        fastcgi_read_timeout 180;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;
    }
```

### Quick Start

```
docker run -d --name=app -p=80:80 -p=443:443 -e GENERATE_DEFAULT_HOST=true 
```

### By creating a new image and embedding the web content

	FROM valuebound/appserver:latest
