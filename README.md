Roundcube Webmail Docker Image
==============================

[![Build Status](https://travis-ci.org/instrumentisto/roundcube-docker-image.svg?branch=master)](https://travis-ci.org/instrumentisto/roundcube-docker-image) [![Docker Pulls](https://img.shields.io/docker/pulls/instrumentisto/roundcube.svg)](https://hub.docker.com/r/instrumentisto/roundcube) [![Uses](https://img.shields.io/badge/uses-s6--overlay-blue.svg)](https://github.com/just-containers/s6-overlay)




## Supported tags and respective `Dockerfile` links

- `1.3.6-apache`, `1.3-apache`, `1-apache`, `apache`, `latest` [(1.3/apache/Dockerfile)][101]
- `1.3.6-fpm`, `1.3-fpm`, `1-fpm`, `fpm` [(1.3/fpm/Dockerfile)][102]
- `1.2.8-apache`, `1.2-apache` [(1.2/apache/Dockerfile)][103]
- `1.2.8-fpm`, `1.2-fpm` [(1.2/fpm/Dockerfile)][104]




## What is Roundcube Webmail?

Roundcube Webmail is a browser-based multilingual IMAP client with an application-like user interface. It provides full functionality you expect from an email client, including MIME support, address book, folder manipulation, message searching and spell checking.
[More details...](https://roundcube.net/about)

> [roundcube.net](https://roundcube.net/)

![Roundcube Logo](https://roundcube.net/images/logo.png)




## How to use this image

To simply run Roundcube Webmail image mount your Roundcube configuration and use `apache` image version: 
```bash
docker run -d -p 80:80 -v /my/roundcube.config.php:/app/config/config.inc.php \
    instrumentisto/roundcube:apache
```

It's better to do it with [Docker Compose][8]. See [Apache Docker Compose example][7] for details.

If you prefer [Nginx][10] and [PHP-FPM][9], you just require second sidecar [Nginx container][11]:
```yaml
version: '3'
services:
  roundcube:
    image: instrumentisto/roundcube:fpm
    expose:
      - "9000"
    volumes:
      - app-volume:/app
      - ./roundcube.config.php:/app/config/config.inc.php:ro
  nginx:
    image: nginx:stable-alpine
    depends_on:
      - roundcube
    ports:
      - "80:80"
    volumes:
      - app-volume:/var/www
      - ./nginx.vh.conf:/etc/nginx/conf.d/default.conf:ro
volumes:
  app-volume:
```

See [Nginx and PHP-FPM Docker Compose example][6] for details.

Also, this image contains prepared directory for SQLite database (if you choose to use one) in `/var/db/` path. So your `db_dsnw` parameter is preferred to have following value:
```php
$config['db_dsnw'] = 'sqlite:////var/db/roundcube.db?mode=0640';
```

Check out [examples][13] for more details.




## Environment Variables


### `PHP_OPCACHE_REVALIDATION`

The image contains [PHP OPcache][4] enabled. By default cache revalidation is disabled for performance purposes, so once PHP script runs - it is cached forever and no changes to it have effect.

To disable this behavior specify `PHP_OPCACHE_REVALIDATION=1` environment variable on container start. This will turn on OPcache revalidation, so any changes to PHP scripts will have desired effect.


### `SHARE_APP`

There are some container environments (like [Kubernetes](https://kubernetes.io)) where you can't share directory from one container to another directly. Instead, you should create a volume, place there desired files and mount this volume to both containers.

With providing `SHARE_APP=1` environment variable you have this behavior out-of-the-box. It will copy all the Roundcube Webmail sources from `/app/` directory to `/shared/` directory (just mount your volume to this directory) on container start and serve them from there. See [Kubernetes example][5] for details.




## Image versions


### `apache`, `latest`

The image with Roundcube Webmail served by [Apache HTTP server](http://httpd.apache.org). 


### `fpm`

The image with Roundcube Webmail served by [PHP-FPM][9].  
It cannot be used alone and is intended to be used in conjunction with some other web server image (like [Nginx][11], [Apache][12], etc).

This image is based on the popular [Alpine Linux project][1], available in [the alpine official image][2]. Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.


### `X.Y`

Latest version of `X.Y` Roundcube Webmail branch.


### `X.Y.Z`

Concrete `vX.Y.Z` version of Roundcube Webmail.




## License

Roundcube Webmail is licensed under [GPL-3.0 license][91].

Roundcube Webmail Docker image is licensed under [MIT license][90].




## Issues

We can't notice comments in the DockerHub so don't use them for reporting issue or asking question.

If you have any problems with or questions about this image, please contact us through a [GitHub issue][3].





[1]: http://alpinelinux.org
[2]: https://hub.docker.com/_/alpine
[3]: https://github.com/instrumentisto/roundcube-docker-image/issues
[4]: http://php.net/manual/en/book.opcache.php
[5]: https://github.com/instrumentisto/roundcube-docker-image/blob/master/examples/fpm-nginx.k8s.yml
[6]: https://github.com/instrumentisto/roundcube-docker-image/blob/master/examples/fpm-nginx.docker-compose.yml
[7]: https://github.com/instrumentisto/roundcube-docker-image/blob/master/examples/apache.docker-compose.yml
[8]: https://docs.docker.com/compose
[9]: https://php-fpm.org
[10]: https://www.nginx.com
[11]: https://hub.docker.com/_/nginx
[12]: https://hub.docker.com/_/httpd
[13]: https://github.com/instrumentisto/roundcube-docker-image/blob/master/examples
[90]: https://github.com/instrumentisto/roundcube-docker-image/blob/master/LICENSE.md
[91]: https://github.com/roundcube/roundcubemail/blob/master/LICENSE
[101]: https://github.com/instrumentisto/roundcube-docker-image/blob/master/1.3/apache/Dockerfile
[102]: https://github.com/instrumentisto/roundcube-docker-image/blob/master/1.3/fpm/Dockerfile
[103]: https://github.com/instrumentisto/roundcube-docker-image/blob/master/1.2/apache/Dockerfile
[104]: https://github.com/instrumentisto/roundcube-docker-image/blob/master/1.2/fpm/Dockerfile
