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

rm -f /usr/local/etc/php/conf.d/zz-opcache-jit.ini
if [ ! -z "$PHP_OPCACHE_JIT_BUFFER_SIZE" ] ; then
  echo "opcache.jit_buffer_size = $PHP_OPCACHE_JIT_BUFFER_SIZE" \
    > /usr/local/etc/php/conf.d/zz-opcache-jit.ini
if [ "$PHP_OPCACHE_JIT_BUFFER_SIZE" != "0" ] ; then
  logMsg "STARTUP: PHP OPcache JIT is enabled of $PHP_OPCACHE_JIT_BUFFER_SIZE"
fi
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
