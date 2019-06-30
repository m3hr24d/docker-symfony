***Docker Symfony***
====================

you can build your own symfony images

***Installation:***
===================
	$ git clone git@gitlab.com:m3hr24d/docker-symfony.git
or

	$ git clone git@github.com:m3hr24d/docker-symfony.git
you'll be able to pull default images

	$ docker pull registry.gitlab.com/m3hr24d/docker-symfony:v[VERSION]-[DISTRO]
	
***You can use these dists:***
============================
* [debian](./dists/debian/README.md)
	
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

	$ make build REGISTRY_NAME=registry.gitlab.com/[user]/task-list DISTRO=[debian]
you can see your image with ***`latest`*** version by run this:

	$ docker images
 now, you can push your image to your project's registry, just do:
 
	$ make release REGISTRY_NAME=registry.gitlab.com/[user]/task-list

***How to config your own image***
==================================
* REGISTRY_NAME: ***`required`*** in both ***`build`*** and ***`release`*** command, registry address of your project.

* DISTRO: ***`required`*** in ***`build`*** command. chose your distribution. for example: ***`debian`***, ***`alpine`*** or ...

* EXPOSED_PORTS: ***`optional`*** in ***`build`*** command. default exposed ports are ***`80 443`***. 
you can expose additional ports with this format, EX: ***`"443 8080 3306"`*** (with double quote) 

* VERSION: ***`optional`*** in both ***`build`*** and ***`release`*** command, default value ***`latest`***, 
you can manage your image's revision by this variable

* DEBUG: ***`optional`*** just use in ***`build`*** command, default value ***`false`***, when set to ***`true`***, 
you can see all of debug information in build time, and also used to build a development docker image for the project

> ***Note:*** when your image created successfully, you will have an environment variable named ***`DEBUG`*** 
that it's value is same as the ***`DEBUG`*** argument

* PROJECT_NAME: ***`optional`*** just use in ***`build`*** command, default value ***`app`***, after build completed successfully, 
you have in your image, a user with same name, a home directory for the user, a project directory with this path 
***`/srv/[PROJECT_NAME]`*** that owned by the user

* APT_CACHER_SERVER: ***`optional`*** just use in ***`build`*** command and when ***`DISTRO`*** is based on debian, 
default value ***`null`***, if you use an apt cacher server, you can pass that's address and port to your image and use that

> ***Note:*** when your image created successfully, apt-cacher's config will be remove from image

> ***Note:*** apt cacher server must be passed with schema, like this: http(s)://[apt-cacher-server-ip]:[port]