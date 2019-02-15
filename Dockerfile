FROM php:7.2-fpm-jessie
LABEL maintainer="Adrian Pasten <fredpalas@apperturedev.es>"

#install laravel requirements and aditional extensions
RUN requirements="libmcrypt-dev g++ libicu-dev libmcrypt4 libicu52 zlib1g-dev git libpng-dev libbz2-dev libpq-dev libxml2-dev curl libcurl4-openssl-dev" \
    && apt-get update && apt-get install -y $requirements \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install intl \
    && docker-php-ext-install json \
    && docker-php-ext-install zip \
    && docker-php-ext-install gd \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install xml \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install curl \
    && pecl install apcu \ 
    && docker-php-ext-enable apcu \    
    && apt-get purge --auto-remove -y libmcrypt-dev g++ libicu-dev zlib1g-dev libpq-dev libbz2-dev libxml2-dev libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

#install composer globally
RUN curl -sSL https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

#replace default php-fpm config
RUN rm -v /usr/local/etc/php-fpm.conf

COPY config/php-fpm.conf /usr/local/etc/

#add custom php.ini
COPY config/php.ini /usr/local/etc/php/

RUN usermod -u 1000 www-data \
    && groupmod -g 1000 www-data

# Setup Volume
VOLUME ["/usr/share/nginx/html"]

#Set Workdir
WORKDIR /usr/share/nginx/html

#Add entrypoint
COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
