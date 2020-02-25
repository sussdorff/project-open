FROM sussdorff/project-open

WORKDIR /var/www/openacs/packages
ENV PKGS_LIST "intranet-rest intranet-hr intranet-core intranet-invoices intranet-filestorage \
    intranet-forum intranet-reporting intranet-payments intranet-openoffice intranet-material \
    intranet-mail intranet-jira intranet-dynfield intranet-cost \
    intranet-timesheet2 intranet-timesheet2-tasks intranet-timesheet2-invoices \
    intranet-timesheet2-workflow intranet-workflow"

RUN for pkg in ${PKGS_LIST} ; do echo $pkg \
    && rm -rf $pkg && wget -q https://gitlab.com/cognovis-5/$pkg/-/archive/master/$pkg.tar.gz \
    && tar xfz $pkg.tar.gz && mv ${pkg}-master-* $pkg && rm $pkg.tar.gz ; done

COPY config.tcl.postload /var/www/openacs/tcl/config.tcl.postload
COPY openacs-config.tcl /usr/local/ns/conf/openacs-config.tcl
COPY wait-for-postgres.sh /usr/local/ns/bin/wait-for-postgres.sh
