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
- https://github.com/erseco/alpine-moodle
