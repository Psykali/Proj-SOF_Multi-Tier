#!/bin/bash

# Set variables
location="francecentral"
resourceGroupName="PERSO_SIEF"
webAppName="skwp"
sqlServerName="skazsqldb"
sqlDatabaseName="wordpress"
storageAccountName="skstorageacc"
containerName="wpimg"
vmName="skvm"
adminUsername="adminskadmin"
adminPassword="l0gP@ssw4rdd!"

# Create resource group
##az group create --name $resourceGroupName --location $location

# Create Web App
az webapp create --resource-group $resourceGroupName --plan $webAppName --name $webAppName --runtime "PHP|7.4"

# Create SQL Server
az sql server create --resource-group $resourceGroupName --name $sqlServerName --location $location --admin-user $adminUsername --admin-password $adminPassword

# Configure firewall for SQL Server
az sql server firewall-rule create --resource-group $resourceGroupName --server $sqlServerName --name AllowAll --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255

# Create SQL Database
az sql db create --resource-group $resourceGroupName --server $sqlServerName --name $sqlDatabaseName --edition GeneralPurpose --family Gen5 --capacity 2 --zone-redundant false

# Create Storage Account
az storage account create --name $storageAccountName --resource-group $resourceGroupName --location $location --sku Standard_LRS --encryption-services blob

# Create Blob Container
az storage container create --account-name $storageAccountName --name $containerName

# Create Linux VM
az vm create --resource-group $resourceGroupName --name $vmName --image UbuntuLTS --admin-username $adminUsername --admin-password $adminPassword --generate-ssh-keys --public-ip-address ""

# Install MySQL on Linux VM
az vm extension set --resource-group $resourceGroupName --vm-name $vmName --name customScript --publisher Microsoft.Azure.Extensions --version 2.0 --settings '{"fileUris":["https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/mysql-on-ubuntu/azuredeploy.json"],"commandToExecute":"bash azuredeploy.json"}'

# Configure connection strings
az webapp config connection-string set --resource-group $resourceGroupName --name $webAppName --settings "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$(az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query [0].value -o tsv)" --connection-string-type Custom --slot "production"
az webapp config connection-string set --resource-group $resourceGroupName --name $webAppName --settings "SQLAZURECONNSTR_DefaultConnection=Server=tcp:$sqlServerName.database.windows.net;Database=$sqlDatabaseName;User ID=$adminUsername@$sqlServerName;Password=$adminPassword;Encrypt=true;Connection Timeout=30;" --connection-string-type SQLAzure --slot "production"