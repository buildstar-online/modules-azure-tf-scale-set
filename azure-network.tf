resource "azurerm_subnet" "vm_subnet" {
  name                 = "${var.vnet_subnet_name}"
  resource_group_name  = var.resource_group
  virtual_network_name = "${var.vnet_name}"
  address_prefixes     = var.subnet_prefixes
  private_link_service_network_policies_enabled = true
  service_endpoints    = [ "Microsoft.Storage" ]
}

resource "azurerm_network_security_group" "scaleset_security_group" {
  name                = "ScaleSet-NetSec"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = ["${var.allowed_ips}"]
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.scaleset_security_group.name
}
