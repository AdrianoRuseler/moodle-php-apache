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
- https://github.com/erseco/alpine-moodle


## Issues

php_setting 	zend.exception_ignore_args
It is strongly recommended that the PHP setting zend.exception_ignore_args be enabled as a security precaution.

Composer dependencies were not found. Make sure the "composer install --no-dev --classmap-authoritative" command has been run in the Moodle root directory. If you are not using Composer, make sure the vendor directory exists and contains the necessary files.

### Composer

```bash
cd ~
curl -sS https://getcomposer.org/installer -o composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
composer --version
```