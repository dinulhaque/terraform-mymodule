

resource "azurerm_resource_group" "lesson1" {
  name     = var.project_name
  location = var.region
}
resource "azurerm_virtual_network" "lesson1" {
  name                = "${var.project_name}network"

  location            = azurerm_resource_group.lesson1.location
  resource_group_name = azurerm_resource_group.lesson1.name
  address_space       = [var.ip_cidr]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.project_name}-subnet1"
  resource_group_name  = azurerm_resource_group.lesson1.name
  virtual_network_name = azurerm_virtual_network.lesson1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "publicip1" {
  name                = "${var.project_name}-publicip1"
  resource_group_name = azurerm_resource_group.lesson1.name
  location            = azurerm_resource_group.lesson1.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.project_name}-nic"
  location            = azurerm_resource_group.lesson1.location
  resource_group_name = azurerm_resource_group.lesson1.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip1.id
     
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "${var.project_name}vm"
  location              = azurerm_resource_group.lesson1.location
  resource_group_name   = azurerm_resource_group.lesson1.name
  network_interface_ids = [azurerm_network_interface.main.id]
  size               = var.vm_sku

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  admin_username        = "ubuntu"
  
  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version =   "latest"
  }
}



