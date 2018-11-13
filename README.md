An image running the latest [Alpine:latest](https://hub.docker.com/_/alpine/) build with PHP7 and [Spotweb](https://github.com/spotweb/spotweb).

## Requirements
You need a separate database server (both MySQL/MariaDB and PostgreSQL are supported through my config) or you can use SQLite within the container.

## Usage

### Supported modes
The container can be to connect to directly with or without SSL. You can also connect a reverse proxy to the exposed port and setup any sort of connection from there.

### Initial installation
When you run the docker image for the first time without optional parameters it will download the master Spotweb branch into the webfolder and install the chosen php7 SQL module.
```
docker run --restart=always -d -p 80:80 \
		--hostname=spotweb \
		--name=spotweb \
		-e TZ='Europe/Amsterdam' \
		-e SQL='mysql'
		jerheij/spotweb
```
After this browse to the exposed port and add "install.php" to it to run the configuration wizard.

### Permanent version
To make the installation permanent (surviving an upgrade) you need to secure the /var/www/spotweb/dbsettings.inc.php configuration. The best way is to copy that file to your config folder and make a manual mapping:

```
docker run --restart=always -d -p 80:80 \
		--hostname=spotweb \
		--name=spotweb \
		-v <location_dbsettings.inc.php>:/var/www/spotweb/dbsettings.inc.php \
		-e TZ='Europe/Amsterdam' \
		-e SQL='mysql'
		jerheij/spotweb
```
The run command will keep the container "permanent".

### Docker compose example
The following docker-compose.yml example correspondents to the above:
```
services:
  spotweb:
    image: jerheij/spotweb:latest
    container_name: spotweb
    restart: always
    ports:
      - "192.168.1.1:80:80"
    environment:
      TZ: Europe/Amsterdam
      SQL: mysql
    volumes:
      - config/dbsettings_spotweb.php:/var/www/spotweb/dbsettings.inc.php
```
### Required parameters
- TZ: The timezone that will be added to the php configuation
- SQL: SQL type it will use, it installs the PHP module based on this

### Optional parameters
- SSL: enabled/disabled, this will control the Apache2 SSL support
- UUID: UID of the apache user, for mount and persistence compatibility
- GUID: GID of the apache group, for mount and persistence compatibility

##### SSL
This will enable the SSL modules and configuration in Apache2 and deploy an Apache2 SSL configuration on port 443. It expects the following files to be available:
- /etc/ssl/web/spotweb.crt
- /etc/ssl/web/spotweb.key
- /etc/ssl/web/spotweb.chain.crt

Suggested method is to mount a local directory with those certificates to /etc/ssl/webfolder:
```
...
volumes:
  - ssl:/etc/ssl/web:ro
```
