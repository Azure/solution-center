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

resource "azurerm_windows_virtual_machine" "example" {
    name                = "example-windows-vm"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name

    size                 = "Standard_B1s"
    admin_username       = "adminuser"
    network_interface_ids = [azurerm_network_interface.example.id]

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }

    os_disk {
        name              = "example-windows-os-disk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    computer_name  = "examplewindowsvm"
    admin_password = "Password1234!"

    custom_data = <<-EOF
                                <powershell>
                                # Install IIS
                                Install-WindowsFeature -name Web-Server -IncludeManagementTools

                                # Install MySQL
                                Install-WindowsFeature -name MySQL

                                # Install PHP
                                Install-WindowsFeature -name Web-App-Dev -IncludeManagementTools

                                # Configure IIS
                                Set-WebConfigurationProperty -Filter /system.webServer/security/authentication/windowsAuthentication -name enabled -value true
                                Set-WebConfigurationProperty -Filter /system.webServer/security/authentication/anonymousAuthentication -name enabled -value false

                                # Restart IIS
                                Restart-Service -Name W3SVC
                                </powershell>
                                EOF
}
