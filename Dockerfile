FROM sussdorff/project-open:5.10

WORKDIR /var/www/openacs/packages

# Packages to overwrite
ENV PKGS_LIST "sencha-portal sencha-assignment sencha-freelance-translation intranet-sencha-tables intranet-trans-invoices intranet-translation intranet-trans-trados intranet-trans-memoq"
ENV OLD_PKGS_LIST "intranet-freelance intranet-freelance-invoices intranet-trans-project-wizard intranet-trans-termbase intranet-freelance-translation intranet-reporting-translation intranet-reporting-finance intranet-trans-quality"

RUN for pkg in ${PKGS_LIST} ; do git clone https://gitlab.com/cognovis-5/${pkg}.git ; done && for pkg in ${OLD_PKGS_LIST} ; do git clone https://gitlab.com/cognovis/${pkg}.git ; done

WORKDIR /var/www/openacs