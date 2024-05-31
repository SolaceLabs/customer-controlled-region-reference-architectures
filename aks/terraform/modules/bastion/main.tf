locals {
  bastion_prefix   = "${var.cluster_name}-bastion"
  bastion_username = "ubuntu"
}

resource "azurerm_public_ip" "bastion" {
  count = var.create_bastion ? 1 : 0

  name                = local.bastion_prefix
  location            = var.region
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "bastion" {
  count = var.create_bastion ? 1 : 0

  name                = local.bastion_prefix
  location            = var.region
  resource_group_name = var.resource_group_name
  tags                = var.common_tags

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefixes    = var.bastion_ssh_authorized_networks
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }

  lifecycle {
    precondition {
      condition     = length(var.bastion_ssh_authorized_networks) > 0
      error_message = "At least one authorized network must be provided if bastion host is being created."
    }
  }
}

resource "azurerm_network_interface_security_group_association" "bastion" {
  count = var.create_bastion ? 1 : 0

  network_interface_id      = azurerm_network_interface.bastion[0].id
  network_security_group_id = azurerm_network_security_group.bastion[0].id
}

resource "azurerm_network_interface" "bastion" {
  count = var.create_bastion ? 1 : 0

  name                = local.bastion_prefix
  location            = var.region
  resource_group_name = var.resource_group_name
  tags                = var.common_tags

  ip_configuration {
    name                          = local.bastion_prefix
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion[0].id
  }

  lifecycle {
    precondition {
      condition     = var.subnet_id != ""
      error_message = "Subnet ID must be provided if bastion host is being created."
    }
  }
}

resource "azurerm_virtual_machine" "bastion" {
  #checkov:skip=CKV2_AZURE_12:Solace is not opinionated on the use of Azure Backup for the bastion VM
  #checkov:skip=CKV2_AZURE_10:Solace is not opinionated on the use of Azure Antimalware for the bastion VM

  count = var.create_bastion ? 1 : 0

  name                  = local.bastion_prefix
  location              = var.region
  resource_group_name   = var.resource_group_name
  tags                  = var.common_tags
  network_interface_ids = [azurerm_network_interface.bastion[0].id]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = local.bastion_prefix
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_profile {
    computer_name  = local.bastion_prefix
    admin_username = local.bastion_username
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${local.bastion_username}/.ssh/authorized_keys"
      key_data = var.bastion_ssh_public_key
    }
  }

  depends_on = [azurerm_network_interface_security_group_association.bastion[0]]

  lifecycle {
    precondition {
      condition     = var.bastion_ssh_public_key != ""
      error_message = "Public key must be provided if bastion host is being created."
    }
  }
}
