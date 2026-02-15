# moodle-php-apache
PHP + Apache docker images for Moodle 

## php:8.2-apache-trixie

```bash
docker pull php:8.2-apache-trixie
```

## Docker HUB

- https://hub.docker.com/r/ruseler/moodle-php-apache

```bash
docker build -t ruseler/moodle-php-apache:8.2 .
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

## Composer

```bash
docker exec -it <container_name> composer --version
```

```bash
docker exec -it -u www-data moodle-app composer install --no-dev --classmap-authoritative
```

## Initialize Moodle database for manual testing

```bash
docker exec -it -u www-data moodle-app php admin/cli/install_database.php --agree-license --fullname="Docker moodle" --shortname="docker_moodle" --summary="Docker moodle site" --adminpass="M@0dl3ing" --adminemail="admin@host.docker.internal"
```

```bash
docker exec -it -u www-data moodle-cron php admin/cli/install_database.php --agree-license --fullname="Docker moodle" --shortname="docker_moodle" --summary="Docker moodle site" --adminpass="M@0dl3ing" --adminemail="admin@host.docker.internal"
```

## Moodle CLI

- FROM php:8.4-cli-trixie

```bash
docker exec -it -u www-data moodle-cron composer install --no-dev --classmap-authoritative
```

```bash
docker exec -it -u www-data moodle-cron php admin/cli/cron.php
```

```bash
docker exec -it -u www-data moodle-app php admin/cli/cron.php
```

```bash
docker exec -it -u www-data moodle-app php admin/cli/checks.php
```
- Enter Maintenance Mode
```bash
docker exec -it -u www-data moodle-app php admin/cli/maintenance.php --enable
```
- Running Database Upgrade
```bash
docker exec -it -u www-data moodle-app php admin/cli/upgrade.php --non-interactive
```

- Clearing Caches
```bash
docker exec -it -u www-data moodle-app php admin/cli/purge_caches.php
```
- Disable Maintenance Mode
```bash
docker exec -it -u www-data moodle-app php admin/cli/maintenance.php --disable
```

- Check if Ghostscript is found
```bash
docker exec -u www-data moodle-cron gs --version
```

- Check if Graphviz (dot) is found
```bash
docker exec -u www-data moodle-cron dot -V
```

```bash
docker exec moodle-db pg_dump -U moodleuser moodle > moodle_backup_$(date +%F).sql
docker exec moodle-db pg_dump -U moodleuser moodle > backup.sql
```

Self-Termination: The script will automatically exit after 180 seconds (or whatever value you set). Because your Docker restart: always or the while true loop is present, it will immediately start a fresh process. This prevents potential PHP memory leaks from building up over days.

Native Concurrency: Moodle's internal task manager is smarter than a shell loop; it knows how to handle lock files properly so you don't accidentally run the same heavy task twice.


To get the most out of this, log in to your Moodle site as an Admin and navigate to:
Site Administration > Server > Tasks > Task processing

Check these two settings:

- Concurrency limit for adhoc tasks: If you have a multi-core CPU, set this to 2 or 3 to allow multiple tasks to run at the exact same time.
- Adhoc task runner lifetime: Set this to match your --keep-alive value (e.g., 180).


## References
- https://github.com/moodlehq/moodle-php-apache
- https://github.com/moodlehq/moodle-docker
- https://github.com/erseco/alpine-moodle
- https://github.com/tmuras/moosh
