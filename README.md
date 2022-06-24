Roundcube Webmail Docker image
==============================

[![Release](https://img.shields.io/github/v/release/instrumentisto/roundcube-docker-image "Release")](https://github.com/instrumentisto/roundcube-docker-image/releases)
[![CI](https://github.com/instrumentisto/roundcube-docker-image/workflows/CI/badge.svg?branch=main "CI")](https://github.com/instrumentisto/roundcube-docker-image/actions?query=workflow%3ACI+branch%3Amain)
[![Docker Hub](https://img.shields.io/docker/pulls/instrumentisto/roundcube?label=Docker%20Hub%20pulls "Docker Hub pulls")](https://hub.docker.com/r/instrumentisto/roundcube)
[![Uses](https://img.shields.io/badge/uses-s6--overlay-blue.svg "Uses s6-overlay")](https://github.com/just-containers/s6-overlay)

[Docker Hub](https://hub.docker.com/r/instrumentisto/roundcube)
| [GitHub Container Registry](https://github.com/orgs/instrumentisto/packages/container/package/roundcube)
| [Quay.io](https://quay.io/repository/instrumentisto/roundcube)

[Changelog](https://github.com/instrumentisto/roundcube-docker-image/blob/main/CHANGELOG.md)




## Supported tags and respective `Dockerfile` links

- [`1.5.2-r8-apache`, `1.5.2-apache`, `1.5-apache`, `1-apache`, `apache`, `latest`][101]
- [`1.5.2-r8-fpm`, `1.5.2-fpm`, `1.5-fpm`, `1-fpm`, `fpm`][102]
- [`1.4.13-r8-apache`, `1.4.13-apache`, `1.4-apache`][103]
- [`1.4.13-r8-fpm`, `1.4.13-fpm`, `1.4-fpm`][104]
- [`1.3.17-r9-apache`, `1.3.17-apache`, `1.3-apache`][105]
- [`1.3.17-r9-fpm`, `1.3.17-fpm`, `1.3-fpm`][106]




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

The image contains [PHP OPcache][4] enabled. By default, cache revalidation is disabled for performance purposes, so once PHP script runs - it is cached forever and no changes to it have effect.

To disable this behavior, specify `PHP_OPCACHE_REVALIDATION=1` environment variable on container start. This will turn on OPcache revalidation, so any changes to PHP scripts will have desired effect. In this case it's also recommended disabling [PHP OPcache JIT][14], as described below.


### `PHP_OPCACHE_JIT_BUFFER_SIZE` (>= 1.5 only)

By default, the image contains `tracing` [PHP OPcache JIT][14] enabled of `100M` buffer size, for performance purposes.

To disable this behavior, specify `PHP_OPCACHE_JIT_BUFFER_SIZE=0` environment variable on container start. This will turn off [OPcache JIT][14] completely.


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


### `X`

Latest tag of `X` Roundcube Webmail's major version.


### `X.Y`

Latest tag of `X.Y` Roundcube Webmail's minor version.


### `X.Y.Z`

Latest tag of a concrete `vX.Y.Z` version of Roundcube Webmail.


### `X.Y.Z-rN`

Concrete `N` image revision tag of a Roundcube Webmail's concrete `X.Y.Z` version.

Once build, it's never updated.




## License

Roundcube Webmail is licensed under [GPL-3.0-or-later license][90].

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

The [sources][92] for producing `instrumentisto/roundcube` Docker images are licensed under [Blue Oak Model License 1.0.0][91].




## Issues

We can't notice comments in the [DockerHub] (or other container registries) so don't use them for reporting issue or asking question.

If you have any problems with or questions about this image, please contact us through a [GitHub issue][3].





[DockerHub]: https://hub.docker.com

[1]: http://alpinelinux.org
[2]: https://hub.docker.com/_/alpine
[3]: https://github.com/instrumentisto/roundcube-docker-image/issues
[4]: http://php.net/manual/en/book.opcache.php
[5]: https://github.com/instrumentisto/roundcube-docker-image/blob/main/examples/fpm-nginx.k8s.yml
[6]: https://github.com/instrumentisto/roundcube-docker-image/blob/main/examples/fpm-nginx.docker-compose.yml
[7]: https://github.com/instrumentisto/roundcube-docker-image/blob/main/examples/apache.docker-compose.yml
[8]: https://docs.docker.com/compose
[9]: https://php-fpm.org
[10]: https://www.nginx.com
[11]: https://hub.docker.com/_/nginx
[12]: https://hub.docker.com/_/httpd
[13]: https://github.com/instrumentisto/roundcube-docker-image/blob/main/examples
[14]: https://wiki.php.net/rfc/jit

[90]: https://github.com/roundcube/roundcubemail/blob/main/LICENSE
[91]: https://github.com/instrumentisto/roundcube-docker-image/blob/main/LICENSE.md
[92]: https://github.com/instrumentisto/roundcube-docker-image

[101]: https://github.com/instrumentisto/roundcube-docker-image/blob/main/1.5/apache/Dockerfile
[102]: https://github.com/instrumentisto/roundcube-docker-image/blob/main/1.5/fpm/Dockerfile
[103]: https://github.com/instrumentisto/roundcube-docker-image/blob/main/1.4/apache/Dockerfile
[104]: https://github.com/instrumentisto/roundcube-docker-image/blob/main/1.4/fpm/Dockerfile
[105]: https://github.com/instrumentisto/roundcube-docker-image/blob/main/1.3/apache/Dockerfile
[106]: https://github.com/instrumentisto/roundcube-docker-image/blob/main/1.3/fpm/Dockerfile
