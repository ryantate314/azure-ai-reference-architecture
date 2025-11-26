resource "azurerm_public_ip" "bastion" {
  count = var.deploy_bastion ? 1 : 0

  name                = "bastion-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones              = ["1", "2", "3"]
}

resource "azurerm_bastion_host" "bastion" {
  count = var.deploy_bastion ? 1 : 0

  name = "bastion-host"
  location = var.location
  resource_group_name = var.resource_group_name
  sku = "Basic"
  ip_connect_enabled = false
  kerberos_enabled = false
  shareable_link_enabled = false
  tunneling_enabled = false

  ip_configuration {
    name = "configuration"
    subnet_id = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}

resource "azurerm_network_interface" "jump_box" {
  count = var.deploy_bastion ? 1 : 0

  name                = "jump-box-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  # auxiliary_mode = "None"
  # auxiliary_sku = "None"
  ip_forwarding_enabled = false
  accelerated_networking_enabled = false

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.jump_box.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "jump_box" {
  count = var.deploy_bastion ? 1 : 0

  name                = "jump-box-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_Ds1_v2"
  admin_username      = "azureuser"
  admin_password = var.bastion_password

  network_interface_ids = [
    azurerm_network_interface.jump_box[0].id,
  ]

  identity {
     type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-Datacenter"
    version   = "latest"
  }

  additional_capabilities {
    ultra_ssd_enabled = false
    hibernation_enabled = false
  }
}