FROM sussdorff/openacs:5.10

RUN  apt-get update && apt-get -y dist-upgrade && apt-get install perl -y && apt-get -y autoremove

RUN mkdir /var/www/openacs/filestorage

WORKDIR /var/www/openacs/packages

# Packages to overwrite
ENV PKGS_LIST "cognovis-core cognovis-rest intranet-invoices intranet-openoffice intranet-material intranet-mail intranet-chilkat intranet-fs intranet-slack intranet-collmex webix-portal"
RUN for pkg in ${PKGS_LIST} ; do git clone https://gitlab.com/cognovis-5/${pkg}.git ; done

ENV OLD_PKGS_LIST "intranet-jquery"
RUN for pkg in ${OLD_PKGS_LIST} ; do git clone https://gitlab.com/cognovis/${pkg}.git ; done

ENV PO_PKGS_LIST "intranet-cost-center upgrade-5.0-5.3 intranet-ganttproject"
RUN for pkg in ${PO_PKGS_LIST} ; do git clone https://gitlab.com/project-open/${pkg}.git ; done

ENV OPENACS_LIST "acs-events rss-support oacs-dav  file-storage attachments calendar categories general-comments acs-datetime views"
RUN for pkg in ${OPENACS_LIST} ; do git clone -b oacs-5-10 https://github.com/openacs/${pkg}.git ; done


ENV PROJOP_LIST "acs-mail acs-workflow diagram workflow simple-survey installer-linux intranet-calendar intranet-core intranet-cost intranet-dw-light intranet-milestone intranet-dynfield intranet-expenses intranet-exchange-rate intranet-filestorage intranet-forum\
 intranet-helpdesk intranet-hr intranet-notes intranet-payments intranet-reporting intranet-reporting-dashboard intranet-reporting-tutorial \
 intranet-rest intranet-search-pg intranet-security-update-client intranet-simple-survey intranet-sysconfig intranet-timesheet2 intranet-timesheet2-invoices \
 intranet-timesheet2-tasks intranet-timesheet2-workflow intranet-workflow ref-currency intranet-confdb"
RUN for pkg in ${PROJOP_LIST} ; do git clone https://gitlab.project-open.net/project-open/${pkg}.git ; done



RUN cp -pr installer-linux/bin /var/www/openacs 
RUN cp -pr installer-linux/content-repository-content-files /var/www/openacs 
RUN rm -rf installer-linux

WORKDIR /var/www/openacs

ENV PKGS_LIST "webix-portal sencha-portal sencha-assignment sencha-freelance-translation intranet-sencha-tables intranet-trans-invoices intranet-translation intranet-trans-trados intranet-trans-memoq"
ENV PKGS_OLD_LIST "intranet-trans-project-wizard intranet-trans-termbase intranet-freelance intranet-freelance-translation intranet-freelance-invoices"