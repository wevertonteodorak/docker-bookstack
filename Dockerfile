# using ideas/code from other sparklyballs templates
# set variable to get archive based on github api data (sparklyballs heimdall inspiration)

FROM lsiobase/alpine.nginx:3.7

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="homerr"

# install packages
RUN \
echo "**** install build packages ****" && \
apk add --no-cache  \
    curl \
    php7-openssl \
    php7-pdo_mysql \
    php7-mbstring \
    php7-tidy \
    php7-phar \
    php7-dom \
    php7-tokenizer \
    php7-gd \
    php7-mysqlnd \
    php7-tidy \
    php7-simplexml \
    tar && \

echo "**** configure php-fpm to pass env vars ****" && \
     sed -i \
     's/;clear_env = no/clear_env = no/g' \
     /etc/php7/php-fpm.d/www.conf && \
     echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php7/php-fpm.conf && \

echo "**** get bookstack ****" && \

BSAPP_VER="$(curl -sX GET https://api.github.com/repos/BookStackApp/BookStack/releases/latest | grep 'tag_name' | cut -d\" -f4)" && \

mkdir -p\
    /var/www/html && \

curl -o \
/tmp/bookstack.tar.gz -L \
    "https://github.com/BookStackApp/BookStack/archive/${BSAPP_VER}.tar.gz" && \

tar xf \
/tmp/bookstack.tar.gz -C \
    /var/www/html/ --strip-components=1 && \

cp /var/www/html/.env.example /var/www/html/.env && \

echo "**** get composer ****" && \

cd /tmp && \
    curl -sS https://getcomposer.org/installer | php && \
    mv /tmp/composer.phar /usr/local/bin/composer && \

echo "**** run composer install ****"

composer install -d /var/www/html/ && \

echo "**** cleanup ****" && \
rm -rf \
    /root/.composer \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
VOLUME /config
