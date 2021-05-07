#!/bin/sh
apt update
apt install gettext-base -y
cat /tmp/config-init/wordpress.mssql | envsubst > /tmp/wordpress-new-customer.mssql
mysql -h ${WORDPRESS_DB_HOST} -u root -p${MYSQL_ROOT_PASSWORD} < /tmp/wordpress-new-customer.mssql
