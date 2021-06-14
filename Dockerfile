FROM sussdorff/openacs

RUN  apt-get update && apt-get -y dist-upgrade && apt-get -y autoremove

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


RUN wget https://sourceforge.net/projects/project-open/files/project-open/V5.0/update/project-open-Update-5.0.3.0.0.tgz \
    && tar xzf project-open-Update-5.0.3.0.0.tgz && rm project-open-Update-5.0.3.0.0.tgz \
    && wget https://downloads.sourceforge.net/project/project-open/project-open/Support%20Files/web_projop-aux-files.5.0.0.0.0.tgz \
    && tar xzf web_projop-aux-files.5.0.0.0.0.tgz && rm web_projop-aux-files.5.0.0.0.0.tgz \
    && mv -n packages/* /var/www/openacs/packages/ && rm -rf /var/www/projop \
    && chown -R nsadmin.nsadmin /var/www/openacs

COPY upgrade/intranet-core /var/www/openacs/packages/intranet-core/sql/postgresql/upgrade
COPY upgrade/intranet-dynfield /var/www/openacs/packages/intranet-dynfield/sql/postgresql/upgrade
COPY upgrade/intranet-material /var/www/openacs/packages/intranet-material/sql/postgresql/upgrade
COPY upgrade/intranet-reporting /var/www/openacs/packages/intranet-reporting/sql/postgresql/upgrade
COPY upgrade/intranet-timesheet2 /var/www/openacs/packages/intranet-timesheet2/sql/postgresql/upgrade
COPY upgrade/intranet-timesheet2-workflow /var/www/openacs/packages/intranet-timesheet2-workflow/sql/postgresql/upgrade
COPY upgrade/intranet-cost /var/www/openacs/packages/intranet-cost/sql/postgresql/upgrade
COPY upgrade/intranet-forum /var/www/openacs/packages/intranet-forum/sql/postgresql/upgrade
COPY upgrade/intranet-planning /var/www/openacs/packages/intranet-planning/sql/postgresql/upgrade
COPY upgrade/intranet-rest /var/www/openacs/packages/intranet-rest/sql/postgresql/upgrade
COPY upgrade/intranet-timesheet2-tasks /var/www/openacs/packages/intranet-timesheet2-tasks/sql/postgresql/upgrade
COPY upgrade/intranet-workflow /var/www/openacs/packages/intranet-workflow/sql/postgresql/upgrade

WORKDIR /var/www/openacs
