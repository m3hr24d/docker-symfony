#!/usr/bin/env bash

if [[ "$DEBUG" = 'true' ]]; then
	set -eux
fi

USER_HOME=/home/${PROJECT_NAME}

ASSETS_PATH=/tmp/${PROJECT_NAME}
CONFIGS_PATH=${ASSETS_PATH}/configs
PROJECT_DIR=${PROJECT_DIR}

##########################
# config apt source list #
###################################################################################
echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc && apt-key add ACCC4CF8.asc

echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -

apt-get update

#####################
#  install php 7.1  #
###################################################################################
DEBCONF_FRONTEND=noninteractive apt-get install -y php7.1 php7.1-common php7.1-fpm php7.1-xml\
	php7.1-pgsql php7.1-gd php7.1-intl php7.1-phpdbg php7.1-tidy php-xdebug php7.1-mbstring php7.1-mcrypt php7.1-zip \

#####################
# config apt cacher #
###################################################################################
if [ "$APT_CACHER_SERVER" != '' ]; then
    echo "Acquire::http::Proxy \"$APT_CACHER_SERVER\";" > /etc/apt/apt.conf.d/01proxy;
    echo 'Acquire::https::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy;
fi

####################
# install packages #
###################################################################################
DEBCONF_FRONTEND=noninteractive apt-get install -y htop nano zsh zip unzip nginx net-tools iputils-ping supervisor \
	postgresql-client-9.6 software-properties-common python3-software-properties

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
rm -f /etc/nginx/sites-enabled/default \
	&& mv ${CONFIGS_PATH}/nginx/default /etc/nginx/sites-enabled/${PROJECT_NAME}
	sed -i "s/user www-data;/user $PROJECT_USER;/" /etc/nginx/nginx.conf
	sed -i "s/access.log;/${PROJECT_NAME}_access.log;/" /etc/nginx/sites-enabled/${PROJECT_NAME}
	sed -i "s/error.log;/${PROJECT_NAME}_error.log;/" /etc/nginx/sites-enabled/${PROJECT_NAME}
	sed -i "s#/srv/www;#/srv/$PROJECT_NAME/public;#" /etc/nginx/sites-enabled/${PROJECT_NAME}

##################
# Config php-fpm #
###################################################################################
sed -i "s/user = www-data/user = $PROJECT_USER/g" /etc/php/7.1/fpm/pool.d/www.conf \
	 && sed -i "s/group = www-data/group = $PROJECT_GROUP/g" /etc/php/7.1/fpm/pool.d/www.conf \
	 && sed -i "s/listen.owner = www-data/listen.owner = $PROJECT_USER/g" /etc/php/7.1/fpm/pool.d/www.conf \
	 && sed -i "s/listen.group = www-data/listen.group = $PROJECT_GROUP/g" /etc/php/7.1/fpm/pool.d/www.conf \
	 && sed -i "s/;extension=php_curl.dll/extension=php_curl.dll/g" /etc/php/7.1/fpm/php.ini \
	 && sed -i "s/;extension=php_fileinfo.dll/extension=php_fileinfo.dll/g" /etc/php/7.1/fpm/php.ini \
	 && sed -i "s/;extension=php_gd2.dll/extension=php_gd2.dll/g" /etc/php/7.1/fpm/php.ini \
	 && sed -i "s/;extension=php_ctype.dll/extension=php_ctype.dll/g" /etc/php/7.1/fpm/php.ini \
	 && sed -i "s/;extension=php_iconv.dll/extension=php_iconv.dll/g" /etc/php/7.1/fpm/php.ini \
	 && sed -i "s/;extension=php_pdo_pgsql.dll/extension=php_pdo_pgsql.dll/g" /etc/php/7.1/fpm/php.ini \
	 && sed -i "s/;extension=php_pgsql.dll/extension=php_pgsql.dll/g" /etc/php/7.1/fpm/php.ini \
	 && sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.1/fpm/php.ini \
	 && sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.1/fpm/php.ini \
	 && cp -v ${CONFIGS_PATH}/php-fpm/php-ini-overrides.ini /etc/php/7.1/fpm/conf.d/99-overrides.ini

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
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /etc/${PROJECT_NAME}
if [ -f /etc/apt/apt.conf.d/01proxy ]; then
    rm -f /etc/apt/apt.conf.d/01proxy
fi