FROM sussdorff/openacs

RUN apt-get update && apt-get -y dist-upgrade && apt-get install -y perl && apt-get install -y git  && apt-get -y autoremove \
    && mkdir -p /var/www/projop && mkdir -p /var/www/openacs/filestorage && mkdir -p /var/www/openacs/log && mkdir -p /var/www/openacs/packages \
    && rm -rf /var/www/openacs/packages/*

WORKDIR /var/www/projop

COPY project-open-Update-5.0.3.0.0.tgz /var/www/projop/
COPY web_projop-aux-files.5.0.0.0.0.tgz /var/www/projop/

RUN tar xzf project-open-Update-5.0.3.0.0.tgz && rm project-open-Update-5.0.3.0.0.tgz \
    && tar xzf web_projop-aux-files.5.0.0.0.0.tgz && rm web_projop-aux-files.5.0.0.0.0.tgz \
    && mv -n packages/* /var/www/openacs/packages/ && rm -rf /var/www/projop \
    && chown -R nsadmin.nsadmin /var/www/openacs

WORKDIR /var/www/openacs/packages
COPY upgrade /var/www/openacs/packages/upgrade-5.0-5.3

RUN chmod 755 /var/www/openacs/packages/upgrade-5.0-5.3/install-upgrades.perl \
    && /var/www/openacs/packages/upgrade-5.0-5.3/install-upgrades.perl \
    && cp /var/www/openacs/packages/upgrade-5.0-5.3/intranet-core/cleanup* /var/www/openacs/packages/intranet-core/sql/postgresql/upgrade/

WORKDIR /var/www/openacs