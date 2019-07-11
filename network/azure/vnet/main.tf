#--------------------------------------------------------------
# This module creates all resources necessary for a VNET
#--------------------------------------------------------------
variable "ARM_SUBSCRIPTION_ID" {}

variable "ARM_CLIENT_ID" {}
variable "ARM_TENANT_ID" {}

variable "vnet_rg"  {}
variable "az_location" {}
variable "az_location1" {}

variable "vnet_cidr"   {}
variable "vnet_name"  {}

variable "wrk_root_pw"  {}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  version = "~> 1.20"

  subscription_id = "${var.ARM_SUBSCRIPTION_ID}"
  tenant_id       = "${var.ARM_TENANT_ID}"
}

######################################################
#  RESOURCE GROUPS
######################################################

// resource "azurerm_resource_group" "vnet_rg" {
//   name      = "${var.vnet_rg}"
//   location  = "francecentral"
//   // tags      = "${var.tags_network}"
// }

// data "azurerm_resource_group" "vnet_rg" {
//   name                = "homework-tudorfil-rg"
// }

######################################################
#  VIRTUAL NETWORKS
######################################################

// resource "azurerm_virtual_network" "vnet_vn" {
//   name                = "${var.vnet_name}"
//   address_space       = ["${var.vnet_cidr}"]
//   location            = "${var.az_location}"
//   resource_group_name = "homework-tudorfil-rg"
//   // tags = "${var.tags_network}"
//   }

######################################################
#  DNS
######################################################

// resource "azurerm_dns_zone" "workzone" {
//   name                = "work.zone.local"
//   resource_group_name = "homework-tudorfil-rg"
// }

######################################################
#  SUBNETS
######################################################

// resource "azurerm_subnet" "GatewaySubnet" {
//   name                 = "GatewaySubnet"
//   resource_group_name  = "homework-tudorfil-rg"
//   virtual_network_name = "${var.vnet_name}"
//   address_prefix       = "10.0.0.0/26"
// }

// resource "azurerm_subnet" "prodmgmt_sn" {
//   name                 = "prodmgmt_sn"
//   resource_group_name  = "homework-tudorfil-rg"
//   virtual_network_name = "${var.vnet_name}"
//   address_prefix       = "10.0.0.65/26"
//   // network_security_group_id = "${azurerm_network_security_group.prodvn_nsg.id}"
// }

######################################################
# NETWORK SECURITY GROUPS
######################################################

// resource "azurerm_network_security_group" "prodmgmt_nsg" {
//   name                = "prodmgmt_nsg"
//   location            = "${var.az_location}"
//   resource_group_name = "homework-tudorfil-rg"  
// }

######################################################
## ASSOCIATION RESOURCES WILL BE AVAILABLE FOR AZURERM PROVIDER 2.0 for now they create problems.
######################################################

// resource "azurerm_subnet_network_security_group_association" "prodmgmt_sn_nsga" {
//   subnet_id                 = "${azurerm_subnet.prodmgmt_sn.id}"
//   network_security_group_id = "${azurerm_network_security_group.prodmgmt_nsg.id}"
//   depends_on = [ 
//     "azurerm_subnet.prodmgmt_sn",
//     "azurerm_network_security_group.prodmgmt_nsg"
//     ]
// }

######################################################
#  NETWORK SECURITY RULES
######################################################

// resource "azurerm_network_security_rule" "prodapplicationgatewaysnsr" {
//   name                        = "ssh"
//   priority                    = 102
//   direction                   = "Inbound"
//   access                      = "Allow"
//   protocol                    = "Tcp"
//   source_port_range           = "*"
//   destination_port_range      = "22"
//   source_address_prefix       = "*"
//   destination_address_prefix  = "*"
//   resource_group_name         = "homework-tudorfil-rg"
//   network_security_group_name = "${azurerm_network_security_group.prodmgmt_nsg.name}"

//   depends_on = [ 
//     "azurerm_subnet.prodmgmt_sn",
//     "azurerm_network_security_group.prodmgmt_nsg"
//     ]
// }

######################################################
# PUBLIC IPS
######################################################

#Public IP Allocation
resource "azurerm_public_ip" "apphost1publicip" {
  name                = "apphost1publicip"
  location            = "${var.az_location}"
  resource_group_name = "homework-tudorfil-rg"
  allocation_method   = "Dynamic"
  // sku                 = "Basic"
  domain_name_label   = "wrkapphost1"
}

resource "azurerm_public_ip" "apphost2publicip" {
  name                = "apphost2publicip"
  location            = "${var.az_location}"
  resource_group_name = "homework-tudorfil-rg"
  allocation_method   = "Dynamic"
  // sku                 = "Basic"
  domain_name_label   = "wrkapphost2"
}


######################################################
# ROUTE TABLES
######################################################


// resource "azurerm_route_table" "route_table1" {
//   name                          = "route_table1"
//   location                      = "${var.az_location}"
//   resource_group_name           = "${data.azurerm_resource_group.vnet_rg.name}"
//   disable_bgp_route_propagation = true

//   // route {
//   //   name           = "route1"
//   //   address_prefix = "10.1.0.0/16"
//   //   next_hop_type  = "vnetlocal"
//   // }

//   tags                = "${var.tags_network}"

// }

######################################################
# VIRTUAL MACHINES
######################################################

#--------------------------------------------------------------
# APP HOST1
#--------------------------------------------------------------

resource "azurerm_network_interface" "apphost1nic" {
  name                = "apphost1-nic0"
  location            = "${var.az_location}"
  resource_group_name = "homework-tudorfil-rg"

  ip_configuration {
    name                          = "ipconfiguration0"
    // subnet_id                     = "${azurerm_subnet.prodmgmt_sn.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.apphost1publicip.id}"

  }
}

resource "azurerm_virtual_machine" "apphost1" {
  name                  = "apphost1"
  location              = "${var.az_location}"
  resource_group_name   = "homework-tudorfil-rg"
  network_interface_ids = ["${azurerm_network_interface.apphost1nic.id}"]
  vm_size               = "Standard_D2S_v3"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "apphost1"
    admin_username = "tudorfil"
    admin_password = "${var.wrk_root_pw}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
        ssh_keys {
          path     = "~/.ssh/authorized_keys"
          key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }
}

#--------------------------------------------------------------
# APP HOST2
#--------------------------------------------------------------

resource "azurerm_network_interface" "apphost2nic" {
  name                = "apphost2-nic0"
  location            = "${var.az_location1}"
  resource_group_name = "homework-tudorfil-rg"

  ip_configuration {
    name                          = "ipconfiguration0"
    // subnet_id                     = "${azurerm_subnet.prodmgmt_sn.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.apphost2publicip.id}"

  }
}

resource "azurerm_virtual_machine" "apphost2" {
  name                  = "apphost2"
  location              = "${var.az_location1}"
  resource_group_name   = "homework-tudorfil-rg"
  network_interface_ids = ["${azurerm_network_interface.apphost2nic.id}"]
  vm_size               = "Standard_D2S_v3"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "apphost1"
    admin_username = "tudorfil"
    admin_password = "${var.wrk_root_pw}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
        ssh_keys {
          path     = "~/.ssh/authorized_keys"
          key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }
}


######################################################
#  TRAFFIC MANAGER
######################################################
resource "random_id" "server" {
  keepers = {
    azi_id = 1
  }

  byte_length = 8
}

resource "azurerm_traffic_manager_profile" "wrktfmanprofile" {
  name                = "${random_id.server.hex}"
  resource_group_name = "homework-tudorfil-rg"

  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "${random_id.server.hex}"
    ttl           = 5
  }

  monitor_config {
    protocol = "http"
    port     = 80
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "apphost1endpoint" {
  name                = "${random_id.server.hex}"
  resource_group_name = "homework-tudorfil-rg"
  profile_name        = "${azurerm_traffic_manager_profile.wrktfmanprofile.name}"
  target_resource_id  = "${azurerm_virtual_machine.apphost1.id}"
  type                = "azureEndpoints"
  priority              = 100
}

resource "azurerm_traffic_manager_endpoint" "apphost2endpoint" {
  name                = "${random_id.server.hex}"
  resource_group_name = "homework-tudorfil-rg"
  profile_name        = "${azurerm_traffic_manager_profile.wrktfmanprofile.name}"
  target_resource_id  = "${azurerm_virtual_machine.apphost2.id}"
  type                = "azureEndpoints"
  priority              = 200
}
