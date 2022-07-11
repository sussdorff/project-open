FROM sussdorff/project-open:5.10

RUN  apt-get update && apt-get -y dist-upgrade && apt-get install perl -y && apt-get -y autoremove

WORKDIR /var/www/openacs/packages

# Packages to overwrite
ENV PKGS_LIST "sencha-portal sencha-assignment sencha-freelance-translation intranet-sencha-tables intranet-trans-invoices intranet-translation intranet-trans-trados intranet-trans-memoq"
RUN for pkg in ${PKGS_LIST} ; do git clone https://gitlab.com/cognovis-5/${pkg}.git ; done

ENV OLD_PKGS_LIST "intranet-freelance intranet-freelance-invoices intranet-trans-project-wizard intranet-trans-termbase intranet-freelance-translation"

RUN for pkg in ${OLD_PKGS_LIST} ; do git clone https://gitlab.com/cognovis/${pkg}.git ; done

WORKDIR /var/www/openacs