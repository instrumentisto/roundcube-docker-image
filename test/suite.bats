#!/usr/bin/env bats


@test "PHP ext 'PDO' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx PDO'
  [ "$status" -eq 0 ]
}

@test "PHP ext 'pdo_mysql' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'php -m | grep -Fx pdo_mysql'
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

@test "PHP ext 'Zend OPcache' is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c \
                                              'php -m | grep -Fx "Zend OPcache"'
  [ "$status" -eq 0 ]
}


@test "post_push hook is up-to-date" {
  run sh -c "cat Makefile | grep 'TAGS ?= ' | cut -d ' ' -f 3"
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]
  expected="$output"

  run sh -c "cat hooks/post_push | grep 'for tag in' \
                                 | cut -d '{' -f 2 | cut -d '}' -f 1"
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]
  actual="$output"

  [ "$actual" = "$expected" ]
}


@test "APP_MOVE_INSTEAD_LINK=0 makes /var/www link to /app folder" {
  run docker run --rm -e APP_MOVE_INSTEAD_LINK=0 --entrypoint /start.sh $IMAGE \
    sh -c 'test -L /var/www && readlink -f /var/www | tr -d "\n"'
  [ "$status" -eq 0 ]
  [ "$output" == "/app" ]
}

@test "APP_MOVE_INSTEAD_LINK=0 sets correct owner of /var/www link" {
  run docker run --rm -e APP_MOVE_INSTEAD_LINK=0 --entrypoint /start.sh $IMAGE \
    sh -c 'ls -l /var/www | tr -d "\n " | grep nobodynobody | wc -l'
  [ "$status" -eq 0 ]
  [ "$output" == "1" ]
}

@test "APP_MOVE_INSTEAD_LINK=1 moves /app folder to /var/www" {
  run docker run --rm -e APP_MOVE_INSTEAD_LINK=1 --entrypoint /start.sh $IMAGE \
    sh -c 'test -d /var/www && ls -A /var/www/ | wc -l | tr -d "\n "'
  [ "$status" -eq 0 ]
  [ "$output" != "0" ]
}

@test "APP_MOVE_INSTEAD_LINK=1 makes /app link to /var/www folder" {
  run docker run --rm -e APP_MOVE_INSTEAD_LINK=1 --entrypoint /start.sh $IMAGE \
    sh -c 'test -L /app && readlink -f /app | tr -d "\n"'
  [ "$status" -eq 0 ]
  [ "$output" == "/var/www" ]
}

@test "APP_MOVE_INSTEAD_LINK=1 sets correct owner of /app link" {
  run docker run --rm -e APP_MOVE_INSTEAD_LINK=1 --entrypoint /start.sh $IMAGE \
    sh -c 'ls -l /app | tr -d "\n " | grep nobodynobody | wc -l'
  [ "$status" -eq 0 ]
  [ "$output" == "1" ]
}
