#!/bin/sh

echo "Creating database"
/opt/mssql-tools/bin/sqlcmd -S mssql -U sa -P "$MSSQL_SA_PASSWORD" -d master -i /opt/migration/init.sql
echo "Migration completed"