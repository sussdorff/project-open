FROM sussdorff/project-open:oacs-5-10

WORKDIR /var/www/openacs/packages
ENV PKGS_LIST "intranet-rest intranet-hr intranet-core intranet-invoices intranet-filestorage \
    intranet-forum intranet-reporting intranet-payments intranet-openoffice intranet-material \
    intranet-mail intranet-jira intranet-dynfield intranet-cost \
    intranet-timesheet2 intranet-timesheet2-tasks intranet-timesheet2-invoices \
    intranet-timesheet2-workflow intranet-workflow"

RUN for pkg in ${PKGS_LIST} ; do echo $pkg \
    && rm -rf $pkg && wget -q https://gitlab.com/cognovis-5/$pkg/-/archive/master/$pkg.tar.gz \
    && tar xfz $pkg.tar.gz && mv ${pkg}-master-* $pkg && rm $pkg.tar.gz ; done
