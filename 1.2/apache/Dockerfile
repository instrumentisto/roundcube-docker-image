# https://github.com/docker-library/php/blob/master/7.0/fpm/alpine/Dockerfile
FROM php:7.0-apache

MAINTAINER Instrumentisto Team <developer@instrumentisto.com>


# Install s6-overlay
RUN curl -L -o /tmp/s6-overlay.tar.gz \
         https://github.com/just-containers/s6-overlay/releases/download/v1.19.1.1/s6-overlay-amd64.tar.gz \
 && tar -xzf /tmp/s6-overlay.tar.gz -C / \
 && rm -rf /tmp/s6-overlay.tar.gz

ENV S6_KEEP_ENV=1 \
    S6_CMD_WAIT_FOR_SERVICES=1


# Install required libraries and PHP extensions
RUN apt-get update \
 && apt-get upgrade -y \
 && update-ca-certificates \
 && apt-get install -y --no-install-recommends \
            rsyslog \
 && apt-get install -y --no-install-recommends \
            libpq5 libodbc1 libsybdb5 \
            libaspell15 \
            libicu52 \
            libldap-2.4-2 libsasl2-2 \

 && buildDeps=" \
      libpq-dev unixodbc-dev freetds-dev \
      libpspell-dev \
      libicu-dev \
      libldap2-dev \
      libzip-dev \
    " \
 && apt-get install -y $buildDeps --no-install-recommends \

 && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
 && docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
 && docker-php-ext-configure pdo_dblib --with-libdir=lib/x86_64-linux-gnu \
 && docker-php-ext-install \
           exif \
           intl \
           ldap \
           opcache \
           pdo_mysql pdo_pgsql pdo_odbc pdo_dblib \
           pspell \
           sockets \
           zip \

 && a2enmod expires \
            headers \
            rewrite \

 && apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/*


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
 && apt-get update \
 && composerDeps="git" \
 && apt-get install -y $composerDeps --no-install-recommends \
 && mv /var/www/composer.json-dist /var/www/composer.json \
 && cd /var/www \
 && /tmp/composer install --no-dev --optimize-autoloader \

 # Make default Roudcube configuration log to syslog
 && sed -i -r 's/^([^\s]{9}log_driver[^\s]{2} =) [^\s]+$/\1 "syslog";/g' \
        /var/www/config/defaults.inc.php \

 # Fix Roundcube .htaccess for PHP7
 && sed -i -r 's/^(<IfModule mod)_php5/\1_php7/g' \
        /var/www/.htaccess \
 && sed -i -r 's/^(php_flag[ ]+(register_globals|magic_quotes|suhosin))/#\1/g' \
        /var/www/.htaccess \

 # Set correct owner
 && ln -s /var/www/public_html /var/www/html \
 && chown -R www-data:www-data /var/www \

 && apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $composerDeps \
 && rm -rf /var/lib/apt/lists/* \
           /tmp/*


# Install configurations
COPY rootfs /

# Fix executable rights
RUN chmod +x /etc/services.d/*/run \
             /start.sh \

 # Prepare directory for SQLite database
 && mkdir -p /var/db \
 && chown -R www-data:www-data /var/db


WORKDIR /var/www

ENTRYPOINT ["/init", "/start.sh"]

CMD ["apache2-foreground"]
