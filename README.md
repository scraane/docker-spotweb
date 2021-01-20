## Spotweb container

### Sources
Base image: [Alpine:latest](https://hub.docker.com/_/alpine/)
Main software: [Spotweb](https://github.com/spotweb/spotweb)
Packages: php7, openssl, apache2


### Requirements
You need a separate database server (both MySQL/MariaDB and PostgreSQL are supported through my config) or you can use SQLite within the container.

### Usage

#### Supported modes
You can connect to the container with or without SSL You can also connect a reverse proxy to the exposed port and setup any sort of connection from there.

#### Installation
When you run the docker image for the first time without optional parameters it will download the master Spotweb branch into the webfolder and install the chosen php7 SQL module.
```
docker run --restart=always -d -p 80:80 \
		--hostname=spotweb \
		--name=spotweb \
		-e TZ='Europe/Amsterdam' \
		-e SQL='mysql'
		-v /local-storage-place:/var/www/spotweb
		nutjob/spotweb
```
After this browse to the exposed port and add "install.php" to it to run the configuration wizard.

#### Docker compose example
The following docker-compose.yml example correspondents to the above:
```
services:
  spotweb:
    image: nutjob/spotweb:latest
    container_name: spotweb
    restart: always
    ports:
      - "80:80"
    environment:
      TZ: Europe/Amsterdam
      SQL: mysql
    volumes:
      - /local-storage-place:/var/www/spotweb
```


### Variables
| Variable | Function | Optional |
| --- | --- | --- |
| `TZ` | Timezone for PHP configuration | no |
| `SQL`| SQL type for Spotweb (sqlite, psql or mysql) | no |
| `SSL`| Enable or disable SSL support in apache (enabled/disabled) | yes|
|`UUID`| UID of the apache user, for mount and persistence compatibility | yes |
|`GUID`| GID of the apache group, for mount and persistence compatibility| yes |
|`VERSION`| Spotweb version, defaults to master branch but you can use a version tag from their [git](https://github.com/spotweb/spotweb) page | yes |