#!/bin/bash

# Set variables
resource_group="PERSO_SIEF"
webapp_dev="SK_webapp_dev"
webapp_prod="SK_webapp_prod"
mysql_server="SK_mariadb"
mysql_admin="adminuser"
mysql_password="password"
mysql_db="wordpressdb"
mysql_host="${mysql_server}.mysql.database.azure.com"

# Deploy WordPress to development environment
az webapp deployment source config-zip --resource-group $resource_group \
--name $webapp_dev --src https://wordpress.org/latest.zip

# Configure database connection for development environment
az webapp config appsettings set --resource-group $resource_group --name $webapp_dev \
--settings WORDPRESS_DB_HOST=$mysql_host WORDPRESS_DB_USER=$mysql_admin \
WORDPRESS_DB_PASSWORD=$mysql_password WORDPRESS_DB_NAME=$mysql_db

# Deploy WordPress to production environment
az webapp deployment source config-zip --resource-group $resource_group \
--name $webapp_prod --src https://wordpress.org/latest.zip

# Configure database connection for production environment
az webapp config appsettings set --resource-group $resource_group --name $webapp_prod \
--settings WORDPRESS_DB_HOST=$mysql_host WORDPRESS_DB_USER=$mysql_admin \
WORDPRESS_DB_PASSWORD=$mysql_password WORDPRESS_DB_NAME=$mysql_db