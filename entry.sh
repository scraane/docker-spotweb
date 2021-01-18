#!/usr/bin/env bash
# /usr/sbin/httpd -D FOREGROUND -f /etc/apache2/httpd.conf

echo "                __      __      __  ";
echo "   ____  __  __/ /_    / /___  / /_ ";
echo "  / __ \/ / / / __/_  / / __ \/ __ \";
echo " / / / / /_/ / /_/ /_/ / /_/ / /_/ /";
echo "/_/ /_/\__,_/\__/\____/\____/_.___/ ";
echo "                                    ";


WebConf=/etc/apache2/conf.d/spotweb.conf
SSLWebConf=/etc/apache2/conf.d/spotweb_ssl.conf
WebDir=/var/www/spotweb

echo
echo "Lets see if we start new or already have an installation"
cd ${WebDir}

if [ -d ".git" ]; then
    echo ".git folder exists. Assuming we have an installation. Lets update."
    git pull
else 
    echo ".git folder not found. Lets clone it now."
    git clone https://github.com/spotweb/spotweb .
    git config pull.rebase false
fi

echo
echo "Creating crontab to update Spotweb every 15 minutes."
echo "#!/bin/sh" > /etc/periodic/15min/spotwebupdate
echo "php /var/www/spotweb/retrieve.php" >> /etc/periodic/15min/spotwebupdate
chmod a+x /etc/periodic/15min/spotwebupdate

echo "Starting cron"
crond

echo
case ${SSL} in
  enabled)
    echo "Deploying apache config with SSL support:"
    cat <<EOF > ${SSLWebConf}
<VirtualHost 0.0.0.0:443>
    ServerAdmin _

    SSLEngine on
    SSLCertificateFile "/etc/ssl/web/spotweb.crt"
    SSLCertificateKeyFile "/etc/ssl/web/spotweb.key"
    SSLCertificateChainFile "/etc/ssl/web/spotweb.chain.crt"

    DocumentRoot ${WebDir}
    <Directory ${WebDir}/>
        RewriteEngine on
        RewriteCond %{REQUEST_URI} !api/
        RewriteRule ^api/?$ index.php?page=newznabapi [QSA,L]
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
  chown apache: ${SSLWebConf}
  chmod 600 /etc/ssl/web/*
  apk add apache2-ssl
  ;;

  *)
    echo "Deploying apache config without SSL support:"
esac

cat <<EOF > ${WebConf}
<VirtualHost 0.0.0.0:80>
    ServerAdmin _

    DocumentRoot ${WebDir}
    <Directory ${WebDir}/>
        RewriteEngine on
        RewriteCond %{REQUEST_URI} !api/
        RewriteRule ^api/?$ index.php?page=newznabapi [QSA,L]
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
chown apache: ${WebConf}
sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/g' /etc/apache2/httpd.conf
sed -i "s/#ServerName www.example.com/ServerName $(hostname)/g" /etc/apache2/httpd.conf
echo "date.timezone = ${TZ}" >> /etc/php7/php.ini

echo
echo "Installing ${SQL} support:"
case ${SQL} in
  sqlite)
    apk add php7-pdo_sqlite
  ;;

  psql)
    apk add php7-pgsql php7-pdo_pgsql
  ;;

  mysql)
    apk add php7-mysqlnd php7-pdo_mysql
  ;;

  *)
    echo
    echo "Option SQL=${SQL} invalid, use sqlite, psql or mysql!"
  ;;
esac



if [[ ! -z ${UUID} ]]
then
  echo
  echo "Replacing old apache UID with ${UUID}"
  OldUID=$(getent passwd apache | cut -d ':' -f3)
  usermod -u ${UUID} apache
  find / -user ${OldUID} -exec chown -h apache {} \; &> /dev/null
fi

if [[ ! -z ${GUID} ]]
then
  echo "Replacing old apache GID with ${GUID}"
  OldGID=$(getent passwd apache | cut -d ':' -f4)
  groupmod -g ${GUID} apache
  find / -group ${OldGID} -exec chgrp -h apache {} \; &> /dev/null
fi

chown -R apache: ${WebDir}
rm -rf /var/cache/apk/* && \

echo "Deployment done!"
exec "$@"
echo "Starting webserver"
/usr/sbin/httpd -D FOREGROUND -f /etc/apache2/httpd.conf
echo "All done :)"
