FROM sussdorff/openacs:oacs-5-10

RUN mkdir -p /var/www/projop && mkdir /var/www/openacs/filestorage

WORKDIR /var/www/projop

RUN wget --quiet https://sourceforge.net/projects/project-open/files/project-open/V5.0/update/project-open-Update-5.0.3.0.0.tgz \
    && tar xzf project-open-Update-5.0.3.0.0.tgz && rm project-open-Update-5.0.3.0.0.tgz \
    && wget --quiet https://sourceforge.net/projects/project-open/files/project-open/Support%20Files/web_projop-aux-files.5.0.0.0.0.tgz \
    && tar xzf web_projop-aux-files.5.0.0.0.0.tgz && rm web_projop-aux-files.5.0.0.0.0.tgz \
    && mv -n packages/* /var/www/openacs/packages/ && rm -rf /var/www/projop \
    && chown -R nsadmin.nsadmin /var/www/openacs

COPY intranet-search-pg/intranet-search-pg-procs.tcl /var/www/openacs/packages/intranet-search-pg/tcl/intranet-search-pg-procs.tcl
COPY intranet-search-pg/search.tcl /var/www/openacs/packages/intranet-search-pg/www/search.tcl

WORKDIR /var/www/openacs
