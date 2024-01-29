#!/bin/bash
###############################################################################
## Author:  @spicyFajitas
## Date:    2023-07-05
## Desc:    converts database character set from whatever to utf8mb4
###############################################################################
set -exuo pipefail
# Connect to MySQL and retrieve a list of all databases
DATABASES=$(mysql -e "SHOW DATABASES;" | grep -Ev "(information_schema|performance_schema)")

# Iterate over each database and convert tables to utf8mb4 character set
for DATABASE in $DATABASES; do
  TABLES=$(mysql -N -B -e "USE $DATABASE; SHOW TABLES;" | tr '\n' ' ')
#  TABLES=$(mysql -u $MYSQL_USER -p $MYSQL_PASSWORD -N -B -e "USE $DATABASE; SHOW TABLES;" | tr '\n' ' ')
  for TABLE in $TABLES; do
    echo "Converting table $TABLE in database $DATABASE..."
    mysql -e "USE $DATABASE; ALTER TABLE $TABLE CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  done
done

# Set default character set to utf8mb4 for each database
for DATABASE in $DATABASES; do
  echo "Setting default character set to utf8mb4 for database $DATABASE..."
  mysql -e "USE $DATABASE; ALTER DATABASE $DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
#  mysql -u $MYSQL_USER -p $MYSQL_PASSWORD -e "USE $DATABASE; ALTER DATABASE $DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
done

echo "Conversion complete!"
