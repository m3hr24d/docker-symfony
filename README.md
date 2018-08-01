***Docker Symfony***
====================

you can build your own symfony images

> ***Note:*** support symfony 4.x (for now)

***Tech specs***
================

* OS: Debian slim-stretch
* Services:
	* supervisord
		* nginx
		* php-fpm (7.1)
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
	
> ***Note:*** 

***Installation:***
===================

	> git clone git@gitlab.com:m3hr24d/docker-symfony.git
	
***How to use***
===================

I try to explain how this project can help to you by an example, let's assume that you have a symfony project that it's name is 
***`task-list`***. so, you will have a repo like this:

	https://gitlab.com/[user]/task-list
and you will have a registry (if enabled before in setting) like this:

	registry.gitlab.com/[user]/task-list
now, you want build a docker image for this project:

go to ***`docker-symfony`*** directory

	$ cd docker-symfony 
run command below:

	$ make build REGISTRY_NAME=registry.gitlab.com/[user]/task-list
you can see your image with ***`latest`*** version by run this:

	$ docker images
 now, you can push your image to your project's registry, just do:
 
	$ make release REGISTRY_NAME=registry.gitlab.com/[user]/task-list

***How to config your own image***
==================================

1. by environment variables
	* REGISTRY_NAME: ***`required`*** in both ***`build`*** and ***`release`*** command, registry address of your project.
	* VERSION: ***`optional`*** in both ***`build`*** and ***`release`*** command, default value ***`latest`***, 
	you can manage your image's revision by this variable
	* DEBUG: ***`optional`*** just use in ***`build`*** command, default value ***`false`***, when set to ***`true`***, 
	you can see all of debug information in build time, and also used to build a development docker image for the project
	* PROJECT_NAME: ***`optional`*** just use in ***`build`*** command, default value ***`app`***, after build completed successfully, 
    you have in your image, a user with same name, a home directory for the user, a project directory with this path 
    ***`/srv/[PROJECT_NAME]`*** that owned by the user
    * APT_CACHER_SERVER: ***`optional`*** just use in ***`build`*** command, default value ***`null`***, if you use an apt cacher server, 
    	you can pass that's address and port to your image and use that

2. by config files from outside in ***`assets/configs/[nginx|php-fpm|supervisor]`***
	* nginx: you can change all nginx configuration in ***`default`*** file and build your own image
	* php-fpm: you can override all of parameters in php.ini by editing ***`php-ini-overrides.ini`***
	* supervisor: you can change ***`php-fpm's`*** and ***`nginx's`*** service in ***`supervisor-php-fpm.conf`*** 
	and ***`supervisor-nginx.conf`***

> ***Note:*** when your image created successfully, you will have an environment variable named ***`debug_mode`*** 
that it's value is same as the ***`DEBUG`*** variable
   
> ***Note:*** when your image created successfully, apt-cacher's config will be remove from image

> ***Note:*** apt cacher server must be passed with schema, like this: http(s)://[apt-cacher-server-ip]:[port]

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