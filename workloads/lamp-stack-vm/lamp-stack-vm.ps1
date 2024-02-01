#!/bin/bash

# Create a resource group
az group create --name myResourceGroup --location eastus

# Create a virtual machine
az vm create \
  --resource-group myResourceGroup \
  --name myVM \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys

# Open port 80 for web traffic
az vm open-port --port 80 --resource-group myResourceGroup --name myVM

# Install Apache, MySQL, and PHP
az vm run-command invoke \
  --resource-group myResourceGroup \
  --name myVM \
  --command-id RunShellScript \
  --scripts "sudo apt-get update && sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql"

# Verify installation and configuration
az vm run-command invoke \
  --resource-group myResourceGroup \
  --name myVM \
  --command-id RunShellScript \
  --scripts "curl -s http://localhost | grep 'Welcome to Apache' && mysql -u root -p -e 'show databases;'"
