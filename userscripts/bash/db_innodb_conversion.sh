#!/bin/bash
###############################################################################
## Author:  @spicyFajitas
## Date:    2023-07-05
## Desc:    converts database engine from whatever engine to InnoDB
###############################################################################
set -exuo pipefail
# MySQL credentials
MYSQL_USER="your_username"
MYSQL_PASSWORD="your_password"

# Connect to MySQL and retrieve a list of all databases
DATABASES=$(mysql -e "SHOW DATABASES;" | grep -Ev "(information_schema|performance_schema)")

# Iterate over each database and convert tables from MyISAM to InnoDB
for DATABASE in $DATABASES; do
  TABLES=$(mysql -N -B -e "USE $DATABASE; SHOW TABLES;" | tr '\n' ' ')
#  TABLES=$(mysql -u $MYSQL_USER -p $MYSQL_PASSWORD -N -B -e "USE $DATABASE; SHOW TABLES;" | tr '\n' ' ')
  for TABLE in $TABLES; do
    echo "Converting table $TABLE in database $DATABASE..."
    mysql -e "USE $DATABASE; ALTER TABLE $TABLE ENGINE=InnoDB;"
#    mysql -u $MYSQL_USER -p $MYSQL_PASSWORD -e "USE $DATABASE; ALTER TABLE $TABLE CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

  done
done

echo "Conversion complete!"
