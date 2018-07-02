#!/usr/bin/env bats

IMAGE_TYPE=$(echo "$DOCKERFILE" | cut -d '/' -f 2 | tr -d ' ')
ROUNDCUBE_MINOR_VER=$(echo "$DOCKERFILE" | cut -d '/' -f 1 | tr -d ' ')


@test "post_push hook is up-to-date" {
  run sh -c "cat Makefile | grep $DOCKERFILE: \
                          | cut -d ':' -f 2 \
                          | cut -d '\\' -f 1 \
                          | tr -d ' '"
  [ "$status" -eq 0 ]
  [ "$output" != '' ]
  expected="$output"

  run sh -c "cat '$DOCKERFILE/hooks/post_push' \
               | grep 'for tag in' \
               | cut -d '{' -f 2 \
               | cut -d '}' -f 1"
  [ "$status" -eq 0 ]
  [ "$output" != '' ]
  actual="$output"

  [ "$actual" == "$expected" ]
}


@test "PHP ext 'dom' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx dom'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'exif' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx exif'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'fileinfo' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx fileinfo'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'gd' is installed" {
  [ "$ROUNDCUBE_MINOR_VER" == "1.2" ] && skip "no gd required"
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx gd'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'iconv' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx iconv'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'intl' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx intl'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'json' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx json'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'ldap' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx ldap'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'mbstring' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx mbstring'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'openssl' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx openssl'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'pcre' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx pcre'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'PDO' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx PDO'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'pdo_dblib' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx pdo_dblib'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'pdo_mysql' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx pdo_mysql'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'pdo_odbc' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx PDO_ODBC'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'pdo_pgsql' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx pdo_pgsql'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'pdo_sqlite' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx pdo_sqlite'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'pspell' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx pspell'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'session' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx session'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'sockets' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx sockets'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'zip' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx zip'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'Zend OPcache' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c \
                                              'php -m | grep -Fx "Zend OPcache"'
  [ "$status" -eq 0 ]
}


@test "PHP display_errors disabled" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "display_errors => Off => Off"'
  [ "$status" -eq 0 ]
}

@test "PHP log_errors enabled" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "log_errors => On => On"'
  [ "$status" -eq 0 ]
}

@test "PHP error_reporting level is E_ALL & ~E_NOTICE & ~E_STRICT" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "error_reporting => 30711 => 30711"'
  [ "$status" -eq 0 ]
}

@test "PHP file_uploads enabled" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "file_uploads => On => On"'
  [ "$status" -eq 0 ]
}

@test "PHP upload_max_filesize is 5M" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "upload_max_filesize => 5M => 5M"'
  [ "$status" -eq 0 ]
}

@test "PHP post_max_size is 6M" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "post_max_size => 6M => 6M"'
  [ "$status" -eq 0 ]
}

@test "PHP memory_limit is 64M" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "memory_limit => 64M => 64M"'
  [ "$status" -eq 0 ]
}

@test "PHP mbstring.func_overload disabled" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "mbstring.func_overload => 0 => 0"'
  [ "$status" -eq 0 ]
}

@test "PHP session.auto_start disabled" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "session.auto_start => Off => Off"'
  [ "$status" -eq 0 ]
}

@test "PHP session.gc_maxlifetime is 21600" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "session.gc_maxlifetime => 21600 => 21600"'
  [ "$status" -eq 0 ]
}

@test "PHP session.gc_divisor is 500" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "session.gc_divisor => 500 => 500"'
  [ "$status" -eq 0 ]
}

@test "PHP session.gc_probability is 1" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "session.gc_probability => 1 => 1"'
  [ "$status" -eq 0 ]
}

@test "PHP zlib.output_compression disabled" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "zlib.output_compression => Off => Off"'
  [ "$status" -eq 0 ]
}

@test "PHP OPcache enabled" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "opcache.enable => On => On"'
  [ "$status" -eq 0 ]
}


@test "PHP_OPCACHE_REVALIDATION=0 disables OPcache timestamps validation" {
  run docker run --rm -e PHP_OPCACHE_REVALIDATION=0 \
                      --entrypoint /docker-entrypoint.sh $IMAGE sh -c \
    'php -i | grep -Fx "opcache.validate_timestamps => Off => Off"'
  [ "$status" -eq 0 ]
}

@test "PHP_OPCACHE_REVALIDATION=1 enables OPcache timestamps validation" {
  run docker run --rm -e PHP_OPCACHE_REVALIDATION=1 \
                      --entrypoint /docker-entrypoint.sh $IMAGE sh -c \
    'php -i | grep -Fx "opcache.validate_timestamps => On => On"'
  [ "$status" -eq 0 ]
}


@test "SHARE_APP=0 makes /var/www link to /app/ dir" {
  run docker run --rm -e SHARE_APP=0 \
                      --entrypoint /docker-entrypoint.sh $IMAGE sh -c \
    'test -L /var/www && readlink -f /var/www | tr -d "\n"'
  [ "$status" -eq 0 ]
  [ "$output" == "/app" ]
}

@test "SHARE_APP=1 makes /var/www link to /shared/ dir" {
  run docker run --rm -e SHARE_APP=1 \
                      --entrypoint /docker-entrypoint.sh $IMAGE sh -c \
    'test -L /var/www && readlink -f /var/www | tr -d "\n"'
  [ "$status" -eq 0 ]
  [ "$output" == "/shared" ]
}

@test "SHARE_APP=1 copies all files from /app/ to /shared/" {
  run docker run --rm -e SHARE_APP=0 \
                      --entrypoint /docker-entrypoint.sh $IMAGE sh -c \
    'cd /app && find . | sort'
  [ "$status" -eq 0 ]
  expected="$output"

  run docker run --rm -e SHARE_APP=1 \
                      --entrypoint /docker-entrypoint.sh $IMAGE sh -c \
    'cd /app && find . | sort'
  [ "$status" -eq 0 ]
  preserved="$output"

  run docker run --rm -e SHARE_APP=1 \
                      --entrypoint /docker-entrypoint.sh $IMAGE sh -c \
    'cd /shared && find . | sort'
  [ "$status" -eq 0 ]
  actual="$output"

  [ "$actual" == "$expected" ]
  [ "$preserved" == "$expected" ]
}


@test "Apache 'autoindex' module is loaded" {
  [ "$IMAGE_TYPE" != "apache" ] && skip "no Apache"
  run docker run --rm --entrypoint sh $IMAGE -c \
    'apache2ctl -M | grep -F autoindex_module'
  [ "$status" -eq 0 ]
}

@test "Apache 'deflate' module is loaded" {
  [ "$IMAGE_TYPE" != "apache" ] && skip "no Apache"
  run docker run --rm --entrypoint sh $IMAGE -c \
    'apache2ctl -M | grep -F deflate_module'
  [ "$status" -eq 0 ]
}

@test "Apache 'expires' module is loaded" {
  [ "$IMAGE_TYPE" != "apache" ] && skip "no Apache"
  run docker run --rm --entrypoint sh $IMAGE -c \
    'apache2ctl -M | grep -F expires_module'
  [ "$status" -eq 0 ]
}

@test "Apache 'headers' module is loaded" {
  [ "$IMAGE_TYPE" != "apache" ] && skip "no Apache"
  run docker run --rm --entrypoint sh $IMAGE -c \
    'apache2ctl -M | grep -F headers_module'
  [ "$status" -eq 0 ]
}

@test "Apache 'php7' module is loaded" {
  [ "$IMAGE_TYPE" != "apache" ] && skip "no Apache"
  run docker run --rm --entrypoint sh $IMAGE -c \
    'apache2ctl -M | grep -F php7_module'
  [ "$status" -eq 0 ]
}

@test "Apache 'rewrite' module is loaded" {
  [ "$IMAGE_TYPE" != "apache" ] && skip "no Apache"
  run docker run --rm --entrypoint sh $IMAGE -c \
    'apache2ctl -M | grep -F rewrite_module'
  [ "$status" -eq 0 ]
}


@test "Roundcube .htaccess uses correct 'mod_php'" {
  [ "$IMAGE_TYPE" != "apache" ] && skip "no .htaccess used"
  run docker run --rm --entrypoint sh $IMAGE -c \
    'cat /var/www/.htaccess | grep -F mod_php7'
  [ "$status" -eq 0 ]
  run docker run --rm --entrypoint sh $IMAGE -c \
    'cat /var/www/.htaccess | grep -F mod_php5 | wc -l'
  [ "$status" -eq 0 ]
  [ "$output" == "0" ]
}

@test "Roundcube .htaccess has unexistent PHP options being commented" {
  [ "$IMAGE_TYPE" != "apache" ] && skip "no .htaccess used"
  if [ "$ROUNDCUBE_MINOR_VER" == "1.2" ]; then
    run docker run --rm --entrypoint sh $IMAGE -c \
      'cat /var/www/.htaccess | grep -F register_globals | head -c 1'
    [ "$status" -eq 0 ]
    [ "$output"  == "#" ]
    run docker run --rm --entrypoint sh $IMAGE -c \
      'cat /var/www/.htaccess | grep -F magic_quotes_gpc | head -c 1'
    [ "$status" -eq 0 ]
    [ "$output"  == "#" ]
    run docker run --rm --entrypoint sh $IMAGE -c \
      'cat /var/www/.htaccess | grep -F magic_quotes_runtime | head -c 1'
    [ "$status" -eq 0 ]
    [ "$output"  == "#" ]
  fi
  run docker run --rm --entrypoint sh $IMAGE -c \
    'cat /var/www/.htaccess | grep -F suhosin.session.encrypt | head -c 1'
  [ "$status" -eq 0 ]
  [ "$output"  == "#" ]
}


@test "gpg is present" {
  run docker run --rm --entrypoint sh $IMAGE -c 'which curl'
  [ "$status" -eq 0 ]
}

@test "gpg runs ok" {
  run docker run --rm --entrypoint sh $IMAGE -c 'gpg --help'
  [ "$status" -eq 0 ]
}
