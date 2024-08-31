locals {
  tags = {
    project   = var.project_short_name
    owner     = var.owner
    region    = var.location
    managedBy = "Terraform"
  }

  common_name = "${var.project_short_name}-${var.application_short_name}-${var.locatio_short_name}"
}

resource "azurerm_resource_group" "primary" {
  name     = "${local.common_name}-rg"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "primary" {

  name                = "${local.common_name}-vnet"
  resource_group_name = azurerm_resource_group.primary.name
  location            = var.location
  tags                = local.tags
  address_space       = var.vnet_address_space
  depends_on          = [azurerm_resource_group.primary]
}

resource "azurerm_subnet" "primary" {
  name                 = "${local.common_name}-subnet"
  resource_group_name  = azurerm_resource_group.primary.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = var.subnet_address_prefixes
  depends_on           = [azurerm_virtual_network.primary]
}

resource "azurerm_network_interface" "primary" {
  count               = length(var.virtual_machines)
  name                = "${local.common_name}-${format("%03d", count.index + 1)}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.primary.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.primary.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_password" "vm_passwords" {
  count   = length(var.virtual_machines)
  length  = 24
  special = false
}

resource "azurerm_virtual_machine" "main" {
  count = length(var.virtual_machines)

  name = "${local.common_name}-${format("%03d", count.index + 1)}-vm"

  location              = var.location
  resource_group_name   = azurerm_resource_group.primary.name
  network_interface_ids = [azurerm_network_interface.primary[count.index].id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = var.virtual_machines[count.index].image == "ubuntu22" ? "0001-com-ubuntu-server-jammy" : "0001-com-ubuntu-server-focal"
    sku       = var.virtual_machines[count.index].image == "ubuntu22" ? "22_04-lts" : "20_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${local.common_name}-${format("%03d", count.index + 1)}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.common_name}-${format("%03d", count.index + 1)}"
    admin_username = "testadmin"
    admin_password = random_password.vm_passwords[count.index].result
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = local.tags

  depends_on = [azurerm_subnet.primary]
}

resource "azurerm_virtual_machine_run_command" "ping" {  
  count = length(var.virtual_machines)

  name               = "${local.common_name}-${format("%03d", count.index + 1)}-ping"
  location           = var.location
  virtual_machine_id = azurerm_virtual_machine.main[count.index].id

  source {
    script = "ping ${azurerm_network_interface.primary[(count.index+1)%length(var.virtual_machines)].ip_configuration.0.private_ip_address} -c 1 >/dev/null 2>&1 && echo pass || echo fail"
  }
}
