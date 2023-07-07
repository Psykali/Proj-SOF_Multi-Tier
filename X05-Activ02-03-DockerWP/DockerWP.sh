#!/bin/bash

# Set variables for the new MySQL server and database
resourceGroupName=PERSO_SIEF
location=francecentral
adminUser=myadmin
password=P@ssW0rd!!
serverName=mysqlserver-$RANDOM

# Create a resource group
az group create \
    --name $resourceGroupName \
    --location $location

# Create a MySQL server in the resource group
az mysql server create \
    --name $serverName \
    --resource-group $resourceGroupName \
    --location $location \
    --admin-user $adminUser \
    --admin-password $password \
    --sku-name GP_Gen5_2

# Configure firewall rules for the MySQL server
az mysql server firewall-rule create \
    --name allAzureIPs \
    --server-name $serverName \
    --resource-group $resourceGroupName \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

# Create a WordPress container that uses the MySQL server
docker run -e WORDPRESS_DB_HOST=$serverName.mysql.database.azure.com -e WORDPRESS_DB_USER=$adminUser@$serverName -e WORDPRESS_DB_PASSWORD=$password -p 8080:80 -d wordpress
