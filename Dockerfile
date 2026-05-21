FROM httpd:2.4

RUN apt-get update && apt-get install -y apache2-utils curl && rm -rf /var/lib/apt/lists/*
RUN htpasswd -cb /usr/local/apache2/user.passwd username password
RUN mkdir -p /usr/local/apache2/uploads /usr/local/apache2/var && \
    chown -R www-data:www-data /usr/local/apache2/uploads /usr/local/apache2/var

RUN sed -i 's/#LoadModule dav_module/LoadModule dav_module/' /usr/local/apache2/conf/httpd.conf
RUN sed -i 's/#LoadModule dav_fs_module/LoadModule dav_fs_module/' /usr/local/apache2/conf/httpd.conf

RUN sed -i 's|DocumentRoot "/usr/local/apache2/htdocs"|DocumentRoot "/usr/local/apache2/uploads"|' /usr/local/apache2/conf/httpd.conf
RUN sed -i 's|<Directory "/usr/local/apache2/htdocs">|<Directory "/usr/local/apache2/uploads">|' /usr/local/apache2/conf/httpd.conf

RUN echo '\n\
DavLockDB /usr/local/apache2/var/DavLock\n\
<Location />\n\
    Dav On\n\
    AuthType Basic\n\
    AuthName "WebDAV"\n\
    AuthUserFile /usr/local/apache2/user.passwd\n\
    Require valid-user\n\
</Location>' >> /usr/local/apache2/conf/httpd.conf
