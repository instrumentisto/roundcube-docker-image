#!/bin/sh


logMsg() {
  echo "["`date +%d'-'%b'-'%Y' '%H':'%M':'%S`"] $1" >> /proc/self/fd/2
}


rm -f /usr/local/etc/php/conf.d/zz-opcache-revalidation.ini
if [ "$PHP_OPCACHE_REVALIDATION" == "1" ]; then
  echo "opcache.validate_timestamps = On" \
    > /usr/local/etc/php/conf.d/zz-opcache-revalidation.ini
  logMsg "STARTUP: PHP OPcache revalidation is enabled"
fi


appDir=/app
if [ "$SHARE_APP" == "1" ]; then
  mkdir -p /shared
  cp -rf /app/* /app/.htaccess /shared/
  chown -R www-data:www-data /shared/* /shared/.htaccess
  appDir=/shared
fi
rm -f /var/www
ln -s $appDir /var/www
chown -R www-data:www-data /var/www


exec "$@"
