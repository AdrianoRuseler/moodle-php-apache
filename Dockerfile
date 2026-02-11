FROM php:8.4-apache-trixie

# So we can use it anywhere for conditional stuff. Keeping BC with old (non-buildkit, builders)
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
RUN echo "Building for ${TARGETPLATFORM}"

# Install some packages that are useful within the images.
RUN apt-get update && apt-get install -y \
    bc default-mysql-client-core locales \
&& rm -rf /var/lib/apt/lists/*


# 2. Configure and generate locales
RUN sed -i -e 's/# en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

# 3. Set environment variables so PHP/Moodle recognize the locale
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Setup the required extensions.
ADD root/tmp/setup/php-extensions.sh /tmp/setup/php-extensions.sh
RUN /tmp/setup/php-extensions.sh

# Copy the Composer binary from the official Composer image
#COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN mkdir /var/www/moodledata && chown www-data /var/www/moodledata && \
    mkdir /var/www/phpunitdata && chown www-data /var/www/phpunitdata && \
    mkdir /var/www/behatdata && chown www-data /var/www/behatdata && \
    mkdir /var/www/behatfaildumps && chown www-data /var/www/behatfaildumps && \
    mkdir /var/www/.npm && chown www-data /var/www/.npm && \
    mkdir /var/www/.nvm && chown www-data /var/www/.nvm

ADD root/usr /usr
ADD root/etc /etc
ADD root/system-docker-entrypoint.d/wwwroot.sh /system-docker-entrypoint.d/10-wwwroot.sh

# Fix the original permissions of /tmp, the PHP default upload tmp dir.
RUN chmod 777 /tmp && chmod +t /tmp

# Keep our image size down..
RUN apt-get autoremove -y
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Allow configuration of the Apache DocumentRoot via environment variable.
# Note: Do not specify a default value here, as it will be set in the
#       `wwwroot.sh` script, which will be run before the Apache server starts.
#       This allows the user to override the default value by setting the
#       `APACHE_DOCUMENT_ROOT` environment variable when running the container.

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

CMD ["apache2-foreground"]
ENTRYPOINT ["moodle-docker-php-entrypoint"]
