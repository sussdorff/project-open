FROM sussdorff/openacs

RUN  apt-get update && apt-get -y dist-upgrade && apt-get -y autoremove

RUN mkdir -p /var/www/projop && mkdir /var/www/openacs/filestorage

WORKDIR /var/www/projop

RUN wget --quiet https://sourceforge.net/projects/project-open/files/project-open/V5.0/update/project-open-Update-5.0.3.0.0.tgz \
    && tar xzf project-open-Update-5.0.3.0.0.tgz && rm project-open-Update-5.0.3.0.0.tgz \
    && wget --quiet https://downloads.sourceforge.net/project/project-open/project-open/Support%20Files/web_projop-aux-files.5.0.0.0.0.tgz \
    && tar xzf web_projop-aux-files.5.0.0.0.0.tgz && rm web_projop-aux-files.5.0.0.0.0.tgz \
    && mv -n packages/* /var/www/openacs/packages/ && rm -rf /var/www/projop \
    && chown -R nsadmin.nsadmin /var/www/openacs

WORKDIR /var/www/openacs
