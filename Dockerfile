FROM php:8.1.1-fpm

# Arguments
ARG user=tilt
ARG uid=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

#Install oracle instant client
# WORKDIR    /opt/oracle
# RUN        apt-get update && apt-get install -y libaio1 wget unzip \
#             && wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip \
#             && unzip instantclient-basiclite-linuxx64.zip \
#             && rm -f instantclient-basiclite-linuxx64.zip \
#             && cd /opt/oracle/instantclient* \
#             && rm -f *jdbc* *occi* *mysql* *README *jar uidrvci genezi adrci \
#             && echo /opt/oracle/instantclient* > /etc/ld.so.conf.d/oracle-instantclient.conf \
#             && ldconfig

WORKDIR /var/www


# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets
# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Install redis
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# Set working directory
WORKDIR /var/www
RUN sudo chown -R $user /home/$user/.composer
RUN echo "$user:1234!" | chpasswd

USER $user

EXPOSE 80