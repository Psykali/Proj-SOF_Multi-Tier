#!/bin/bash

# Read environment variables
DB_SERVER=skwp_sqlserver
DB_NAME=skwp_sqldb
DB_USER=SkLoginDipP20
DB_PASSWORD=P@ssw0rd123P@ssw0rd123

# Connect to Azure SQL Database using sqlcmd
sqlcmd -S $DB_SERVER -d $DB_NAME -U $DB_USER -P $DB_PASSWORD