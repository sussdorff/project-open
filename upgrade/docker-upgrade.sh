#!/bin/bash

# This is following documentation found at http://www.project-open.com/en/upgrade-40-50 to correctly upgrade ]project-open[

apt-get update -y
apt-get install -y perl
chmod 755 /var/www/openacs/packages/upgrade-5.0-5.3/install-upgrades.perl
/var/www/openacs/packages/upgrade-5.0-5.3/install-upgrades.perl

cp /var/www/openacs/packages/upgrade-5.0-5.3/intranet-core/cleanup* /var/www/openacs/packages/intranet-core/sql/postgresql/upgrade/

PGPASSWORD=testing psql -U openacs -h postgres -f /var/www/openacs/packages/intranet-core/sql/postgresql/upgrade/cleanup-tsearch2.sql
PGPASSWORD=testing psql -U openacs -h postgres -f /var/www/openacs/packages/intranet-core/sql/postgresql/upgrade/cleanup-ams.sql
PGPASSWORD=testing psql -U openacs -h postgres -f /var/www/openacs/packages/intranet-core/sql/postgresql/upgrade/cleanup-bug-tracker.sql
PGPASSWORD=testing psql -U openacs -h postgres -f /var/www/openacs/packages/intranet-core/sql/postgresql/upgrade/cleanup-etp.sql
PGPASSWORD=testing psql -U openacs -h postgres -f /var/www/openacs/packages/intranet-core/sql/postgresql/upgrade/cleanup-events.sql
PGPASSWORD=testing psql -U openacs -h postgres -f /var/www/openacs/packages/intranet-core/sql/postgresql/upgrade/cleanup-news.sql
PGPASSWORD=testing psql -U openacs -h postgres -f /var/www/openacs/packages/intranet-core/sql/postgresql/upgrade/cleanup-postgresql-92.sql
PGPASSWORD=testing psql -U openacs -h postgres -f /var/www/openacs/packages/acs-kernel/sql/postgresql/upgrade/upgrade-5.7.0d3-5.7.0d4.sql
PGPASSWORD=testing psql -U openacs -h postgres -f /var/www/openacs/packages/ref-countries/sql/postgresql/ref-countries-create.sql