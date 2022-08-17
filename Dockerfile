FROM sussdorff/openacs:5.10-compat

RUN mkdir /var/www/openacs/filestorage && mkdir /var/www/gitlab

COPY gitlab/ /var/www/gitlab

WORKDIR /var/www/openacs/packages

# Packages to overwrite
ENV PKGS_LIST "cognovis-core cognovis-rest  intranet-chilkat intranet-fs intranet-slack intranet-collmex webix-portal"
ENV OLD_PKGS_LIST "intranet-jquery"
ENV PO_PKGS_LIST "intranet-cost-center upgrade-5.0-5.3 intranet-ganttproject"
ENV OPENACS_LIST "acs-events rss-support oacs-dav  file-storage attachments calendar categories general-comments acs-datetime views"
ENV PROJOP_LIST "acs-mail acs-workflow diagram workflow simple-survey installer-linux intranet-calendar intranet-core intranet-cost intranet-dw-light intranet-milestone intranet-dynfield intranet-expenses intranet-exchange-rate intranet-filestorage intranet-forum \
intranet-helpdesk intranet-hr intranet-notes intranet-payments intranet-reporting intranet-reporting-dashboard intranet-reporting-tutorial intranet-invoices intranet-openoffice intranet-material intranet-mail \
intranet-rest intranet-search-pg intranet-security-update-client intranet-simple-survey intranet-sysconfig intranet-timesheet2 intranet-timesheet2-invoices \
intranet-timesheet2-tasks intranet-timesheet2-workflow intranet-workflow ref-currency intranet-confdb"

RUN for pkg in ${PKGS_LIST} ; do git clone https://gitlab.com/cognovis-5/${pkg}.git ; done \
    && for pkg in ${OLD_PKGS_LIST} ; do git clone https://gitlab.com/cognovis/${pkg}.git ; done \
    && for pkg in ${PO_PKGS_LIST} ; do git clone https://gitlab.com/project-open/${pkg}.git ; done \
    && for pkg in ${OPENACS_LIST} ; do git clone -b openacs-5-10-compat https://github.com/openacs/${pkg}.git ; done \
    && for pkg in ${PROJOP_LIST} ; do mv /var/www/gitlab/${pkg} /var/www/openacs/packages  ; done \
    && cp -pr installer-linux/bin /var/www/openacs && cp -pr installer-linux/content-repository-content-files /var/www/openacs && rm -rf installer-linux && rm -rf /var/www/gitlab

WORKDIR /var/www/openacs