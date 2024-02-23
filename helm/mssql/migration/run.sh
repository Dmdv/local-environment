#!/bin/sh
set -e

echo "Checking connection to database and failing if it's not available"

RELEASE_NAME=mssql
HOST=${RELEASE_NAME}.mssql.svc.cluster.local

echo "Checking connection to ${HOST} with sa user and password $MSSQL_SA_PASSWORD"

/opt/mssql-tools/bin/sqlcmd -S "$HOST" -U sa -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" > /dev/null || exit 1

echo "Starting migration"

echo "Creating database and users"
/opt/mssql-tools/bin/sqlcmd -S "$HOST" -U sa -P "$MSSQL_SA_PASSWORD" -d master -i /opt/migration/init_users.sql
echo "Created database and users"

echo "Creating schema"
/opt/mssql-tools/bin/sqlcmd -S "$HOST" -U sa -P "$MSSQL_SA_PASSWORD" -d master -i /opt/migration/init_schema.sql
echo "Created schema"

echo "Import data"
/opt/mssql-tools/bin/sqlcmd -S "$HOST" -U sa -P "$MSSQL_SA_PASSWORD" -d master -i /opt/migration/init_data.sql
echo "Data imported"

echo "Migration completed"

exit 0