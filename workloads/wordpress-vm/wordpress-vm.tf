provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "example" {
    name     = "example-resources"
    location = "eastus"
}

resource "azurerm_virtual_network" "example" {
    name                = "example-network"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
    name                 = "example-subnet"
    resource_group_name  = azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.example.name
    address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "example" {
    name                = "example-public-ip"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "example" {
    name                = "example-nsg"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name

    security_rule {
        name                       = "HTTP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "SSH"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface" "example" {
    name                = "example-nic"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.example.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.example.id
    }
}

resource "azurerm_linux_virtual_machine" "example" {
    name                = "example-vm"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name

    size                 = "Standard_B1s"
    admin_username       = "adminuser"
    network_interface_ids = [azurerm_network_interface.example.id]

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_disk {
        name              = "example-os-disk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    computer_name  = "examplevm"
    admin_password = "Password1234!"

    custom_data = <<-EOF
                                #!/bin/bash
                                sudo apt-get update
                                sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql
                                EOF
}

resource "azurerm_mysql_server" "example" {
    name                = "example-mysql-server"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    sku_name            = "B_Gen5_1"
    storage_mb          = 5120
    version             = "5.7"
    administrator_login          = "mysqladmin"
    administrator_login_password = "Password1234!"
}

resource "azurerm_app_service_plan" "example" {
    name                = "example-app-service-plan"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    sku {
        tier = "Standard"
        size = "S1"
    }
}

resource "azurerm_app_service" "example" {
    name                = "example-app-service"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    app_service_plan_id = azurerm_app_service_plan.example.id
    site_config {
        linux_fx_version = "DOCKER|wordpress"
        app_settings = {
            WORDPRESS_DB_HOST     = azurerm_mysql_server.example.fully_qualified_domain_name
            WORDPRESS_DB_USER     = azurerm_mysql_server.example.administrator_login
            WORDPRESS_DB_PASSWORD = azurerm_mysql_server.example.administrator_login_password
        }
    }
}
