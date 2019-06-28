***Tech specs***
================

* OS: Debian Stretch Slim
* Services:
	* supervisord
		* nginx (1.14)
		* php-fpm (7.2)
* PHP extensions:
	* php7.2-common
	* php7.2-fpm
	* php7.2-xml
	* php7.2-pgsql
	* php7.2-mysql
	* php7.2-sqlite3
	* php7.2-gd
	* php7.2-intl
	* php7.2-phpdbg
	* php7.2-tidy
	* php7.2-mbstring
	* php7.2-zip
	* php7.2-soap
	* php7.2-sybase
	* php7.2-xsl
	* php7.2-curl
	* php-xdebug
* Some useful installed packages:
	* wget
	* curl 
	* sudo 
	* git
	* htop 
	* nano 
	* zsh (and oh-my-zsh)
	* zip 
	* unzip 
	* net-tools 
	* iputils-ping 
	* composer
	* mysql-client
	* nodejs

***How to config your own image***
==================================
by config files from outside in ***`assets/configs/[nginx|php-fpm|supervisor]`***

* ***`nginx:`*** you can change all nginx configuration in ***`default`*** file and build your own image
* ***`php-fpm:`*** you can override all of parameters in php.ini by editing ***`php-ini-overrides.ini`***
* ***`supervisor:`*** you can change ***`php-fpm's`*** and ***`nginx's`*** service in ***`supervisor-php-fpm.conf`*** 
and ***`supervisor-nginx.conf`***

***Therefore***
===============
	
after you set all of your configurations, you can use ***`build`*** command like below:

to build ***`development`*** image

	$ make build REGISTRY_NAME=registry.gitlab.com/[user]/task-list \
	DISTRO=debian \
	PROJECT_NAME=task-list \
	VERSION=v1-dev \
	DEBUG=true \
	APT_CACHER_SERVER=http://172.17.0.1:3142

to build ***`production`*** image

	$ make build REGISTRY_NAME=registry.gitlab.com/[user]/task-list VERSION=v1 \
	DISTRO=debian \
	PROJECT_NAME=task-list 
	
and in the end, you can use default image (with default configs) of this project (always master is latest version):

	$ docker pull registry.gitlab.com/m3hr24d/docker-symfony:[master|vX.Y.Z]