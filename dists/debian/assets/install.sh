#!/usr/bin/env bash

if [[ "$DEBUG" = 'true' ]]; then
	set -eux
fi

USER_HOME=/home/${PROJECT_NAME}
ASSETS_PATH=/tmp/${PROJECT_NAME}
CONFIGS_PATH=${ASSETS_PATH}/configs
PROJECT_DIR=${PROJECT_DIR}

#####################
# config apt cacher #
###################################################################################
if [ "$APT_CACHER_SERVER" != '' ]; then
    echo "Acquire::http::Proxy \"$APT_CACHER_SERVER\";" > /etc/apt/apt.conf.d/01proxy;
    echo "Acquire::https::Proxy \"$APT_CACHER_SERVER\";" >> /etc/apt/apt.conf.d/01proxy;
fi

##########################
# install base packages  #
###################################################################################
DEBCONF_FRONTEND=noninteractive apt-get update \
	&& DEBCONF_FRONTEND=noninteractive apt-get install -y \
	ca-certificates \
	gnupg2 \
	apt-transport-https \
	wget

##########################
# config apt source list #
###################################################################################
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list

wget -q https://nginx.org/keys/nginx_signing.key -O- | apt-key add -
echo "deb https://nginx.org/packages/debian/ stretch nginx" >> /etc/apt/sources.list.d/nginx.list
echo "deb-src https://nginx.org/packages/debian/ stretch nginx" >> /etc/apt/sources.list.d/nginx.list

wget --quiet -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
NODEJS_VERSION=node_12.x
DISTRO="$(lsb_release -s -c)"
echo "deb https://deb.nodesource.com/$NODEJS_VERSION $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list
echo "deb-src https://deb.nodesource.com/$NODEJS_VERSION $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list

apt-get update

#####################
# install packages  #
###################################################################################
DEBCONF_FRONTEND=noninteractive apt-get install -y \
	curl \
	sudo \
	git \
	htop \
	nano \
	zsh \
	zip \
	unzip \
	nginx \
	net-tools \
	iputils-ping \
	supervisor \
	software-properties-common \
	python3-software-properties \
	php7.2 \
	php7.2-common \
	php7.2-fpm \
	php7.2-xml \
	php7.2-pgsql \
	php7.2-mysql \
	php7.2-gd \
	php7.2-intl \
	php7.2-phpdbg \
	php7.2-tidy \
	php-xdebug \
	php7.2-mbstring \
	php7.2-zip \
	php7.2-soap \
	php7.2-sqlite3 \
	php7.2-sybase \
	php7.2-xsl \
	php7.2-curl \
	mysql-client \
	nodejs

###############################
# Add and config project user #
###################################################################################
echo "$PROJECT_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
useradd --create-home --user-group -s /usr/bin/zsh ${PROJECT_USER}
sudo -u ${PROJECT_USER} -H sh -c "export SHELL=/usr/bin/zsh; export TERM=xterm; $(curl --retry 5 -fsSL https://cdn.rawgit.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
    && sudo -u ${PROJECT_USER} -H sh -c "sed -i 's/ZSH_THEME=\".*\"/ZSH_THEME=\"candy\"/g' ${USER_HOME}/.zshrc"
chown -R ${PROJECT_USER}:${PROJECT_GROUP} ${PROJECT_DIR}

####################
# install composer #
###################################################################################
EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")
if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
fi
sudo -u ${PROJECT_USER} -H sh -c "php composer-setup.php --install-dir=${USER_HOME} --filename=composer --quiet"
RESULT=$?
if [[ "$RESULT" == "0" ]]; then
    ln -s ${USER_HOME}/composer /usr/local/bin/composer
fi
rm composer-setup.php
echo "composer setup completed with exit code $RESULT"

################
# Config nginx #
###################################################################################
rm -f /etc/nginx/conf.d/default.conf \
	&& mv ${CONFIGS_PATH}/nginx/default /etc/nginx/conf.d/${PROJECT_NAME}.conf
	sed -i "s/user\s\{1,\}nginx;/user $PROJECT_USER;/" /etc/nginx/nginx.conf
	sed -i "s/access.log;/${PROJECT_NAME}_access.log;/" /etc/nginx/conf.d/${PROJECT_NAME}.conf
	sed -i "s/error.log;/${PROJECT_NAME}_error.log;/" /etc/nginx/conf.d/${PROJECT_NAME}.conf
	sed -i "s#/srv/www;#$PROJECT_DIR/public;#" /etc/nginx/conf.d/${PROJECT_NAME}.conf

##################
# Config php-fpm #
###################################################################################
sed -i "s/user = www-data/user = $PROJECT_USER/g" /etc/php/7.2/fpm/pool.d/www.conf \
	 && sed -i "s/group = www-data/group = $PROJECT_GROUP/g" /etc/php/7.2/fpm/pool.d/www.conf \
	 && sed -i "s/listen.owner = www-data/listen.owner = $PROJECT_USER/g" /etc/php/7.2/fpm/pool.d/www.conf \
	 && sed -i "s/listen.group = www-data/listen.group = $PROJECT_GROUP/g" /etc/php/7.2/fpm/pool.d/www.conf \
	 && sed -i "s/;extension=php_curl.dll/extension=php_curl.dll/g" /etc/php/7.2/fpm/php.ini \
	 && sed -i "s/;extension=php_fileinfo.dll/extension=php_fileinfo.dll/g" /etc/php/7.2/fpm/php.ini \
	 && sed -i "s/;extension=php_gd2.dll/extension=php_gd2.dll/g" /etc/php/7.2/fpm/php.ini \
	 && sed -i "s/;extension=php_ctype.dll/extension=php_ctype.dll/g" /etc/php/7.2/fpm/php.ini \
	 && sed -i "s/;extension=php_iconv.dll/extension=php_iconv.dll/g" /etc/php/7.2/fpm/php.ini \
	 && sed -i "s/;extension=php_pdo_pgsql.dll/extension=php_pdo_pgsql.dll/g" /etc/php/7.2/fpm/php.ini \
	 && sed -i "s/;extension=php_pgsql.dll/extension=php_pgsql.dll/g" /etc/php/7.2/fpm/php.ini \
	 && sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.2/fpm/php.ini \
	 && sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.2/fpm/php.ini \
	 && cp -v ${CONFIGS_PATH}/php-fpm/php-ini-overrides.ini /etc/php/7.2/fpm/conf.d/99-overrides.ini \
	 && chown -R ${PROJECT_USER}:${PROJECT_GROUP} /var/lib/php/sessions

#####################
# Config supervisor #
###################################################################################
cp -v ${CONFIGS_PATH}/supervisor/*.conf /etc/supervisor/conf.d/ \
	&& mkdir -p /var/log/supervisor/nginx/ \
	&& mkdir -p /var/log/supervisor/php-fpm/ \
	&& mkdir -p /run/php

###########
# Cleanup #
###################################################################################
apt-get autoremove --purge
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
if [ -f /etc/apt/apt.conf.d/01proxy ]; then
    rm -f /etc/apt/apt.conf.d/01proxy
fi