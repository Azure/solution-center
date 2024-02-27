#!/bin/bash

# Set variables for the new account, website, and database
resourceGroupName=myResourceGroup
location=WestUS
subscriptionId=yourSubscriptionId
planName=myAppServicePlan
webAppName=myWebApp$RANDOM
dbName=mySampleDatabase

# Set the subscription context for the Azure account
az account set --subscription $subscriptionId

# Create a resource group
az group create --name $resourceGroupName --location $location

# Create an App Service plan in the resource group
az appservice plan create --name $planName --resource-group $resourceGroupName --location $location --sku FREE

# Create a web app in the App Service plan
az webapp create --name $webAppName --resource-group $resourceGroupName --plan $planName

# Configure the web app to use the WordPress stack
az webapp config set --name $webAppName --resource-group $resourceGroupName --linux-fx-version "PHP|7.3"

# Create a MySQL database in the resource group
az mysql server create --name $dbName --resource-group $resourceGroupName --location $location --admin-user myadmin --admin-password mypassword --sku-name B_Gen5_1 --version 5.7

# Configure the firewall for the MySQL database
az mysql server firewall-rule create --name allAzureIPs --server $dbName --resource-group $resourceGroupName --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
