FROM sussdorff/openacs

RUN  apt-get update && apt-get -y dist-upgrade && apt-get install -y perl && apt-get -y autoremove

RUN mkdir -p /var/www/projop && mkdir /var/www/openacs/filestorage

WORKDIR /var/www/projop

# Get initial OpenACS modules
RUN wget --quiet https://openacs.org/projects/openacs/download/download/openacs-5.9.1-full.tar.gz \
    && tar xfz openacs-5.9.1-full.tar.gz

RUN mv openacs-5.9.1/packages/file-storage /var/www/openacs/packages/file-storage \
    && mv openacs-5.9.1/packages/attachments /var/www/openacs/packages/attachments \
    && mv openacs-5.9.1/packages/ajaxhelper /var/www/openacs/packages/ajaxhelper \
    && mv openacs-5.9.1/packages/calendar /var/www/openacs/packages/calendar \
    && mv openacs-5.9.1/packages/categories /var/www/openacs/packages/categories \
    && mv openacs-5.9.1/packages/general-comments /var/www/openacs/packages/general-comments \
    && mv openacs-5.9.1/packages/acs-datetime /var/www/openacs/packages/acs-datetime

COPY project-open-Update-5.0.3.0.0.tgz /var/www/projop/
COPY web_projop-aux-files.5.0.0.0.0.tgz /var/www/projop/

RUN tar xzf project-open-Update-5.0.3.0.0.tgz && rm project-open-Update-5.0.3.0.0.tgz \
    && tar xzf web_projop-aux-files.5.0.0.0.0.tgz && rm web_projop-aux-files.5.0.0.0.0.tgz \
    && mv -n packages/* /var/www/openacs/packages/ && rm -rf /var/www/projop \
    && chown -R nsadmin.nsadmin /var/www/openacs

WORKDIR /var/www/openacs/packages
COPY upgrade /var/www/openacs/packages/upgrade-5.0-5.3

RUN chmod 755 /var/www/openacs/packages/upgrade-5.0-5.3/install-upgrades.perl

RUN /var/www/openacs/packages/upgrade-5.0-5.3/install-upgrades.perl

RUN cp /var/www/openacs/packages/upgrade-5.0-5.3/intranet-core/cleanup* /var/www/openacs/packages/intranet-core/sql/postgresql/upgrade/

WORKDIR /var/www/openacs