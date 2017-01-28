# https://github.com/docker-library/php/blob/master/7.0/fpm/alpine/Dockerfile
FROM php:7.0-fpm-alpine

MAINTAINER Instrumentisto Team <developer@instrumentisto.com>


# Install s6-overlay
RUN curl -L -o /tmp/s6-overlay.tar.gz \
         https://github.com/just-containers/s6-overlay/releases/download/v1.19.1.1/s6-overlay-amd64.tar.gz \
 && tar -xzf /tmp/s6-overlay.tar.gz -C / \
 && rm -rf /tmp/s6-overlay.tar.gz

ENV S6_KEEP_ENV=1 \
    S6_CMD_WAIT_FOR_SERVICES=1


# Install required libraries and PHP extensions
RUN apk update \
 && apk upgrade \
 && update-ca-certificates \
 && apk add --no-cache --virtual .php-ext-deps \
        libpq unixodbc freetds \
        aspell-libs \
        icu-libs \
        libldap \
        zlib \

 && apk add --no-cache --virtual .build-deps \
        postgresql-dev unixodbc-dev freetds-dev \
        aspell-dev \
        icu-dev \
        openldap-dev \
        zlib-dev \

 && docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
 && docker-php-ext-install \
           exif \
           intl \
           ldap \
           opcache \
           pdo_mysql pdo_pgsql pdo_odbc pdo_dblib \
           pspell \
           sockets \
           zip \

 && apk del .build-deps \
 && rm -rf /var/cache/apk/*


# Install Roundcube
RUN curl -L -o /tmp/roundcube.tar.gz \
         https://github.com/roundcube/roundcubemail/releases/download/1.2.2/roundcubemail-1.2.2.tar.gz \
 && tar -xzf /tmp/roundcube.tar.gz -C /tmp/ \
 && rm -rf /var/www \
 && mv /tmp/roundcubemail-1.2.2 /var/www \

 # Install Composer to resolve Roundcube dependencies
 && curl -L -o /tmp/composer-setup.php \
          https://getcomposer.org/installer \
 && curl -L -o /tmp/composer-setup.sig \
          https://composer.github.io/installer.sig \
 && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { echo 'Invalid installer' . PHP_EOL; exit(1); }" \
 && php /tmp/composer-setup.php --install-dir=/tmp --filename=composer \

 # Resolve Roudcube dependencies
 && apk add --update --no-cache --virtual .composer-deps \
        git \
 && mv /var/www/composer.json-dist /var/www/composer.json \
 && cd /var/www \
 && /tmp/composer install --no-dev --optimize-autoloader \

 # Make default Roudcube configuration log to syslog
 && sed -i -r 's/^([^\s]{9}log_driver[^\s]{2} =) [^\s]+$/\1 "syslog";/g' \
        /var/www/config/defaults.inc.php \

 # Set correct owner
 && ln -s /var/www/public_html /var/www/html \
 && chown -R www-data:www-data /var/www \

 && apk del .composer-deps \
 && rm -rf /var/cache/apk/* \
           /tmp/*


# Install configurations
COPY rootfs /

# Fix executable rights
RUN chmod +x /etc/services.d/*/run \
             /start.sh \

 # Prepare directory for SQLite database
 && mkdir -p /var/db \
 && chown -R www-data:www-data /var/db

ENV PHP_OPCACHE_REVALIDATION=0


WORKDIR /var/www

ENTRYPOINT ["/init", "/start.sh"]

CMD ["php-fpm"]
