***Tech specs***
================

* OS: Debian Stretch Slim
* Services:
	* supervisord
		* nginx (1.14)
		* php-fpm (7.2)
* Some useful installed packages:
	* wget
	* curl 
	* sudo 
	* git
	* htop 
	* nano 
	* zsh 
	* zip 
	* unzip 
	* net-tools 
	* iputils-ping 
	* composer

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
	PROJECT_NAME=task-list \
	VERSION=v1-dev \
	DEBUG=true \
	APT_CACHER_SERVER=http://172.17.0.1:3142
to build ***`staging`*** image


	$ make build REGISTRY_NAME=registry.gitlab.com/[user]/task-list \
	PROJECT_NAME=task-list \
    VERSION=v1-stg \
    APT_CACHER_SERVER=http://172.17.0.1:3142
to build ***`production`*** image


	$ make build REGISTRY_NAME=registry.gitlab.com/[user]/task-list VERSION=v1 PROJECT_NAME=task-list 
	
and in the end, you can use default image (with default configs) of this project (always master is latest version):


	$ docker pull registry.gitlab.com/m3hr24d/docker-symfony:[master|vX.Y.Z]