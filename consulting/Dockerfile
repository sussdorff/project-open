FROM sussdorff/project-open

WORKDIR /var/www/openacs/packages
ENV PKGS_LIST "intranet-rest"

RUN for pkg in ${PKGS_LIST} ; do echo $pkg \
    && rm -rf $pkg && wget -q https://gitlab.com/cognovis-5/$pkg/-/archive/master/$pkg.tar.gz \
    && tar xfz $pkg.tar.gz && mv ${pkg}-master-* $pkg && rm $pkg.tar.gz ; done

ENV PKGS_OLD_LIST "sencha-portal webix-portal intranet-sencha-tables"

RUN for pkg in ${PKGS_OLD_LIST} ; do echo $pkg \
    && rm -rf $pkg && wget -q https://gitlab.com/cognovis/$pkg/-/archive/master/$pkg.tar.gz \
    && tar xfz $pkg.tar.gz && mv ${pkg}-master-* $pkg && rm $pkg.tar.gz ; done
COPY config.tcl.postload /var/www/openacs/tcl/config.tcl.postload
COPY openacs-config.tcl /usr/local/ns/conf/openacs-config.tcl
COPY wait-for-postgres.sh /usr/local/ns/bin/wait-for-postgres.sh
