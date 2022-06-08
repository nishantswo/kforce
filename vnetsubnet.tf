# Mention the existing Route table 

resource "azurerm_route_table" "udr" {
  name                = "${var.UDR}"
  resource_group_name = "${var.resource_group_name_peer1}"
}

# Create New Vnet

resource "azurerm_virtual_network" "vnet1" {
  name                = "${var.vnet_name1}"
  location 	      = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["${var.vnet_add1}"]
  dns_servers         = ["10.20.0.4", "10.0.0.4", "10.0.0.5", "168.63.129.16"]
depends_on = ["azurerm_resource_group.rg"]
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "${var.vnet_name2}"
  location 	      = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["${var.vnet_add2}"]
  dns_servers         = ["10.20.0.4", "10.0.0.4", "10.0.0.5", "168.63.129.16"]
depends_on = ["azurerm_resource_group.rg"]
}

# Create New Subnets

resource "azurerm_subnet" "sub1" {
  name           = "${var.subnet1}"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name  = "${azurerm_virtual_network.vnet.name}"
  address_prefix = "${var.sub1_add}"
  service_endpoints    = ["Microsoft.KeyVault"]
depends_on = ["azurerm_virtual_network.vnet"]
  }

 resource "azurerm_subnet" "sub2" {
    name           = "${var.subnet2}"
resource_group_name = "${var.resource_group_name}"
virtual_network_name  = "${azurerm_virtual_network.vnet.name}"
    address_prefix = "${var.sub2_add}"
service_endpoints    = ["Microsoft.KeyVault"]
depends_on = ["azurerm_virtual_network.vnet"]
  }

resource "azurerm_subnet" "sub3" {
    name           = "${var.subnet3}"
resource_group_name = "${var.resource_group_name}"
virtual_network_name  = "${azurerm_virtual_network.vnet.name}"
    address_prefix = "${var.sub3_add}"
service_endpoints    = ["Microsoft.KeyVault"]
depends_on = ["azurerm_virtual_network.vnet"]
}

resource "azurerm_subnet" "sub4" {
    name           = "${var.subnet4}"
resource_group_name = "${var.resource_group_name}"
virtual_network_name  = "${azurerm_virtual_network.vnet.name}"
    address_prefix = "${var.sub4_add}"
service_endpoints    = ["Microsoft.KeyVault"]
depends_on = ["azurerm_virtual_network.vnet"]
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "${var.vnet_name2}"
  location 	      = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["${var.vnet_add}"]
  dns_servers         = ["10.20.0.4", "10.0.0.4", "10.0.0.5", "168.63.129.16"]
depends_on = ["azurerm_resource_group.rg"]
}

