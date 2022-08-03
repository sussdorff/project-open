FROM sussdorff/openacs:5.10

RUN  apt-get update && apt-get -y dist-upgrade && apt-get install perl -y && apt-get -y autoremove

RUN mkdir /var/www/openacs/filestorage

WORKDIR /var/www/openacs/packages

# Packages to overwrite
ENV PKGS_LIST "cognovis-core cognovis-rest  intranet-chilkat intranet-fs intranet-slack intranet-collmex webix-portal intranet-dynfield"
RUN for pkg in ${PKGS_LIST} ; do git clone https://gitlab.com/cognovis-5/${pkg}.git ; done

ENV OLD_PKGS_LIST "intranet-jquery"
RUN for pkg in ${OLD_PKGS_LIST} ; do git clone https://gitlab.com/cognovis/${pkg}.git ; done

ENV PO_PKGS_LIST "intranet-cost-center upgrade-5.0-5.3 intranet-ganttproject"
RUN for pkg in ${PO_PKGS_LIST} ; do git clone https://gitlab.com/project-open/${pkg}.git ; done

ENV OPENACS_LIST "acs-events rss-support oacs-dav  file-storage attachments calendar categories general-comments acs-datetime views"
RUN for pkg in ${OPENACS_LIST} ; do git clone -b oacs-5-10 https://github.com/openacs/${pkg}.git ; done

RUN mkdir /var/www/gitlab
COPY gitlab/ /var/www/gitlab

ENV PROJOP_LIST "acs-mail acs-workflow diagram workflow simple-survey installer-linux intranet-calendar intranet-core intranet-cost intranet-dw-light intranet-milestone intranet-dynfield intranet-expenses intranet-exchange-rate intranet-filestorage intranet-forum\
intranet-helpdesk intranet-hr intranet-notes intranet-payments intranet-reporting intranet-reporting-dashboard intranet-reporting-tutorial intranet-invoices intranet-openoffice intranet-material intranet-mail \
intranet-rest intranet-search-pg intranet-security-update-client intranet-simple-survey intranet-sysconfig intranet-timesheet2 intranet-timesheet2-invoices \
intranet-timesheet2-tasks intranet-timesheet2-workflow intranet-workflow ref-currency intranet-confdb"

RUN for pkg in ${PROJOP_LIST} ; do mv /var/www/gitlab/${pkg} /var/www/openacs/packages  ; done

RUN cp -pr installer-linux/bin /var/www/openacs 
RUN cp -pr installer-linux/content-repository-content-files /var/www/openacs 
RUN rm -rf installer-linux

WORKDIR /var/www/openacs