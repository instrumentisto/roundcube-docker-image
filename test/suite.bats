#!/usr/bin/env bats


@test "post_push hook is up-to-date" {
  run sh -c "cat Makefile | grep 'TAGS ?= ' \
                          | cut -d ' ' -f 3"
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]
  expected="$output"

  run sh -c "cat hooks/post_push | grep 'for tag in' \
                                 | cut -d '{' -f 2 \
                                 | cut -d '}' -f 1"
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]
  actual="$output"

  [ "$actual" = "$expected" ]
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

@test "PHP session.auto_start disabled" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "session.auto_start => Off => Off"'
  [ "$status" -eq 0 ]
}

@test "PHP mbstring.func_overload disabled" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "mbstring.func_overload => 0 => 0"'
  [ "$status" -eq 0 ]
}

@test "PHP OPcache enabled" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'php -i | grep -Fx "opcache.enable => On => On"'
  [ "$status" -eq 0 ]
}


@test "PHP_OPCACHE_REVALIDATION=0 disables OPcache timestamps validation" {
  run docker run --rm -e PHP_OPCACHE_REVALIDATION=0 \
                      --entrypoint /start.sh $IMAGE sh -c \
    'php -i | grep -Fx "opcache.validate_timestamps => Off => Off"'
  [ "$status" -eq 0 ]
}

@test "PHP_OPCACHE_REVALIDATION=1 enables OPcache timestamps validation" {
  run docker run --rm -e PHP_OPCACHE_REVALIDATION=1 \
                      --entrypoint /start.sh $IMAGE sh -c \
    'php -i | grep -Fx "opcache.validate_timestamps => On => On"'
  [ "$status" -eq 0 ]
}


#@test "APP_MOVE_INSTEAD_LINK=0 makes /var/www link to /app folder" {
#  run docker run --rm -e APP_MOVE_INSTEAD_LINK=0 --entrypoint /start.sh $IMAGE \
#    sh -c 'test -L /var/www && readlink -f /var/www | tr -d "\n"'
#  [ "$status" -eq 0 ]
#  [ "$output" == "/app" ]
#}

#@test "APP_MOVE_INSTEAD_LINK=0 sets correct owner of /var/www link" {
#  run docker run --rm -e APP_MOVE_INSTEAD_LINK=0 --entrypoint /start.sh $IMAGE \
#    sh -c 'ls -l /var/www | tr -d "\n " | grep nobodynobody | wc -l'
#  [ "$status" -eq 0 ]
#  [ "$output" == "1" ]
#}

#@test "APP_MOVE_INSTEAD_LINK=1 moves /app folder to /var/www" {
#  run docker run --rm -e APP_MOVE_INSTEAD_LINK=1 --entrypoint /start.sh $IMAGE \
#    sh -c 'test -d /var/www && ls -A /var/www/ | wc -l | tr -d "\n "'
#  [ "$status" -eq 0 ]
#  [ "$output" != "0" ]
#  run docker run --rm -e APP_MOVE_INSTEAD_LINK=1 --entrypoint /start.sh $IMAGE \
#    sh -c 'ls -A /app/ | wc -l | tr -d "\n "'
#  [ "$status" -eq 0 ]
#  [ "$output" == "0" ]
#}
