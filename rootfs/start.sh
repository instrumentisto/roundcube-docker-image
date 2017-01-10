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


if [ "$APP_MOVE_INSTEAD_LINK" == "1" ]; then
  [ -L /var/www ] && rm -f /var/www
  [ -d /var/www ] || mkdir -p /var/www
  mv -f /app/* /app/.h* /var/www/
fi


exec "$@"
