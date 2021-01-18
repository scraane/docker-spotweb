FROM alpine:latest

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/scraane/docker-spotweb"

COPY entry.sh /entry.sh
RUN apk update
RUN apk add bash php php7-apache2 php7-cli php7-common php7-curl php7-gd php7-json php7-mbstring php7-session php7-pdo php7-opcache php7-xml php7-simplexml php7-xmlrpc php7-zip php7-gmp php7-dom php7-gettext openssl apache2 git shadow
RUN chmod +x /entry.sh
RUN rm -rf /var/cache/apk/*
RUN mkdir -p /run/apache2
RUN chown apache: /run/apache2
EXPOSE 80 443
ENTRYPOINT ["/entry.sh"]
#CMD ["/usr/sbin/httpd", "-D", "FOREGROUND", "-f", "/etc/apache2/httpd.conf"]
