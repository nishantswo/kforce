# Create network interface 

resource "azurerm_network_interface" "myterraformniclb" {
    count               = var.gwip_count
    name                      = "${var.lb}-NIC"
    location                  = "${var.location}"
    resource_group_name       = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name                          = "ipconfig-${var.lb}"
        subnet_id                     = "${azurerm_subnet.sub1.id}" 
        private_ip_address_allocation = "static"
        private_ip_address            = "${cidrhost("${var.sub1_add}",  6+count.index)}"
        
}
depends_on = ["azurerm_application_gateway.network"]
}

# Create Azure Load Balancer

resource "azurerm_lb" "lb" {
  name                = "${var.lb}"
  location 	      = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                 = "LBFrontEnd"
    subnet_id            = "${azurerm_subnet.sub1.id}"
    private_ip_address = "${azurerm_network_interface.myterraformniclb.0.ip_configuration[0].private_ip_address}"
  }
  depends_on = ["azurerm_network_interface.myterraformniclb"]
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "BackEndAddressPool"
  depends_on = ["azurerm_lb.lb"]
}

resource "azurerm_network_interface_backend_address_pool_association" "lbtarget1" {
  network_interface_id    = "${azurerm_network_interface.myterraformnicweb.0.id}"
  ip_configuration_name= "${azurerm_network_interface.myterraformnicweb.0.ip_configuration[0].name}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bepool.id
  depends_on = ["azurerm_lb_backend_address_pool.bepool"]
}

resource "azurerm_network_interface_backend_address_pool_association" "lbtarget2" {
  network_interface_id    = "${azurerm_network_interface.myterraformnicweb.1.id}"
  ip_configuration_name= "${azurerm_network_interface.myterraformnicweb.1.ip_configuration[0].name}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bepool.id		
  depends_on = ["azurerm_lb_backend_address_pool.bepool"]
}

resource "azurerm_lb_probe" "probe1" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id                = azurerm_lb.lb.id
  name                = "OSINTEGEUSPOCPORWEB-PROBE-18430"
  port                = 18430
  depends_on = ["azurerm_lb.lb"]
}

resource "azurerm_lb_rule" "rule1" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "OSINTEGEUSPOCPORWEB-LBRULE-18430"
  protocol                       = "Tcp"
  frontend_port                  = 18430
  backend_port                   = 18430
  frontend_ip_configuration_name = "LBFrontEnd"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bepool.id
  probe_id                       = azurerm_lb_probe.probe1.id
  idle_timeout_in_minutes        = "4"
  load_distribution              = "SourceIPProtocol"
  depends_on = ["azurerm_lb_backend_address_pool.bepool"]
}

resource "azurerm_lb_probe" "probe2" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id                = azurerm_lb.lb.id
  name                = "OSINTEGEUSPORWEB-PROBE-18440"
  port                = 18440
  depends_on = ["azurerm_lb.lb"]
}

resource "azurerm_lb_rule" "rule2" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "OSINTEGEUSPOCPORWEB-LBRULE-18440"
  protocol                       = "Tcp"
  frontend_port                  = 18440
  backend_port                   = 18440
  frontend_ip_configuration_name = "LBFrontEnd"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bepool.id
  probe_id                       = azurerm_lb_probe.probe2.id
  idle_timeout_in_minutes        = "4"
  load_distribution              = "SourceIPProtocol"
  depends_on = ["azurerm_lb_backend_address_pool.bepool"]
}

resource "azurerm_lb_probe" "probe3" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id                = azurerm_lb.lb.id
  name                = "OSINTEGEUSPOCPORWEB-PROBE-18443"
  port                = 18443
  depends_on = ["azurerm_lb.lb"]
}

resource "azurerm_lb_rule" "rule3" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "OSINTEGEUSPOCPORWEB-LBRULE-18443"
  protocol                       = "Tcp"
  frontend_port                  = 18443
  backend_port                   = 18443
  frontend_ip_configuration_name = "LBFrontEnd"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bepool.id
  probe_id                       = azurerm_lb_probe.probe3.id
  idle_timeout_in_minutes        = "4"
  load_distribution              = "SourceIPProtocol"
  depends_on = ["azurerm_lb_backend_address_pool.bepool"]
}

resource "azurerm_lb_probe" "probe4" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id                = azurerm_lb.lb.id
  name                = "OSINTEGEUSPOCPORWEB-PROBE-40443"
  port                = 40443
  depends_on = ["azurerm_lb.lb"]
}

resource "azurerm_lb_rule" "rule4" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "OSINTEGEUSPOCPORWEB-LBRULE-40443"
  protocol                       = "Tcp"
  frontend_port                  = 40443
  backend_port                   = 40443
  frontend_ip_configuration_name = "LBFrontEnd"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bepool.id
  probe_id                       = azurerm_lb_probe.probe4.id
  idle_timeout_in_minutes        = "4"
  load_distribution              = "SourceIPProtocol"
  depends_on = ["azurerm_lb_backend_address_pool.bepool"]
}
