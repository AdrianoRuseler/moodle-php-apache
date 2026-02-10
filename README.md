# moodle-php-apache
PHP + Apache docker images for Moodle 

## php:8.4-apache-trixie

```bash
docker pull php:8.4-apache-trixie
```

## Docker HUB

- https://hub.docker.com/r/ruseler/moodle-php-apache

```bash
docker build -t ruseler/moodle-php-apache:latest .
```

## Config

```php
$defaults['moodle']['pathtophp'] = '/usr/local/bin/php';
$defaults['moodle']['pathtodu'] = '/usr/bin/du';
$defaults['moodle']['aspellpath'] = '/usr/bin/aspell';
$defaults['moodle']['pathtogs'] = '/usr/bin/gs';
$defaults['moodle']['pathtodot'] = '/usr/bin/dot';
$defaults['moodle']['pathtopdftoppm'] = '/usr/bin/pdftoppm';
$defaults['moodle']['pathtopython'] = '/usr/bin/python3';
```

## References
- https://github.com/moodlehq/moodle-php-apache
- https://github.com/moodlehq/moodle-docker
- https://github.com/erseco/alpine-moodle


## Issues

php_setting 	zend.exception_ignore_args
It is strongly recommended that the PHP setting zend.exception_ignore_args be enabled as a security precaution.

Composer dependencies were not found. Make sure the "composer install --no-dev --classmap-authoritative" command has been run in the Moodle root directory. If you are not using Composer, make sure the vendor directory exists and contains the necessary files.

### Composer

```bash
docker exec -it <container_name> composer --version
```

```bash
docker exec -it -u www-data moodle-app composer install --no-dev --directory=/var/www/html
```

## Initialize Moodle database for manual testing

```bash
bin/moodle-docker-compose exec webserver php admin/cli/install_database.php --agree-license --fullname="Docker moodle" --shortname="docker_moodle" --summary="Docker moodle site" --adminpass="test" --adminemail="admin@example.com"
```